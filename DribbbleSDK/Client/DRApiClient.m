//
//  DRApiClient.m
//  
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRApiClient.h"
#import "NXOAuth2.h"

static NSInteger const kDefaultShotsPerPageNumber = 20;
static NSInteger const kUploadFileBytesLimitSize = 8.0;

static NSString * kHttpMethodGet = @"GET";
static NSString * kHttpMethodPost = @"POST";
static NSString * kHttpMethodPut = @"PUT";
static NSString * kHttpMethodDelete = @"DELETE";

static NSString * const kAuthorizationHTTPFieldName = @"Authorization";
static NSString * const kBearerString = @"Bearer";
static NSString * const kUploadImageSizeAssertionString = @"Your file must be exatly 400x300 or 800x600";
static NSString * const kUploadFileSizeAssertionString = @"Your file must be no larger than eight megabytes";

void DRLog(NSString *format, ...) {
    if (DribbbleSDKLogsEnabled) {
        va_list argList;
        va_start(argList, format);
        NSString *string = [NSString stringWithFormat:@"%@ %@", DribbbleSDKLogPrefix, format];
        NSLogv(string, argList);
        va_end(argList);
    }
}

@interface DRApiClient ()

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) DROAuthManager *oauthManager;


@end

@implementation DRApiClient

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.oauthManager = [DROAuthManager new];
        [JSONModel setGlobalKeyMapper:[JSONKeyMapper mapperFromUnderscoreCaseToCamelCase]];
    }
    return self;
}

- (instancetype)initWithSettings:(DRApiClientSettings *)settings {
    if (self = [self init]) {
        _settings = settings;
        [self restoreAccessToken];
        if (!_accessToken) {
            [self resetAccessToken];
        }
    }
    return self;
}

#pragma mark - Authorization

- (void)setAccessToken:(NSString *)accessToken {
    _accessToken = accessToken;
    [self.apiManager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@", kBearerString, self.accessToken] forHTTPHeaderField:kAuthorizationHTTPFieldName];
}

// use client access secret while no access token retrieved
// also call this method on logout
- (void)resetAccessToken {
    self.accessToken = self.settings.clientAccessToken;
}

- (void)restoreAccessToken {
    NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType: kIDMOAccountType] lastObject];
    if (account) {
        DRLog(@"token restored: %@", account.accessToken.accessToken);
        self.accessToken = account.accessToken.accessToken;
    }
}

- (BOOL)isUserAuthorized {
    return [self.accessToken length] && ![self.accessToken isEqualToString:self.settings.clientAccessToken];
}

#pragma mark - OAuth calls

- (void)authorizeWithWebView:(UIWebView *)webView authHandler:(DROAuthHandler)authHandler {
    __weak typeof(self) weakSelf = self;
    [self.oauthManager authorizeWithWebView:webView settings:self.settings authHandler:^(NXOAuth2Account *account, NSError *error) {
        if (!error && account) {
            if (account.accessToken.accessToken.length > 0) {
                weakSelf.accessToken = account.accessToken.accessToken;
            }
        } else {
            [weakSelf resetAccessToken];
            if (weakSelf.defaultErrorHandler) weakSelf.defaultErrorHandler(error);
        }
        if (authHandler) authHandler(account, error);
    }];
}

- (void)logout {
    [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:kIDMOAccountType] enumerateObjectsUsingBlock:^(NXOAuth2Account * obj, NSUInteger idx, BOOL *stop) {
        [[NXOAuth2AccountStore sharedStore] removeAccount:obj];
    }];
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [self resetAccessToken];
}

#pragma mark - Setup

- (AFHTTPRequestOperationManager *)apiManager {
    if (!_apiManager) {
        _apiManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:self.settings.baseUrl]];
        [_apiManager.requestSerializer setHTTPShouldHandleCookies:YES];
        _apiManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _apiManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        _apiManager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _apiManager;
}

- (AFHTTPRequestOperation *)createRequestWithMethod:(NSString *)method requestType:(NSString *)requestType modelClass:(Class)modelClass params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    __weak typeof(self)weakSelf = self;
    NSMutableURLRequest *request = [self.apiManager.requestSerializer requestWithMethod:requestType URLString:[[NSURL URLWithString:method relativeToURL:self.apiManager.baseURL] absoluteString] parameters:params error:nil];
    
    AFHTTPRequestOperation *operation = [self.apiManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.response statusCode] == kHttpAuthErrorCode || [operation.response statusCode] == kHttpRateLimitErrorCode) {
            NSError *error = [NSError errorWithDomain:[responseObject objectForKey:@"message"] code:[operation.response statusCode] userInfo:nil];
            if (weakSelf.defaultErrorHandler) weakSelf.defaultErrorHandler(error);
        }
        if (responseHandler) {
            responseHandler([weakSelf mappedDataFromResponseObject:responseObject modelClass:modelClass]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kHttpNotFoundErrorCode) {
            NSError *dribbbleFalseError = [NSError errorWithDomain:error.domain code:kHttpNotFoundErrorCode userInfo:error.userInfo];
            error = dribbbleFalseError;
        }
        if (weakSelf.defaultErrorHandler) weakSelf.defaultErrorHandler(error);
        if (responseHandler) responseHandler([DRApiResponse responseWithError:error]);
    }];
    return operation;
}

- (void)runMultiPartRequestWithMethod:(NSString *)method parameterName:(NSString *)paramaterName params:(NSDictionary *)params fileName:(NSString *)fileName data:(NSData *)data mimeType:(NSString *)mimeType responseHandler:(DRResponseHandler)responseHandler {
    __weak typeof(self)weakSelf = self;
    [self.apiManager POST:method parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:paramaterName fileName:fileName mimeType:mimeType];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseHandler) responseHandler([DRApiResponse responseWithObject:responseObject]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (weakSelf.defaultErrorHandler) weakSelf.defaultErrorHandler(error);
        if ([operation.response statusCode] == kHttpRequestFailedErrorCode) {
            NSDictionary *userInfo = @{ kDRUploadErrorFailureKey : error.userInfo[NSLocalizedDescriptionKey] ?:@"", NSUnderlyingErrorKey : error};
            NSError *userError = [[NSError alloc] initWithDomain:kDRUploadErrorFailureKey code:kHttpRequestFailedErrorCode userInfo:userInfo];
            error = userError;
        }
        if (responseHandler) responseHandler([DRApiResponse responseWithError:error]);
    }];
}

- (void)runRequestWithMethod:(NSString *)method requestType:(NSString *)requestType modelClass:(Class)modelClass params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [[self createRequestWithMethod:method requestType:requestType modelClass:modelClass params:params responseHandler:responseHandler] start];
}

#pragma mark - Data response mapping

- (id)mappedDataFromResponseObject:(id)object modelClass:(Class)modelClass {
    if (modelClass == [NSNull class]) { // then bypass parsing
        return [DRApiResponse responseWithObject:object];
    }
    id mappedObject = nil;
    if ([object isKindOfClass:[NSArray class]]) {
        mappedObject = [(NSArray *)object bk_map:^id(id obj) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                return [[modelClass alloc] initWithDictionary:obj error:nil];
            } else {
                return [NSNull null];
            }
        }];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        mappedObject = [[modelClass alloc] initWithDictionary:object error:nil];
    }
    return [DRApiResponse responseWithObject:mappedObject];
}

#pragma mark - API CALLS

#pragma mark - User

- (void)loadUserInfoWithResponseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:kDRApiMethodUser requestType:kHttpMethodGet modelClass:[DRUser class] params:nil responseHandler:responseHandler];
}

- (void)loadAccountWithUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserInfo, userId] requestType:kHttpMethodGet modelClass:[DRUser class] params:nil responseHandler:responseHandler];
}

- (void)loadLikesWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserLikes, userId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params responseHandler:responseHandler];
}

- (void)loadMyLikesWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:kDRApiMethodMyLikes requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params responseHandler:responseHandler];
}

- (void)loadProjectsWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserProjects, userId] requestType:kHttpMethodGet modelClass:[DRProject class] params:params responseHandler:responseHandler];
}

- (void)loadMyProjectsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:kDRApiMethodOwnUserProjects requestType:kHttpMethodGet modelClass:[DRProject class] params:params responseHandler:responseHandler];
}

- (void)loadTeamsWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserTeams, userId] requestType:kHttpMethodGet modelClass:[DRTeam class] params:params responseHandler:responseHandler];
}

- (void)loadMyTeamsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:kDRApiMethodMyTeams requestType:kHttpMethodGet modelClass:[DRTeam class] params:params responseHandler:responseHandler];
}

- (void)loadFollowersWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodGetFollowers, userId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params responseHandler:responseHandler];
}

- (void)loadMyFollowersWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:kDRApiMethodGetMyFollowers requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params responseHandler:responseHandler];
}

- (void)loadFolloweesWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodGetFollowees, userId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params responseHandler:responseHandler];
}

- (void)loadMyFolloweesWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:kDRApiMethodGetMyFollowees requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params responseHandler:responseHandler];
}

- (void)loadFolloweesShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:kDRApiMethodGetFolloweesShot requestType:kHttpMethodGet modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

#pragma mark - Shots

- (void)uploadShotWithParams:(NSDictionary *)params file:(NSData *)file fileName:(NSString *)fileName mimeType:(NSString *)mimeType responseHandler:(DRResponseHandler)responseHandler {
    UIImage *image = [[UIImage alloc] initWithData:file];
    CGSize imageSize = image.size;
    NSAssert((imageSize.width == 400.f && imageSize.height == 300.f) || (imageSize.width == 800.f && imageSize.height == 600.f), kUploadImageSizeAssertionString);
    NSAssert((file.length/1024.f/1024.f) <= kUploadFileBytesLimitSize, kUploadFileSizeAssertionString);
    [self runMultiPartRequestWithMethod:kDRApiMethodShots parameterName:kDRParamImage params:params fileName:fileName data:file mimeType:mimeType responseHandler:responseHandler];
}

- (void)updateShot:(NSNumber *)shotId withParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShot, shotId] requestType:kHttpMethodPut modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

- (void)deleteShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShot, shotId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

- (void)loadShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:kDRApiMethodShots requestType:kHttpMethodGet modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

- (void)loadShotsFromCategory:(DRShotCategory *)category atPage:(int)page responseHandler:(DRResponseHandler)responseHandler {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (category) {
        if ([category.categoryValue isEqualToString:@"recent"]) {
            dict[kDRParamSort] = category.categoryValue;
        } else if (![category.categoryValue isEqualToString:@"popular"]) {
            dict[kDRParamList] = category.categoryValue;
        }
    }
    if (page > 0) {
        dict[kDRParamPage] = @(page);
        dict[kDRParamPerPage] = @(kDefaultShotsPerPageNumber);
    }
    [self loadShotsWithParams:dict responseHandler:responseHandler];
}

- (void)loadShotsWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserShots, userId] requestType:kHttpMethodGet modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

- (void)loadMyShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:kDRApiMethodOwnUserShots requestType:kHttpMethodGet modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:url requestType:kHttpMethodGet modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

- (void)loadReboundsWithShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotRebounds, shotId] requestType:kHttpMethodGet modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

- (void)loadShotWith:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShot, shotId] requestType:kHttpMethodGet modelClass:[DRShot class] params:nil responseHandler:responseHandler];
}

- (void)likeWithShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLikeShot, shotId] requestType:kHttpMethodPost modelClass:[DRTransactionModel class] params:nil responseHandler:responseHandler];
}

- (void)unlikeWithShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLikeShot, shotId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

- (void)checkLikeWithShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckShotWasLiked, shotId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:nil responseHandler:responseHandler];
}

- (void)loadLikesWithShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotLikes, shotId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params responseHandler:responseHandler];
}

#pragma mark - Comments

- (void)uploadCommentWithShot:(NSNumber *)shotId withBody:(NSString *)body responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotComments, shotId] requestType:kHttpMethodPost modelClass:[DRComment class] params:@{kDRParamBody:body} responseHandler:responseHandler];
}

- (void)updateCommentWith:(NSNumber *)commentId forShot:(NSNumber *)shotId withBody:(NSString *)body responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodEditComment, shotId, commentId] requestType:kHttpMethodPut modelClass:[DRComment class] params:@{kDRParamBody:body} responseHandler:responseHandler];
}

- (void)deleteCommentWith:(NSNumber *)commentId forShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodComment, shotId, commentId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

- (void)loadCommentsWithShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotComments, shotId] requestType:kHttpMethodGet modelClass:[DRComment class] params:params responseHandler:responseHandler];
}

- (void)loadCommentWith:(NSNumber *)commentId forShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodComment, shotId, commentId] requestType:kHttpMethodGet modelClass:[DRComment class] params:nil responseHandler:responseHandler];
}

- (void)loadLikesWithComment:(NSNumber *)commentId forShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCommentLikes, shotId, commentId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:nil responseHandler:responseHandler];
}

- (void)checkLikeWithComment:(NSNumber *)commentId forShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckLikeComment, shotId, commentId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:nil responseHandler:responseHandler];
}

- (void)likeWithComment:(NSNumber *)commentId forShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckLikeComment, shotId, commentId] requestType:kHttpMethodPost modelClass:[DRTransactionModel class] params:nil responseHandler:responseHandler];
}

- (void)unlikeWithComment:(NSNumber *)commentId forShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckLikeComment, shotId, commentId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

#pragma mark - Attachments

- (void)uploadAttachmentWithShot:(NSNumber *)shotId params:(NSDictionary *)params file:(NSData *)file fileName:(NSString *)fileName mimeType:(NSString *)mimeType responseHandler:(DRResponseHandler)responseHandler {
    [self runMultiPartRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotAttachments, shotId] parameterName:kDRParamFile params:params fileName:fileName data:file mimeType:mimeType responseHandler:responseHandler];
}

- (void)deleteAttachmentWith:(NSNumber *)attachmentId forShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodAttachment, shotId, attachmentId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

- (void)loadAttachmentsWithShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotAttachments, shotId] requestType:kHttpMethodGet modelClass:[DRShotAttachment class] params:nil responseHandler:responseHandler];
}

- (void)loadAttachmentWith:(NSNumber *)attachmentId forShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodAttachment, shotId, attachmentId] requestType:kHttpMethodGet modelClass:[DRShotAttachment class] params:nil responseHandler:responseHandler];
}

#pragma mark - Projects

- (void)loadProjectsWithShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotProjects, shotId] requestType:kHttpMethodGet modelClass:[DRProject class] params:params responseHandler:responseHandler];
}

- (void)loadProjectWith:(NSNumber *)projectId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodProject, projectId] requestType:kHttpMethodGet modelClass:[DRProject class] params:nil responseHandler:responseHandler];
}

- (void)loadProjectShotsWith:(NSNumber *)projectId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodProjectShots, projectId] requestType:kHttpMethodGet modelClass:[DRShot class] params:nil responseHandler:responseHandler];
}

#pragma mark - Team

- (void)loadMembersWithTeam:(NSNumber *)teamId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodTeamMembers, teamId] requestType:kHttpMethodGet modelClass:[DRUser class] params:nil responseHandler:responseHandler];
}

- (void)loadShotsWithTeam:(NSNumber *)teamId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodTeamShots, teamId] requestType:kHttpMethodGet modelClass:[DRShot class] params:nil responseHandler:responseHandler];
}

#pragma mark - Following

- (void)followUserWith:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodFollowUser, userId] requestType:kHttpMethodPut modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

- (void)unFollowUserWith:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodFollowUser, userId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

- (void)checkFollowingWithUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckIfUserFollowing, userId] requestType:kHttpMethodGet modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

- (void)checkIfUserWith:(NSNumber *)userId followingAnotherUserWith:(NSNumber *)anotherUserId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckIfOneUserFollowingAnother, userId, anotherUserId] requestType:kHttpMethodGet modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

#pragma mark - Buckets

- (void)loadMyBucketsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:kDRApiMethodMyBuckets requestType:kHttpMethodGet modelClass:[DRBucket class] params:params responseHandler:responseHandler];
}

- (void)loadBucketsWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserBuckets, userId] requestType:kHttpMethodGet modelClass:[DRBucket class] params:params responseHandler:responseHandler];
}

- (void)loadBucketsForShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodBucketsForShot, shotId] requestType:kHttpMethodGet modelClass:[DRBucket class] params:params responseHandler:responseHandler];
}

- (void)loadBucket:(NSNumber *)bucketId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLoadBucket, bucketId] requestType:kHttpMethodGet modelClass:[DRBucket class] params:params responseHandler:responseHandler];
}

- (void)loadBucketShots:(NSNumber *)bucketId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLoadBucketShots, bucketId] requestType:kHttpMethodGet modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

- (void)addShotToBucket:(NSNumber *)bucketId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLoadBucketShots, bucketId] requestType:kHttpMethodPut modelClass:[DRApiResponse class] params:params responseHandler:responseHandler];
}

- (void)deleteShotFromBucket:(NSNumber *)bucketId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLoadBucketShots, bucketId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:params responseHandler:responseHandler];
}

- (void)addBucketWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:kDRApiMethodAddBucket requestType:kHttpMethodPost modelClass:[DRBucket class] params:params responseHandler:responseHandler];
}

- (void)updateBucket:(NSNumber *)bucketId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLoadBucket, bucketId] requestType:kHttpMethodPut modelClass:[DRBucket class] params:params responseHandler:responseHandler];
}

- (void)deleteBucket:(NSNumber *)bucketId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLoadBucket, bucketId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:params responseHandler:responseHandler];
}

@end

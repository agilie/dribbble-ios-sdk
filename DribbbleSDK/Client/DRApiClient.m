//
//  DRApiClient.m
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRApiClient.h"
#import "DribbbleSDK.h"

static NSInteger const kDefaultShotsPerPageNumber = 20;

static NSString * kHttpMethodGet = @"GET";
static NSString * kHttpMethodPost = @"POST";
static NSString * kHttpMethodPut = @"PUT";
static NSString * kHttpMethodDelete = @"DELETE";

static NSString * const kAuthorizationHTTPFieldName = @"Authorization";
static NSString * const kBearerString = @"Bearer";

void logInteral(NSString *format, ...) {
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
        logInteral(@"token restored: %@", account.accessToken.accessToken);
        self.accessToken = account.accessToken.accessToken;
    }
}

- (BOOL)isUserAuthorized {
    return [self.accessToken length] && ![self.accessToken isEqualToString:self.settings.clientAccessToken];
}

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
#warning TODO remove token from keychain and user info from NSUserDefaults
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


#pragma mark - OAuth calls

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
        if (weakSelf.defaultErrorHandler) weakSelf.defaultErrorHandler(error);
        if (responseHandler) responseHandler([DRApiResponse responseWithError:error]);
    }];
    
    return operation;
}

- (void)runMultiPartRequestWithMethod:(NSString *)method params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self.apiManager POST:method parameters:@{@"title": @"my_shot"} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:[params objectForKey:@"image"] name:@"image"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"sucess - %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure - %@", error);
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

- (void)loadUserInfo:(NSString *)userId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserInfo, userId] requestType:kHttpMethodGet modelClass:[DRUser class] params:nil responseHandler:responseHandler];
}

- (void)loadLikesOfUser:(NSString *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserLikes, userId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params responseHandler:responseHandler];
}

- (void)loadProjectsOfUser:(NSString *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserProjects, userId] requestType:kHttpMethodGet modelClass:[DRProject class] params:params responseHandler:responseHandler];
}

- (void)loadTeamsOfUser:(NSString *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserTeams, userId] requestType:kHttpMethodGet modelClass:[DRTeam class] params:params responseHandler:responseHandler];
}

- (void)loadUserFollowees:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodGetFollowers, userId] requestType:kHttpMethodGet modelClass:[DRFolloweeUser class] params:params responseHandler:responseHandler];
}

- (void)loadFolloweesShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:kDRApiMethodGetFolloweesShot requestType:kHttpMethodGet modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

#pragma mark - Shots

- (void)uploadShotWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runMultiPartRequestWithMethod:kDRApiMethodShots params:params responseHandler:responseHandler];
}

- (void)updateShot:(NSString *)shotId withParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShot, shotId] requestType:kHttpMethodPut modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

- (void)deleteShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShot, shotId] requestType:kHttpMethodGet modelClass:[DRShot class] params:nil responseHandler:responseHandler];    
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

- (void)loadShotsOfUser:(NSString *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodUserShots, userId] requestType:kHttpMethodGet modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:url requestType:kHttpMethodGet modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

- (void)loadReboundsOfShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotRebounds, shotId] requestType:kHttpMethodGet modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

- (void)loadShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShot, shotId] requestType:kHttpMethodGet modelClass:[DRShot class] params:nil responseHandler:responseHandler];
}

- (void)likeShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLikeShot, shotId] requestType:kHttpMethodPost modelClass:[DRTransactionModel class] params:nil responseHandler:responseHandler];
}

- (void)unlikeShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodLikeShot, shotId] requestType:kHttpMethodDelete modelClass:[DRTransactionModel class] params:nil responseHandler:responseHandler];
}

- (void)checkLikeShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckShotWasLiked, shotId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:nil responseHandler:responseHandler];
}

- (void)loadLikesOfShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotLikes, shotId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:params responseHandler:responseHandler];
}

#pragma mark - Comments

- (void)loadCommentsOfShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotComments, shotId] requestType:kHttpMethodGet modelClass:[DRComment class] params:params responseHandler:responseHandler];
}

- (void)loadComment:(NSString *)commentId forShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodComment, shotId, commentId] requestType:kHttpMethodGet modelClass:[DRComment class] params:nil responseHandler:responseHandler];
}

- (void)loadLikesOfComment:(NSString *)commentId forShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCommentLikes, shotId, commentId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:nil responseHandler:responseHandler];
}

- (void)checkLikeComment:(NSString *)commentId forShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckLikeComment, shotId, commentId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:nil responseHandler:responseHandler];
}

#pragma mark - Attachments

- (void)loadAttachmentsOfShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotAttachments, shotId] requestType:kHttpMethodGet modelClass:[DRShotAttachment class] params:params responseHandler:responseHandler];
}

- (void)loadAttachment:(NSString *)attachmentId forShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodAttachment, attachmentId, shotId] requestType:kHttpMethodGet modelClass:[DRShotAttachment class] params:params responseHandler:responseHandler];
}

#pragma mark - Projects

- (void)loadProjectsOfShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodShotProjects, shotId] requestType:kHttpMethodGet modelClass:[DRProject class] params:params responseHandler:responseHandler];
}

- (void)loadProject:(NSString *)projectId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodProject, projectId] requestType:kHttpMethodGet modelClass:[DRProject class] params:nil responseHandler:responseHandler];
}

#pragma mark - Team

- (void)loadMembersOfTeam:(NSString *)teamId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodTeamMembers, teamId] requestType:kHttpMethodGet modelClass:[DRUser class] params:nil responseHandler:responseHandler];
}

- (void)loadShotsOfTeam:(NSString *)teamId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodTeamShots, teamId] requestType:kHttpMethodGet modelClass:[DRShot class] params:nil responseHandler:responseHandler];
}

#pragma mark - Following

- (void)followUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodFollowUser, userId] requestType:kHttpMethodPut modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

- (void)unFollowUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodFollowUser, userId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

- (void)checkFollowingUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDRApiMethodCheckIfUserFollowing, userId] requestType:kHttpMethodGet modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

@end

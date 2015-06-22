//
//  DRApiClient.m
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRApiClient.h"
#import "DROAuthManager.h"
#import "DribbbleSDK.h"
#import "DRApiResponse.h"
#import "DRFolloweeUser.h"
#import "DRShot.h"
#import "DRTransactionModel.h"
#import "DRShotCategory.h"
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
        [self restoreAccessToken];
        [JSONModel setGlobalKeyMapper:[JSONKeyMapper mapperFromUnderscoreCaseToCamelCase]];
    }
    return self;
}

- (instancetype)initWithSettings:(DRApiClientSettings *)settings {
    if (self = [self init]) {
        _settings = settings;
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
    [self runRequestWithMethod:kDribbbleApiMethodUser requestType:kHttpMethodGet modelClass:[DRUser class] params:nil responseHandler:responseHandler];
}

- (void)loadUserFollowees:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodGetFollowers, userId] requestType:kHttpMethodGet modelClass:[DRFolloweeUser class] params:params responseHandler:responseHandler];
}

- (void)loadFolloweesShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:kDribbbleApiMethodGetFolloweesShot requestType:kHttpMethodGet modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

#pragma mark - Shots

- (void)loadShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:kDribbbleApiMethodShots requestType:kHttpMethodGet modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

- (void)loadShotsFromCategory:(DRShotCategory *)category atPage:(int)page responseHandler:(DRResponseHandler)responseHandler {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (category) {
        if ([category.categoryValue isEqualToString:@"recent"]) {
            dict[@"sort"] = category.categoryValue;
        } else if (![category.categoryValue isEqualToString:@"popular"]) {
            dict[@"list"] = category.categoryValue;
        }
    }
    if (page > 0) {
        dict[@"page"] = @(page);
        dict[@"per_page"] = @(kDefaultShotsPerPageNumber);
    }
    [self loadShotsWithParams:dict responseHandler:responseHandler];
}

- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:url requestType:kHttpMethodGet modelClass:[DRShot class] params:params responseHandler:responseHandler];
}

- (void)loadShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodShot, shotId] requestType:kHttpMethodGet modelClass:[DRShot class] params:nil responseHandler:responseHandler];
}

- (void)likeShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodLikeShot, shotId] requestType:kHttpMethodPost modelClass:[DRTransactionModel class] params:nil responseHandler:responseHandler];
}

- (void)unlikeShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodLikeShot, shotId] requestType:kHttpMethodDelete modelClass:[DRTransactionModel class] params:nil responseHandler:responseHandler];
}

- (void)checkLikeShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodCheckShotWasLiked, shotId] requestType:kHttpMethodGet modelClass:[DRTransactionModel class] params:nil responseHandler:responseHandler];
}

#pragma mark - Following

- (void)followUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodFollowUser, userId] requestType:kHttpMethodPut modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

- (void)unFollowUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodFollowUser, userId] requestType:kHttpMethodDelete modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

- (void)checkFollowingUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodCheckIfUserFollowing, userId] requestType:kHttpMethodGet modelClass:[DRApiResponse class] params:nil responseHandler:responseHandler];
}

@end

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
@property (strong, nonatomic) AFHTTPRequestOperationManager *apiManager;

@end

@implementation DRApiClient

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupDefaults];
        self.oauthManager = [DROAuthManager new];
        [self restoreAccessToken];
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

- (void)setupDefaults {
    
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

- (void)authorizeWithWebView:(UIWebView *)webView completionHandler:(DRCompletionHandler)completionHandler cancellationHandler:(DRHandler)cancellationHandler {
    __weak typeof(self) weakSelf = self;
    self.oauthManager.dismissWebViewHandler = cancellationHandler;
    [self.oauthManager authorizeWithWebView:webView settings:self.settings completionHandler:^(DRApiResponse *data) {
        if (!data.error) {
            NXOAuth2Account *account = data.object;
            if (account.accessToken.accessToken.length > 0) {
                weakSelf.accessToken = account.accessToken.accessToken;
            }
        } else {
            [weakSelf resetAccessToken];
            if (weakSelf.clientErrorHandler) weakSelf.clientErrorHandler(data.error);
        }
        if (completionHandler) completionHandler(data);
    }];
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

- (AFHTTPRequestOperation *)createRequestWithMethod:(NSString *)method requestType:(NSString *)requestType modelClass:(Class)modelClass params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler {
    __weak typeof(self)weakSelf = self;
    NSMutableURLRequest *request = [self.apiManager.requestSerializer requestWithMethod:requestType URLString:[[NSURL URLWithString:method relativeToURL:self.apiManager.baseURL] absoluteString] parameters:params error:nil];
    AFHTTPRequestOperation *operation = [self.apiManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.response statusCode] == kHttpAuthErrorCode || [operation.response statusCode] == kHttpRateLimitErrorCode) {
            NSError *error = [NSError errorWithDomain:[responseObject objectForKey:@"message"] code:[operation.response statusCode] userInfo:nil];
            if (weakSelf.clientErrorHandler) weakSelf.clientErrorHandler(error);
        }
        if ([operation.response statusCode] == kHttpRateLimitErrorCode) {
#warning TODO ???
        }
        if (completionHandler) {
            completionHandler([weakSelf mappedDataFromResponseObject:responseObject modelClass:modelClass]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (self.clientErrorHandler) self.clientErrorHandler(error);
        if (completionHandler) completionHandler([DRApiResponse modelWithError:error]);
    }];
    return operation;
}

- (void)runRequestWithMethod:(NSString *)method requestType:(NSString *)requestType modelClass:(Class)modelClass params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler {
    [[self createRequestWithMethod:method requestType:requestType modelClass:modelClass params:params completionHandler:completionHandler] start];
}

#pragma mark - Data response mapping

- (id)mappedDataFromResponseObject:(id)object modelClass:(Class)modelClass {
    if (modelClass == [NSNull class]) { // then bypass parsing
        return [DRApiResponse modelWithData:object];
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
    return [DRApiResponse modelWithData:mappedObject];
}


#pragma mark - API CALLS 
#pragma mark - User

- (void)loadUserInfoWithCompletionHandler:(DRCompletionHandler)completionHandler {
    [self runRequestWithMethod:kDribbbleApiMethodUser requestType:kDribbbleGetRequest modelClass:[DRUser class] params:nil completionHandler:completionHandler];
}

- (void)loadUserFollowees:(NSNumber *)userId params:(NSDictionary *)params withCompletionHandler:(DRCompletionHandler)completionHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodGetFollowers, userId] requestType:kDribbbleGetRequest modelClass:[DRFolloweeUser class] params:params completionHandler:completionHandler];
}

- (void)loadFolloweesShotsWithParams:(NSDictionary *)params withCompletionHandler:(DRCompletionHandler)completionHandler {
    [self runRequestWithMethod:kDribbbleApiMethodGetFolloweesShot requestType:kDribbbleGetRequest modelClass:[DRShot class] params:params completionHandler:completionHandler];
}

#pragma mark - Shots

- (void)loadShotsWithParams:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler {
    [self runRequestWithMethod:kDribbbleApiMethodShots requestType:kDribbbleGetRequest modelClass:[DRShot class] params:params completionHandler:completionHandler];
}

- (void)loadShotsFromCategory:(DRShotCategory *)category atPage:(int)page completionHandler:(DRCompletionHandler)completionHandler {
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
    [self loadShotsWithParams:dict completionHandler:completionHandler];
}

- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler {
    [self runRequestWithMethod:url requestType:kDribbbleGetRequest modelClass:[DRShot class] params:params completionHandler:completionHandler];
}

- (void)loadShot:(NSString *)shotId completionHandler:(DRCompletionHandler)completionHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodShot, shotId] requestType:kDribbbleGetRequest modelClass:[DRShot class] params:nil completionHandler:completionHandler];
}

- (void)likeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodLikeShot, shotId] requestType:kDribbblePostRequest modelClass:[DRTransactionModel class] params:nil completionHandler:completionHandler];
}

- (void)unlikeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodLikeShot, shotId] requestType:kDribbbleDeleteRequest modelClass:[DRTransactionModel class] params:nil completionHandler:completionHandler];
}

- (void)checkLikeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodCheckShotWasLiked, shotId] requestType:kDribbbleGetRequest modelClass:[DRTransactionModel class] params:nil completionHandler:completionHandler];
}

#pragma mark - Following

- (void)followUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodFollowUser, userId] requestType:kDribbblePutRequest modelClass:[DRApiResponse class] params:nil completionHandler:completionHandler];
}

- (void)unFollowUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodFollowUser, userId] requestType:kDribbbleDeleteRequest modelClass:[DRApiResponse class] params:nil completionHandler:completionHandler];
}

- (void)checkFollowingUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodCheckIfUserFollowing, userId] requestType:kDribbbleGetRequest modelClass:[DRApiResponse class] params:nil completionHandler:completionHandler];
}

@end

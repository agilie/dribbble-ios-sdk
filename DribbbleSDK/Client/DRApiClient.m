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
#import "DRBaseModel.h"
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

@property (strong, nonatomic) NSString *baseApiUrl;

@property (strong, nonatomic) DROAuthManager *oauthManager;
@property (strong, nonatomic) AFHTTPRequestOperationManager *apiManager;
@property (strong, nonatomic) AFHTTPRequestOperationManager *imageManager;
@property (strong, nonatomic) NSString *clientAccessSecret;

@property (assign, nonatomic) NSURLRequestCachePolicy imageCachePolicy;
@property (assign, nonatomic) NSURLRequestCachePolicy apiCachePolicy;
@property (assign, nonatomic) NSInteger imageManagerMaxConcurrentCount;
@property (assign, nonatomic) NSInteger apiManagerMaxConcurrentCount;
@property (strong, nonatomic) AFHTTPResponseSerializer *imageResponseSerializer;
@property (strong, nonatomic) AFHTTPResponseSerializer *apiResponseSerializer;

@end

@implementation DRApiClient

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
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

- (void)restoreAccessToken {
    NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType: kIDMOAccountType] lastObject];
    if (account) {
        logInteral(@"We have token restored: %@", account.accessToken.accessToken);
        self.accessToken = account.accessToken.accessToken;
    }
}

#pragma mark - Setup

- (void)obtainDelegateForWebView:(UIWebView *)webView {
    webView.delegate = self.oauthManager;
}

- (void)setupOAuthDismissWebViewHandler:(DRHandler)dismissWebViewHandler {
    self.oauthManager.dismissWebViewHandler = dismissWebViewHandler;
}

- (void)setupApiManagerWithCachePolicy:(NSURLRequestCachePolicy)policy responseSerializer:(AFHTTPResponseSerializer *)responseSerializer andMaxConcurrentOperations:(NSInteger)count {
    [self.apiManager.requestSerializer setCachePolicy:policy];
    [self.apiManager setResponseSerializer:responseSerializer];
    [self.apiManager.operationQueue setMaxConcurrentOperationCount:count];
}

- (void)setupImageManagerWithCachePolicy:(NSURLRequestCachePolicy)policy responseSerializer:(AFHTTPResponseSerializer *)responseSerializer andMaxConcurrentOperations:(NSInteger)count {
    [self.imageManager.requestSerializer setCachePolicy:policy];
    [self.imageManager setResponseSerializer:responseSerializer];
    [self.imageManager.operationQueue setMaxConcurrentOperationCount:count];
}

// use client access secret while no access token retrieved
// also call this method on logout

- (void)resetAccessToken {
    self.accessToken = self.settings.clientAccessToken;
}

- (void)setAccessToken:(NSString *)accessToken {
    _accessToken = accessToken;
    [self.apiManager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@", kBearerString, self.accessToken] forHTTPHeaderField:kAuthorizationHTTPFieldName];
}

- (BOOL)isUserAuthorized {
    return [self.accessToken length] && ![self.accessToken isEqualToString:self.clientAccessSecret];
}

#pragma mark - Getters

- (AFHTTPRequestOperationManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[AFHTTPRequestOperationManager alloc] init];
        _imageManager.securityPolicy.allowInvalidCertificates = YES;
        _imageManager.requestSerializer.cachePolicy = self.imageCachePolicy;
        _imageManager.responseSerializer = self.imageResponseSerializer;
        [_imageManager.operationQueue setMaxConcurrentOperationCount:self.imageManagerMaxConcurrentCount];
    }
    return _imageManager;
}

- (AFHTTPRequestOperationManager *)apiManager {
    if (!_apiManager) {
        _apiManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:self.baseApiUrl]];
        [_apiManager.requestSerializer setHTTPShouldHandleCookies:YES];
        _apiManager.securityPolicy.allowInvalidCertificates = YES;
        _apiManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _apiManager.requestSerializer.cachePolicy = self.apiCachePolicy;
        _apiManager.responseSerializer = self.apiResponseSerializer;
        [_apiManager.operationQueue setMaxConcurrentOperationCount:self.apiManagerMaxConcurrentCount];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
            logInteral(@"Internet reachability %d", status);
        }];
    }
    if (self.accessToken) {
        [_apiManager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@", kBearerString, self.accessToken] forHTTPHeaderField:kAuthorizationHTTPFieldName];
    }
    return _apiManager;
}

- (NSURLRequestCachePolicy)imageCachePolicy {
    if (_imageCachePolicy == NSURLRequestUseProtocolCachePolicy) {
        _imageCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    return _imageCachePolicy;
}

- (NSURLRequestCachePolicy)apiCachePolicy {
    if (_apiCachePolicy == NSURLRequestUseProtocolCachePolicy) {
        _apiCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    }
    return _apiCachePolicy;
}

- (AFHTTPResponseSerializer *)imageResponseSerializer {
    if (!_imageResponseSerializer) {
        _imageResponseSerializer = [AFCompoundResponseSerializer serializer];
    }
    return _imageResponseSerializer;
}

- (AFHTTPResponseSerializer *)apiResponseSerializer {
    if (!_apiResponseSerializer) {
        _apiResponseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _apiResponseSerializer;
}

- (NSInteger)imageManagerMaxConcurrentCount {
    if (_imageManagerMaxConcurrentCount == 0) {
        _imageManagerMaxConcurrentCount = 1;
    }
    return _imageManagerMaxConcurrentCount;
}

- (NSInteger)apiManagerMaxConcurrentCount {
    if (_apiManagerMaxConcurrentCount == 0) {
        _apiManagerMaxConcurrentCount = 1;
    }
    return _apiManagerMaxConcurrentCount;
}

#pragma mark - OAuth calls

- (void)requestOAuth2Login:(UIWebView *)webView completionHandler:(DRCompletionHandler)completionHandler {
    __weak typeof(self) weakSelf = self;
    [self.oauthManager authorizeWithWebView:webView settings:self.settings completionHandler:^(DRBaseModel *data) {
        if (!data.error) {
            NXOAuth2Account *account = data.object;
            if (account.accessToken.accessToken.length > 0) {
                weakSelf.accessToken = account.accessToken.accessToken;
            }
        } else {
            [weakSelf resetAccessToken];
            if (weakSelf.clientErrorHandler) weakSelf.clientErrorHandler(data.error, @"OAuth", NO);
        }
        if (completionHandler) completionHandler(data);
    }];
}

- (AFHTTPRequestOperation *)createRequestWithMethod:(NSString *)method requestType:(NSString *)requestType modelClass:(Class)modelClass params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler {
    __weak typeof(self)weakSelf = self;
    NSMutableURLRequest *request = [self.apiManager.requestSerializer requestWithMethod:requestType URLString:[[NSURL URLWithString:method relativeToURL:self.apiManager.baseURL] absoluteString] parameters:params error:nil];
    AFHTTPRequestOperation *operation = [self.apiManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (weakSelf.operationEndHandler) weakSelf.operationEndHandler(operation);
        
        if ([operation.response statusCode] == kHttpAuthErrorCode || [operation.response statusCode] == kHttpRateLimitErrorCode) {
            NSError *error = [NSError errorWithDomain:[responseObject objectForKey:@"message"] code:[operation.response statusCode] userInfo:nil];
            if (weakSelf.clientErrorHandler) weakSelf.clientErrorHandler(error, method, NO);
        }
        if ([operation.response statusCode] == kHttpRateLimitErrorCode) {
            if (weakSelf.operationLimitHandler) weakSelf.operationLimitHandler(operation);
        }
        if (completionHandler) {
            completionHandler([weakSelf mappedDataFromResponseObject:responseObject modelClass:modelClass]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (self.operationEndHandler) self.operationEndHandler(operation);
        if (self.clientErrorHandler) self.clientErrorHandler(error, method, NO);
        if (completionHandler) completionHandler([DRBaseModel modelWithError:error]);
    }];
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        
    }];
//    [operation start];
    
    if (self.operationStartHandler) self.operationStartHandler(operation);
    return operation;
}

- (void)runRequestWithMethod:(NSString *)method requestType:(NSString *)requestType modelClass:(Class)modelClass params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler {
    [[self createRequestWithMethod:method requestType:requestType modelClass:modelClass params:params completionHandler:completionHandler] start];
}

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
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodFollowUser, userId] requestType:kDribbblePutRequest modelClass:[DRBaseModel class] params:nil completionHandler:completionHandler];
}

- (void)unFollowUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodFollowUser, userId] requestType:kDribbbleDeleteRequest modelClass:[DRBaseModel class] params:nil completionHandler:completionHandler];
}

- (void)checkFollowingUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler {
    [self runRequestWithMethod:[NSString stringWithFormat:kDribbbleApiMethodCheckIfUserFollowing, userId] requestType:kDribbbleGetRequest modelClass:[DRBaseModel class] params:nil completionHandler:completionHandler];
}

#pragma mark - Images/Giffs

- (AFHTTPRequestOperation *)loadShotImage:(DRShot *)shot isHighQuality:(BOOL)isHighQuality completionHandler:(DROperationCompletionHandler)completionHandler progressHandler:(DRDownloadProgressHandler)progressHandler {
    return [self requestImageWithUrl:isHighQuality ? shot.defaultUrl:shot.images.teaser completionHandler:completionHandler progressHandler:progressHandler];
}

- (AFHTTPRequestOperation *)loadShotImage:(DRShot *)shot isHighQuality:(BOOL)isHighQuality completionHandler:(DROperationCompletionHandler)completionHandler {
    return [self loadShotImage:shot isHighQuality:isHighQuality completionHandler:completionHandler progressHandler:nil];
}

- (AFHTTPRequestOperation *)requestImageWithUrl:(NSString *)url completionHandler:(DROperationCompletionHandler)completionHandler progressHandler:(DRDownloadProgressHandler)progressHandler {
    __weak typeof(self)weakSelf = self;
    if (!url) {
        logInteral(@"Requested image with null url");
        return nil;
    }
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.f];
    AFHTTPRequestOperation *requestOperation = [self.imageManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completionHandler) completionHandler([DRBaseModel modelWithData:responseObject], operation);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (weakSelf.clientErrorHandler) {
            weakSelf.clientErrorHandler(error, operation.request.URL.absoluteString, NO);
        }
        if (completionHandler) {
            completionHandler([DRBaseModel modelWithError:error], operation);
        }
    }];
    [requestOperation setDownloadProgressBlock:progressHandler];
    [self.imageManager.operationQueue addOperation:requestOperation];
    return requestOperation;
}

#pragma mark - Data response mapping

- (id)mappedDataFromResponseObject:(id)object modelClass:(Class)modelClass {
    if (modelClass == [NSNull class]) { // then bypass parsing
        return [DRBaseModel modelWithData:object];
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
    return [DRBaseModel modelWithData:mappedObject];
}

@end

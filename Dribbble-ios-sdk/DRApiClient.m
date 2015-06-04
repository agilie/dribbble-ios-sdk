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

static NSString * const kInernalServerPattern = @"devdribbble.agilie.com";

static NSString * const kDefaultsKeyLastModified = @"me.agile.ninja.shotbucket.followees_shots_last_modified";

static NSString * const kHttpHeaderLastModifiedKey = @"Last-Modified";
static NSString * const kHttpHeaderIfModifiedSinceKey = @"If-Modified-Since";


static NSString * const kAuthorizationHTTPFieldName = @"Authorization";
static NSString * const kBearerString = @"Bearer";

static NSInteger const kDefaultShotsPerPageNumber = 20;

static NSTimeInterval kLowPriorityTaskConsumeDelay = 0.5f;

void logInteral(NSString *format, ...) {
    if (DRApiClientLoggingEnabled) {
        va_list argList;
        va_start(argList, format);
        NSString *string = [DribbbleApiServiceLogTag stringByAppendingString:format];
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

@property (strong, nonatomic) AFHTTPRequestOperation *lastAddedImageOperation;

@property (strong, nonatomic) NSMutableArray *scheduledTasks;

@property int opInd;

@property BOOL dispatchLowPriorityTaskRunning;

@end

@implementation DRApiClient

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.baseApiUrl = kBaseApiUrl;
        self.oauthManager = [DROAuthManager new];
        __weak typeof(self) weakSelf = self;
        self.oauthManager.passErrorToClientBlock = ^ (NSError *error, NSString *method, BOOL showAlert) {
            if (weakSelf.clientErrorHandler) {
                weakSelf.clientErrorHandler (error, method, showAlert);
            }
        };
        [self restoreAccessToken];
        self.opInd = 0;
        self.dispatchLowPriorityTaskRunning = NO;
    }
    return self;
}

- (void)restoreAccessToken {
    NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType: kIDMOAccountType] lastObject];
    if (account) {
        NSLog(@"We have token restored: %@", account.accessToken.accessToken);
        self.accessToken = account.accessToken.accessToken;
    }
}

#pragma mark - Setup

- (void)setupOAuthDismissWebViewBlock:(DRHandler)dismissWebViewBlock {
    self.oauthManager.dismissWebViewBlock = dismissWebViewBlock;
}


//- (AFHTTPSessionManager *)apiManager {
//    if (!_apiManager) {
//        _apiManager = [self createApiManager];
//        [self setupApiManager];
//    }
//    return _apiManager;
//}

//- (AFHTTPSessionManager *)createApiManager {
//    return [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_baseApiUrl] sessionConfiguration:[self configuration]];
//}

//- (NSURLSessionConfiguration *)configuration {
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    return configuration;
//}

//- (void)setupApiManager {
//    [_apiManager.requestSerializer setHTTPShouldHandleCookies:YES];
//    _apiManager.securityPolicy.allowInvalidCertificates = YES;
//    _apiManager.requestSerializer = [AFJSONRequestSerializer serializer];
//    _apiManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
//    _apiManager.responseSerializer = [AFJSONResponseSerializer serializer];
//    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
//    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
//        logInteral(@"Internet reachability %d", status);
//    }];
//    __weak typeof(self)weakSelf = self;
//    [_apiManager setTaskDidCompleteBlock:^(NSURLSession *session, NSURLSessionTask *task, NSError *error) {
//        [weakSelf handleOperationEnd:(NSURLSessionDataTask *)task];
//    }];
//    
//}

#pragma mark - Setup

- (void)setupDefaultSettings {
    self.autoRetryCount = 3;
    self.autoRetryInterval = 1;
}

#warning REMOVE FROM SDK

- (void)setupCleanBadCredentialsBlock:(DRHandler)cleanBadCredentialsBlock {
    self.cleanBadCredentialsHandler = cleanBadCredentialsBlock;
}

// use client access secret while no access token retrieved
// also call this method on logout

- (void)resetAccessToken {
    self.accessToken = self.clientAccessSecret;
}

- (void)setAccessToken:(NSString *)accessToken {
    self.accessToken = accessToken;
    [self.apiManager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@", kBearerString, self.accessToken] forHTTPHeaderField:kAuthorizationHTTPFieldName];
    
}

- (BOOL)isUserAuthorized {
    return [self.accessToken length] && ![self.accessToken isEqualToString:self.clientAccessSecret];
}

- (NSURLSessionConfiguration *)configuration {
    NSURLSessionConfiguration *configuration = [self configuration];
    configuration.HTTPMaximumConnectionsPerHost = 1;
    return configuration;
}

- (instancetype)initWithOAuthClientAccessSecret:(NSString *)clientAccessSecret {
    self = [self init];
    if (self) {
        self.clientAccessSecret = clientAccessSecret;
        [self resetAccessToken];
    }
    return self;
}

- (AFHTTPRequestOperationManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[AFHTTPRequestOperationManager alloc] init];
        _imageManager.securityPolicy.allowInvalidCertificates = YES;
        _imageManager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        _imageManager.responseSerializer = [AFCompoundResponseSerializer serializer];
        [_imageManager.operationQueue setMaxConcurrentOperationCount:10];
    }
    return _imageManager;
}

#pragma mark - OAuth calls

- (void)requestOAuth2Login:(UIWebView *)webView completionHandler:(DRCompletionHandler)completion failureHandler:(DRErrorHandler)errorHandler {
    __weak typeof(self) weakSelf = self;
    [self.oauthManager requestOAuth2Login:webView completionHandler:^(DRBaseModel *data) {
        if (!data.error) {
            NXOAuth2Account *account = data.object;
            if (account.accessToken.accessToken.length) {
                weakSelf.accessToken = account.accessToken.accessToken;
            }
            if (completion) completion(data);
        } else {
            [weakSelf resetAccessToken];
            if (errorHandler) errorHandler(data);
        }
    } failureHandler:errorHandler];
}

- (void)runRequest:(NSString *)method requestType:(NSString *)type modelClass:(Class)class params:(NSDictionary *)params showError:(BOOL)shouldShowError completion:(DRCompletionHandler)completion errorBlock:(DRErrorHandler)errorHandler {
    NSURLSessionDataTask *requestOperation = [self prepareRequest:method requestType:type modelClass:class params:params showError:shouldShowError completion:completion errorBlock:errorHandler autoRetryCount:self.autoRetryCount];
    [self startOperation:requestOperation];
}

- (void)prepareRequest:(NSString *)method requestType:(NSString *)type modelClass:(Class)class params:(NSDictionary *)params showError:(BOOL)shouldShowError completion:(DRCompletionHandler)completion errorBlock:(DRErrorHandler)errorHandler autoRetryCount:(NSInteger)autoRetryCount {
    __weak typeof(self)weakSelf = self;
    
    NSMutableURLRequest *request = [self.apiManager.requestSerializer requestWithMethod:type URLString:[[NSURL URLWithString:method relativeToURL:self.apiManager.baseURL] absoluteString] parameters:params error:nil];
    AFHTTPRequestOperation *operation = [self.apiManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.responseData) {
            NSString *jsonString = [operation.responseData base64EncodedStringWithOptions:0];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        
    } autoRetryOf:3 retryInterval:1];
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        
    }];
    [operation start];
    
    if (self.operationStartHandler) self.operationStartHandler(operation);
    
    
    __block NSURLSessionDataTask *dataTask = [self.apiManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (!error) {
            //
            //            #warning REMOVE FROM SDK
            //
            //            if ([responseObject isKindOfClass:[NSDictionary class]]) {
            //                NSNumber *status = [responseObject obtainNumber:@"success"];
            //                NSError *error = nil;
            //                if (status) {
            //                    responseObject = [responseObject obtainDictionary:@"result"];
            //                    if ([status intValue] == 0) {
            //                        if (completion) completion([weakSelf mappedDataFromResponseObject:responseObject modelClass:class]);
            //                    } else  {
            //                        error = [NSError errorWithDomain:[responseObject objectForKey:@"message"]?:@"Auth error" code:kHttpAuthErrorCode userInfo:nil];
            //                        if (weakSelf.clientErrorHandler) weakSelf.clientErrorHandler(error, response.URL.absoluteString, shouldShowError);
            //                        if (completion) completion([DRBaseModel modelWithError:error]);
            //                    }
            //                } else {
            //                    if (completion) completion([weakSelf mappedDataFromResponseObject:responseObject modelClass:class]);
            //                }
            //            } else {
            
                if (completion) completion([weakSelf mappedDataFromResponseObject:responseObject modelClass:class]);
            //            }
        } else {
            
            //            if ([(NSHTTPURLResponse *)response statusCode] == kHttpAuthErrorCode) {
            //                UIAlertView *alertMessage = [UIAlertView alertWithMessage:kConfirmationRequireText andTitle:@"Info"];
            //                [alertMessage bk_setCancelBlock:^{
            //
            //#warning TODO rename to nonAuthorizedErrorHandler()
            //
            //                    if (weakSelf.cleanBadCredentialsHandler) {
            //                        weakSelf.cleanBadCredentialsHandler();
            //                    }
            //                }];
            //                [alertMessage show];
            //            }
            if (weakSelf.clientErrorHandler) weakSelf.clientErrorHandler(error, response.URL.absoluteString, shouldShowError);
            
            if (completion) completion([DRBaseModel modelWithError:error]);
        }
    }];
    
    return dataTask;
}

- (NSURLSessionDataTask *)queueRequest:(NSString *)method requestType:(NSString *)type modelClass:(Class)class params:(NSDictionary *)params showError:(BOOL)shouldShowError completion:(DRCompletionHandler)completion errorBlock:(DRErrorHandler)errorHandler {
    return [self queueRequest:method requestType:type modelClass:class params:params showError:shouldShowError completion:completion errorBlock:errorHandler priority:DRURLSessionTaskPriorityDefault  autoRetryCount:self.autoRetryCount];
}

#warning TODO rename to createRequestWithMethod

- (NSURLSessionDataTask *)queueRequest:(NSString *)method requestType:(NSString *)type modelClass:(Class)class params:(NSDictionary *)params showError:(BOOL)shouldShowError completion:(DRCompletionHandler)completion errorBlock:(DRErrorHandler)errorHandler priority:(float)priority autoRetryCount:(NSInteger)autoRetryCount {
    NSURLSessionDataTask *operation = [self prepareRequest:method requestType:type modelClass:class params:params showError:shouldShowError completion:completion errorBlock:errorHandler autoRetryCount:autoRetryCount];
    
    
    [self startOperation:operation];
    return operation;
}

#warning REMOVE FROM SDK. to run request, user should just call [task resume]

#warning TODO refactor back to NSURLConnection

- (void)startOperation:(NSURLSessionDataTask *)operation {
    if ([self.apiManager.tasks count] ||) {
        [self scheduleTask:operation];
    } else {
        [self resumeTask:operation];
    }
}

#warning TODO make public blocks: operationStartHandler(operation) and operationEndHandler(operation)


- (void)startOperation:(NSURLSessionDataTask *)operation {
    [operation resume];
    [self handleOperationStart:operation];
}

- (void)handleOperationStart:(NSURLSessionDataTask *)operation {
    if (self.operationStartHandler) self.operationStartHandler(operation);
}


- (void)handleOperationEnd:(NSURLSessionDataTask *)operation {
    if (self.operationEndHandler) self.operationEndHandler(operation);
}

#pragma mark - User

- (void)loadUserInfoWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self queueRequest:kDribbbleApiMethodUser requestType:kDribbbleGetRequest modelClass:[DRUser class] params:nil showError:YES completion:completionHandler errorBlock:errorHandler];
}

- (void)loadUserFollowees:(NSNumber *)userId params:(NSDictionary *)params withCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self queueRequest:[NSString stringWithFormat:kDribbbleApiMethodGetFollowers, userId] requestType:kDribbbleGetRequest modelClass:[DRFolloweeUser class] params:params showError:YES completion:completionHandler errorBlock:errorHandler];
}

- (void)loadFolloweesShotsWithParams:(NSDictionary *)params withCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self queueRequest:kDribbbleApiMethodGetFolloweesShot requestType:kDribbbleGetRequest modelClass:[DRShot class] params:params showError:YES completion:completionHandler errorBlock:errorHandler];
}

#pragma mark - Shots

#warning TODO add one more method - loadShotsWith... - and make same params as in dribbble api doc

- (void)loadShotsFromCategory:(NSString *)category atPage:(int)page completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([category isEqualToString:@"recent"]) {
        dict[@"sort"] = category;
    } else if (category && ![category isEqualToString:@"popular"]) {
        dict[@"list"] = category;
    }
    if (page > 0) {
        dict[@"page"] = @(page);
        dict[@"per_page"] = @(kDefaultShotsPerPageNumber);
    }
    [self queueRequest:kDribbbleApiMethodShots requestType:kDribbbleGetRequest modelClass:[DRShot class] params:dict showError:YES completion:completionHandler errorBlock:errorHandler];
}

- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self queueRequest:url requestType:kDribbbleGetRequest modelClass:[DRShot class] params:params showError:YES completion:completionHandler errorBlock:errorHandler];
}

- (void)loadShot:(NSString *)shotId completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self queueRequest:[NSString stringWithFormat:kDribbbleApiMethodShot, shotId] requestType:kDribbbleGetRequest modelClass:[DRShot class] params:nil showError:NO completion:completionHandler errorBlock:errorHandler];
}

- (void)likeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self queueRequest:[NSString stringWithFormat:kDribbbleApiMethodLikeShot, shotId] requestType:kDribbblePostRequest modelClass:[DRTransactionModel class] params:nil showError:YES completion:completionHandler errorBlock:errorHandler];
}

- (void)unlikeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self queueRequest:[NSString stringWithFormat:kDribbbleApiMethodLikeShot, shotId] requestType:kDribbbleDeleteRequest modelClass:[DRTransactionModel class] params:nil showError:YES completion:completionHandler errorBlock:errorHandler];
}

- (void)checkLikeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self queueRequest:[NSString stringWithFormat:kDribbbleApiMethodCheckShotWasLiked, shotId] requestType:kDribbbleGetRequest modelClass:[DRTransactionModel class] params:nil showError:NO completion:completionHandler errorBlock:errorHandler priority:DRURLSessionTaskPriorityLow autoRetryCount:0].taskDescription = [NSString stringWithFormat:@"like%d-%@", i1++, shotId];
}

#pragma mark - Following

- (void)followUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self queueRequest:[NSString stringWithFormat:kDribbbleApiMethodFollowUser, userId] requestType:kDribbblePutRequest modelClass:[DRBaseModel class] params:nil showError:YES completion:completionHandler errorBlock:errorHandler];
}

- (void)unFollowUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self queueRequest:[NSString stringWithFormat:kDribbbleApiMethodFollowUser, userId] requestType:kDribbbleDeleteRequest modelClass:[DRBaseModel class] params:nil showError:YES completion:completionHandler errorBlock:errorHandler];
}

- (void)checkFollowingUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self queueRequest:[NSString stringWithFormat:kDribbbleApiMethodCheckIfUserFollowing, userId] requestType:kDribbbleGetRequest modelClass:[DRBaseModel class] params:nil showError:NO completion:completionHandler errorBlock:errorHandler priority:DRURLSessionTaskPriorityLow autoRetryCount:0].taskDescription = [NSString stringWithFormat:@"follow%d-%@", i2++, userId];
}

#pragma mark - Images/Giffs


#warning TODO make method interface like: loadShotImage:(shot) ofQuality:(teaser/full). maybe add progress tracking block

- (AFHTTPRequestOperation *)requestImageWithUrl:(NSString *)url completionHandler:(DROperationCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    return [self requestImageWithUrl:url completionHandler:completionHandler failureHandler:errorHandler progressBlock:nil];
}

- (AFHTTPRequestOperation *)requestImageWithUrl:(NSString *)url completionHandler:(DROperationCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler progressBlock:(DRDOwnloadProgressBlock)downLoadProgressBlock {
    __weak typeof(self)weakSelf = self;
    if (!url) {
        logInteral(@"Requested image with null url");
        return nil;
    }
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.f];
    AFHTTPRequestOperation *requestOperation = [self.imageManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completionHandler) completionHandler(responseObject, operation);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (weakSelf.clientErrorHandler) {
            weakSelf.clientErrorHandler(error, operation.request.URL.absoluteString, NO);
        }
        if (errorHandler) {
            errorHandler ([DRBaseModel modelWithError:error]);
        }
        
    } autoRetryOf:3 retryInterval:0];
    [requestOperation setDownloadProgressBlock:downLoadProgressBlock];
    [self.imageManager.operationQueue addOperation:requestOperation];
    return requestOperation;
}

#pragma mark - Data response mapping

- (id)objectFromDictionary:(NSDictionary *)dict modelClass:(JSONModel *)modelClass {
    return nil;
}

- (id)mappedDataFromResponseObject:(id)object modelClass:(JSONModel *)modelClass {
    if (modelClass == [NSNull class]) { // then bypass parsing
        return [DRBaseModel modelWithData:object];
    }
    id mappedObject = nil;
    if ([object isKindOfClass:[NSDictionary class]]) {
        mappedObject = [self objectFromDictionary:object modelClass:modelClass];
    } else if ([object isKindOfClass:[NSArray class]]) {
        mappedObject = [(NSArray *)object bk_map:^id(id obj) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                return [self objectFromDictionary:obj modelClass:modelClass];
            } else {
                return [NSNull null];
            }
        }];
    }
    return [DRBaseModel modelWithData:mappedObject];
}

@end

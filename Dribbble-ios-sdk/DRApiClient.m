//
//  DRApiClient.m
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRApiClient.h"
#import "DROAuthManager.h"
#import "DRRequestLimitHandler.h"
#import "DRTransactionModel.h"
#import "DRFolloweeUser.h"
#import "NSURLSessionTask+TaskPriority.h"

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

@property (strong, nonatomic) DROAuthManager *oauthManager;
@property (strong, nonatomic) AFHTTPRequestOperationManager *imageManager;
@property (strong, nonatomic) NSString *clientAccessSecret;

@property (strong, nonatomic) AFHTTPRequestOperation *lastAddedImageOperation;

@property (strong, nonatomic) DRRequestLimitHandler *limitHandler;

@property (strong, nonatomic) NSMutableArray *scheduledTasks;

@property int opInd;

@property BOOL dispatchLowPriorityTaskRunning;

@end

@implementation DRApiClient

#pragma mark - Init

- (instancetype)init {
    self = [super initWithBaseUrl:kBaseApiUrl];
    if (self) {
        self.oauthManager = [DROAuthManager new];
        self.oauthManager.progressHUDShowBlock = self.progressHUDShowBlock;
        self.oauthManager.progressHUDDismissBlock = self.progressHUDDismissBlock;
        __weak typeof(self) weakSelf = self;
        self.oauthManager.passErrorToClientBlock = ^ (NSError *error, NSString *method, BOOL showAlert) {
            if (weakSelf.clientErrorHandler) {
                weakSelf.clientErrorHandler (error, method, showAlert);
            }
        };
        self.opInd = 0;
        self.dispatchLowPriorityTaskRunning = NO;
    }
    return self;
}

#pragma mark - Setup

- (void)setupOAuthDismissWebViewBlock:(DRHandler)dismissWebViewBlock {
    self.oauthManager.dismissWebViewBlock = dismissWebViewBlock;
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
    [super setAccessToken:accessToken];
    [self.apiManager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@", kBearerString, self.accessToken] forHTTPHeaderField:kAuthorizationHTTPFieldName];
    
}

- (BOOL)isUserAuthorized {
    return [super isUserAuthorized] && ![self.accessToken isEqualToString:self.clientAccessSecret];
}

- (NSURLSessionConfiguration *)configuration {
    NSURLSessionConfiguration *configuration = [super configuration];
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

- (void)pullCheckSumWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.oauthManager pullCheckSumWithCompletionHandler:completionHandler failureHandler:errorHandler];
}

- (void)requestOAuth2Login:(UIWebView *)webView completionHandler:(DRCompletionHandler)completion failureHandler:(DRErrorHandler)errorHandler {
    __weak typeof(self) weakSelf = self;
    [self.oauthManager requestOAuth2Login:webView withApiClient:self completionHandler:^(DRBaseModel *data) {
        if (!data.error) {
            if (completion) completion(data);
        } else {
            [weakSelf resetAccessToken];
            if (errorHandler) errorHandler(data);
        }

    } failureHandler:errorHandler];
}

- (void)applyAccount:(NXOAuth2Account *)account withApiClient:(DRApiClient *)apiClient completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorBlock {
    [self.oauthManager applyAccount:account withApiClient:apiClient completionHandler:completionHandler failureHandler:errorBlock];
}

#pragma mark - Managing custom request queue with limit


- (NSURLSessionDataTask *)queueRequest:(NSString *)method requestType:(NSString *)type modelClass:(Class)class params:(NSDictionary *)params showError:(BOOL)shouldShowError completion:(DRCompletionHandler)completion errorBlock:(DRErrorHandler)errorHandler {
    return [self queueRequest:method requestType:type modelClass:class params:params showError:shouldShowError completion:completion errorBlock:errorHandler priority:DRURLSessionTaskPriorityDefault  autoRetryCount:self.autoRetryCount];
}

#warning TODO rename to createRequestWithMethod

- (NSURLSessionDataTask *)queueRequest:(NSString *)method requestType:(NSString *)type modelClass:(Class)class params:(NSDictionary *)params showError:(BOOL)shouldShowError completion:(DRCompletionHandler)completion errorBlock:(DRErrorHandler)errorHandler priority:(float)priority autoRetryCount:(NSInteger)autoRetryCount {
    NSURLSessionDataTask *operation = [super prepareRequest:method requestType:type modelClass:class params:params showError:shouldShowError completion:completion errorBlock:errorHandler autoRetryCount:autoRetryCount];
    
    [self setTaskPriority:priority forTask:operation];
    
    [self startOperation:operation];
    return operation;
}

#warning REMOVE FROM SDK. to run request, user should just call [task resume]

#warning TODO refactor back to NSURLConnection

- (void)startOperation:(NSURLSessionDataTask *)operation {
    if ([self.apiManager.tasks count] || self.limitHandler.isExceeded) {
        [self scheduleTask:operation];
    } else {
        [self resumeTask:operation];
    }
}

#warning TODO make public blocks: operationStartHandler(operation) and operationEndHandler(operation)

- (void)handleOperationStart:(NSURLSessionDataTask *)operation {
    [super handleOperationStart:operation];
    [self.limitHandler updateRemainingForType:DRRequestLimitPerDay];
//    NSLog(@"operation start: %@, limit is: %ld", [operation.request.URL absoluteString], self.limitHandler.minuteLimit.remaining);
}

- (void)handleOperationEnd:(NSURLSessionDataTask *)operation {
    [super handleOperationEnd:operation];
    
    if ([(NSHTTPURLResponse *)operation.response statusCode] == kHttpRateLimitErrorCode) NSLog(@"got server \"limit exceed\" error 429");
    
    if (operation.error && operation.error.code == NSURLErrorCancelled) {
        NSLog(@"task cancelled: %@", operation.taskDescription ?: [operation.originalRequest.URL relativeString]);
    } else {
        NSLog(@"task finished: %@, limit is: %ld;", operation.taskDescription ?: [operation.originalRequest.URL relativeString], (long)self.limitHandler.minuteLimit.remaining);
        [self.limitHandler updateLimitForType:DRRequestLimitPerMinute withHeaders:[(NSHTTPURLResponse *)operation.response allHeaderFields]];
    }
    
    if (!self.limitHandler.isExceeded) {
        [self consumeScheduledTask];
    }
}

#warning REMOVE FROM SDK

- (void)killTaskIfNeeded:(NSURLSessionTask *)task reason:(NSString *)reason {

    float taskPriority = [self priorityForTask:task];
    if (taskPriority == DRURLSessionTaskPriorityLow) {
        NSString *desc = task.taskDescription ?: [task.originalRequest.URL relativeString];
       NSLog(@"killed task: %@; reason: %@", desc, reason);
        [task cancel];
        if ([self.scheduledTasks containsObject:task]) [self.scheduledTasks removeObject:task];
    }
}
#warning REMOVE FROM SDK
- (void)killLowPriorityScheduledTask {
    for (NSURLSessionTask *task in [self.apiManager.tasks arrayByAddingObjectsFromArray:self.scheduledTasks]) {
        [self killTaskIfNeeded:task reason:@"batch"];
    }
}
#warning REMOVE FROM SDK
- (void)killLowPriorityTasksForShot:(DRShot *)shot {
    NSString *likeMethod = [NSString stringWithFormat:kDribbbleApiMethodCheckShotWasLiked, shot.shotId];
    NSString *followMethod = [NSString stringWithFormat:kDribbbleApiMethodCheckIfUserFollowing, shot.authorityId];
    for (NSURLSessionTask *task in [self.apiManager.tasks arrayByAddingObjectsFromArray:self.scheduledTasks]) {
        for (NSString *methodString in @[likeMethod, followMethod]) {
            if ([[task.originalRequest.URL absoluteString] rangeOfString:methodString].location != NSNotFound) {
                [self killTaskIfNeeded:task reason:[NSString stringWithFormat:@"animate off shot id:%@", shot.shotId]];
            }
        }
    }
}
#warning REMOVE FROM SDK
- (DRRequestLimitHandler *)limitHandler {
    __weak typeof(self) weakSelf = self;
    if (!_limitHandler) {
        _limitHandler = [DRRequestLimitHandler standardHandler];
        [_limitHandler loadUserLimits];
        _limitHandler.limitStateChangedHandler = ^(DRRequestLimit *limit) {
            if (limit.isExceeded) {
                [[weakSelf.apiManager tasks] makeObjectsPerformSelector:@selector(suspend)];
            } else {
                if ([weakSelf.apiManager.tasks count]) {
                    [[weakSelf.apiManager tasks] enumerateObjectsUsingBlock:^(NSURLSessionTask *obj, NSUInteger idx, BOOL *stop) {
                        [weakSelf resumeTask:obj];
                    }];
                } else {
                    [weakSelf consumeScheduledTask];
                }
            }
            if (weakSelf.requestLimitStateChangedHandler) weakSelf.requestLimitStateChangedHandler(limit.type, limit.isExceeded);
        };
    }
    return _limitHandler;
}
#warning REMOVE FROM SDK
- (NSMutableArray *)scheduledTasks {
    if (!_scheduledTasks) _scheduledTasks = [NSMutableArray array];
    return _scheduledTasks;
}
#warning REMOVE FROM SDK
- (void)scheduleTask:(NSURLSessionTask *)task {
    __weak typeof(self) weakSelf = self;
    @synchronized(self) {
        [self.scheduledTasks addObject:task];
        [self.scheduledTasks sortUsingComparator:^NSComparisonResult(NSURLSessionTask *task1, NSURLSessionTask *task2) {
            float value1 = [weakSelf priorityForTask:task1];
            float value2 = [weakSelf priorityForTask:task2];
            if (value1 > value2)
                return NSOrderedDescending;
            else if (value1 < value2)
                return NSOrderedAscending;
            return NSOrderedSame;
        }];
    }
}
#warning REMOVE FROM SDK
- (void)resumeTask:(NSURLSessionTask *)task {
    NSLog(@"resuming task: %@", task.taskDescription ?: [task.originalRequest.URL relativeString]);
    [self.scheduledTasks removeObject:task];
    [task resume];
    [self handleOperationStart:(NSURLSessionDataTask *)task];
}

#warning REMOVE FROM SDK

- (void)resumeNextTaskAfterDispatch {
    NSURLSessionTask *task = [self.scheduledTasks firstObject];
    if (!self.limitHandler.isExceeded) {
        [self resumeTask:task];
    }
}

#warning REMOVE FROM SDK

- (void)consumeScheduledTask {
    NSURLSessionTask *task = [self.scheduledTasks firstObject];
    if (task) {
        if ([self priorityForTask:task] == DRURLSessionTaskPriorityLow) {
            if (!self.dispatchLowPriorityTaskRunning) {
                self.dispatchLowPriorityTaskRunning = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kLowPriorityTaskConsumeDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self resumeNextTaskAfterDispatch];
                    self.dispatchLowPriorityTaskRunning = NO;
                });
            }
        } else {
            [self resumeTask:task];
        }
    }
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

static int i1 = 0, i2 = 0;

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

#pragma mark - 

#warning REMOVE FROM SDK

- (void)setTaskPriority:(float)priority forTask:(NSURLSessionTask *)task {
    [task bk_associateValue:@(priority) withKey:&DRURLSessionTaskPriorityKeyPointer];
}

#warning REMOVE FROM SDK

- (float)priorityForTask:(NSURLSessionTask *)task {
    NSNumber *value = [task bk_associatedValueForKey:&DRURLSessionTaskPriorityKeyPointer];
    return value ? [value floatValue] : DRURLSessionTaskPriorityDefault;
}

#warning REMOVE FROM SDK

- (void)loadSavedLimitsForUserId:(NSNumber *)userId {
    [_limitHandler loadUserLimits];
}

@end

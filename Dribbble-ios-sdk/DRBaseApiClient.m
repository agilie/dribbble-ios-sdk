    //
//  DRBaseApiClient.m
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 06.04.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRBaseApiClient.h"
#import "NSURLSessionTask+TaskPriority.h"

static NSString * const kInernalServerPattern = @"devdribbble.agilie.com";

static NSString * const kDefaultsKeyLastModified = @"me.agile.ninja.shotbucket.followees_shots_last_modified";

static NSString * const kHttpHeaderLastModifiedKey = @"Last-Modified";
static NSString * const kHttpHeaderIfModifiedSinceKey = @"If-Modified-Since";

DRErrorHandler showErrorAlertFailureHandler() {
    return ^(DRBaseModel *data) {
        if (data.error) {
            [[UIAlertView alertWithServerError:data.error] show];
        }
    };
}

@interface DRBaseApiClient ()

@property (strong, nonatomic) NSString *baseApiUrl;

@end

@implementation DRBaseApiClient

#pragma  mark - Init

- (instancetype)initWithBaseUrl:(NSString *)baseUrl {
    self = [super init];
    if (self) {
        self.baseApiUrl = baseUrl;
    }
    return self;
}

#pragma mark - Getter

- (AFHTTPSessionManager *)apiManager {
    if (!_apiManager) {
        _apiManager = [self createApiManager];
        [self setupApiManager];
    }
    return _apiManager;
}

- (AFHTTPSessionManager *)createApiManager {
    return [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_baseApiUrl] sessionConfiguration:[self configuration]];
}

- (NSURLSessionConfiguration *)configuration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    return configuration;
}

- (void)setupApiManager {
    [_apiManager.requestSerializer setHTTPShouldHandleCookies:YES];
    _apiManager.securityPolicy.allowInvalidCertificates = YES;
    _apiManager.requestSerializer = [AFJSONRequestSerializer serializer];
    _apiManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    _apiManager.responseSerializer = [AFJSONResponseSerializer serializer];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        logInteral(@"Internet reachability %d", status);
    }];
    __weak typeof(self)weakSelf = self;
    [_apiManager setTaskDidCompleteBlock:^(NSURLSession *session, NSURLSessionTask *task, NSError *error) {
        [weakSelf handleOperationEnd:(NSURLSessionDataTask *)task];
    }];
    
}

#pragma mark - Setup

- (void)setupDefaultSettings {
    self.autoRetryCount = 3;
    self.autoRetryInterval = 1;
}

#pragma mark - Common request

#warning REMOVE FROM SDK

- (NSString *)lastModifiedString {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultsKeyLastModified];
}

#warning REMOVE FROM SDK

- (void)setLastModifiedString:(NSString *)value {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:kDefaultsKeyLastModified];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)runRequest:(NSString *)method requestType:(NSString *)type modelClass:(Class)class params:(NSDictionary *)params showError:(BOOL)shouldShowError completion:(DRCompletionHandler)completion errorBlock:(DRErrorHandler)errorHandler {
    NSURLSessionDataTask *requestOperation = [self prepareRequest:method requestType:type modelClass:class params:params showError:shouldShowError completion:completion errorBlock:errorHandler autoRetryCount:self.autoRetryCount];
    [self startOperation:requestOperation];
}

- (NSURLSessionDataTask *)prepareRequest:(NSString *)method requestType:(NSString *)type modelClass:(Class)class params:(NSDictionary *)params showError:(BOOL)shouldShowError completion:(DRCompletionHandler)completion errorBlock:(DRErrorHandler)errorHandler autoRetryCount:(NSInteger)autoRetryCount {
    __weak typeof(self)weakSelf = self;
    
    NSMutableURLRequest *request = [self.apiManager.requestSerializer requestWithMethod:type URLString:[[NSURL URLWithString:method relativeToURL:self.apiManager.baseURL] absoluteString] parameters:params error:nil];
    
    
    #warning REMOVE FROM SDK
    
    BOOL isFollowingShotsRequest = ([request.URL.absoluteString rangeOfString:@"following"].location != NSNotFound);
    NSString *lastModified = nil;
    if (isFollowingShotsRequest) {
        lastModified = [self lastModifiedString];
        if (lastModified) {
            [request addValue:lastModified forHTTPHeaderField:kHttpHeaderIfModifiedSinceKey];
        }
    }
    __block NSURLSessionDataTask *dataTask = [self.apiManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (isFollowingShotsRequest) {
            NSString *lastModifiedValue = [[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:kHttpHeaderLastModifiedKey];
            if (lastModifiedValue) {
                [weakSelf setLastModifiedString:lastModifiedValue];
            }
        }
        if (!error) {
            
            #warning REMOVE FROM SDK
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSNumber *status = [responseObject obtainNumber:@"success"];
                NSError *error = nil;
                if (status) {
                    responseObject = [responseObject obtainDictionary:@"result"];
                    if ([status intValue] == 0) {
                        if (completion) completion([weakSelf mappedDataFromResponseObject:responseObject modelClass:class]);
                    } else  {
                        error = [NSError errorWithDomain:[responseObject objectForKey:@"message"]?:@"Auth error" code:kHttpAuthErrorCode userInfo:nil];
                        if (weakSelf.clientErrorHandler) weakSelf.clientErrorHandler(error, response.URL.absoluteString, shouldShowError);
                        if (completion) completion([DRBaseModel modelWithError:error]);
                    }
                } else {
                    if (completion) completion([weakSelf mappedDataFromResponseObject:responseObject modelClass:class]);
                }
            } else {
                if (isFollowingShotsRequest) {
                    if (completion) completion([DRBaseModel modelWithData:lastModified]);
                } else {
                    if (completion) completion([weakSelf mappedDataFromResponseObject:responseObject modelClass:class]);
                }
            }
        } else {
            
            #warning REMOVE FROM SDK
            
            if ([(NSHTTPURLResponse *)response statusCode] == kHttpContentNotModifiedCode && lastModified) {
                error = [NSError errorWithDomain:@"Content was not modified" code:kHttpContentNotModifiedCode userInfo:nil];
                if (completion) completion ([DRBaseModel modelWithError:error]);
            } else if ([(NSHTTPURLResponse *)response statusCode] == kHttpAuthErrorCode) {
                UIAlertView *alertMessage = [UIAlertView alertWithMessage:kConfirmationRequireText andTitle:@"Info"];
                [alertMessage bk_setCancelBlock:^{
                    
#warning TODO rename to nonAuthorizedErrorHandler()
                    
                    if (weakSelf.cleanBadCredentialsHandler) {
                        weakSelf.cleanBadCredentialsHandler();
                    }
                }];
                [alertMessage show];
            }
            if (weakSelf.clientErrorHandler) weakSelf.clientErrorHandler(error, response.URL.absoluteString, shouldShowError);
            
            if (completion) completion([DRBaseModel modelWithError:error]);
        }
    }];
    
    return dataTask;
}

#warning REMOVE FROM SDK

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

#pragma mark - Data response mapping

#warning TODO refactor for new mapping pod

- (id)objectFromDictionary:(NSDictionary *)dict modelClass:(Class)modelClass {
    return [(id<DRDictionarySerializationProtocol>)[modelClass class] fromDictionary:dict];
}

- (id)mappedDataFromResponseObject:(id)object modelClass:(Class)modelClass {
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

#pragma mark -

- (void)resetAccessToken {
    self.accessToken = nil;
}

- (BOOL)isUserAuthorized {
    return [self.accessToken length];
}

@end

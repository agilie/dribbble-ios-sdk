//
//  DRBaseApiClient.h
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 06.04.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#define DRApiClientLoggingEnabled 1
#define DribbbleApiServiceLogTag @"[API Service] "

#import "ShotBucketCore.h"

// loging helpers

extern void logInteral(NSString *format, ...);
extern DRErrorHandler showErrorAlertFailureHandler();

typedef void(^DRRequestOperationHandler)(NSURLSessionDataTask *operation);

#import <Foundation/Foundation.h>

@interface DRBaseApiClient : NSObject

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) AFHTTPSessionManager *apiManager;
@property (copy, nonatomic) DRRequestOperationHandler operationStartHandler;
@property (copy, nonatomic) DRRequestOperationHandler operationEndHandler;
@property (copy, nonatomic) DRGeneralErrorHandler clientErrorHandler;
@property (copy, nonatomic) DRHandler cleanBadCredentialsHandler;
@property (assign, nonatomic) int autoRetryCount;
@property (assign, nonatomic) int autoRetryInterval;

- (instancetype)initWithBaseUrl:(NSString *)baseUrl;

- (NSURLSessionConfiguration *)configuration;
- (void)setupApiManager;
- (void)setupDefaultSettings;
- (void)resetAccessToken;
- (BOOL)isUserAuthorized;

- (NSURLSessionDataTask *)prepareRequest:(NSString *)method requestType:(NSString *)type modelClass:(Class)class params:(NSDictionary *)params showError:(BOOL)shouldShowError completion:(DRCompletionHandler)completion errorBlock:(DRErrorHandler)errorHandler autoRetryCount:(NSInteger)autoRetryCount;
- (void)runRequest:(NSString *)method requestType:(NSString *)type modelClass:(Class)class params:(NSDictionary *)params showError:(BOOL)shouldShowError completion:(DRCompletionHandler)completion errorBlock:(DRErrorHandler)errorHandler;

- (void)startOperation:(NSURLSessionDataTask *)operation;

- (void)handleOperationStart:(NSURLSessionDataTask *)operation;
- (void)handleOperationEnd:(NSURLSessionDataTask *)operation;

@end

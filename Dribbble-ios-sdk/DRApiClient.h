//
//  DRApiClient.h
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#define DRApiClientLoggingEnabled 1
#define DribbbleApiServiceLogTag @"[API Service] "



#import <Foundation/Foundation.h>
#import "DRBaseApiClient.h"
#import "NXOAuth2.h"


extern void logInteral(NSString *format, ...);
extern DRErrorHandler showErrorAlertFailureHandler();

typedef void(^DRRequestOperationHandler)(NSURLSessionDataTask *operation);

@interface DRApiClient : DRBaseApiClient

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


- (instancetype)initWithOAuthClientAccessSecret:(NSString *)clientAccessSecret;

#pragma mark - Setup

- (void)setupOAuthDismissWebViewBlock:(DRHandler)dismissWebViewBlock;



#pragma mark - oauth handling

- (void)requestOAuth2Login:(UIWebView *)webView completionHandler:(DRCompletionHandler)completion failureHandler:(DRErrorHandler)errorHandler;

- (AFHTTPRequestOperation *)requestImageWithUrl:(NSString *)url completionHandler:(DROperationCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler progressBlock:(DRDOwnloadProgressBlock)downLoadProgressBlock;
- (AFHTTPRequestOperation *)requestImageWithUrl:(NSString *)url completionHandler:(DROperationCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;

- (void)loadUserInfoWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)loadUserFollowees:(NSNumber *)userId params:(NSDictionary *)params withCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)loadFolloweesShotsWithParams:(NSDictionary *)params withCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;

- (void)loadShot:(NSString *)shotId completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)loadShotsFromCategory:(NSString *)category atPage:(int)page completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;

- (void)likeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)unlikeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)checkLikeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;

- (void)followUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)unFollowUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)checkFollowingUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;



@end

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
#import "NXOAuth2.h"
#import "DribbbleSDK.h"

@class DRShot, DRShotCategory;

extern void logInteral(NSString *format, ...);
extern DRErrorHandler showErrorAlertFailureHandler();

typedef void(^DRRequestOperationHandler)(AFHTTPRequestOperation *operation);

@interface DRApiClient : NSObject

@property (strong, nonatomic) NSString *accessToken;
@property (copy, nonatomic) DRRequestOperationHandler operationStartHandler;
@property (copy, nonatomic) DRRequestOperationHandler operationEndHandler;
@property (copy, nonatomic) DRRequestOperationHandler operationLimitHandler;
@property (copy, nonatomic) DRGeneralErrorHandler clientErrorHandler;

@property (assign, nonatomic, readonly) NSURLRequestCachePolicy imageCachePolicy;
@property (assign, nonatomic, readonly) NSURLRequestCachePolicy apiCachePolicy;
@property (assign, nonatomic, readonly) NSInteger imageManagerMaxConcurrentCount;
@property (assign, nonatomic, readonly) NSInteger apiManagerMaxConcurrentCount;
@property (strong, nonatomic, readonly) AFHTTPResponseSerializer *imageResponseSerializer;
@property (strong, nonatomic, readonly) AFHTTPResponseSerializer *apiResponseSerializer;

- (instancetype)initWithBaseUrl:(NSString *)baseUrl;
- (instancetype)initWithOAuthClientAccessSecret:(NSString *)clientAccessSecret;

- (void)setupDefaultSettings;
- (void)resetAccessToken;
- (BOOL)isUserAuthorized;

- (void)createRequestWithMethod:(NSString *)method requestType:(NSString *)type modelClass:(Class)class params:(NSDictionary *)params completion:(DRCompletionHandler)completion errorBlock:(DRErrorHandler)errorHandler;

#pragma mark - Setup

- (void)setupApiManagerWithCachePolicy:(NSURLRequestCachePolicy)policy responseSerializer:(AFHTTPResponseSerializer *)responseSerializer andMaxConcurrentOperations:(NSInteger)count;
- (void)setupImageManagerWithCachePolicy:(NSURLRequestCachePolicy)policy responseSerializer:(AFHTTPResponseSerializer *)responseSerializer andMaxConcurrentOperations:(NSInteger)count;
- (void)setupOAuthDismissWebViewBlock:(DRHandler)dismissWebViewBlock;

#pragma mark - oauth handling

- (void)requestOAuth2Login:(UIWebView *)webView completionHandler:(DRCompletionHandler)completion failureHandler:(DRErrorHandler)errorHandler;

#pragma mark - image/giffs loading

- (AFHTTPRequestOperation *)loadShotImage:(DRShot *)shot ofHighQuality:(BOOL)isHighQuality completionHandler:(DROperationCompletionHandler)completionHandler errorHandler:(DRErrorHandler)errorHandler progressBlock:(DRDOwnloadProgressBlock)downLoadProgressBlock;

#pragma mark - api calls

- (void)loadUserInfoWithCompletionHandler:(DRCompletionHandler)completionHandler errorHandler:(DRErrorHandler)errorHandler;
- (void)loadUserFollowees:(NSNumber *)userId params:(NSDictionary *)params withCompletionHandler:(DRCompletionHandler)completionHandler errorHandler:(DRErrorHandler)errorHandler;
- (void)loadFolloweesShotsWithParams:(NSDictionary *)params withCompletionHandler:(DRCompletionHandler)completionHandler errorHandler:(DRErrorHandler)errorHandler;

- (void)loadShot:(NSString *)shotId completionHandler:(DRCompletionHandler)completionHandler errorHandler:(DRErrorHandler)errorHandler;
- (void)loadShotsWithParams:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler errorHandler:(DRErrorHandler)errorHandler;
- (void)loadShotsFromCategory:(DRShotCategory *)category atPage:(int)page completionHandler:(DRCompletionHandler)completionHandler errorHandler:(DRErrorHandler)errorHandler;
- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler errorHandler:(DRErrorHandler)errorHandler;

- (void)likeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler errorHandler:(DRErrorHandler)errorHandler;
- (void)unlikeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler errorHandler:(DRErrorHandler)errorHandler;
- (void)checkLikeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler errorHandler:(DRErrorHandler)errorHandler;

- (void)followUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler errorHandler:(DRErrorHandler)errorHandler;
- (void)unFollowUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler errorHandler:(DRErrorHandler)errorHandler;
- (void)checkFollowingUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler errorHandler:(DRErrorHandler)errorHandler;



@end

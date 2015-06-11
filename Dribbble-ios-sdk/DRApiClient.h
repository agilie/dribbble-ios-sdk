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

- (instancetype)initWithOAuthClientAccessSecret:(NSString *)clientAccessSecret;
- (void)resetAccessToken;
- (BOOL)isUserAuthorized;

#pragma mark - Setup

- (void)obtainDelegateForWebView:(UIWebView *)webView;
- (void)setupApiManagerWithCachePolicy:(NSURLRequestCachePolicy)policy responseSerializer:(AFHTTPResponseSerializer *)responseSerializer andMaxConcurrentOperations:(NSInteger)count;
- (void)setupImageManagerWithCachePolicy:(NSURLRequestCachePolicy)policy responseSerializer:(AFHTTPResponseSerializer *)responseSerializer andMaxConcurrentOperations:(NSInteger)count;
- (void)setupOAuthDismissWebViewBlock:(DRHandler)dismissWebViewBlock;

#pragma mark - OAuth handling

- (void)requestOAuth2Login:(UIWebView *)webView completionHandler:(DRCompletionHandler)completion;

#pragma mark - Image/giffs loading

- (AFHTTPRequestOperation *)loadShotImage:(DRShot *)shot ofHighQuality:(BOOL)isHighQuality completionHandler:(DROperationCompletionHandler)completionHandler progressBlock:(DRDOwnloadProgressBlock)downLoadProgressBlock;

#pragma mark - API calls

// common

- (AFHTTPRequestOperation *)createRequestWithMethod:(NSString *)method requestType:(NSString *)type modelClass:(Class)class params:(NSDictionary *)params completion:(DRCompletionHandler)completion;

// rest

- (void)loadUserInfoWithCompletionHandler:(DRCompletionHandler)completionHandler;
- (void)loadUserFollowees:(NSNumber *)userId params:(NSDictionary *)params withCompletionHandler:(DRCompletionHandler)completionHandler;
- (void)loadFolloweesShotsWithParams:(NSDictionary *)params withCompletionHandler:(DRCompletionHandler)completionHandler;

- (void)loadShot:(NSString *)shotId completionHandler:(DRCompletionHandler)completionHandler;
- (void)loadShotsWithParams:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler;
- (void)loadShotsFromCategory:(DRShotCategory *)category atPage:(int)page completionHandler:(DRCompletionHandler)completionHandler;
- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler;

- (void)likeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler;
- (void)unlikeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler;
- (void)checkLikeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler;

- (void)followUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler;
- (void)unFollowUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler;
- (void)checkFollowingUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler;

@end

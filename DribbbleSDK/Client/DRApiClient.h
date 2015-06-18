//
//  DRApiClient.h
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOAuth2.h"
#import "DribbbleSDK.h"
#import "DRApiClientSettings.h"


@class DRShot, DRShotCategory;

extern void logInteral(NSString *format, ...);

typedef void(^DRRequestOperationHandler)(AFHTTPRequestOperation *operation);

@interface DRApiClient : NSObject

@property (strong, readonly) DRApiClientSettings *settings;

@property (strong, nonatomic) NSString *baseApiUrl;

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

- (instancetype)initWithSettings:(DRApiClientSettings *)settings;

- (instancetype)initWithOAuthClientAccessSecret:(NSString *)clientAccessSecret;
- (void)resetAccessToken;
- (BOOL)isUserAuthorized;

#pragma mark - Setup

- (void)obtainDelegateForWebView:(UIWebView *)webView;
- (void)setupApiManagerWithCachePolicy:(NSURLRequestCachePolicy)policy responseSerializer:(AFHTTPResponseSerializer *)responseSerializer andMaxConcurrentOperations:(NSInteger)count;
- (void)setupImageManagerWithCachePolicy:(NSURLRequestCachePolicy)policy responseSerializer:(AFHTTPResponseSerializer *)responseSerializer andMaxConcurrentOperations:(NSInteger)count;
- (void)setupOAuthDismissWebViewHandler:(DRHandler)dismissWebViewHandler;

#pragma mark - OAuth handling

- (void)requestOAuth2Login:(UIWebView *)webView completionHandler:(DRCompletionHandler)completionHandler;

#pragma mark - Image/giffs loading

- (AFHTTPRequestOperation *)loadShotImage:(DRShot *)shot isHighQuality:(BOOL)isHighQuality completionHandler:(DROperationCompletionHandler)completionHandler progressHandler:(DRDownloadProgressHandler)progressHandler;

#pragma mark - API calls

// common

- (AFHTTPRequestOperation *)createRequestWithMethod:(NSString *)method requestType:(NSString *)requestType modelClass:(Class)modelClass params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler;
- (void)runRequestWithMethod:(NSString *)method requestType:(NSString *)requestType modelClass:(Class)modelClass params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler;

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

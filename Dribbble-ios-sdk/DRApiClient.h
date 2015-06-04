//
//  DRApiClient.h
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "DRBaseApiClient.h"
#import "DRRequestLimit.h"
#import "NXOAuth2.h"

typedef void(^DRRequestLimitStateChangedHandler)(DRRequestLimitType type, BOOL isExceeded);

@interface DRApiClient : DRBaseApiClient

- (instancetype)initWithOAuthClientAccessSecret:(NSString *)clientAccessSecret;

@property (copy, nonatomic) DRRequestLimitStateChangedHandler requestLimitStateChangedHandler;
@property (copy, nonatomic) DRHandler progressHUDShowBlock;
@property (copy, nonatomic) DRHandler progressHUDDismissBlock;

- (void)killLowPriorityScheduledTask;
- (void)killLowPriorityTasksForShot:(DRShot *)shot;

#pragma mark - Setup

- (void)setupOAuthDismissWebViewBlock:(DRHandler)dismissWebViewBlock;
- (void)setupCleanBadCredentialsBlock:(DRHandler)cleanBadCredentialsBlock;

#pragma mark - oauth handling

- (void)pullCheckSumWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)requestOAuth2Login:(UIWebView *)webView completionHandler:(DRCompletionHandler)completion failureHandler:(DRErrorHandler)errorHandler;
- (void)applyAccount:(NXOAuth2Account *)account withApiClient:(DRApiClient *)apiClient completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorBlock;

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

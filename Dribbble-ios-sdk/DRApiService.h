//
//  DRApiService.h
//  DribbbleRunner
//
//  Created by Ankudinov Alexander on 3/17/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "ShotBucketCore.h"

@class DRBaseModel;

@interface DRApiService : NSObject <UIWebViewDelegate>

@property (copy, nonatomic) DRHandler progressHUDShowBlock;
@property (copy, nonatomic) DRHandler progressHUDDismissBlock;

@property (nonatomic, readonly) NSString *identifierForAnalytics;

+ (instancetype)instance;

- (UIStoryboard *)storyBoard;
- (void)setupAccessToken:(NSString *)token;
- (void)resetAccessToken;

#pragma mark -  Blocks Setup

- (void)setupOAuthDismissWebViewBlock:(DRHandler)dismissWebViewBlock;
- (void)setupCleanBadCredentialsBlock:(DRHandler)cleanBadCredentialsBlock;
- (void)setupLimitControllerBlock:(DRHandler)presentLimitControllerBlock;
- (void)setupAuthControllerBlock:(DRHandler)presentAuthControllerBlock;

#pragma mark - User

- (void)loadUserInfoWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler shouldShowProgressHUD:(BOOL)showHUD;
- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)postUserInfo:(NSDictionary *)userDict withCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)loadUserBalanceWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)loadUserFollowees:(NSNumber *)userId page:(NSNumber *)page perPage:(NSNumber *)perPage completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;

#pragma mark - Shots

- (void)loadShotsFromCategory:(NSString *)category atPage:(int)page shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)syncShots:(NSArray *)shots completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)loadFolloweesShotsWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;

#pragma mark - Promotion

- (void)promoteShots:(NSArray *)shots completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)stopPromoteShotsCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;


#pragma mark - Like

- (void)likeShot:(DRShot *)shot authorId:(NSString *)userId shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)unlikeShot:(NSNumber *)shotId shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)checkLikeShot:(NSNumber *)shotId shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;

#pragma mark - Following

- (void)followUser:(NSNumber *)userId shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)unFollowUser:(NSNumber *)userId shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)checkFollowingUser:(NSNumber *)userId shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;

#pragma mark - 

- (void)followUsSpecialWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (AFHTTPRequestOperation *)requestImageWithUrl:(NSString *)url completionHandler:(DROperationCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (AFHTTPRequestOperation *)requestImageWithUrl:(NSString *)url completionHandler:(DROperationCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler progressBlock:(DRDOwnloadProgressBlock)downLoadProgressBlock;

#pragma mark - Auth

- (BOOL)isUserAuthorized;
- (void)pullCheckSumWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)requestOAuth2Login:(UIWebView *)webView completionHandler:(DRCompletionHandler)completion failureHandler:(DRErrorHandler)errorHandler;

#pragma mark - error handling

- (void)handleError:(NSError*)error forMethod:(NSString *)method withAlert:(BOOL)showAlert;
- (void)sendAnalyticsEvent:(DREvent *)event;

#pragma mark - Operation priority task

- (void)killLowPriorityTasksForShot:(DRShot *)shot;

@end

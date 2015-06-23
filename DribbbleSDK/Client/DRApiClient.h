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

@interface DRApiClient : NSObject

@property (strong, nonatomic, readonly) DRApiClientSettings *settings;
@property (nonatomic, readonly, getter=isUserAuthorized) BOOL userAuthorized;
@property (strong, nonatomic) AFHTTPRequestOperationManager *apiManager;

@property (copy, nonatomic) DRErrorHandler defaultErrorHandler;

- (instancetype)initWithSettings:(DRApiClientSettings *)settings;

#pragma mark - Auth

- (void)authorizeWithWebView:(UIWebView *)webView authHandler:(DROAuthHandler)authHandler;

#pragma mark - API methods

// rest

- (void)loadUserInfoWithResponseHandler:(DRResponseHandler)responseHandler;
- (void)loadUserInfo:(NSString *)userId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadLikesOfUser:(NSString *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadProjectsOfUser:(NSString *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadTeamsOfUser:(NSString *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotsOfUser:(NSString *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadUserFollowees:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadFolloweesShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

- (void)uploadShotWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)updateShotWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)deleteShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler;

- (void)loadShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotsFromCategory:(DRShotCategory *)category atPage:(int)page responseHandler:(DRResponseHandler)responseHandler;
- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadReboundsOfShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

- (void)likeShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)unlikeShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)checkLikeShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadLikesOfShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

- (void)loadCommentsOfShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadComment:(NSString *)commentId forShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadLikesOfComment:(NSString *)commentId forShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)checkLikeComment:(NSString *)commentId forShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler;

- (void)loadAttachmentsOfShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadAttachment:(NSString *)attachmentId forShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

- (void)loadProjectsOfShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadProject:(NSString *)projectId responseHandler:(DRResponseHandler)responseHandler;

- (void)loadMembersOfTeam:(NSString *)teamId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotsOfTeam:(NSString *)teamId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

- (void)followUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler;
- (void)unFollowUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler;
- (void)checkFollowingUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler;

- (void)logout;

@end
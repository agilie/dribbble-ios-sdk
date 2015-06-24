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

extern void DRLog(NSString *format, ...);

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
- (void)loadAccountWithUser:(NSString *)userId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadLikesWithUser:(NSString *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadProjectsWithUser:(NSString *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadTeamsWithUser:(NSString *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotsWithUser:(NSString *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadFolloweesWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadFolloweesShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

- (void)uploadShotWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)updateShot:(NSString *)shotId withParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)deleteShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler;

- (void)loadShotWith:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotsFromCategory:(DRShotCategory *)category atPage:(int)page responseHandler:(DRResponseHandler)responseHandler;
- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadReboundsWithShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

- (void)likeWithShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)unlikeWithShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)checkLikeWithShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadLikesWithShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

- (void)loadCommentsWithShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadCommentWith:(NSString *)commentId forShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadLikesWithComment:(NSString *)commentId forShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)checkLikeWithComment:(NSString *)commentId forShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler;

- (void)loadAttachmentsWithShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadAttachmentWith:(NSString *)attachmentId forShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

- (void)loadProjectsWithShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadProjectWith:(NSString *)projectId responseHandler:(DRResponseHandler)responseHandler;

- (void)loadMembersWithTeam:(NSString *)teamId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotsWithTeam:(NSString *)teamId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

- (void)followUserWith:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler;
- (void)unFollowUserWith:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler;
- (void)checkFollowingWithUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler;

- (void)logout;

@end
//
//  DRApiClient.h
//  
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DribbbleSDK.h"

@class DRShot, DRShotCategory, DRApiClientSettings;

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
- (void)loadAccountWithUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadLikesWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadProjectsWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadTeamsWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotsWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadFollowersWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadFolloweesWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadFolloweesShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

// shots

- (void)uploadShotWithParams:(NSDictionary *)params file:(NSData *)file mimeType:(NSString *)mimeType responseHandler:(DRResponseHandler)responseHandler;
- (void)updateShot:(NSNumber *)shotId withParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)deleteShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotWith:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotsFromCategory:(DRShotCategory *)category atPage:(int)page responseHandler:(DRResponseHandler)responseHandler;
- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadReboundsWithShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)likeWithShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)unlikeWithShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)checkLikeWithShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadLikesWithShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

// comments

- (void)uploadCommentWithShot:(NSNumber *)shotId withBody:(NSString *)body responseHandler:(DRResponseHandler)responseHandler;
- (void)updateCommentWith:(NSNumber *)commentId forShot:(NSNumber *)shotId withBody:(NSString *)body responseHandler:(DRResponseHandler)responseHandler;
- (void)deleteCommentWith:(NSNumber *)commentId forShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadCommentsWithShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadCommentWith:(NSNumber *)commentId forShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)likeWithComment:(NSNumber *)commentId forShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)unlikeWithComment:(NSNumber *)commentId forShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)checkLikeWithComment:(NSNumber *)commentId forShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadLikesWithComment:(NSNumber *)commentId forShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

// attachments

- (void)uploadAttachmentWithShot:(NSNumber *)shotId params:(NSDictionary *)params file:(NSData *)file mimeType:(NSString *)mimeType responseHandler:(DRResponseHandler)responseHandler;
- (void)deleteAttachmentWith:(NSNumber *)attachmentId forShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadAttachmentsWithShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadAttachmentWith:(NSNumber *)attachmentId forShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

// projects

- (void)loadProjectsWithShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadProjectWith:(NSNumber *)projectId responseHandler:(DRResponseHandler)responseHandler;

// following

- (void)followUserWith:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler;
- (void)unFollowUserWith:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler;
- (void)checkFollowingWithUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler;
- (void)checkIfUserWith:(NSNumber *)userId followingAnotherUserWith:(NSNumber *)anotherUserId responseHandler:(DRResponseHandler)responseHandler;

//

- (void)loadMembersWithTeam:(NSNumber *)teamId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotsWithTeam:(NSNumber *)teamId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

- (void)logout;

@end
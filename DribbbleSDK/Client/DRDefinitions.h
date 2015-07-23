//
//  OAuthDefinitions.h
//  
//
//  Created by Ankudinov Alexander on 3/16/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#ifndef DribbbleRunner_OAuthDefinitions_h
#define DribbbleRunner_OAuthDefinitions_h


// Override to disable logging
#define DribbbleSDKLogsEnabled 1
#define DribbbleSDKLogPrefix @"[DribbbleSDK]"

// Block definitions

@class DRApiResponse, NXOAuth2Account;

typedef void(^DRHandler)(void);
typedef void(^DRResponseHandler)(DRApiResponse *response);
typedef void(^DROAuthHandler)(NXOAuth2Account *account, NSError *error);
typedef void(^DRErrorHandler)(NSError *error);
typedef void(^DRDownloadProgressHandler)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);

// Dribbble API methods

static NSString * const kDRApiMethodUser = @"user";
static NSString * const kDRApiMethodUserInfo = @"users/%@";
static NSString * const kDRApiMethodUserLikes = @"users/%@/likes";
static NSString * const kDRApiMethodMyLikes = @"user/likes";
static NSString * const kDRApiMethodUserProjects = @"users/%@/projects";
static NSString * const kDRApiMethodOwnUserProjects = @"user/projects";
static NSString * const kDRApiMethodUserTeams = @"users/%@/teams";
static NSString * const kDRApiMethodMyTeams = @"user/teams";
static NSString * const kDRApiMethodUserShots = @"users/%@/shots";
static NSString * const kDRApiMethodOwnUserShots = @"user/shots";
static NSString * const kDRApiMethodShotProjects = @"shots/%@/projects";
static NSString * const kDRApiMethodProject = @"projects/%@";
static NSString * const kDRApiMethodProjectShots = @"projects/%@/shots";
static NSString * const kDRApiMethodShotAttachments = @"shots/%@/attachments";
static NSString * const kDRApiMethodAttachment = @"shots/%@/attachments/%@";
static NSString * const kDRApiMethodEditComment = @"shots/%@/comments/%@";
static NSString * const kDRApiMethodShotComments = @"shots/%@/comments";
static NSString * const kDRApiMethodComment = @"shots/%@/comments/%@";
static NSString * const kDRApiMethodCommentLikes = @"shots/%@/comments/%@/likes";
static NSString * const kDRApiMethodCheckLikeComment = @"shots/%@/comments/%@/like";
static NSString * const kDRApiMethodShots = @"shots";
static NSString * const kDRApiMethodShot = @"shots/%@";
static NSString * const kDRApiMethodLikeShot = @"shots/%@/like";
static NSString * const kDRApiMethodShotLikes = @"shots/%@/likes";
static NSString * const kDRApiMethodShotRebounds = @"shots/%@/rebounds";
static NSString * const kDRApiMethodFollowUser = @"users/%@/follow";
static NSString * const kDRApiMethodCheckShotWasLiked = @"shots/%@/like";
static NSString * const kDRApiMethodGetFollowers = @"users/%@/followers";
static NSString * const kDRApiMethodGetMyFollowers = @"user/followers";
static NSString * const kDRApiMethodCheckIfUserFollowing = @"user/following/%@";
static NSString * const kDRApiMethodCheckIfOneUserFollowingAnother = @"users/%@/following/%@";
static NSString * const kDRApiMethodGetFollowees = @"users/%@/following";
static NSString * const kDRApiMethodGetMyFollowees = @"user/following";
static NSString * const kDRApiMethodGetFolloweesShot = @"user/following/shots";
static NSString * const kDRApiMethodGetLikes = @"users/%@/likes";
static NSString * const kDRApiMethodTeamMembers = @"teams/%@/members";
static NSString * const kDRApiMethodTeamShots = @"teams/%@/shots";
static NSString * const kDRApiMethodMyBuckets = @"user/buckets";
static NSString * const kDRApiMethodUserBuckets = @"users/%@/buckets";
static NSString * const kDRApiMethodBucketsForShot = @"shots/%@/buckets";
static NSString * const kDRApiMethodLoadBucket = @"buckets/%@";
static NSString * const kDRApiMethodLoadBucketShots = @"buckets/%@/shots";
static NSString * const kDRApiMethodAddBucket = @"buckets";

// Dribbble API params keys

static NSString * const kDRParamPage = @"page";
static NSString * const kDRParamPerPage = @"per_page";
static NSString * const kDRParamList = @"list";
static NSString * const kDRParamTimeFrame = @"timeframe";
static NSString * const kDRParamDate = @"date";
static NSString * const kDRParamSort = @"sort";

// Dribbble API param keys

static NSString * const kDRParamTitle = @"title";
static NSString * const kDRParamImage = @"image";
static NSString * const kDRParamDescription = @"description";
static NSString * const kDRParamTags = @"tags";
static NSString * const kDRParamTeamId = @"team_id";
static NSString * const kDRParamReboundSourceId = @"rebound_source_id";
static NSString * const kDRParamBody = @"body";
static NSString * const kDRParamFile = @"file";

// Dribbble API permission keys

static NSString * const kDRPublicScope = @"public";
static NSString * const kDRWriteScope = @"write";
static NSString * const kDRCommentScope = @"comment";
static NSString * const kDRUploadScope = @"upload";

// Http errors

static NSInteger const kHttpAuthErrorCode = 401;
static NSInteger const kHttpNotFoundErrorCode = 404;
static NSInteger const kHttpRequestFailedErrorCode = 403;
static NSInteger const kHttpRateLimitErrorCode = 429;
static NSInteger const kHttpInternalServerErrorCode = 500;
static NSInteger const kHttpContentNotModifiedCode = 304;

static NSString * const kDROAuthErrorDomain = @"DROAuthErrorDomain";
static NSString * const kDROAuthErrorFailureKey = @"DRAuthErrorFailureKey";
static NSString * const kDRUploadErrorFailureKey = @"DRUploadErrorFailureKey";

static NSInteger kDROAuthErrorCodeUnacceptableRedirectUrl = 10001;
static NSString * const kDROAuthErrorUnacceptableRedirectUrlDescription = @"Authentification failed, please try again";

// Keychain

static NSString * const kIDMOAccountType = @"DribbleAuth";

// Misc

static NSString * const kUnacceptableWebViewUrl = @"session/new";

#endif
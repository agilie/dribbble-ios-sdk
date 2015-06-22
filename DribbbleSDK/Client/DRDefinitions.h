//
//  OAuthDefinitions.h
//  DribbbleRunner
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

static NSString * const kDribbbleApiMethodUser = @"user";
static NSString * const kDribbbleApiMethodShots = @"shots";
static NSString * const kDribbbleApiMethodShot = @"shots/%@";
static NSString * const kDribbbleApiMethodLikeShot = @"shots/%@/like";
static NSString * const kDribbbleApiMethodFollowUser = @"users/%@/follow";
static NSString * const kDribbbleApiMethodCheckShotWasLiked = @"shots/%@/like";
static NSString * const kDribbbleApiMethodCheckIfUserFollowing = @"user/following/%@";
static NSString * const kDribbbleApiMethodGetFollowers = @"users/%@/following";
static NSString * const kDribbbleApiMethodGetFolloweesShot = @"user/following/shots";
static NSString * const kDribbbleApiMethodGetLikes = @"users/%@/likes";

// Http errors

static NSInteger const kHttpAuthErrorCode = 401;
static NSInteger const kHttpRateLimitErrorCode = 429;
static NSInteger const kHttpContentNotModifiedCode = 304;

static NSString * const kInvalidAuthData = @"Invalid auth data";

// Keychain

static NSString * const kIDMOAccountType = @"DribbleAuth";

// Misc

static NSString * const kUnacceptableWebViewUrl = @"session/new";

#endif
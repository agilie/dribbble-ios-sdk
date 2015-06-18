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

typedef void(^DRHandler)(void);
typedef void(^DROperationCompletionHandler)(id data, AFHTTPRequestOperation *operation);
typedef void(^DRCompletionHandler)(id data);
typedef void(^DRGeneralErrorHandler)(NSError *error, NSString *method, BOOL showAlert);
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

// Http request methods

static NSString * kDribbbleGetRequest = @"GET";
static NSString * kDribbblePostRequest = @"POST";
static NSString * kDribbblePutRequest = @"PUT";
static NSString * kDribbbleDeleteRequest = @"DELETE";

static NSString * const kAuthorizationHTTPFieldName = @"Authorization";
static NSString * const kBearerString = @"Bearer";

// Http errors

static NSInteger const kHttpAuthErrorCode = 401;
static NSInteger const kHttpRateLimitErrorCode = 429;
static NSInteger const kHttpContentNotModifiedCode = 304;
static NSInteger const kHttpCannotFindHost = -1003;
static NSInteger const kHttpCannotConnectToHost = -1004;
static NSInteger const kHttpConnectionLost = -1005;

static NSString * const kInvalidAuthData = @"Invalid auth data";

// Keychain

static NSString * const kIDMOAccountType = @"DribbleAuth";

// Misc

static NSString * const kUnacceptableWebViewUrl = @"session/new";

#endif
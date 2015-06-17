//
//  OAuthDefinitions.h
//  DribbbleRunner
//
//  Created by Ankudinov Alexander on 3/16/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#ifndef DribbbleRunner_OAuthDefinitions_h
#define DribbbleRunner_OAuthDefinitions_h

// Block definitions

typedef void(^DRHandler)(void);
typedef void(^DROperationCompletionHandler)(id data, AFHTTPRequestOperation *operation);
typedef void(^DRCompletionHandler)(id data);
typedef void(^DRGeneralErrorHandler)(NSError *error, NSString *method, BOOL showAlert);
typedef void(^DRDownloadProgressHandler)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);

// ApiTestApp credentials

static NSString * const kIDMOAuth2ClientId = @"d1bf57813d51b916e816894683371d2bcfaff08a5a5f389965f1cf779e7da6f8";
static NSString * const kIDMOAuth2ClientSecret = @"305fea0abc1074b8d613a05790fba550b56d93023995fdc67987eed288cd1af5";
static NSString * const kIDMOAuth2ClientAccessSecret =@"ebc7adb327f3ae4cf2517de0a37b483a0973d932b3187578501c55b9f5ede17b";
static NSString * const kIDMOAuth2RedirectURL = @"apitestapp://authorize";

// Dribbble API

static NSString * const kUnacceptableWebViewUrl = @"session/new";
static NSString * const kIDMOAuth2AuthorizationURL = @"https://dribbble.com/oauth/authorize";
static NSString * const kIDMOAuth2TokenURL = @"https://dribbble.com/oauth/token";
static NSString * const kIDMOAccountType = @"DribbleAuth";
static NSString * const kBaseApiUrl = @"https://api.dribbble.com/v1/";

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

static NSString * const kRedirectUrlDribbbleFormat = @"%@&state=%@";

// Http request methods

static NSString * kDribbbleGetRequest = @"GET";
static NSString * kDribbblePostRequest = @"POST";
static NSString * kDribbblePutRequest = @"PUT";
static NSString * kDribbbleDeleteRequest = @"DELETE";

// Http errors

static NSInteger const kHttpAuthErrorCode = 401;
static NSInteger const kHttpRateLimitErrorCode = 429;
static NSInteger const kHttpContentNotModifiedCode = 304;
static NSInteger const kHttpCannotFindHost = -1003;
static NSInteger const kHttpCannotConnectToHost = -1004;
static NSInteger const kHttpConnectionLost = -1005;

static NSString * const kInvalidAuthData = @"Invalid auth data";

#endif
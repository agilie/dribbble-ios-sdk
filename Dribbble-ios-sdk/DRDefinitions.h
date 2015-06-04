//
//  OAuthDefinitions.h
//  DribbbleRunner
//
//  Created by Ankudinov Alexander on 3/16/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#ifndef DribbbleRunner_OAuthDefinitions_h
#define DribbbleRunner_OAuthDefinitions_h

#define methodNotImplemented() \
NSLog(@"METHOD NOT IMPLEMENTED: %s:%d:%s", __FILE__, __LINE__, __PRETTY_FUNCTION__)

#define mustOverride() \
@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil]

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

static const BOOL kSkipTutorialInDebug = NO;

// Block definitions
typedef void(^DRHandler)(void);
typedef void(^DROperationCompletionHandler)(id data, AFHTTPRequestOperation *operation);
typedef void(^DRCompletionHandler)(id data);
typedef void(^DRCompletionBackGroundFetchHandler)(UIBackgroundFetchResult);
typedef void(^DRErrorHandler)(id data);
typedef void(^DRGeneralErrorHandler)(NSError *error, NSString *method, BOOL showAlert);
typedef void(^DRDOwnloadProgressBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);

// App Groups
static NSString *const kAppGroupName = @"group.me.agile.ninja.shotbucket";

//NEED SOME PROTECTION!!!
static NSString * const kIDMOAuth2ClientId = @"b575d9c8011ae288c8f5d8d8bd96f3dbfd240f16171bd14236958c219bac9f13";
static NSString * const kIDMOAuth2ClientSecret = @"8b4a1d08d53f4fbecd8d9b5594436b248497142a94e4735287d41f40e25d506c";

// DEV Ids
//static NSString * const kIDMOAuth2ClientId = @"e0a7a4e6d2ab6c95d9fd2a7c5a8fc2c80c6ab342266348b9eb0f21f0ecd9ca9f";
//static NSString * const kIDMOAuth2ClientSecret = @"1b2a553724854049aeb94a0b035541f80876272bdd3482e5302215183012671e";

//FOR ANON ACESS
static NSString * const kIDMOAuth2ClientAccessSecret =@"4899ba8cb9e8697d0c546f4c7c0677fc4b9759143f552f36f2f5bb15fc553d0d";
//DEV TOKEN
//static NSString * const kIDMOAuth2ClientAccessSecret =@"391ce8fff424c848f47e1a4f1bf574ced6f9f2f129f772084c498208b9bf8e4f";

static NSString * const kIDMOAuth2RedirectURL = @"https://shotbucketapp.com/web/oauth";
static NSString * const kUnacceptableWebViewUrl = @"session/new";
static NSString * const kIDMOAuth2AuthorizationURL = @"https://dribbble.com/oauth/authorize";
static NSString * const kIDMOAuth2TokenURL = @"https://dribbble.com/oauth/token";

static NSString * const kIDMOAccountType = @"DribbleAuth";
static NSString * const kAccountID = @"597558";

static NSString * const kBaseApiUrl = @"https://api.dribbble.com/v1/";
//static NSString * const kBaseServerUrl = @"http://devdribbble.agilie.com/api/";
static NSString * const kBaseServerUrl = @"https://shotbucketapp.com/api/";

// User Defaults Keys

static NSString * const kDribbbleFollowUsSpecialKey = @"followUsSpecial";
static NSString * const kDribbblePreviousAuthKey = @"previousAuthUser";
static NSString * const kDribbbleUserKey = @"dribbbleUser";
static NSString * const kUserBallanceKey = @"dribbbleUserBallance";
static NSString * const kUserLikedShotsArrayKey = @"userLikedShotsArray";
static NSString * const kUserFollowedShotsAuthorityArrayKey = @"userFollowedShotsAuthorityArray";
static NSString * const kUserFollowingsArrayKey = @"followings";
static NSString * const kUserFollowingsPage = @"userFollowingsPage";

// Storyboard constants

static NSString * const kShowShotsSegueIdentifier = @"showShotsSegue";
static NSString * const kShowLoginSegueIdentifier = @"showLoginSegue";
static NSString * const kShowProfileSegueIdentifier = @"showProfileSegue";

// Http request methods

static NSString * kDribbbleGetRequest = @"GET";
static NSString * kDribbblePostRequest = @"POST";
static NSString * kDribbblePutRequest = @"PUT";
static NSString * kDribbbleDeleteRequest = @"DELETE";

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

// Dribbble agilie server methods

static NSString * const kDribbbleApiMethodChecksumForAuth = @"getchecksumforauth";
static NSString * const kDribbbleApiMethodApplyAccessToken = @"applyat";
static NSString * const kDribbbleLocalMethodLikeShot = @"v2/shot/i_like_shot";
static NSString * const kDribbbleLocalMethodFollowUser = @"follow/i_follow_somebody";
static NSString * const kDribbbleLocalMethodProfile = @"profile";
static NSString * const kDribbbleLocalMethodBalance = @"profile/balance";
static NSString * const kDribbbleLocalMethodSyncShots = @"v2/shot/sync";
static NSString * const kDribbbleLocalMethodStartPromote = @"profile/start_promoute";
static NSString * const kDribbbleLocalMethodStopPromote = @"profile/stop_promoute";
static NSString * const kDribbbleLocalMethodListPromote = @"v2/shot/list_promoute";
static NSString * const kDribbbleLocalMethodFollowUs = @"follow/follow_us_special";

static NSString * const kDribbbleLocalMethodClientEvent = @"client_events";

// Animation constants

static CGFloat const kAppleStyleAnimationDuration = 0.245;
static CGFloat const kMaterialStyleAnimationDuration = 0.5;
static CGFloat const kMaterialFasterStyleAnimationDuration = 0.4;

// Http errors

static NSInteger const kHttpAuthErrorCode = 401;
static NSInteger const kHttpRateLimitErrorCode = 429;
static NSInteger const kHttpContentNotModifiedCode = 304;

static NSInteger const kHttpCannotFindHost = -1003;
static NSInteger const kHttpCannotConnectToHost = -1004;
static NSInteger const kHttpConnectionLost = -1005;


static NSString * const kFeaturedCategoryTitle = @"Featured";
static NSString * const kFeaturedCategoryValue = @"featured";
static NSString * const kRecentCategoryTitle = @"recent";

// Path format

static NSString * const kUserLimitsFileFormat = @"user_limits.dat";

// Message constant

static NSString * const kNotificationReminderText = @"You don't launch app more than 3 days. Check new shots of your followees";
static NSString * const kInternetConnectionLost = @"Bad internet connection";
static NSString * const kConfirmationRequireText = @"Please confirm your email address for using Application, a confirmation message was sent to your email";

#endif
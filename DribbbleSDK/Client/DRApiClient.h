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
@property (copy, nonatomic) DRErrorHandler clientErrorHandler;

- (instancetype)initWithSettings:(DRApiClientSettings *)settings;
- (void)resetAccessToken;

#pragma mark - Auth

- (void)authorizeWithWebView:(UIWebView *)webView completionHandler:(DRCompletionHandler)completionHandler cancellationHandler:(DRHandler)cancellationHandler;

#pragma mark - API methods

// rest

- (void)loadUserInfoWithCompletionHandler:(DRCompletionHandler)completionHandler;
- (void)loadUserFollowees:(NSNumber *)userId params:(NSDictionary *)params withCompletionHandler:(DRCompletionHandler)completionHandler;
- (void)loadFolloweesShotsWithParams:(NSDictionary *)params withCompletionHandler:(DRCompletionHandler)completionHandler;

- (void)loadShot:(NSString *)shotId completionHandler:(DRCompletionHandler)completionHandler;
- (void)loadShotsWithParams:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler;
- (void)loadShotsFromCategory:(DRShotCategory *)category atPage:(int)page completionHandler:(DRCompletionHandler)completionHandler;
- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler;

- (void)likeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler;
- (void)unlikeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler;
- (void)checkLikeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler;

- (void)followUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler;
- (void)unFollowUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler;
- (void)checkFollowingUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler;

@end

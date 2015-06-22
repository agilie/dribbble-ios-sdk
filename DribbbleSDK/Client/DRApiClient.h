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

#pragma mark - Auth

- (void)authorizeWithWebView:(UIWebView *)webView responseHandler:(DRResponseHandler)responseHandler cancellationHandler:(DRHandler)cancellationHandler;

#pragma mark - API methods

// rest

- (void)loadUserInfoWithResponseHandler:(DRResponseHandler)responseHandler;
- (void)loadUserFollowees:(NSNumber *)userId params:(NSDictionary *)params withResponseHandler:(DRResponseHandler)responseHandler;
- (void)loadFolloweesShotsWithParams:(NSDictionary *)params withResponseHandler:(DRResponseHandler)responseHandler;

- (void)loadShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
- (void)loadShotsFromCategory:(DRShotCategory *)category atPage:(int)page responseHandler:(DRResponseHandler)responseHandler;
- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;

- (void)likeShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)unlikeShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
- (void)checkLikeShot:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;

- (void)followUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler;
- (void)unFollowUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler;
- (void)checkFollowingUser:(NSNumber *)userId responseHandler:(DRResponseHandler)responseHandler;

- (void)logout;

@end

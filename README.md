# DribbbleSDK

DribbbleSDK provides easy-to-use iOS API for Dribbble services. We implemented all needed methods for you. Have fun.


[![CI Status](http://img.shields.io/travis/agilie/dribbble-ios-sdk.svg?style=flat)](https://travis-ci.org/agilie/dribbble-ios-sdk)
[![Version](https://img.shields.io/cocoapods/v/dribbble-ios-sdk.svg?style=flat)](http://cocoadocs.org/docsets/dribbble-ios-sdk)
[![License](https://img.shields.io/cocoapods/l/dribbble-ios-sdk.svg?style=flat)](http://cocoadocs.org/docsets/dribbble-ios-sdk)
[![Platform](https://img.shields.io/cocoapods/p/dribbble-ios-sdk.svg?style=flat)](http://cocoadocs.org/docsets/dribbble-ios-sdk)

## Usage

To run the example project, clone the repo, and run `pod install` from the Demo directory first.

Use DROAuthManager class methods for native Dribbble authentification
```obj-c
- (void)requestOAuth2Login:(UIWebView *)webView completionHandler:(DRCompletionHandler)completion;
```
Use DRApiClient class for all Dribbble stuff

- Get user info with loadUserInfoWithCompletionHandler method
```obj-c
- (void)loadUserInfoWithCompletionHandler:(DRCompletionHandler)completionHandler;
```

- Get users followees with loadUserFollowees method
```obj-c
- (void)loadUserFollowees:(NSNumber *)userId params:(NSDictionary *)params withCompletionHandler:(DRCompletionHandler)completionHandler;
```

- Followees shots with loadFolloweesShotsWithParams method
```obj-c
- (void)loadFolloweesShotsWithParams:(NSDictionary *)params withCompletionHandler:(DRCompletionHandler)completionHandler;
```

- Users shots with loadUserShots method
```obj-c
- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler;
```

- You can discover shots by categories with loadShotsFromCategory method
```obj-c
- (void)loadShotsFromCategory:(DRShotCategory *)category atPage:(int)page completionHandler:(DRCompletionHandler)completionHandler;
```

- Like shot methods: likeShot, unlikeShot, checkLikeShot
```obj-c
- (void)likeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler;
- (void)unlikeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler;
- (void)checkLikeShot:(NSNumber *)shotId completionHandler:(DRCompletionHandler)completionHandler;
```

- Follow user methods: followUser, unFollowUser, checkFollowingUser
```obj-c
- (void)followUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler;
- (void)unFollowUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler;
- (void)checkFollowingUser:(NSNumber *)userId completionHandler:(DRCompletionHandler)completionHandler;
```

- You can load shots (Images/GIF) with different quality
```obj-c
- (AFHTTPRequestOperation *)loadShotImage:(DRShot *)shot isHighQuality:(BOOL)isHighQuality completionHandler:(DROperationCompletionHandler)completionHandler progressHandler:(DRDownloadProgressHandler)progressHandler;
```

## Credentials

For using DribbbleSDK with your app, you need to setup credentials into DRDefinitions.h class.
( kIDMOAuth2ClientId, kIDMOAuth2ClientSecret, kIDMOAuth2ClientAccessSecret )

Dribbble resources:
Register your app wia https://dribbble.com/account/applications/new
Documentation http://developer.dribbble.com/v1/

## Requirements

## Installation

Dribbble iOS SDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DribbbleSDK"

## Author

Agilie info@agilie.com

## License

DribbbleSDK is available under the MIT license. See the LICENSE file for more info.


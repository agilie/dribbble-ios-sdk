//
//  DRAppDelegate.m
//  Dribbble-ios-sdk
//
//  Created by zgonik vova on 04.06.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRAppDelegate.h"

#import "DribbbleSDK.h"
#import "DRShotCategory.h"
#import "DRBaseModel.h"

@interface DRAppDelegate ()

@end

@implementation DRAppDelegate

#pragma mark - Static Methods

+ (DRAppDelegate *)appDelegate {
    return (DRAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"didFinishLaunchingWithOptions");
    
    [self testApiClient];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark -

- (void)testApiClient {
    DRApiClient *client = [[DRApiClient alloc] initWithOAuthClientAccessSecret:kIDMOAuth2ClientAccessSecret];
    
    [client loadShotsFromCategory:[DRShotCategory recentShotsCategory] atPage:1 completionHandler:^(DRBaseModel *data) {
        NSLog(@"");
    } errorHandler:^(DRBaseModel *data) {
        NSLog(@"");
    }];
}

@end

//
//  DRAppDelegate.m
//  Dribbble-ios-sdk
//
//  Created by zgonik vova on 04.06.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRAppDelegate.h"
#import "DRApiService.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "DRLimitViewController.h"
#import "HKRLocalNotificationManager.h"
#import "NXOAuth2.h"

@interface DRAppDelegate ()

@end

@implementation DRAppDelegate

#pragma mark - Static Methods

+ (DRAppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"didFinishLaunchingWithOptions");
    
    NSUInteger cacheSizeMemory = 0; // 500 MB
    NSUInteger cacheSizeDisk = 500*1024*1024; // 500 MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
    
    sleep(1);
    [self setupApiService];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:kDribbblePreviousAuthKey]) {
        [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:kIDMOAccountType] enumerateObjectsUsingBlock:^(NXOAuth2Account * obj, NSUInteger idx, BOOL *stop) {
            [[NXOAuth2AccountStore sharedStore] removeAccount:obj];
        }];
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
#warning TODO refactor and get to work
        [userDefaults setObject:[self genRandStringLength:20] forKey:kDribbblePreviousAuthKey];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Setup ApiService

- (void)setupApiService {
    DRApiService *apiService = [DRApiService instance];
    __weak typeof(self)weakSelf = self;
    apiService.progressHUDShowBlock = ^ {
        if (![SVProgressHUD isVisible]) [SVProgressHUD show];
    };
    apiService.progressHUDDismissBlock = ^ {
        [SVProgressHUD dismiss];
    };
    [apiService setupCleanBadCredentialsBlock:^{
        [[DRActionManager instance] logout];
        [[DRAppDelegate appDelegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    [apiService setupOAuthDismissWebViewBlock:^{
        [[DRAppDelegate appDelegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    [apiService setupLimitControllerBlock:^{
        if ([weakSelf.window.rootViewController isKindOfClass:[UINavigationController class]]) {
            DRLimitViewController *limitController = [[DRLimitViewController alloc] initWithNibName:@"DRLimitViewController" bundle:nil];
            [weakSelf.window.rootViewController presentViewController:limitController animated:YES completion:nil];
        }
    }];
    [apiService setupAuthControllerBlock:^{
        if ([weakSelf.window.rootViewController isKindOfClass:[UINavigationController class]]) {
            [weakSelf.window.rootViewController performSegueWithIdentifier:kShowLoginSegueIdentifier sender:nil];
        }
    }];
}

#pragma mark - helpers

// Generates alpha-numeric-random string
- (NSString *)genRandStringLength:(int)len {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

@end

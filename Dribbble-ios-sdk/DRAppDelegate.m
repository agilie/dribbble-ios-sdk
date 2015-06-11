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

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation DRAppDelegate

#pragma mark - Getter

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.window.rootViewController.view.frame];
    }
    return _webView;
}

#pragma mark - Static Methods

+ (DRAppDelegate *)appDelegate {
    return (DRAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"didFinishLaunchingWithOptions");
    [self testApiClient];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UIViewController alloc] init];
    [self.window makeKeyAndVisible];
    
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
    DRApiClient *client = [[DRApiClient alloc] init];
    
    __weak typeof(client) weakClient = client;
    __weak typeof(self) weakSelf = self;
    
    client.clientErrorHandler = ^ (NSError *error, NSString *method, BOOL showAlert) {
        if (![weakClient isUserAuthorized]) {
            [weakClient obtainDelegateForWebView:weakSelf.webView];
            [weakSelf.window.rootViewController.view addSubview:weakSelf.webView];
            [weakClient requestOAuth2Login:weakSelf.webView completionHandler:^(DRBaseModel *data) {
                    if (!data.error) {
                        [weakClient loadShotsFromCategory:[DRShotCategory recentShotsCategory] atPage:1 completionHandler:^(DRBaseModel *data) {
                            NSLog(@"response");
                        }];
                    }
                
                
                
                }];
        }
    };
    [client loadShotsFromCategory:[DRShotCategory recentShotsCategory] atPage:1 completionHandler:^(DRBaseModel *data) {
        NSLog(@"response");
    }];
}

@end

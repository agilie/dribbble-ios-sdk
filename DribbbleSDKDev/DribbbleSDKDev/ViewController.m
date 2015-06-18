//
//  ViewController.m
//  DribbbleSDKDemo
//
//  Created by Dmitry Salnikov on 6/11/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "ViewController.h"
#import "LoginViewController.h"
#import "DribbbleSDK.h"

// SDK setup constants

static NSString * const kIDMOAuth2ClientId = @"d1bf57813d51b916e816894683371d2bcfaff08a5a5f389965f1cf779e7da6f8";
static NSString * const kIDMOAuth2ClientSecret = @"305fea0abc1074b8d613a05790fba550b56d93023995fdc67987eed288cd1af5";
static NSString * const kIDMOAuth2ClientAccessToken = @"ebc7adb327f3ae4cf2517de0a37b483a0973d932b3187578501c55b9f5ede17b";

static NSString * const kIDMOAuth2RedirectURL = @"apitestapp://authorize";
static NSString * const kIDMOAuth2AuthorizationURL = @"https://dribbble.com/oauth/authorize";
static NSString * const kIDMOAuth2TokenURL = @"https://dribbble.com/oauth/token";

static NSString * const kBaseApiUrl = @"https://api.dribbble.com/v1/";

// ---

NSString * kSegueIdentifierAuthorize = @"authorizeSegue";

@interface ViewController ()

@property (strong, nonatomic) DRApiClient *apiClient;

@property (strong, nonatomic) IBOutlet LoginViewController *loginViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupApiClient];
}

- (void)setupApiClient {
    
    DRApiClientSettings *settings = [[DRApiClientSettings alloc] initWithBaseUrl:kBaseApiUrl
                                                               oAuth2RedirectUrl:kIDMOAuth2RedirectURL
                                                          oAuth2AuthorizationUrl:kIDMOAuth2AuthorizationURL
                                                                  oAuth2TokenUrl:kIDMOAuth2TokenURL
                                                                        clientId:kIDMOAuth2ClientId
                                                                    clientSecret:kIDMOAuth2ClientSecret
                                                               clientAccessToken:kIDMOAuth2ClientAccessToken];
    
    self.apiClient = [[DRApiClient alloc] initWithSettings:settings];
    __weak typeof(self) weakSelf = self;
    self.apiClient.clientErrorHandler = ^ (NSError *error, NSString *method, BOOL showAlert) {
        if (![weakSelf.apiClient isUserAuthorized]) {
            [weakSelf performSegueWithIdentifier:kSegueIdentifierAuthorize sender:nil];
        }
    };
}

- (void)loadSomeData {
    [self.apiClient loadShotsFromCategory:[DRShotCategory recentShotsCategory] atPage:1 completionHandler:^(DRBaseModel *data) {
        NSLog(@"response: %@", data.object);
    }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdentifierAuthorize]) {
        LoginViewController *loginViewController = (LoginViewController *)segue.destinationViewController;
        loginViewController.apiClient = self.apiClient;
        __weak typeof(self) weakSelf = self;
        loginViewController.authCompletionHandler = ^(NSNumber *authSucceeded) {
            if ([authSucceeded boolValue]) {
                [weakSelf loadSomeData];
            }
        };
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadSomeData];
}

@end

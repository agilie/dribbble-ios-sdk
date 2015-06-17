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
    self.apiClient = [DRApiClient new];
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

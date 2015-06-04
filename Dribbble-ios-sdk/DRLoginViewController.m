//
//  DRViewController.m
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 16.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRLoginViewController.h"
#import "DRBaseApiClient.h"

@interface DRLoginViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *loginWebView;

@end

@implementation DRLoginViewController

#pragma mark - View LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    [SVProgressHUD show];
    [self.apiService pullCheckSumWithCompletionHandler:^(DRBaseModel *data) {
        if (!data.error) {
            [weakSelf.apiService requestOAuth2Login:_loginWebView completionHandler:^(DRBaseModel *data) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            } failureHandler:showErrorAlertFailureHandler()];
        }
        [SVProgressHUD dismiss];
    } failureHandler:showErrorAlertFailureHandler()];
}

#pragma mark - IBAction

- (IBAction)skipButtonAction:(id)sender {
    [self.apiService resetAccessToken];
    [self dismissViewControllerAnimated:YES completion:nil];
    DREvent *event = [DREvent eventType:@"e_skip_auth" navigation:@"auth" actionId:nil];
    [[DRApiService instance] sendAnalyticsEvent:event];
}

@end

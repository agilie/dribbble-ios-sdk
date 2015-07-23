//
//  LoginViewController.m
//  DribbbleSDKExample
//
//  Created by Dmitry Salnikov on 6/11/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "LoginViewController.h"
#import "NXOAuth2Account.h"
#import "NXOAuth2AccessToken.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak typeof(self) weakSelf = self;
    [self.apiClient authorizeWithWebView:self.webView authHandler:^(NXOAuth2Account *account, NSError *error) {
        weakSelf.authCompletionHandler(@(account != nil));
        [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end

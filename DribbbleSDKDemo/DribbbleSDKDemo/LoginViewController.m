//
//  LoginViewController.m
//  DribbbleSDKDemo
//
//  Created by Dmitry Salnikov on 6/11/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "LoginViewController.h"

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
    [self.apiClient requestOAuth2Login:self.webView completionHandler:^(DRApiResponse *data) {
        if (!data.error) {
            weakSelf.authCompletionHandler(@YES);
        }
    }];
}

@end

//
//  TestApiViewController.m
//  DribbbleSDKExample
//
//  Created by Dmitry Salnikov on 6/24/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "TestApiViewController.h"
#import "ApiCallWrapper.h"
#import "DRApiResponse.h"

@interface TestApiViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;


@end

@implementation TestApiViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self runApiCall];
}

- (void)runApiCall {
    __weak typeof(self) weakSelf = self;
    self.apiCallWrapper.responseHandler = ^(DRApiResponse *response) {
        if (response.object) {
            weakSelf.textView.text = [NSString stringWithFormat:@"Request succeeded, response object:\n%@", [response.object description]];
        } else if (response.error) {
            if (response.error.code == kHttpNotFoundErrorCode) {
                weakSelf.textView.text = [NSString stringWithFormat:@"Request succeeded. No data"];
            } else {
                weakSelf.textView.text = [NSString stringWithFormat:@"Request failed with error:\n%@", response.error];
            }
        } else if (!response.object && !response.error) {
            weakSelf.textView.text = [NSString stringWithFormat:@"Request succeeded"];
        }
    };
    [self.apiCallWrapper invokeWithApiClient:self.apiClient];
}

@end

//
//  LoginViewController.h
//  DribbbleSDKDemo
//
//  Created by Dmitry Salnikov on 6/11/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DribbbleSDK.h"

@interface LoginViewController : UIViewController

@property (strong, nonatomic) DRApiClient *apiClient;

@property (copy, nonatomic) DRCompletionHandler authCompletionHandler;

@end

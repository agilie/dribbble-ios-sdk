//
//  TestApiViewController.h
//  DribbbleSDKDev
//
//  Created by Dmitry Salnikov on 6/24/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApiCallWrapper.h"
#import "DribbbleSDK.h"

@interface TestApiViewController : UIViewController

@property (strong, nonatomic) ApiCallWrapper *apiCallWrapper;
@property (strong, nonatomic) DRApiClient *apiClient;

@end

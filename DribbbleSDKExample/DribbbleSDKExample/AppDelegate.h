//
//  AppDelegate.h
//  DribbbleSDKExample
//
//  Created by Dmitry Salnikov on 6/17/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRUser.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DRUser *user;

+ (AppDelegate *)delegate;

@end


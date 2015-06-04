//
//  DRAppDelegate.h
//  Dribbble-ios-sdk
//
//  Created by zgonik vova on 04.06.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#pragma mark - Static Methods

+ (DRAppDelegate *)appDelegate;

@end


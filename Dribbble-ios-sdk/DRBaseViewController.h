//
//  DRBaseViewController.h
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 19.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRApiService.h"
#import "DRShotsController.h"

static NSString * const kYouLikedShotText = @"You liked %@ shot";
static NSString * const kYouAreFollowingSMBText = @"Now you are following %@";

@interface DRBaseViewController : UIViewController

@property (nonatomic, readonly) DRApiService *apiService;
@property (nonatomic, readonly) DRActionManager *actionManager;

@end
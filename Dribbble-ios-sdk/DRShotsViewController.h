//
//  DRShotsViewController.h
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 18.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRBaseViewController.h"

typedef void (^completion)(BOOL success);

@interface DRShotsViewController : DRBaseViewController

@property float cardYPosiyion;

- (instancetype)initWithShotsController:(DRShotsController *)shotsController;
- (BOOL)updateActionsProgressWithLikeProgress:(float)likeProgress followProgress:(float)followProgress allowAction:(BOOL) allowAction;

@end

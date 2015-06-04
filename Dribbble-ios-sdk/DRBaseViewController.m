//
//  DRBaseViewController.m
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 19.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRBaseViewController.h"

@interface DRBaseViewController ()

@end

@implementation DRBaseViewController

#pragma mark - Getters

- (DRApiService *)apiService {
    return [DRApiService instance];
}

- (DRActionManager *)actionManager {
    return [DRActionManager instance];
}

@end

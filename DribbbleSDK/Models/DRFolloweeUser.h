//
//  DRFolloweeUser.h
//  DribbbleRunner
//
//  Created by zgonik vova on 25.05.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRBaseModel.h"

@class DRUser;

@interface DRFolloweeUser : DRBaseModel

@property (nonatomic, strong) DRUser *followee;

@end

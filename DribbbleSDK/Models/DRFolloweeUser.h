//
//  DRFolloweeUser.h
//  
//
//  Created by zgonik vova on 25.05.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@class DRUser;

@interface DRFolloweeUser : JSONModel

@property (nonatomic, strong) DRUser *followee;

@end

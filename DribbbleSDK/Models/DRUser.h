//
//  DRUser.h
//  DribbbleRunner
//
//  Created by zgonik vova on 17.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "JSONModel.h"
#import "DRAuthority.h"

@class DRLink;

@interface DRUser : DRAuthority

@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSString <Optional>*teamsUrl;
@property (strong, nonatomic) NSNumber <Optional>*teamsCount;

@end

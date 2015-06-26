//
//  DRUser.h
//  
//
//  Created by zgonik vova on 17.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRAuthority.h"

@interface DRUser : DRAuthority

@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSString <Optional>*teamsUrl;
@property (strong, nonatomic) NSNumber <Optional>*teamsCount;

@end

//
//  DRTransactionModel.h
//  
//
//  Created by zgonik vova on 12.05.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "JSONModel.h"

@class DRUser, DRTeam, DRShot;

@interface DRTransactionModel : JSONModel

@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSNumber *transactionId;
@property (strong, nonatomic) DRUser <Optional>*follower;
@property (strong, nonatomic) DRUser <Optional>*followee;
@property (strong, nonatomic) DRUser <Optional>*user;
@property (strong, nonatomic) DRTeam <Optional>*team;
@property (strong, nonatomic) DRShot <Optional>*shot;

@end

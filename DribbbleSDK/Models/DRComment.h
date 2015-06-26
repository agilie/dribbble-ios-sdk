//
//  DRComment.h
//  DribbbleSDKDev
//
//  Created by zgonik vova on 23.06.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "JSONModel.h"

@class DRUser, DRTeam;

@interface DRComment : JSONModel

@property (strong, nonatomic) NSNumber *commentId;
@property (strong, nonatomic) NSNumber *likesCount;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *likesUrl;
@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSString *updatedAt;
@property (strong, nonatomic) DRUser <Optional> *user;
@property (strong, nonatomic) DRTeam <Optional> *team;

@end

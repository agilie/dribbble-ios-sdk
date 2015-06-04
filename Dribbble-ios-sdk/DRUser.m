//
//  DRUser.m
//  DribbbleRunner
//
//  Created by zgonik vova on 17.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRUser.h"

@implementation DRUser

#pragma mark - Dictionary Serialization

+ (instancetype)fromDictionary:(NSDictionary *)userDict {
    DRUser *userItem = [super fromDictionary:userDict];
    userItem.userId = [userDict obtainNumber:@"id"];
    return userItem;
}

@end

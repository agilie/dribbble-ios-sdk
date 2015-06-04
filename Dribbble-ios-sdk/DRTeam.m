//
//  DRTeam.m
//  DribbbleRunner
//
//  Created by zgonik vova on 17.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRTeam.h"

@implementation DRTeam

#pragma mark - Dictionary Serialization

+ (instancetype)fromDictionary:(NSDictionary *)teamDict {
    DRTeam *teamItem = [super fromDictionary:teamDict];
    teamItem.teamId = [teamDict obtainNumber:@"id"];
    return teamItem;
}

@end

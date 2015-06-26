//
//  DRTeam.m
//  
//
//  Created by zgonik vova on 17.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRTeam.h"
#import "DRCombinedJSONKeyMapper.h"

@implementation DRTeam

+ (JSONKeyMapper *)keyMapper {
    return [[DRCombinedJSONKeyMapper alloc] initWithDictionary:@{@"id" : @"teamId"}];
}

@end

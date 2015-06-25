//
//  DRUser.m
//  
//
//  Created by zgonik vova on 17.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRUser.h"
#import "DRCombinedJSONKeyMapper.h"

@implementation DRUser

+ (JSONKeyMapper *)keyMapper {
    return [[DRCombinedJSONKeyMapper alloc] initWithDictionary:@{@"id" : @"userId"}];
}

@end

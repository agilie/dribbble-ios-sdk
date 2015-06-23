//
//  DRComment.m
//  DribbbleSDKDev
//
//  Created by zgonik vova on 23.06.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRComment.h"
#import "DRCombinedJSONKeyMapper.h"

@implementation DRComment

+ (JSONKeyMapper *)keyMapper {
    return [[DRCombinedJSONKeyMapper alloc] initWithDictionary:@{@"id" : @"commentId"}];
}


@end

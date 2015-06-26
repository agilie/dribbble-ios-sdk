//
//  DRProject.m
//  
//
//  Created by zgonik vova on 23.06.15.
//
//

#import "DRProject.h"
#import "DRCombinedJSONKeyMapper.h"

@implementation DRProject

+ (JSONKeyMapper *)keyMapper {
    return [[DRCombinedJSONKeyMapper alloc] initWithDictionary:@{@"id"          : @"projectId",
                                                                 @"description" : @"projectDescription"}];
}

@end

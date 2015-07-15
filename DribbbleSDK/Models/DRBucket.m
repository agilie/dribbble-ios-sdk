//
//  DRBucket.m
//  Pods
//
//  Created by Vermillion on 15.07.15.
//
//

#import "DRBucket.h"
#import "DRCombinedJSONKeyMapper.h"

@implementation DRBucket

+ (JSONKeyMapper *)keyMapper {
    return [[DRCombinedJSONKeyMapper alloc] initWithDictionary:@{@"id" : @"bucketId",
                                                                 @"description" : @"bucketDescription"
                                                                 }];
}

@end

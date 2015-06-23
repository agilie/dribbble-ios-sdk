//
//  DRShotAttachment.m
//  
//
//  Created by zgonik vova on 23.06.15.
//
//

#import "DRShotAttachment.h"
#import "DRCombinedJSONKeyMapper.h"

@implementation DRShotAttachment

+ (JSONKeyMapper *)keyMapper {
    return [[DRCombinedJSONKeyMapper alloc] initWithDictionary:@{@"id" : @"attachmentId"}];
}

@end

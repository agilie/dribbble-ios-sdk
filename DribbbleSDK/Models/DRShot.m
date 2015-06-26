//
//  DRShot.m
//  
//
//  Created by zgonik vova on 17.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DribbbleSDK.h"
#import "DRCombinedJSONKeyMapper.h"

static NSString * const kFileExtensionGif = @"gif";

@implementation DRShot

#pragma mark - Key Mapping

+ (JSONKeyMapper *)keyMapper {
    return [[DRCombinedJSONKeyMapper alloc] initWithDictionary:@{@"id"                : @"shotId",
                                                       @"description"       : @"shotDescription",
                                                       @"rebound_source_url": @"rebound_source_url"
                                                       }];
}

#pragma mark - Helpers

- (NSNumber *)authorityId {
    return self.user ? self.user.userId : self.team.teamId;
}

- (NSString *)defaultUrl {
    return self.images.hidpi ?: self.images.normal;
}

- (NSString *)fileType {
    return [[self.defaultUrl pathExtension] lowercaseString];
}

- (BOOL)isAnimation {
    return [self.fileType isEqualToString:kFileExtensionGif];
}

#pragma mark - Override

- (BOOL)isEqual:(id)object {
    DRShot *shot = (DRShot*)object;
    return [shot.shotId isEqualToNumber:self.shotId];
}

- (NSUInteger)hash {
    return [[self.shotId stringValue] hash];
}


@end

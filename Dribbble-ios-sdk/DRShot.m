//
//  DRShot.m
//  DribbbleRunner
//
//  Created by zgonik vova on 17.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRShot.h"
#import "DRUser.h"
#import "DRTeam.h"

static NSString * const kFileExtensionGif = @"gif";

@implementation DRShot

#pragma mark - Dictionary Serialization

//+ (instancetype)fromDictionary:(NSDictionary *)shotDict {
//    DRShot *shotItem = [super fromDictionary:shotDict];
//    shotItem.shotId = [shotDict obtainNumber:@"id"];
//    shotItem.shotDescription = [shotDict obtainString:@"description"];
//    shotItem.user = (DRUser *)[DRUser fromDictionary:[shotDict obtainDictionary:@"user"]];
//    shotItem.team = (DRTeam *)[DRTeam fromDictionary:[shotDict obtainDictionary:@"team"]];
//    return shotItem;
//}

+ (NSArray *)transientProperties {
    return @[@"defaultUrl", @"fileType", @"db_shot_id", @"db_like_count", @"db_data", @"authorityId", @"isAuthorityFollowed", @"isLiked"];
}

#pragma mark - Helpers

- (NSNumber *)authorityId {
    if (!self.user.userId && !self.team.teamId) {
        NSLog(@"found shot with no authority, shot id: %@", self.shotId);
    }
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

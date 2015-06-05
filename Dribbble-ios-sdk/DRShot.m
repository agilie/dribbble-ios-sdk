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

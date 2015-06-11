//
//  DRShot.h
//  DribbbleRunner
//
//  Created by zgonik vova on 17.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRBaseModel.h"
#import "DRUser.h"
#import "DRTeam.h"
#import "DRImage.h"

@interface DRShot : JSONModel

@property (strong, nonatomic) NSNumber *shotId;
@property (strong, nonatomic) NSNumber *width;
@property (strong, nonatomic) NSNumber *height;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString <Optional>*shotDescription;
@property (strong, nonatomic) NSNumber *views_count;
@property (strong, nonatomic) NSNumber *likes_count;
@property (strong, nonatomic) NSNumber *comments_count;
@property (strong, nonatomic) NSNumber *attachments_count;
@property (strong, nonatomic) DRImage *images;
@property (strong, nonatomic) NSNumber *rebounds_count;
@property (strong, nonatomic) NSNumber *buckets_count;
@property (strong, nonatomic) NSString *created_at;
@property (strong, nonatomic) NSString *updated_at;
@property (strong, nonatomic) NSString <Optional> *rebound_source_url;
@property (strong, nonatomic) NSString <Optional>*html_url;
@property (strong, nonatomic) NSString <Optional>*attachments_url;
@property (strong, nonatomic) NSString <Optional>*buckets_url;
@property (strong, nonatomic) NSString <Optional>*comments_url;
@property (strong, nonatomic) NSString <Optional>*likes_url;
@property (strong, nonatomic) NSString <Optional>*projects_url;
@property (strong, nonatomic) NSString <Optional>*rebounds_url;
@property (strong, nonatomic) NSArray *tags;
@property (strong, nonatomic) DRUser <Optional> *user;
@property (strong, nonatomic) DRTeam <Optional> *team;

// helper properties

@property (nonatomic, readonly) NSString <Ignore> *defaultUrl;
@property (nonatomic, copy) NSString <Ignore> *fileType;
@property (nonatomic, readonly) NSNumber <Ignore> *authorityId;

- (BOOL)isAnimation;

@end

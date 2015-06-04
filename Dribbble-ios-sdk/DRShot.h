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

@interface DRShot : DRBaseModel

@property (strong, nonatomic) NSNumber *shotId;
@property (strong, nonatomic) NSNumber *width;
@property (strong, nonatomic) NSNumber *height;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *shotDescription;
@property (strong, nonatomic) NSNumber *views_count;
@property (strong, nonatomic) NSNumber *likes_count;
@property (strong, nonatomic) NSNumber *comments_count;
@property (strong, nonatomic) NSNumber *attachments_count;
@property (strong, nonatomic) DRImage *images;
@property (strong, nonatomic) NSNumber *rebounds_count;
@property (strong, nonatomic) NSNumber *buckets_count;
@property (strong, nonatomic) NSDate *created_at;
@property (strong, nonatomic) NSDate *updated_at;
@property (strong, nonatomic) NSString *rebound_source_url;
@property (strong, nonatomic) NSString *html_url;
@property (strong, nonatomic) NSString *attachments_url;
@property (strong, nonatomic) NSString *buckets_url;
@property (strong, nonatomic) NSString *comments_url;
@property (strong, nonatomic) NSString *likes_url;
@property (strong, nonatomic) NSString *projects_url;
@property (strong, nonatomic) NSString *rebounds_url;
@property (strong, nonatomic) NSArray *tags;
@property (strong, nonatomic) DRUser *user;
@property (strong, nonatomic) DRTeam *team;

// internal server data

@property (strong, nonatomic) NSString *db_shot_id;
@property (strong, nonatomic) NSNumber *db_like_count;
@property (strong, nonatomic) NSDictionary *db_data;

// helper properties

@property (nonatomic, readonly) NSString *defaultUrl;
@property (nonatomic) NSString *fileType;
@property (nonatomic, readonly) NSNumber *authorityId;

@property (nonatomic, readonly) BOOL isLiked;
@property (nonatomic, readonly) BOOL isAuthorityFollowed;

- (BOOL)isAnimation;

+ (DRShot *)makeStub;
- (BOOL)isStub;

@end

//
//  DRUser.h
//  DribbbleRunner
//
//  Created by zgonik vova on 17.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRBaseModel.h"
#import "DRLink.h"

@interface DRUser : JSONModel

@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *html_url;
@property (strong, nonatomic) NSString *avatar_url;
@property (strong, nonatomic) NSString *bio;
@property (strong, nonatomic) NSString <Optional>*location;
@property (strong, nonatomic) DRLink *links;
@property (strong, nonatomic) NSString <Optional>*buckets_url;
@property (strong, nonatomic) NSString <Optional>*followers_url;
@property (strong, nonatomic) NSString <Optional>*following_url;
@property (strong, nonatomic) NSString <Optional>*likes_url;
@property (strong, nonatomic) NSString <Optional>*shots_url;
@property (strong, nonatomic) NSString <Optional>*team_shots_url;
@property (strong, nonatomic) NSString <Optional>*teams_url;
@property (strong, nonatomic) NSString <Optional>*members_url;
@property (strong, nonatomic) NSString <Optional>*projects_url;
@property (strong, nonatomic) NSString *created_at;
@property (strong, nonatomic) NSString *updated_at;
@property (strong, nonatomic) NSNumber <Optional>*members_count;
@property (strong, nonatomic) NSNumber *buckets_count;
@property (strong, nonatomic) NSNumber *comments_received_count;
@property (strong, nonatomic) NSNumber *followers_count;
@property (strong, nonatomic) NSNumber *followings_count;
@property (strong, nonatomic) NSNumber *likes_count;
@property (strong, nonatomic) NSNumber *likes_received_count;
@property (strong, nonatomic) NSNumber *projects_count;
@property (strong, nonatomic) NSNumber *rebounds_received_count;
@property (strong, nonatomic) NSNumber *shots_count;
@property (strong, nonatomic) NSNumber <Optional>*teams_count;
@property (strong, nonatomic) NSString *type;
@property (assign, nonatomic) BOOL can_upload_shot;
@property (assign, nonatomic) BOOL pro;

@end

//
//  DRTeam.h
//  DribbbleRunner
//
//  Created by zgonik vova on 17.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRBaseModel.h"

@interface DRTeam : DRBaseModel <DRDictionarySerializationProtocol>

@property (strong, nonatomic) NSNumber *teamId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *html_url;
@property (strong, nonatomic) NSString *avatar_url;
@property (strong, nonatomic) NSString *followers_url;
@property (strong, nonatomic) NSString *shots_url;
@property (strong, nonatomic) NSString *team_shots_url;
@property (strong, nonatomic) NSString *following_url;
@property (strong, nonatomic) NSString *projects_url;
@property (strong, nonatomic) NSString *members_url;
@property (strong, nonatomic) NSString *buckets_url;
@property (strong, nonatomic) NSString *likes_url;
@property (strong, nonatomic) NSString *bio;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) DRLink *links;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSNumber *buckets_count;
@property (strong, nonatomic) NSNumber *comments_received_count;
@property (strong, nonatomic) NSNumber *followers_count;
@property (strong, nonatomic) NSNumber *followings_count;
@property (strong, nonatomic) NSNumber *likes_count;
@property (strong, nonatomic) NSNumber *likes_received_count;
@property (strong, nonatomic) NSNumber *members_count;
@property (strong, nonatomic) NSNumber *projects_count;
@property (strong, nonatomic) NSNumber *rebounds_received_count;
@property (strong, nonatomic) NSNumber *shots_count;
@property (strong, nonatomic) NSDate *created_at;
@property (strong, nonatomic) NSDate *updated_at;
@property (assign, nonatomic) BOOL can_upload_shot;
@property (assign, nonatomic) BOOL pro;

@end

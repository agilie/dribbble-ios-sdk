//
//  DRUser.h
//  DribbbleRunner
//
//  Created by zgonik vova on 17.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "JSONModel.h"

@class DRLink;

@interface DRUser : JSONModel

@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *htmlUrl;
@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) NSString *bio;
@property (strong, nonatomic) NSString <Optional>*location;
@property (strong, nonatomic) DRLink *links;
@property (strong, nonatomic) NSString <Optional>*bucketsUrl;
@property (strong, nonatomic) NSString <Optional>*followersUrl;
@property (strong, nonatomic) NSString <Optional>*followingUrl;
@property (strong, nonatomic) NSString <Optional>*likesUrl;
@property (strong, nonatomic) NSString <Optional>*shotsUrl;
@property (strong, nonatomic) NSString <Optional>*team_shotsUrl;
@property (strong, nonatomic) NSString <Optional>*teamsUrl;
@property (strong, nonatomic) NSString <Optional>*membersUrl;
@property (strong, nonatomic) NSString <Optional>*projectsUrl;
@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSString *updatedAt;
@property (strong, nonatomic) NSNumber <Optional>*membersCount;
@property (strong, nonatomic) NSNumber *bucketsCount;
@property (strong, nonatomic) NSNumber *commentsReceivedCount;
@property (strong, nonatomic) NSNumber *followersCount;
@property (strong, nonatomic) NSNumber *followingsCount;
@property (strong, nonatomic) NSNumber *likesCount;
@property (strong, nonatomic) NSNumber *likesReceivedCount;
@property (strong, nonatomic) NSNumber *projectsCount;
@property (strong, nonatomic) NSNumber *reboundsReceivedCount;
@property (strong, nonatomic) NSNumber *shotsCount;
@property (strong, nonatomic) NSNumber <Optional>*teamsCount;
@property (strong, nonatomic) NSString *type;
@property (assign, nonatomic) BOOL canUploadShot;
@property (assign, nonatomic) BOOL pro;

@end

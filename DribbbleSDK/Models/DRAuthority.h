//
//  DRAuthority.h
//  
//
//  Created by zgonik vova on 22.06.15.
//
//

#import "JSONModel.h"

@class DRLink;

@interface DRAuthority : JSONModel

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) NSString *htmlUrl;
@property (strong, nonatomic) NSString <Optional>*location;
@property (strong, nonatomic) NSString <Optional>*bio;
@property (strong, nonatomic) NSString <Optional>*followersUrl;
@property (strong, nonatomic) DRLink *links;
@property (strong, nonatomic) NSNumber <Optional>*membersCount;
@property (strong, nonatomic) NSString <Optional>*shotsUrl;
@property (strong, nonatomic) NSString <Optional>*teamShotsUrl;
@property (strong, nonatomic) NSString <Optional>*membersUrl;
@property (strong, nonatomic) NSString <Optional>*projectsUrl;
@property (strong, nonatomic) NSString <Optional>*bucketsUrl;
@property (strong, nonatomic) NSString <Optional>*followingUrl;
@property (strong, nonatomic) NSString <Optional>*likesUrl;
@property (strong, nonatomic) NSNumber *followersCount;
@property (strong, nonatomic) NSNumber *followingsCount;
@property (strong, nonatomic) NSNumber *likesCount;
@property (strong, nonatomic) NSNumber *projectsCount;
@property (strong, nonatomic) NSNumber *bucketsCount;
@property (strong, nonatomic) NSNumber *commentsReceivedCount;
@property (strong, nonatomic) NSNumber *likesReceivedCount;
@property (strong, nonatomic) NSNumber *reboundsReceivedCount;
@property (strong, nonatomic) NSNumber *shotsCount;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSString *updatedAt;
@property (assign, nonatomic) BOOL canUploadShot;
@property (assign, nonatomic) BOOL pro;

@end

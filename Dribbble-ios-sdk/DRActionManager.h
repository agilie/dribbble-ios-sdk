//
//  DRActionManager.h
//  DribbbleRunner
//
//  Created by Ankudinov Alexander on 4/6/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRBaseModel.h"
#import "DRInternalUser.h"

@protocol DRProfileUpdateDelegate <NSObject>

@optional

- (void)didUpdateUser;
- (void)didUpdateCoins;
- (void)didUpdateIsPromote;
- (void)didUpdateUserShotsOnCount:(NSInteger)count;

@end

@interface DRActionManager : NSObject

@property (strong, nonatomic) DRInternalUser *internalUser;
@property (strong, nonatomic) NSNumber *coins;
@property (strong, nonatomic) NSMutableArray *userShots;

+ (instancetype)instance;

- (void)addProfileUpdateDelegate:(id<DRProfileUpdateDelegate>)delegate;
- (void)removeProfileUpdateDelegate:(id<DRProfileUpdateDelegate>)delegate;

- (BOOL)checkLocalLikedShots:(NSNumber *)shotId;
- (void)addLocalLikedShotId:(NSNumber *)shotId;
- (void)removeLocalLikedShotId:(NSNumber *)shotId;

- (BOOL)checkLocalFollowed:(NSNumber *)authorityId;
- (void)addLocalFollowed:(NSNumber *)authorityId;
- (void)removeLocalFollowed:(NSNumber *)authorityId;

- (void)fetchUserData;
- (void)fetchAndSyncUserShotsWithCompletion:(DRCompletionHandler)completionHandlers;
- (void)updateUserPromoteValue:(NSNumber *)value;
- (void)logout;

- (void)fetchCoinsInBackGroundWithCompletion:(DRCompletionHandler)completionHandler;
- (void)fetchNewFolloweesShotsWithCompletion:(DRCompletionHandler)completion;

@end

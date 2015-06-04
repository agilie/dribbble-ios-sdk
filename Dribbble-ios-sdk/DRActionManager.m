//
//  DRActionManager.m
//  DribbbleRunner
//
//  Created by Ankudinov Alexander on 4/6/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRActionManager.h"
#import "DRApiService.h"
#import "DRInternalApiClient.h"
#import "WeakReference.h"
#import "DRFolloweeUser.h"
#import "NXOAuth2.h"
#import "HKRLocalNotificationManager.h"

static NSString * const kFolloweeDictUserId = @"userId";
static NSString * const kFolloweeDictShotsCount = @"shotsCount";

@interface DRActionManager()

@property (strong, nonatomic) NSMutableArray *localLikedShotsArray;
@property (strong, nonatomic) NSMutableArray *localFollowingArray;

@property (nonatomic, readonly) NSUserDefaults *standardDefaults;
@property (nonatomic, readonly) NSUserDefaults *userDefaults;

@property (nonatomic, strong) NSMutableSet *profileUpdateDelegates;

@property (nonatomic, readonly) NSString *currentUserDefaultsKey;

@end

@implementation DRActionManager

#pragma mark - Calendar

+ (NSCalendar *)currentCalendar {
    static NSCalendar *sharedCalendar = nil;
    if (!sharedCalendar)
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    return sharedCalendar;
}

#pragma mark - Init

+ (instancetype)instance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType: kIDMOAccountType] lastObject];
        if (account) {
            DRApiService *apiService = [DRApiService instance];
            NSLog(@"We have token in Action Manager:%@", account.accessToken.accessToken);
            [apiService setupAccessToken:account.accessToken.accessToken];
            [self fetchUserData];
        }
        NSDictionary *userDict = [self.standardDefaults objectForKey:kDribbbleUserKey];
        if (userDict) {
            _internalUser = [DRInternalUser fromDictionary:userDict];
            self.coins = [self.userDefaults objectForKey:kUserBallanceKey];
        }
    }
    return self;
}

#pragma mark - Getters

- (DRInternalUser *)_internalUser {
    if (!_internalUser) {
        _internalUser = [DRInternalUser new];
    }
    return _internalUser;
}

- (NSUserDefaults *)userDefaults {
    if (self.internalUser.user.userId) {
        return [[NSUserDefaults alloc] initWithSuiteName:self.currentUserDefaultsKey];
    }
    return nil;
}

- (NSMutableArray *)userShots {
    if (!_userShots) _userShots = [NSMutableArray array];
    return _userShots;
}

- (NSUserDefaults *)standardDefaults {
    return [NSUserDefaults standardUserDefaults];
}

- (NSString *)currentUserDefaultsKey {
    return [self.internalUser.user.userId stringValue];
}

- (NSMutableArray *)localLikedShotsArray {
    if (!_localLikedShotsArray) {
        _localLikedShotsArray = [NSMutableArray array];
        NSArray *likedShots = [self.userDefaults objectForKey:kUserLikedShotsArrayKey];
        if (likedShots) {
            [_localLikedShotsArray addObjectsFromArray:likedShots];
        }
    }
    return _localLikedShotsArray;
}

- (NSMutableArray *)localFollowingArray {
    if (!_localFollowingArray) {
        _localFollowingArray = [NSMutableArray array];
        NSArray *followedShots = [self.userDefaults objectForKey:kUserFollowedShotsAuthorityArrayKey];
        if (followedShots) {
            [_localFollowingArray addObjectsFromArray:followedShots];
        }
    }
    return _localFollowingArray;
}

#pragma mark - Setters

- (void)setCoins:(NSNumber *)coins {
    if (![_coins isEqualToNumber:coins]) {
        NSLog(@">>> setCoins: %@ => %@;  main thread? %d", _coins, coins, [NSThread isMainThread]);
        _coins = coins;
        [self.userDefaults setObject:_coins forKey:kUserBallanceKey];
        [self.userDefaults synchronize];
        [self postUpdateCoins];
    }
}

- (void)setInternalUser:(DRInternalUser *)internalUser {
    NSNumber *existingPromoteValue = _internalUser.isPromote;
    _internalUser = internalUser;
    [self postUpdateUser];
    if (!_internalUser.isPromote) {
        _internalUser.isPromote = existingPromoteValue;
    } else {
        [self postUpdateIsPromote];
    }

    if (internalUser) {
        [self.standardDefaults setObject:[internalUser toDictionary] forKey:kDribbbleUserKey];
    } else {
        [self.standardDefaults removeObjectForKey:kDribbbleUserKey];
        [self.localFollowingArray removeAllObjects];
        [self.localLikedShotsArray removeAllObjects];
        self.coins = @(0);
    }
    [self.standardDefaults synchronize];
}

#pragma mark - Local Likes

- (void)storeLikes {
    [self.userDefaults setObject:self.localLikedShotsArray forKey:kUserLikedShotsArrayKey];
    [self.userDefaults synchronize];
}

- (void)storeFollows {
    [self.userDefaults setObject:self.localFollowingArray forKey:kUserFollowedShotsAuthorityArrayKey];
    [self.userDefaults synchronize];
}

- (void)addLocalLikedShotId:(NSNumber *)shotId {
    if (![self checkLocalLikedShots:shotId]) {
        [self.localLikedShotsArray addObject:shotId];
        [self storeLikes];
    }
}

- (void)removeLocalLikedShotId:(NSNumber *)shotId {
    if ([self checkLocalLikedShots:shotId]) {
        [self.localLikedShotsArray removeObject:shotId];
        [self storeLikes];
    }
}

- (BOOL)checkLocalLikedShots:(NSNumber *)shotId {
    return [self.localLikedShotsArray containsObject:shotId];
}

#pragma mark - Local Follows

- (void)addLocalFollowed:(NSNumber *)authorityId {
    if (![self.localFollowingArray containsObject:authorityId]) {
        [self.localFollowingArray addObject:authorityId];
        [self storeFollows];
    }
}

- (void)removeLocalFollowed:(NSNumber *)authorityId {
    if ([self.localFollowingArray containsObject:authorityId]) {
        [self.localFollowingArray removeObject:authorityId];
        [self storeFollows];
    }
}

- (BOOL)checkLocalFollowed:(NSNumber *)authorityId {
    return [self.localFollowingArray containsObject:authorityId];
}

#pragma mark - Load all user data

- (DRErrorHandler)defaultErrorHandler {
    return ^(id data) {
        [SVProgressHUD dismiss];
    };
}

- (void)fetchUserData {
    DRApiService *apiService = [DRApiService instance];
    __weak typeof(self) weakSelf = self;
    [apiService loadUserInfoWithCompletionHandler:^(DRBaseModel *data) {
        if (!data.error) {
//            weakSelf.user = (DRUser *)data.object;
            
            // post user info to internal server
            [apiService postUserInfo:[weakSelf.internalUser.user toDictionary] withCompletionHandler:^(DRBaseModel *data) {
                [weakSelf updateUserPromoteValue:[(DRInternalUser *)data.object isPromote]];
            } failureHandler:nil];
            
            // request coins from internal server
            [apiService loadUserBalanceWithCompletionHandler:^(DRBaseModel *data) {
                if (!data.error) weakSelf.coins = [data.object coins];
            } failureHandler:nil];
        }
    } failureHandler:[self defaultErrorHandler] shouldShowProgressHUD:NO];
}

- (void)fetchAndSyncUserShotsWithCompletion:(DRCompletionHandler)completionHandler {
    __weak typeof(self) weakSelf = self;
    [self.userShots removeAllObjects];
    [self loadUserShotsPage:1 finishedHandler:^(id data) {
        NSMutableArray *shotsArray = [NSMutableArray array];
        NSDictionary *userDict = [weakSelf.internalUser.user toDictionary];
        [weakSelf.userShots enumerateObjectsUsingBlock:^(DRShot *obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *shotDict = [obj toDictionary];
            if (userDict.allKeys.count > 0) {
                [shotDict addEntriesFromDictionary:@{@"user": userDict}];
            }
            [shotsArray addObject:shotDict];
        }];
        [[DRApiService instance] syncShots:shotsArray completionHandler:^(DRBaseModel *data) {
            
#warning TODO handle error!
            
            NSLog(@"all shots are synced");
            if (completionHandler) completionHandler(data);
        } failureHandler:^(DRBaseModel *data) {
            if (completionHandler) completionHandler(data);
        }];
    }];
}

- (void)loadUserShotsPage:(NSInteger)page finishedHandler:(DRCompletionHandler)finishedHandler {
    __weak typeof(self) weakSelf = self;
    if (![self.internalUser.user.shots_count intValue]) {
        finishedHandler(nil);
    } else {
        [[DRApiService instance] loadUserShots:self.internalUser.user.shots_url params:@{ @"page":@(page), @"per_page":@(100) } completionHandler:^(DRBaseModel *data) {
            if (!data.error && [data.object isKindOfClass:[NSArray class]]) {
                [weakSelf.userShots addObjectsFromArray:data.object];
                NSInteger count = [data.object count];
                if ([weakSelf.internalUser.user.shots_count integerValue] == [self.userShots count]) {
                    finishedHandler(nil);
                    [weakSelf postUserShotsUpdateFinished:YES count:count];
                } else {
                    [weakSelf postUserShotsUpdateFinished:NO count:count];
                    [weakSelf loadUserShotsPage:page + 1 finishedHandler:finishedHandler];
                }
            } else {
                finishedHandler(data.error);
            }
        } failureHandler:^(DRBaseModel *data) {
            finishedHandler(data.error);
        }];
    }
}

- (void)updateUserPromoteValue:(NSNumber *)value {
    if (value) {
        self.internalUser.isPromote = value;
        [self postUpdateIsPromote];
    }
}

#pragma mark - ProfileUpdateDelegate

- (NSMutableSet *)profileUpdateDelegates {
    if (!_profileUpdateDelegates) _profileUpdateDelegates = [NSMutableSet set];
    return _profileUpdateDelegates;
}

- (void)addProfileUpdateDelegate:(id<DRProfileUpdateDelegate>)delegate {
    [self.profileUpdateDelegates addObject:[WeakReference weakReferenceWithObject:delegate]];
}

- (void)removeProfileUpdateDelegate:(id<DRProfileUpdateDelegate>)delegate {
    for (int index = 0; index < [self.profileUpdateDelegates count]; index++) {
        WeakReference *weakRef = [self.profileUpdateDelegates allObjects][index];
        id<DRProfileUpdateDelegate> weakDelegate = [weakRef nonretainedObjectValue];
        if (weakDelegate && weakDelegate == delegate) {
            [self.profileUpdateDelegates removeObject:weakRef];
            break;
        }
    }
}

#warning TODO refactor copy/paste avoiding leak on selector

- (void)postUpdateUser {
    for (WeakReference *weakRef in self.profileUpdateDelegates) {
        id<DRProfileUpdateDelegate> weakDelegate = [weakRef nonretainedObjectValue];
        if (weakDelegate && [weakDelegate respondsToSelector:@selector(didUpdateUser)]) {
            [weakDelegate didUpdateUser];
        }
    }
}

- (void)postUpdateCoins {
    for (WeakReference *weakRef in self.profileUpdateDelegates) {
        id<DRProfileUpdateDelegate> weakDelegate = [weakRef nonretainedObjectValue];
        if (weakDelegate && [weakDelegate respondsToSelector:@selector(didUpdateCoins)]) {
            [weakDelegate didUpdateCoins];
        }
    }
}

- (void)postUpdateIsPromote {
    for (WeakReference *weakRef in self.profileUpdateDelegates) {
        id<DRProfileUpdateDelegate> weakDelegate = [weakRef nonretainedObjectValue];
        if (weakDelegate && [weakDelegate respondsToSelector:@selector(didUpdateIsPromote)]) {
            [weakDelegate didUpdateIsPromote];
        }
    }
}

- (void)postUserShotsUpdateFinished:(BOOL)isFinished count:(NSInteger)count {
    for (WeakReference *weakRef in self.profileUpdateDelegates) {
        id<DRProfileUpdateDelegate> weakDelegate = [weakRef nonretainedObjectValue];
        if (weakDelegate && [weakDelegate respondsToSelector:@selector(didUpdateUserShotsOnCount:)]) {
            [weakDelegate didUpdateUserShotsOnCount:count];
        }
    }
}

#pragma mark - Logout

- (void)logout {
    [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:kIDMOAccountType] enumerateObjectsUsingBlock:^(NXOAuth2Account * obj, NSUInteger idx, BOOL *stop) {
        [[NXOAuth2AccountStore sharedStore] removeAccount:obj];
    }];
    [[DRApiService instance] resetAccessToken];
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [self setInternalUser:nil];
}

#pragma mark - Background Ballance Fetch

- (void)fetchCoinsInBackGroundWithCompletion:(DRCompletionHandler)completionHandler {
    [[DRApiService instance] loadUserBalanceWithCompletionHandler:^(DRBaseModel *data) {
        if (!data.error) {
            if ([[data.object coins] intValue] == 0) {
                completionHandler(@YES);
            }
        }
        completionHandler(@NO);
    } failureHandler:^(DRBaseModel *data) {
        completionHandler(@NO);
    }];
}

- (void)fetchNewFolloweesShotsWithCompletion:(DRCompletionHandler)completion {
    [[DRApiService instance] loadFolloweesShotsWithCompletionHandler:^(DRBaseModel *data) {
        if ([data.error code] == kHttpContentNotModifiedCode) {
            completion(@NO);
        } else {
            data.object ? completion(@YES):completion(@NO);
        }
    } failureHandler:^(id data) {
        completion(@NO);
    }];
}

@end

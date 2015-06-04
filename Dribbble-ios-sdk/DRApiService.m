 //
//  DRApiService.m
//  DribbbleRunner
//
//  Created by Ankudinov Alexander on 3/17/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRApiService.h"
#import "DRShot.h"
#import "DRApiClient.h"
#import "DRInternalApiClient.h"
#import <CommonCrypto/CommonDigest.h>

static NSString * kDribbbleApiServiceLogTag = @"[API Service] ";
static int kAccount = 597558;

static NSString * const kDefaultsKeyAnalyticsIdentifier = @"me.agile.ninja.shotbucket.analytics_identifier";

NSString * md5(NSString *string) {
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@interface DRApiService()

@property (assign, nonatomic) AFNetworkReachabilityStatus statusReachability;
@property (strong, nonatomic) DRApiClient *client;
@property (strong, nonatomic) DRInternalApiClient *internalClient;
@property (assign, nonatomic) NSUInteger runningRequestsCount;
@property (strong, nonatomic) NSDictionary *pathsRequireProgressHUD;
@property (strong, nonatomic) NSArray *lastLoadedShots;
@property (copy, nonatomic) DRHandler presentLimitControllerBlock;
@property (copy, nonatomic) DRHandler presentAuthControllerBlock;

- (void)loadFeaturedShotsAtPage:(NSNumber *)page shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;

@end

@implementation DRApiService

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
        __weak typeof(self)weakSelf = self;
        
        self.client.operationStartHandler = ^(NSURLSessionDataTask *operation) {
            weakSelf.runningRequestsCount++;
        };
        self.client.operationEndHandler = ^(NSURLSessionDataTask *operation) {
            weakSelf.runningRequestsCount--;
        };
        self.client.clientErrorHandler = ^(NSError *error, NSString *method, BOOL showAlert) {
            [weakSelf handleError:error forMethod:method withAlert:showAlert];
        };
        
        self.internalClient.operationStartHandler = ^(NSURLSessionDataTask *operation) {
            weakSelf.runningRequestsCount++;
        };
        self.internalClient.operationEndHandler = ^(NSURLSessionDataTask *operation) {
            weakSelf.runningRequestsCount--;
        };
        self.internalClient.clientErrorHandler = ^(NSError *error, NSString *method, BOOL showAlert) {
            [weakSelf handleError:error forMethod:method withAlert:showAlert];
        };
        
        self.client.progressHUDShowBlock = _progressHUDShowBlock;
        self.client.progressHUDDismissBlock = _progressHUDDismissBlock;
    }
    return self;
}

#pragma mark - Analytics Identifier

- (NSString *)identifierForAnalytics {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults stringForKey:kDefaultsKeyAnalyticsIdentifier];
    if (!value) {
        NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSString *time = [NSString stringWithFormat:@"%.3f", [[NSDate date] timeIntervalSince1970]];
        
        value = md5([udid stringByAppendingString:time]);
        
        [defaults setObject:value forKey:kDefaultsKeyAnalyticsIdentifier];
        [defaults synchronize];
    }
    NSLog(@"MD5 uuid: %@", value);
    return value;
}

#pragma mark -  Blocks Setup

- (void)setupOAuthDismissWebViewBlock:(DRHandler)dismissWebViewBlock {
    [self.client setupOAuthDismissWebViewBlock:dismissWebViewBlock];
}

- (void)setupCleanBadCredentialsBlock:(DRHandler)cleanBadCredentialsBlock {
    [self.client setupCleanBadCredentialsBlock:cleanBadCredentialsBlock];
}

- (void)setupLimitControllerBlock:(DRHandler)presentLimitControllerBlock {
    self.presentLimitControllerBlock = presentLimitControllerBlock;
}

- (void)setupAuthControllerBlock:(DRHandler)presentAuthControllerBlock {
    self.presentAuthControllerBlock = presentAuthControllerBlock;
}

#pragma mark - Storyboard

- (UIStoryboard *)storyBoard {
    return [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

#pragma mark - Setup

- (void)setupAccessToken:(NSString *)token {
    [self.internalClient setAccessToken:token];
    [self.client setAccessToken:token];
}

- (void)resetAccessToken {
    [self.internalClient resetAccessToken];
    [self.client resetAccessToken];
}

#pragma mark - Getters

- (DRApiClient *)client {
    if (!_client) {
        _client = [[DRApiClient alloc] initWithOAuthClientAccessSecret:kIDMOAuth2ClientAccessSecret];
        [_client setupDefaultSettings];
        
        _client.requestLimitStateChangedHandler = [self requestLimitHandler];
        _client.autoRetryCount = 3;
    }
    return _client;
}

- (DRInternalApiClient *)internalClient {
    if (!_internalClient) {
        _internalClient = [[DRInternalApiClient alloc] initWithBaseUrl:kBaseServerUrl];
        [_internalClient setupDefaultSettings];
    }
    return _internalClient;
}

#pragma mark - Auth

- (BOOL)isUserAuthorized {
    return [self.client isUserAuthorized];
}

- (void)pullCheckSumWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.client pullCheckSumWithCompletionHandler:completionHandler failureHandler:errorHandler];
}

- (void)requestOAuth2Login:(UIWebView *)webView completionHandler:(DRCompletionHandler)completion failureHandler:(DRErrorHandler)errorHandler {
    __weak typeof(self)weakSelf = self;
    [self.client requestOAuth2Login:webView completionHandler:^(DRBaseModel *data) {
        NXOAuth2Account *account = data.object;
        if (account.accessToken.accessToken.length) {
            [weakSelf setupAccessToken:account.accessToken.accessToken];
            [weakSelf.client applyAccount:account withApiClient:weakSelf.client completionHandler:^(DRBaseModel *data) {
                NSLog(@"applyat success! %@", data.object);
                if ([data.object isKindOfClass:[NSDictionary class]]) {
                    [DRActionManager instance].coins = [[(NSDictionary *)data.object objectForKey:@"result"] objectForKey:@"coins"];
                }
                DRBaseModel *model = [DRBaseModel new];
                model.error = data.error;
                model.object = account.accessToken.accessToken;
                if (!data.error) {
                    if (completion) completion(model);
                } else {
                    UIAlertView *tryAgainAlert = [UIAlertView alertWithMessage:@"You are not authorized" andTitle:@"Retry"];
                    [tryAgainAlert bk_setCancelButtonWithTitle:@"Try again" handler:^{
                        [weakSelf.client applyAccount:account withApiClient:weakSelf.client completionHandler:completion failureHandler:errorHandler];
                    }];
                    [tryAgainAlert show];
                }
                [[DRActionManager instance] fetchUserData];
            } failureHandler:^(DRBaseModel *data) {
                if (errorHandler) errorHandler(data);
            }];
        }
    } failureHandler:^(DRBaseModel *data) {
        
    }];
}

#pragma mark - Profile

- (void)loadUserInfoWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler shouldShowProgressHUD:(BOOL)showHUD {
    [self.client loadUserInfoWithCompletionHandler:^(DRBaseModel *data) {
        DRUser *dribbbleUser = data.object;
        DRActionManager *manager = [DRActionManager instance];
        if ([dribbbleUser.userId integerValue] != [manager.internalUser.user.userId integerValue] && [self.lastLoadedShots count]) {
            [[DRApiService instance] loadLikesAndFollowsForShots:self.lastLoadedShots];
            self.lastLoadedShots = nil;
        }
        manager.internalUser = [DRInternalUser user:dribbbleUser];
        if (completionHandler) completionHandler(data);
    } failureHandler:errorHandler];
}

- (void)loadUserFollowees:(NSNumber *)userId page:(NSNumber *)page perPage:(NSNumber *)perPage completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.client loadUserFollowees:userId params:@{ @"page":page, @"per_page":perPage } withCompletionHandler:completionHandler failureHandler:errorHandler];
}

- (void)loadFolloweesShotsWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.client loadFolloweesShotsWithParams:@{@"per_page":@1} withCompletionHandler:completionHandler failureHandler:errorHandler];
}

- (void)loadUserShots:(NSString *)url params:(NSDictionary *)params completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.client loadUserShots:url params:params completionHandler:^(DRBaseModel *data) {       
        if (![data.object isKindOfClass:[NSArray class]]) data.object = @[];
        if (completionHandler) {
          completionHandler(data);
        }
    } failureHandler:^(DRBaseModel *data) {
        if (errorHandler) {
            errorHandler(data);
        }
    }];
}

- (void)postUserInfo:(NSDictionary *)userDict withCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.internalClient postUserInfo:userDict withCompletionHandler:completionHandler failureHandler:errorHandler];
}

- (void)loadUserBalanceWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.internalClient loadUserBalanceWithCompletionHandler:completionHandler failureHandler:errorHandler];
}

#pragma mark - Shots

- (void)syncShots:(NSArray *)shots completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.internalClient syncShots:shots completionHandler:completionHandler failureHandler:errorHandler];
}

#pragma mark - Promotion

- (void)promoteShots:(NSArray *)shots completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.internalClient promoteShots:shots completionHandler:^(DRBaseModel *data) {
        
        if (!data.error) [[DRActionManager instance] updateUserPromoteValue:@YES];
        
        if (completionHandler) completionHandler(data);
    
    } failureHandler:^(DRBaseModel *data) {
        if (errorHandler) {
            errorHandler(data);
        }
    }];
}

- (void)stopPromoteShotsCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.internalClient stopPromoteShotsCompletionHandler:^(DRBaseModel *data) {
        
        if (!data.error) [[DRActionManager instance] updateUserPromoteValue:@NO];
        
        if (completionHandler) completionHandler(data);
    
    } failureHandler:^(DRBaseModel *data) {
        if (errorHandler) {
            errorHandler(data);
        }
    }];
}

#pragma mark - TODO refactor: make category object-typed

- (void)loadShotsFromCategory:(NSString *)category atPage:(int)page shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    if (showHUD) {
        if (self.progressHUDShowBlock) {
            self.progressHUDShowBlock();
        }
    }
    __weak typeof(self) weakSelf = self;
    if ([category isEqualToString:kFeaturedCategoryValue]) {
        [self loadFeaturedShotsAtPage:@(page) shouldShowProgressHUD:showHUD completionHandler:^(DRBaseModel *data) {
            if (weakSelf.progressHUDDismissBlock) {
                weakSelf.progressHUDDismissBlock();
            }
            if (!data.error) {
                NSInteger fullCount = [[data.object full_count] integerValue];
                if (fullCount == 0) {
                    [self loadShotsFromCategory:kRecentCategoryTitle atPage:page shouldShowProgressHUD:showHUD completionHandler:^(DRBaseModel *data) {
                        if (weakSelf.progressHUDDismissBlock) {
                            weakSelf.progressHUDDismissBlock();
                        }
                        if (!data.error) {
                            completionHandler(data);
                        }
                    } failureHandler:nil];
                } else {
                    completionHandler(data);
                }
            } else if (data.error.code == kHttpAuthErrorCode) {
                [self loadShotsFromCategory:kRecentCategoryTitle atPage:page shouldShowProgressHUD:showHUD completionHandler:^(DRBaseModel *data) {
                    if (weakSelf.progressHUDDismissBlock) {
                        weakSelf.progressHUDDismissBlock();
                    }
                    if (!data.error) {
                        completionHandler(data);
                    }
                } failureHandler:nil];
            }
        } failureHandler:errorHandler];
    } else {
        [self.client loadShotsFromCategory:category atPage:page completionHandler:^(DRBaseModel *data) {
            if (![data.object isKindOfClass:[NSArray class]]) data.object = @[];
            if (weakSelf.progressHUDDismissBlock) {
                weakSelf.progressHUDDismissBlock();
            }
            completionHandler(data);
            NSLog(@"loaded %lu shots", (unsigned long)[data.object count]);
            if ([weakSelf.client isUserAuthorized]) {
                [weakSelf loadLikesAndFollowsForShots:data.object];
            } else {
                weakSelf.lastLoadedShots = data.object;
            }
        } failureHandler:errorHandler];
    }
}

- (void)loadLikesAndFollowsForShots:(NSArray *)shots {
    NSMutableSet *checkedShots = [NSMutableSet set];
    NSMutableSet *checkedAuthorities = [NSMutableSet set];
    for (DRShot *shot in shots) {
        if (![checkedAuthorities containsObject:shot.authorityId]) {
            [self checkFollowingUser:shot.authorityId shouldShowProgressHUD:NO completionHandler:^(DRBaseModel *data) {
                if (!data.error) {
                    [[DRActionManager instance] addLocalFollowed:shot.authorityId];
                }
            } failureHandler:^(id data) {
                logInteral(@"checkIfYouFollowingUser error: %@", data);
            }];
            [checkedAuthorities addObject:shot.authorityId];
        }
        if (![checkedShots containsObject:shot.shotId]) {
            [self checkLikeShot:shot.shotId shouldShowProgressHUD:NO completionHandler:^(DRBaseModel *data) {
                if (!data.error) {
                    [[DRActionManager instance] addLocalLikedShotId:shot.shotId];
                }
            } failureHandler:^(id data) {
                logInteral(@"checkIfYouLikeShot error: %@", data);
            }];
            [checkedShots addObject:shot.shotId];
        }
    }
}

- (void)loadFeaturedShotsAtPage:(NSNumber *)page shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    if (showHUD) {
        if (self.progressHUDShowBlock) {
            self.progressHUDShowBlock();
        }
    }
    __weak typeof(self) weakSelf = self;
    [self.internalClient loadPromotionListAtPage:page countOnPage:@(12) completionHandler:^(DRBaseModel *data) {
        if (weakSelf.progressHUDDismissBlock) {
            weakSelf.progressHUDDismissBlock();
        }
        completionHandler(data);
    } failureHandler:errorHandler];
}

#pragma mark - Like

- (void)likeShot:(DRShot *)shot authorId:(NSString *)userId shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    __weak typeof(self) weakSelf = self;
    DRActionManager *actionManager = [DRActionManager instance];
    [actionManager addLocalLikedShotId:shot.shotId];
    [self.client likeShot:shot.shotId completionHandler:^(DRBaseModel *data) {
        if (!data.error) {
            [weakSelf.internalClient likeShot:shot authorId:userId completionHandler:^(DRBaseModel *data) {
                if (!data.error) {
                    actionManager.coins = [data.object coins];
                } else {
                    [actionManager removeLocalLikedShotId:shot.shotId];
                }
            } failureHandler:^(DRBaseModel *data) {
                [actionManager removeLocalLikedShotId:shot.shotId];
            }];
        }
        completionHandler(data);
    } failureHandler:^(DRBaseModel *data) {
        [actionManager removeLocalLikedShotId:shot.shotId];
    }];
}

- (void)unlikeShot:(NSNumber *)shotId shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.client unlikeShot:shotId completionHandler:completionHandler failureHandler:errorHandler];
}

- (void)checkLikeShot:(NSNumber *)shotId shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.client checkLikeShot:shotId completionHandler:completionHandler failureHandler:errorHandler];
}

#pragma mark - Following

- (void)followUser:(NSNumber *)userId shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    __weak typeof(self) weakSelf = self;
    DRActionManager *actionManager = [DRActionManager instance];
    [actionManager addLocalFollowed:userId];
    [self.client followUser:userId completionHandler:^(DRBaseModel *data) {
        if (!data.error) {
            [weakSelf.internalClient followUser:userId completionHandler:^(DRBaseModel *data) {
                if (!data.error) {
                    actionManager.coins = [data.object coins];
                } else {
                    [actionManager removeLocalFollowed:userId];
                }
            } failureHandler:^(DRBaseModel *data) {
                [actionManager removeLocalFollowed:userId];
            }];
        }
        completionHandler(data);
    } failureHandler:^(DRBaseModel *data) {
        [actionManager removeLocalFollowed:userId];
    }];
}

- (void)unFollowUser:(NSNumber *)userId shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.client unFollowUser:userId completionHandler:completionHandler failureHandler:errorHandler];
}

- (void)checkFollowingUser:(NSNumber *)userId shouldShowProgressHUD:(BOOL)showHUD completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.client checkFollowingUser:userId completionHandler:completionHandler failureHandler:errorHandler];
}

#pragma mark - 

- (void)followUsSpecialWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    [self.client followUser:@(kAccount) completionHandler:^(DRBaseModel *data) {
        if (!data.error) {
            [self.internalClient followUsSpecialWithCompletionHandler:completionHandler failureHandler:errorHandler];
        }
        completionHandler(data);
    } failureHandler:nil];
}

- (AFHTTPRequestOperation *)requestImageWithUrl:(NSString *)url completionHandler:(DROperationCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler {
    return [self.client requestImageWithUrl:url completionHandler:completionHandler failureHandler:errorHandler progressBlock:nil];
}

- (AFHTTPRequestOperation *)requestImageWithUrl:(NSString *)url completionHandler:(DROperationCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler progressBlock:(DRDOwnloadProgressBlock)downLoadProgressBlock {
    return [self.client requestImageWithUrl:url completionHandler:completionHandler failureHandler:errorHandler progressBlock:downLoadProgressBlock];
}

#pragma mark - Error handling

- (void)handleError:(NSError*)error forMethod:(NSString *)method withAlert:(BOOL)showAlert {
    // let's skip "check follow" and "check like" 404 error
    if ([method rangeOfString:@"user/following"].length > 0 || [method rangeOfString:@"/like"].length > 0 || [method rangeOfString:@"LoadImage"].length > 0) return;
    logInteral(@"Error:%@ - %@", [NSString stringWithFormat:@"%@", method], error.description);
    if (error.code == kHttpAuthErrorCode) {
        if (self.presentAuthControllerBlock) {
            self.presentAuthControllerBlock();
        }
    }
    if (showAlert) {
        if (error.code == kHttpConnectionLost || error.code == kHttpCannotFindHost || error.code == kHttpCannotConnectToHost) {
            [[UIAlertView alertWithMessage:kInternetConnectionLost andTitle:@"Error"] show];
        }
        [[UIAlertView alertWithError:error] show];
    }
}

#pragma mark - Request limit handling

- (DRRequestLimitStateChangedHandler)requestLimitHandler {
    __weak typeof(self) weakSelf = self;
    return ^(DRRequestLimitType type, BOOL isExceeded) {
        if (isExceeded) {
            if (type == DRRequestLimitPerDay) {
                if (weakSelf.presentLimitControllerBlock) {
                    weakSelf.presentLimitControllerBlock();
                }
            }
            if (type == DRRequestLimitPerMinute) {
                if (weakSelf.progressHUDShowBlock) {
                    weakSelf.progressHUDShowBlock();
                }
            }
        } else {
            if (weakSelf.progressHUDDismissBlock) {
                weakSelf.progressHUDDismissBlock();
            }
        }
    };
}

#pragma mark - Analytics

- (void)sendAnalyticsEvent:(DREvent *)event {
    event.auth = [self isUserAuthorized]? @"on":@"off";
    event.unique_device_id = self.identifierForAnalytics;
    [self.internalClient sendEvent:event completionHandler:^(id data) {
       // todo handle if needed
    } failureHandler:^(id data) {
    // todo handle if needed
    }];
}

#pragma mark - Operation Priority Tasks

- (void)killLowPriorityTasksForShot:(DRShot *)shot {
    [self.client killLowPriorityTasksForShot:shot];
}

@end
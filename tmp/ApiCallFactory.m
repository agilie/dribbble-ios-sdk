//
//  ApiCallFactory.m
//  DribbbleSDKDev
//
//  Created by Dmitry Salnikov on 6/24/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "ApiCallFactory.h"

static NSString * const kDemoUserId = @"597558";
static NSString * const kDemoShotId = @"472178";
static NSString * const kDemoCommentId = @"1146540";
static NSString * const kDemoProjectId = @"48926";
static NSString * const kDemoTeamId = @"834683";

@implementation ApiCallFactory

+ (ApiCallWrapper *)apiCallWrapperWithTitle:(NSString *)title selector:(SEL)selector args:(NSArray *)args responseHandler:(DRResponseHandler)responseHandler {
    ApiCallWrapper *wrapper = [ApiCallWrapper new];
    wrapper.title = title;
    wrapper.args = args;
    wrapper.responseHandler = responseHandler;
    wrapper.selectorString = NSStringFromSelector(selector);
    return wrapper;
}

+ (NSArray *)demoApiCallWrappers {
    
    /*
     - (void)loadUserInfo:(NSString *)userId responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadLikesOfUser:(NSString *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadProjectsOfUser:(NSString *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadTeamsWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadShotsWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadFolloweesWithUser:(NSNumber *)userId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadFolloweesShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadShotWith:(NSNumber *)shotId responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadShotsWithParams:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadShotsFromCategory:(DRShotCategory *)category atPage:(int)page responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadReboundsWithShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadLikesWithShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadCommentsWithShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadCommentWith:(NSNumber *)commentId forShot:(NSString *)shotId responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadLikesWithComment:(NSNumber *)commentId forShot:(NSString *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadProjectsWithShot:(NSNumber *)shotId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadProjectWith:(NSNumber *)projectId responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadMembersWithTeam:(NSNumber *)teamId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
     - (void)loadShotsWithTeam:(NSNumber *)teamId params:(NSDictionary *)params responseHandler:(DRResponseHandler)responseHandler;
     */
    
    DRResponseHandler sharedHandler = ^(DRApiResponse *response) {
        NSLog(@"response: %@", response);
    };

    NSArray *apiCallWrappers = [NSArray arrayWithObjects:
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Info" selector:@selector(loadAccountWithUser:responseHandler:) args:@[kDemoUserId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Likes" selector:@selector(loadLikesWithUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Projects" selector:@selector(loadProjectsWithUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Teams" selector:@selector(loadTeamsWithUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Shots" selector:@selector(loadShotsWithUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Followees" selector:@selector(loadFolloweesWithUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Followees Shots" selector:@selector(loadFolloweesShotsWithParams:responseHandler:) args:@[@{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Shot" selector:@selector(loadShotWith:responseHandler:) args:@[kDemoShotId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Teams" selector:@selector(loadTeamsWithUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Recent Category Shots" selector:@selector(loadShotsFromCategory:atPage:responseHandler:) args:@[[DRShotCategory recentShotsCategory], @{kDRParamPage:@1}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Shot Rebounds" selector:@selector(loadReboundsWithShot:params:responseHandler:) args:@[kDemoShotId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Shot Likes" selector:@selector(loadLikesWithShot:params:responseHandler:) args:@[kDemoShotId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Shot Comments" selector:@selector(loadCommentsWithShot:params:responseHandler:) args:@[kDemoShotId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Shot Comment" selector:@selector(loadCommentWith:forShot:responseHandler:) args:@[kDemoCommentId, kDemoShotId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Comment Likes" selector:@selector(loadLikesWithComment:forShot:params:responseHandler:) args:@[kDemoCommentId, kDemoShotId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Shot Projects" selector:@selector(loadProjectsWithShot:params:responseHandler:) args:@[kDemoShotId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Project" selector:@selector(loadProjectWith:responseHandler:) args:@[kDemoProjectId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Team members" selector:@selector(loadMembersWithTeam:params:responseHandler:) args:@[kDemoTeamId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Team shots" selector:@selector(loadShotsWithTeam:params:responseHandler:) args:@[kDemoTeamId, @{}] responseHandler:sharedHandler],
                                nil];
    
    return apiCallWrappers;
}

/*
 //    [self.apiClient loadProjectsOfUser:@"597558" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadLikesOfUser:@"597558" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadUserInfo:@"597558" responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadTeamsOfUser:@"597558" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadShotsOfUser:@"597558" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadReboundsOfShot:@"472178" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadShot:@"2037338" responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadLikesOfShot:@"2037338" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadCommentsOfShot:@"2037338" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadComment:@"4526047" forShot:@"2037338" responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadLikesOfComment:@"4526047" forShot:@"2037338" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient checkLikeComment:@"4526047" forShot:@"2037338" responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadAttachmentsOfShot:@"471756" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadProjectsOfShot:@"471756" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadProject:@"48926" responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadMembersOfTeam:@"834683" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 //    [self.apiClient loadShotsOfTeam:@"834683" params:@{kDRParamPage:@1} responseHandler:^(DRApiResponse *response) {
 //        NSLog(@"response - %@", response.object);
 //    }];
 
 */

@end

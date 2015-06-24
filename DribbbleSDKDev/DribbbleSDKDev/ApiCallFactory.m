//
//  ApiCallFactory.m
//  DribbbleSDKDev
//
//  Created by Dmitry Salnikov on 6/24/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "ApiCallFactory.h"

static NSString * const kDemoUserId = @"597558";

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
     */
    
    DRResponseHandler sharedHandler = ^(DRApiResponse *response) {
        NSLog(@"response: %@", response);
    };

    NSArray *apiCallWrappers = [NSArray arrayWithObjects:
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Info" selector:@selector(loadUserInfo:responseHandler:) args:@[kDemoUserId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Likes" selector:@selector(loadLikesOfUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Projects" selector:@selector(loadProjectsOfUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
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

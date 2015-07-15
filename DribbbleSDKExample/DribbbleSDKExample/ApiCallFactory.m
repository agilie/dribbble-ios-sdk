//
//  ApiCallFactory.m
//  DribbbleSDKExample
//
//  Created by Dmitry Salnikov on 6/24/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "ApiCallFactory.h"
#import "AppDelegate.h"

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
    AppDelegate *delegate = [AppDelegate delegate];
    DRResponseHandler sharedHandler = ^(DRApiResponse *response) {
        NSLog(@"response: %@", response);
    };
    
    NSArray *apiCallWrappers = [NSArray arrayWithObjects:
                                [ApiCallFactory apiCallWrapperWithTitle:@"TESTTESTTEST" selector:@selector(loadBucketsWithUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Info" selector:@selector(loadAccountWithUser:responseHandler:) args:@[kDemoUserId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Likes" selector:@selector(loadLikesWithUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Projects" selector:@selector(loadProjectsWithUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Teams" selector:@selector(loadTeamsWithUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Shots" selector:@selector(loadShotsWithUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Followees" selector:@selector(loadFolloweesWithUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Followees Shots" selector:@selector(loadFolloweesShotsWithParams:responseHandler:) args:@[@{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Followers" selector:@selector(loadFollowersWithUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Shot" selector:@selector(loadShotWith:responseHandler:) args:@[kDemoShotId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"User Teams" selector:@selector(loadTeamsWithUser:params:responseHandler:) args:@[kDemoUserId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Recent Category Shots" selector:@selector(loadShotsFromCategory:atPage:responseHandler:) args:@[[DRShotCategory recentShotsCategory], @{kDRParamPage:@1}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Shot Rebounds" selector:@selector(loadReboundsWithShot:params:responseHandler:) args:@[kDemoShotId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Like shot" selector:@selector(likeWithShot:responseHandler:) args:@[kDemoShotId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Check shot like" selector:@selector(checkLikeWithShot:responseHandler:) args:@[kDemoShotId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Shot Likes" selector:@selector(loadLikesWithShot:params:responseHandler:) args:@[kDemoShotId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Unlike shot" selector:@selector(unlikeWithShot:responseHandler:) args:@[kDemoShotId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Shot Comments" selector:@selector(loadCommentsWithShot:params:responseHandler:) args:@[kDemoShotId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Shot Comment" selector:@selector(loadCommentWith:forShot:responseHandler:) args:@[kDemoCommentId, kDemoShotId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Comment Likes" selector:@selector(loadLikesWithComment:forShot:params:responseHandler:) args:@[kDemoCommentId, kDemoShotId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Shot Projects" selector:@selector(loadProjectsWithShot:params:responseHandler:) args:@[kDemoShotId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Project" selector:@selector(loadProjectWith:responseHandler:) args:@[kDemoProjectId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Team Members" selector:@selector(loadMembersWithTeam:params:responseHandler:) args:@[kDemoTeamId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Team Shots" selector:@selector(loadShotsWithTeam:params:responseHandler:) args:@[kDemoTeamId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Upload New Shot" selector:@selector(uploadShotWithParams:file:mimeType:responseHandler:) args:@[@{kDRParamTitle:@"another one great shot"}, UIImageJPEGRepresentation([UIImage imageNamed:@"ball.jpg"], 0.8), @"image/jpeg"] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Follow user" selector:@selector(followUserWith:responseHandler:) args:@[kDemoUserId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Unfollow user" selector:@selector(unFollowUserWith:responseHandler:) args:@[kDemoUserId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Check if you are following a user" selector:@selector(checkFollowingWithUser:responseHandler:) args:@[kDemoUserId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Are you following user" selector:@selector(checkIfUserWith:followingAnotherUserWith:responseHandler:) args:@[delegate.user.userId ?: kDemoUserId, kDemoUserId] responseHandler:sharedHandler],
                                
                                [ApiCallFactory apiCallWrapperWithTitle:@"Upload comment" selector:@selector(uploadCommentWithShot:withBody:responseHandler:) args:@[delegate.shot.shotId ?: kDemoShotId, @"API test comment"] responseHandler:sharedHandler],
                                
                                [ApiCallFactory apiCallWrapperWithTitle:@"Update comment (upload & restart first)" selector:@selector(updateCommentWith:forShot:withBody:responseHandler:) args:@[delegate.comment.commentId ?: kDemoCommentId, delegate.shot.shotId ?: kDemoShotId, @"API test updated comment"] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Delete comment (upload & restart first)" selector:@selector(deleteCommentWith:forShot:responseHandler:) args:@[delegate.comment.commentId ?: kDemoCommentId, delegate.shot.shotId ?: kDemoShotId] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Upload attachment" selector:@selector(uploadAttachmentWithShot:params:file:mimeType:responseHandler:) args:@[delegate.shot.shotId ?: kDemoShotId, @{}, UIImageJPEGRepresentation([UIImage imageNamed:@"ball.jpg"], 0.8), @"image/jpeg"] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Load attach (restart after upload)" selector:@selector(loadAttachmentWith:forShot:params:responseHandler:) args:@[delegate.attachment.attachmentId ?: @(0), delegate.shot.shotId ?: kDemoShotId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Load attach-s with shot (restart after upload)" selector:@selector(loadAttachmentsWithShot:params:responseHandler:) args:@[delegate.shot.shotId ?: kDemoShotId, @{}] responseHandler:sharedHandler],
                                [ApiCallFactory apiCallWrapperWithTitle:@"Delete attach (restart after upload)" selector:@selector(deleteAttachmentWith:forShot:responseHandler:) args:@[delegate.attachment.attachmentId ?: @(0), delegate.shot.shotId ?: kDemoShotId] responseHandler:sharedHandler],
                                nil];
    
    return apiCallWrappers;
}

@end

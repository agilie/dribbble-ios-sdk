//
//  DRMainViewController.m
//  DribbbleRunner
//
//  Created by Ankudinov Alexander on 3/17/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRMainViewController.h"
#import "DRShotsViewController.h"
#import "UIImage+animatedGIF.h"
#import "DRShotsPage.h"
#import "DRAppDelegate.h"

typedef void(^InitGalleryBlock)(NSArray *shots, NSArray *shotIds, DRBaseModel *model);

@interface DRMainViewController()

@property (nonatomic) BOOL isLaunched;
@property (nonatomic) BOOL shouldReloadDataOnEnterForeground;
@property (copy, nonatomic) InitGalleryBlock initGalleryBlock;

@end

@implementation DRMainViewController

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.isLaunched = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - View LifeCycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //if (![DRAppDelegate appDelegate].watchAppLaunched) {
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive || !self.isLaunched) {
            self.isLaunched = YES;
            [self receiveShots];
        } else {
            self.shouldReloadDataOnEnterForeground = YES;
        }
    //}
}

#pragma mark - Notification

- (void)appWillEnterForeground:(NSNotification *)note {
    //if (![DRAppDelegate appDelegate].watchAppLaunched) {
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive || self.shouldReloadDataOnEnterForeground) {
            self.shouldReloadDataOnEnterForeground = NO;
            [self receiveShots];
        }
    //}
}

#pragma mark -

- (void)receiveShots {
    __weak typeof(self) weakSelf = self;
    DRShotsController *shotsController = [DRAppDelegate appDelegate].watchController;
    __weak DRShotsController *weakController = shotsController;
    shotsController.onFirstPageLoadedHandler = ^{
        DRShotsViewController *shotsViewController = [[DRShotsViewController alloc] initWithShotsController:weakController];
        [weakSelf.navigationController pushViewController:shotsViewController animated:YES];
    };
    if (shotsController.shots.count > 0) {
        [shotsController reload];
    }
}

@end


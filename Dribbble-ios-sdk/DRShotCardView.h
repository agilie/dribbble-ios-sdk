//
//  DRShotCardView.h
//  DribbbleRunner
//
//  Created by Ankudinov Alexander on 3/20/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRShot.h"
#import "DRShotsViewController.h"

@interface DRShotCardView : UIView

@property (strong, nonatomic) FLAnimatedImageView *animatedImageView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) DRShotsViewController *parentViewController;
@property (weak, nonatomic) AFHTTPRequestOperation *currentOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *teaserCurrentOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *avatarCurrentOperation;
@property (weak, nonatomic) DRShot *currentShot;
@property (nonatomic) BOOL directionLockEnabled;
@property BOOL isAnimatingFrame;
@property (nonatomic, readonly) BOOL isMoving;
@property (nonatomic, copy) void (^colorBlock)(UIColor *);

@property BOOL isViewed;

- (void)reuseView:(DRShot *)photo;
- (void)updateBackgroundColorForView;
- (void)needDisplay;

- (void)resetViewRequests;
- (void)resetViewUi;
- (void)incrementLikesCounter;

@end

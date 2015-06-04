//
//  DRShotsViewController.m
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 18.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRShotsViewController.h"
#import "DRShot.h"
#import "DRShotCategory.h"
#import "DRCategoryTableViewCell.h"
#import "UIImage+animatedGIF.h"
#import "UIColor+DRColor.h"
#import "UIView+MaterialDesign.h"
#import "RippleButtton.h"
#import "DRShotCardView.h"
#import "DRProfileViewController.h"
#import "DRAppDelegate.h"

static const BOOL kCardViewControllerEnableLogs = NO;

void logUiController(NSString *format, ...) {
    if (kCardViewControllerEnableLogs) {
        va_list argList;
        va_start(argList, format);
        NSString *string = [[NSString stringWithFormat:@"[LogUI::%@]", NSStringFromClass([DRShotsViewController class])] stringByAppendingString:format];
        NSLogv(string, argList);
        va_end(argList);
    }
}

static NSString * const kCategoryCellIdentifier = @"categoryCellIdentitfier";
static NSString * const kDRCollectionViewCellIdentifier = @"DRCollectionViewCellID";
static NSString * const kRecentCategoryName = @"Recent";
static NSString * const kIsTutorialShownKey = @"isTutorialShown";

static CGFloat const kTopPanelDownPosition = 0.f;
static CGFloat const kTopPanelUpPosition = -1129.f;
static int const kShotsCardCount = 4;

static CGFloat const kShotViewLikeLimit = 0.98;
static CGFloat kShotViewFollowLimit = 0.97;
static CGFloat kShotViewLikeAndFollowMaxDelta = 0.15;

@interface DRShotsViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, DRShotManagerUpdatesDelegate, DRProfileUpdateDelegate>

@property (weak, nonatomic) IBOutlet UIView *topViewPanel;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *coinsLabel;
@property (weak, nonatomic) IBOutlet UIButton *reloadShotsButton;
@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIImageView *likeFullImage;
@property (weak, nonatomic) IBOutlet UIImageView *followFullImage;
@property (weak, nonatomic) IBOutlet UIImageView *categoryArrowView;
@property (weak, nonatomic) IBOutlet UIButton *closeCategoryViewButton;
@property (weak, nonatomic) IBOutlet UIView *tutorialView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPanelSuperviewDistance;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *tutorialViewPages;

@property (strong, nonatomic) RippleButtton *rippleLikeButton;
@property (strong, nonatomic) RippleButtton *rippleFollowButton;
@property (assign, nonatomic) DRPanDirection panDirection;
@property (strong, nonatomic) CAShapeLayer *layerForAnimation;
@property (nonatomic, readonly) BOOL isTopPanelPulled;
@property (nonatomic, assign) BOOL userSelectedCategory;

@property (assign, nonatomic) CGPoint prevLocation;
@property (assign, nonatomic) NSInteger currentIndex;
@property (strong, nonatomic) NSMutableArray *cards;
@property (strong, nonatomic) NSTimer *timer;

@property BOOL animblock;
@property BOOL loadInProgress;

@property (strong, nonatomic) UISwipeGestureRecognizer *swipeUpRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panDownRecognizer;

@property BOOL isActionFired;

@property (strong, nonatomic) DRShotsController *shotsController;

@property (assign, nonatomic) NSInteger currentTutorialPageIndex;

@property (assign, readonly) DRShot *currentShot;

@end

@implementation DRShotsViewController

- (instancetype)initWithShotsController:(DRShotsController *)shotsController {
    self = [super init];
    if (self) {
        self.shotsController = shotsController;
        self.userSelectedCategory = NO;
        self.shotsController.updateDelegate = self;
        [self.actionManager addProfileUpdateDelegate:self];
    }
    return self;
}

- (void)dealloc {
    self.shotsController.updateDelegate = nil;
}

#pragma mark - View LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isActionFired = NO;
    [self.categoryTableView registerNib:[UINib nibWithNibName:NSStringFromClass([DRCategoryTableViewCell class]) bundle:nil] forCellReuseIdentifier:kCategoryCellIdentifier];
    self.layerForAnimation = nil;
    [self didUpdateCategory:self.shotsController.selectedCategory];
    [self setupCategorySwipes];
}

- (void)animateCoinsLabel {
    CGFloat fontSize = 14.f;
    NSString *font = self.coinsLabel.font.fontName;
    CGFloat newFontSize = fontSize * 1.03;
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.coinsLabel.font = [UIFont fontWithName:font size:newFontSize];
        weakSelf.coinsLabel.layer.transform = CATransform3DScale(weakSelf.coinsLabel.layer.transform, 2.0f, 2.0f, 1.f);
    } completion:^(BOOL finished) { 
        [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            weakSelf.coinsLabel.font = [UIFont fontWithName:font size:fontSize];
            weakSelf.coinsLabel.layer.transform = CATransform3DScale(weakSelf.coinsLabel.layer.transform, 0.5f, 0.5f, 1.f);
        } completion:nil];
    }];
}

- (void)updateCoinsLabel {
    self.coinsLabel.text = [NSString stringWithFormat:@"%i", [self.actionManager.coins intValue]];
    self.coinsLabel.hidden = ![self.apiService isUserAuthorized];
    [self animateCoinsLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateCoinsLabel];
    [self.signInButton setImage:nil forState:UIControlStateNormal];
    [self.signInButton setImage:nil forState:UIControlStateSelected];
    [self.signInButton setTitle:@"" forState:UIControlStateNormal];
    [self.signInButton setTitle:@"" forState:UIControlStateSelected];
    if ([self.apiService isUserAuthorized]) {
        [self.signInButton setImage:[UIImage imageNamed:@"coins"] forState:UIControlStateNormal];
    } else {
        [self resetLikeFollowAlpha];
        [self.followButton setImage:[UIImage imageNamed:@"follow"] forState: UIControlStateNormal];
        [self.likeButton setImage:[UIImage imageNamed:@"like"] forState: UIControlStateNormal];
        [self.signInButton setTitle:@"Sign in" forState:UIControlStateNormal];
    }
    [self.categoryTableView reloadData];
    if (!self.cards) {
        _cardYPosiyion = self.view.frame.size.height / 4 ;
        if ([[UIScreen mainScreen] bounds].size.height < 568) {
            _cardYPosiyion -= 15;
        }
        [self setupCards];
        [self.view bringSubviewToFront:self.likeFullImage];
        [self.view bringSubviewToFront:self.followFullImage];
        [self.view bringSubviewToFront:self.likeButton];
        [self.view bringSubviewToFront:self.followButton];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view bringSubviewToFront:self.topViewPanel];
    [self.view bringSubviewToFront:self.categoryButton];
    [self.view bringSubviewToFront:self.categoryArrowView];
    [self.view bringSubviewToFront:self.signInButton];
    [self.view bringSubviewToFront:self.reloadShotsButton];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    
    BOOL forceSkipTutorial = NO;
#if DEBUG
    forceSkipTutorial = kSkipTutorialInDebug;
#endif
    
    if (![defs objectForKey:kIsTutorialShownKey] && !forceSkipTutorial) {
        [self showTutorial];
    } else {
        [self setupGestureFitchers];
        [self.tutorialView removeFromSuperview];
    }
}

#pragma mark

- (void)showTutorial {
    __weak typeof(self)weakSelf = self;
    if (self.currentTutorialPageIndex <= 0) {
        [self.view bringSubviewToFront:self.tutorialView];
        self.currentTutorialPageIndex = 0;
        UIView *firstTutorialPage = [self.tutorialViewPages objectAtIndex:self.currentTutorialPageIndex];
        [firstTutorialPage setAlpha:0.f];
        [UIView animateWithDuration:kAppleStyleAnimationDuration animations:^{
            [weakSelf.tutorialView setHidden:NO];
            [firstTutorialPage setHidden:NO];
            [firstTutorialPage setAlpha:1.f];
        } completion:nil];
        [self.view bringSubviewToFront:firstTutorialPage];
    } else {
        [self toggleCategoryPanel];
        [self showNextTutorialPage];
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        [defs setObject:@(1) forKey:kIsTutorialShownKey];
        [defs synchronize];
    }
}


#pragma mark - DRShotManagerUpdatesDelegate

- (void)didUpdateCategory:(DRShotCategory *)category {
    NSString *categoryName = self.shotsController.selectedCategory.categoryName;
    [self.categoryButton setTitle:categoryName forState:UIControlStateNormal];
    CGFloat buttonWidth = [categoryName boundingRectWithSize:CGSizeMake(MAXFLOAT, self.categoryButton.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:self.categoryButton.titleLabel.font.familyName size:self.categoryButton.titleLabel.font.pointSize]} context:nil].size.width;
    [self.view updateConstraintsIfNeeded];
    [self.categoryButton setFrame:CGRectMake(self.categoryButton.frame.origin.x, self.categoryButton.frame.origin.y, buttonWidth, self.categoryButton.frame.size.height)];
    [self.view layoutIfNeeded];
}

- (void)didUpdateShotsList {
    [self handleDataLoadFinish];
}

#pragma mark - DRProfileUpdateDelegate

- (void)didUpdateLikes {
    [self updateUiForShot:self.shotsController.currentShot];
}

- (void)didUpdateFollows {
    [self updateUiForShot:self.shotsController.currentShot];
}

- (void)didUpdateCoins {
    [self updateCoinsLabel];
}

- (void)didUpdateUser {
    methodNotImplemented();
}

- (void)didUpdateIsPromote {
    methodNotImplemented();
}

#pragma mark - view based galery


- (void)animateForward:(BOOL)isForward {
    __weak typeof(self)weakSelf = self;
    if (_animblock) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [weakSelf animateForward:isForward];
        });
        return;
    };
    
    NSLog(@"animate off shot id: %@", self.currentShot.shotId);
    
    _animblock = YES;
    DRShotCardView *lastCard = [self.cards lastObject];
//    NSLog(@"animate last card idx: %ld", (long)lastCard.tag);
    [self.cards  removeLastObject];
    [[self.cards lastObject] needDisplay];
    lastCard.isViewed = YES;
    CGAffineTransform transformAway = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(isForward ? -22:22));
    CGAffineTransform transformLast = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(32));
    lastCard.isAnimatingFrame = YES;
    [lastCard resetViewRequests];
    lastCard.userInteractionEnabled = NO;
    [UIView animateWithDuration:0 animations:^{
        //        lastCard.y =  _cardYPosiyion ;
    } completion:^(BOOL finished) {
        logUiController(@" <ANIM START> start animate move out idx: %d", lastCard.tag);
        
        CGFloat cardSize = weakSelf.view.frame.size.width;
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionOverrideInheritedCurve | UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGFloat locationDelta = 100;
            CGFloat cardSize = weakSelf.view.frame.size.width;
            
            CGPoint cardPosition = CGPointZero;
            cardPosition.x = cardSize + locationDelta;
            cardPosition.y = lastCard.center.y + locationDelta;
            if (isForward) cardPosition.x *= -1;
            
            lastCard.center = cardPosition;
            
            lastCard.transform = transformAway;
        } completion:^(BOOL finished) {
            logUiController(@" <ANIM END> end animate move out idx: %d", lastCard.tag);
            [weakSelf.view sendSubviewToBack: lastCard];
            lastCard.center = CGPointMake(weakSelf.view.center.x, weakSelf.cardYPosiyion + cardSize / 2);
            lastCard.transform = transformLast;
            lastCard.isAnimatingFrame = NO;
            [weakSelf.cards  insertObject: lastCard atIndex:0];
          
            [weakSelf preloadAndDisplayCards];
            
            
            
            [weakSelf.cards enumerateObjectsUsingBlock:^(DRShotCardView *card, NSUInteger idx, BOOL *stop) {
                double rads = DEGREES_TO_RADIANS(8 * (kShotsCardCount - idx - 1));
                CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
                float opacity = kShotsCardCount - idx -1;
                opacity = opacity/13;
                card.userInteractionEnabled = NO;

                if (card.isMoving) {
                    logUiController(@" <ANIM CANCEL> cancelling animate transform idx: %d", card.tag);
                    card.transform = transform;
                    card.backgroundImageView.alpha = opacity;
                    card.isAnimatingFrame = NO;
                    _animblock = NO;
                    [card setNeedsDisplay];
                } else {
                    logUiController(@" <ANIM START> start animate transform idx: %d", card.tag);
                    card.isAnimatingFrame = YES;
                    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionOverrideInheritedCurve animations:^{
                        card.transform = transform;
                        card.backgroundImageView.alpha = opacity;
                    } completion:^(BOOL finished) {
                        card.isAnimatingFrame = NO;
                        logUiController(@" <ANIM END> end animate transform idx: %d", card.tag);
                        _animblock = NO;
                    }];
                }
            }];
            [weakSelf resetLikeFollowAlpha];
            [[weakSelf.cards lastObject] setUserInteractionEnabled:YES];
        }];
    }];
    
}

- (void)setupCards {
    self.cards = [NSMutableArray arrayWithCapacity:kShotsCardCount];
    for (int cardsCount = 0; cardsCount < kShotsCardCount; cardsCount++) {
        DRShotCardView *shotCard =  [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DRShotCardView class]) owner:self options:nil] firstObject];
        [shotCard setFrame: CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.width )];
        [self.cards addObject: shotCard];
        [self.view addSubview: shotCard];
        shotCard.isViewed = YES;
        shotCard.parentViewController = self;
        shotCard.center = self.view.center;
        shotCard.frame = CGRectMake(shotCard.frame.origin.x, _cardYPosiyion, shotCard.frame.size.width, shotCard.frame.size.height);
        [shotCard updateConstraints];
        double rads = DEGREES_TO_RADIANS(8 * (kShotsCardCount - cardsCount - 1));
        CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
        float opacity = kShotsCardCount - cardsCount - 1;
        opacity = opacity/13;
        [UIView animateWithDuration:0.4 animations:^{
            shotCard.transform = transform;
            shotCard.backgroundImageView.alpha = opacity;
        } completion:^(BOOL finished) {
            
        }];
    }
    [self initCards];
    [self preloadAndDisplayCards];
}

- (void)initCards {
    __weak typeof(self)weakSelf = self;
    [self.cards enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(DRShotCardView *card, NSUInteger idx, BOOL *stop) {
        DRShot *shotToShow = [weakSelf.shotsController obtainShot];
        [card resetViewRequests];
        [card reuseView: shotToShow];
        card.isViewed = NO;
        card.userInteractionEnabled = NO;
    }];
    [[self.cards lastObject] setUserInteractionEnabled:YES];
}

- (void)handleDataLoadFinish {
    for (DRShotCardView *shotView in self.cards) {
        shotView.isAnimatingFrame = YES;
    }
    
    if (self.shotsController.displayIndex == 0) {
        [self initCards];
    }
    
    [self preloadAndDisplayCards];
    
    for (DRShotCardView *shotView in self.cards) {
        shotView.isAnimatingFrame = NO;
    }
    
}

- (void)preloadAndDisplayCards {
    
    __weak __typeof(self) weakSelf = self;
    
    [self.cards enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(DRShotCardView *card, NSUInteger idx, BOOL *stop) {
        if (card.isViewed) {
            [card reuseView:[weakSelf.shotsController obtainShot]];
            card.isViewed = NO;
        }
    }];
    
    [[self.cards lastObject] needDisplay]; // ???
    
    // set needs display the card under top card
    NSInteger preLastIndex = [self.cards count] - 2;
    if (preLastIndex >= 0) {
        [[self.cards objectAtIndex:preLastIndex] needDisplay]; // ????
    }
    
    [self.view bringSubviewToFront:self.topViewPanel];
    [self.view bringSubviewToFront:self.categoryButton];
    [self.view bringSubviewToFront:self.categoryArrowView];
    [self.view bringSubviewToFront:self.signInButton];
    [self.view bringSubviewToFront:self.reloadShotsButton];

    [self updateUiForShot:self.currentShot];
}

- (void)setupShadowInView:(UIView*)view{
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.borderWidth = 1.0f;
}

#pragma mark - Getters


- (RippleButtton *)rippleLikeButton {
    if (!_rippleLikeButton) {
        _rippleLikeButton = [[RippleButtton alloc]initWithImage:[UIImage imageNamed:@"like.png"]
                                                       andFrame:CGRectMake(_likeButton.frame.origin.x, _likeButton.frame.origin.y, _likeButton.frame.size.width, _likeButton.frame.size.height)
                                                      andTarget:@selector(pressLikeButton:)
                                                          andID:self];
        [_rippleLikeButton setRippeEffectEnabled:YES];
        [_rippleLikeButton setRippleEffectWithColor:[UIColor dr_pinkColor]];
    }
    return _rippleLikeButton;
}

- (RippleButtton *)rippleFollowButton {
    if (!_rippleFollowButton) {
        _rippleFollowButton = [[RippleButtton alloc]initWithImage:[UIImage imageNamed:@"follow.png"]
                                                         andFrame:CGRectMake(_followButton.frame.origin.x, _followButton.frame.origin.y, _followButton.frame.size.width, _followButton.frame.size.height)
                                                        andTarget:@selector(pressFollowButton:)
                                                            andID:self];
        [_rippleFollowButton setRippeEffectEnabled:YES];
        [_rippleFollowButton setRippleEffectWithColor:[UIColor dr_pinkColor]];
    }
    return _rippleFollowButton;
}

- (void)updateUiForShot:(DRShot *)shot {
    [self resetLikeFollowAlpha];
    [self.likeButton setImage:[UIImage imageNamed: @"like"] forState:UIControlStateNormal];
    [self.followButton setImage:[UIImage imageNamed:[shot isAuthorityFollowed] ? @"follow_full" : @"follow"] forState: UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:[shot isLiked] ? @"like_full" : @"like"] forState: UIControlStateNormal];
}

- (void)fireAction:(dispatch_block_t)action {
    if (!self.isActionFired) {
        self.isActionFired = YES;
        action();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isActionFired = NO;
        });
    }
}


- (BOOL)updateActionsProgressWithLikeProgress:(float)likeProgress followProgress:(float)followProgress allowAction:(BOOL)allowAction {
    
    
    self.likeFullImage.alpha = (1 - (kShotViewLikeLimit - likeProgress) / kShotViewLikeAndFollowMaxDelta);
    self.followFullImage.alpha = (1 - (kShotViewFollowLimit - followProgress) / kShotViewLikeAndFollowMaxDelta);

    __weak typeof(self)weakSelf = self;
    if (likeProgress > kShotViewLikeLimit && allowAction) {
        [self fireAction:^{
            if ([weakSelf.apiService isUserAuthorized]) {
                [weakSelf pressLikeButton:nil];
                [weakSelf.rippleLikeButton animateTap];
            } else {
                [weakSelf showLoginForm];
            }
            weakSelf.likeFullImage.alpha = 0;
        }];
        return YES;
    }
    if (followProgress > kShotViewFollowLimit  && allowAction) {
        [self fireAction:^{
            if ([weakSelf.apiService isUserAuthorized]) {
                [weakSelf pressFollowButton:nil];
                [weakSelf.rippleFollowButton animateTap];
            } else {
                [weakSelf showLoginForm];
            }
            weakSelf.followFullImage.alpha = 0;
        }];
        return YES;
    }
    return NO;
}

- (void)setupGestureFitchers {
    [self.view addSubview:self.rippleLikeButton];
    [self.view addSubview:self.rippleFollowButton];
    __weak typeof(self)weakSelf = self;
    //left
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] bk_initWithHandler:
                                           ^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                                               [weakSelf animateForward:YES];
                                           }];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    
    //right
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] bk_initWithHandler:
                                            ^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                                                [weakSelf animateForward:NO];
                                            }];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.shotsController.allCategories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DRCategoryTableViewCell *categoryCell = [tableView dequeueReusableCellWithIdentifier:kCategoryCellIdentifier];
    categoryCell.name.text = [[[self.shotsController.allCategories objectAtIndex:indexPath.row] categoryName] uppercaseString];
    categoryCell.name.textColor = [self isHighlightedCategory:indexPath.row] ? [UIColor dr_blackColor]:[UIColor dr_WhiteColor];
    return categoryCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.shotsController.selectedCategory = [self.shotsController.allCategories objectAtIndex:indexPath.row];
    [self.shotsController.wormHole passMessageObject:@{@"reload": @1} identifier:@"selection"];
    if ([DRAppDelegate appDelegate].watchAppLaunched) {
        [DRAppDelegate appDelegate].watchController.selectedCategory = [self.shotsController.allCategories objectAtIndex:indexPath.row];
    }
    self.userSelectedCategory = ![self.shotsController.selectedCategory isFeaturedShotsCategory];
    DREvent *event = [DREvent eventType:@"e_category_was_chosen" navigation:@"gallery" actionId:nil];
    [[DRApiService instance] sendAnalyticsEvent:event];
    [self animateCategoryPanelUp:YES];
}

#pragma mark - Gesture Action

- (DRShot *)currentShot {
    return [[self.cards lastObject] currentShot];
}

- (void)animateCategoryPanelUp:(BOOL)isUp {
    __weak typeof(self)weakSelf = self;
    [self.topViewPanel removeGestureRecognizer: isUp ? self.swipeUpRecognizer : self.panDownRecognizer];
    [self.topViewPanel addGestureRecognizer: isUp ? self.panDownRecognizer : self.swipeUpRecognizer];
    self.topPanelSuperviewDistance.constant = isUp ? kTopPanelUpPosition : kTopPanelDownPosition;
    [self.view updateConstraintsIfNeeded];
    
    void (^animationCompletion)(void) = ^{
        [UIView animateWithDuration:kAppleStyleAnimationDuration animations:^{
            [weakSelf.view layoutIfNeeded];
        } completion:nil];
    };
    
    if (isUp) {
        [self.view mdDeflateAnimatedToPoint:self.view.frame.origin viewForLayer:self.topViewPanel withLayer:self.layerForAnimation backgroundColor:[UIColor clearColor] duration:kMaterialStyleAnimationDuration completion:animationCompletion];
    } else {
        self.layerForAnimation = [self.view mdInflateAnimatedFromPoint:self.view.frame.origin viewForLayer:self.topViewPanel withLayer:nil backgroundColor:[UIColor dr_pinkColor] duration:kMaterialStyleAnimationDuration completion:animationCompletion];
    }
    
    [self.view bringSubviewToFront:self.closeCategoryViewButton];
    
    
    [UIView animateWithDuration:0.1 delay:0 options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.categoryButton.alpha = 0;
        self.closeCategoryViewButton.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kAppleStyleAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.categoryButton.alpha = 1;
            self.closeCategoryViewButton.alpha = 1;
        } completion:nil];
    }];
    
    [UIView animateWithDuration:kAppleStyleAnimationDuration animations:^{
        weakSelf.categoryButton.hidden = weakSelf.categoryArrowView.hidden = !isUp;
        weakSelf.closeCategoryViewButton.hidden = isUp;
    } completion:^(BOOL finished) {
        [weakSelf.categoryTableView reloadData];
        weakSelf.signInButton.hidden = weakSelf.reloadShotsButton.hidden = weakSelf.isTopPanelPulled;
    }];
    
    [[UIApplication sharedApplication] setStatusBarHidden:!isUp withAnimation:UIStatusBarAnimationFade];
    
}
- (void)setupCategorySwipes {
    __weak typeof(self)weakSelf = self;
    
    self.swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateEnded) [weakSelf animateCategoryPanelUp:YES];
        
    }];
    self.swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    
    self.panDownRecognizer = [[UIPanGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *recognizer, UIGestureRecognizerState state, CGPoint location) {
        if (recognizer.state == UIGestureRecognizerStateEnded) [weakSelf animateCategoryPanelUp:NO];
    }];
    [self.topViewPanel addGestureRecognizer:self.panDownRecognizer];
}

- (BOOL)isTopPanelPulled {
    return (self.topViewPanel.frame.origin.y > kTopPanelUpPosition);
}

- (void)toggleCategoryPanel {
    [self animateCategoryPanelUp:self.isTopPanelPulled];
}

#pragma mark - IBAction

- (IBAction)pressUserProfile:(id)sender {
    [self.apiService stopPromoteShotsCompletionHandler:^(DRBaseModel *data) {
        NSLog(@"%@",data);
    } failureHandler:nil];
}

- (IBAction)pressLikeButton:(id)sender {
    if ([self.apiService isUserAuthorized]) {
        if (self.currentShot && ![self.currentShot isStub] && ![self.currentShot isLiked]) {
            if (![self.currentShot.user.userId isEqualToNumber:self.actionManager.internalUser.user.userId]) {
                [self likeShot:self.currentShot];
            }
        }
    } else {
        [self showLoginForm];
    }
}

- (IBAction)pressFollowButton:(id)sender {
    if ([self.apiService isUserAuthorized]) {
        if (self.currentShot && ![self.currentShot isStub] && ![self.currentShot isAuthorityFollowed]) {
            if (![self.currentShot.user.userId isEqualToNumber:self.actionManager.internalUser.user.userId]) {
                [self followUser:self.currentShot];
            }
        }
    } else {
        [self showLoginForm];
    }
    
}

- (IBAction)pressChangeCategory:(id)sender {
    [self toggleCategoryPanel];
}

- (IBAction)pressSignInButton:(id)sender {
    if ([self.apiService isUserAuthorized]) {
        DRProfileViewController *profileController = [self.apiService.storyBoard instantiateViewControllerWithIdentifier:@"profileViewController"];
        [self.navigationController pushViewController:profileController animated:YES];
    } else {
        [self showLoginForm];
    }
}

- (IBAction)closeCategoryViewButtonPressed:(id)sender {
    [self toggleCategoryPanel];
}

- (IBAction)refreshButtonPressed:(id)sender {
    [SVProgressHUD show];
    [self.shotsController reload];
}

#pragma mark -

- (void)resetTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)likeShot:(DRShot *)shot {
    __weak typeof(self)weakSelf = self;
    weakSelf.likeFullImage.alpha = 1.f;
    [self.apiService likeShot:shot authorId:[shot.user.userId stringValue] shouldShowProgressHUD:YES completionHandler:^(DRBaseModel *data) {
        if (!data.error) {
            [weakSelf updateUiForShot:shot];
            [[self.cards lastObject] incrementLikesCounter];
        } else {
            weakSelf.likeFullImage.alpha = 0.f;
        }
    } failureHandler:nil];
    DREvent *event = [DREvent eventType:@"e_like" navigation:@"gallery" actionId:shot.shotId];
    [[DRApiService instance] sendAnalyticsEvent:event];
    [self updateUiForShot:self.shotsController.currentShot];
}

- (void)followUser:(DRShot *)userShot {
    __weak typeof(self)weakSelf = self;
    weakSelf.followFullImage.alpha = 1.f;
    [self.apiService followUser:userShot.authorityId shouldShowProgressHUD:YES completionHandler:^(DRBaseModel *data) {
        if (!data.error) {
            weakSelf.followFullImage.alpha = 0.f;
            [weakSelf updateUiForShot:userShot];
        }
    } failureHandler:nil];
    DREvent *event = [DREvent eventType:@"e_follow" navigation:@"gallery" actionId:userShot.user.userId];
    [[DRApiService instance] sendAnalyticsEvent:event];
}

- (void)showLoginForm {
    [self.navigationController performSegueWithIdentifier:kShowLoginSegueIdentifier sender:nil];
}

- (void)showNextTutorialPage {
    __weak typeof(self)weakSelf = self;
    self.tutorialView.hidden = YES;
    [[self.tutorialViewPages objectAtIndex:self.currentTutorialPageIndex] setHidden:YES];
    self.currentTutorialPageIndex++;
    UIView *nextTutorialPage = [self.tutorialViewPages objectAtIndex:self.currentTutorialPageIndex];
    [UIView animateWithDuration:kAppleStyleAnimationDuration animations:^{
        [nextTutorialPage setAlpha:0];
        [nextTutorialPage setHidden:NO];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kAppleStyleAnimationDuration animations:^{
            weakSelf.tutorialView.hidden = NO;
            [nextTutorialPage setAlpha:1];
            [weakSelf.view bringSubviewToFront:weakSelf.tutorialView];
        } completion:nil];
    }];
}

- (IBAction)firstTutorialPagePressed:(id)sender {
    [self showNextTutorialPage];
}

- (IBAction)secondTutorialPagePressed:(id)sender {
    [self showNextTutorialPage];
}

- (IBAction)thirtTutorialPagePressed:(id)sender {
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:kAppleStyleAnimationDuration animations:^{
        [weakSelf.navigationController performSegueWithIdentifier:kShowProfileSegueIdentifier sender:nil];
        [[weakSelf.tutorialViewPages objectAtIndex:weakSelf.currentTutorialPageIndex] setHidden:YES];
    }];
}

- (IBAction)fourthTutorialPagePressed:(id)sender {
    [[self.tutorialViewPages objectAtIndex:self.currentTutorialPageIndex] setHidden:YES];
    [self setupGestureFitchers];
    [self.tutorialView removeFromSuperview];
    [self toggleCategoryPanel];
}

#pragma helper -

- (BOOL)isHighlightedCategory:(NSInteger)index {
    if (_userSelectedCategory) {
        return self.shotsController.selectedCategory.categoryType == index;
    }
    return index == DRShotCategoryFeaturedShots;
}

- (void)resetLikeFollowAlpha {
    self.likeFullImage.alpha = 0.f;
    self.followFullImage.alpha = 0.f;
}

@end
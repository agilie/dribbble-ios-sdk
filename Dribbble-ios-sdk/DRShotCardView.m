//
//  DRShotCardView.m
//  DribbbleRunner
//
//  Created by Ankudinov Alexander on 3/20/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRShotCardView.h"
#import "ColorCube/CCColorCube.h"

static NSString * const kDragAnimationOnTouchMoveName = @"DragViewAnimationTouchMove";
static NSString * const kDragAnimationOnTouchEndName = @"DragViewAnimationTouchEnd";

static const BOOL kShotCardViewEnableLogs = NO;

void logUi(NSString *format, ...) {
    if (kShotCardViewEnableLogs) {
        va_list argList;
        va_start(argList, format);
        NSString *string = [[NSString stringWithFormat:@"[LogUI::%@]", NSStringFromClass([DRShotCardView class])] stringByAppendingString:format];
        NSLogv(string, argList);
        va_end(argList);
    }
}

static CGFloat const kTopBarViewHeight = 58;

typedef enum : NSUInteger {
    DRShotCardViewScrollDirectionUnknown = 0,
    DRShotCardViewScrollDirectionHorizontal,
    DRShotCardViewScrollDirectionVertical,
} DRShotCardViewScrollDirection;

@interface DRShotCardView()

@property (nonatomic) DRShotCardViewScrollDirection scrollDirection;

@property CGFloat startY;
@property CGFloat maxY;

@end

@implementation DRShotCardView

@synthesize animatedImageView = _animatedImageView;

static int theindex = 0;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _isMoving = NO;
        
        if (kShotCardViewEnableLogs) {
            [self bk_addObserverForKeyPath:@"isAnimatingFrame" identifier:@"1" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
                int old = [change[@"old"] intValue];
                int new = [change[@"new"] intValue];
                logUi(@"set isAnimFrame from: %d, to: %d idx: %d", old, new, self.tag);
                if (old > 1 || old < 0 || new > 1 || old < 0) {
                    logUi(@"something is wrong with the universe");
                }
                
            }];
            [self.layer bk_addObserverForKeyPath:@"bounds" identifier:@"3" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
                CGRect new = [change[@"new"] CGRectValue];
                if (new.size.width != 320) {
                    logUi(@"FRAME BROKEN self = %@", self);
                }
            }];
            
            [self bk_addObserverForKeyPath:@"userInteractionEnabled" identifier:@"5" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
                NSLog(@"userInteractionEnabled: %ld, idx: %d", (long)self.tag, [change[@"new"] intValue]);
            }];
        }
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tag = theindex;
    theindex++;
    self.avatarImage.layer.masksToBounds = YES;
    self.avatarImage.layer.cornerRadius = 17.0;
}

- (FLAnimatedImageView*)animatedImageView {
    if (!_animatedImageView) {
        _animatedImageView = [[FLAnimatedImageView alloc] init];
        _animatedImageView.frame = self.imageView.frame;
        [self addSubview: _animatedImageView];
    }
    return _animatedImageView;
}

//void logInteralOp(AFHTTPRequestOperation *op, NSString *state, DRShotCardView *view) {
//    NSString *string = [@"[OPERATION] " stringByAppendingFormat:@"%@; idx: %ld, url:%@", state, (long)view.tag, [op.request.URL absoluteString]];
//    NSLog(@"%@", string);
//}


//#define LOG_OPERATION(op,txt) ;// NSLog(@"%@; operation: %@", txt, op.request.URL.absoluteString)

- (void)resetViewRequests {
    [[DRApiService instance] killLowPriorityTasksForShot:self.currentShot];
    if (self.currentOperation && ![self.currentOperation isFinished]){
//        logInteralOp(self.currentOperation, @"cancel current", self);
//        NSLog(@"cancel currentOperation: resetView");
        [self.currentOperation cancel];
        self.currentOperation = nil;
    }
    
    if (self.teaserCurrentOperation && ![self.teaserCurrentOperation isFinished]) {
//        logInteralOp(self.teaserCurrentOperation, @"cancel teaser", self);
//        NSLog(@"cancel teaserCurrentOperation: resetView");
        [self.teaserCurrentOperation cancel];
        self.teaserCurrentOperation = nil;
    }
}

- (void)resetViewUi {
    //clear before reuse
    
    self.animatedImageView.image = nil;
    self.animatedImageView.animatedImage = nil;
    self.animatedImageView.hidden = YES;
    self.avatarImage.image = nil;
    self.nameLabel.text = self.authorNameLabel.text = self.likeCountLabel.text = self.viewCountLabel.text = self.commentCountLabel.text = @"";
}

- (void)reuseView:(DRShot *)shot {
    
//    NSLog(@"reuse card idx: %ld", (long)self.tag);
    
    self.currentShot  = shot;
    [self.activityView startAnimating];
    
    [self resetViewUi];

    __weak __typeof(&*self) weakSelf = self;
    
    weakSelf.animatedImageView.alpha = 1.f;
    self.teaserCurrentOperation = [[DRApiService instance] requestImageWithUrl:shot.images.teaser completionHandler:^(id image, AFHTTPRequestOperation *operation) {
//        logInteralOp(self.teaserCurrentOperation, @"end teaser", self);
        if (self.teaserCurrentOperation != operation) return;
        
        if (shot.defaultUrl) {
          self.currentOperation = [[DRApiService instance] requestImageWithUrl:shot.defaultUrl completionHandler:^(id data, AFHTTPRequestOperation *operation) {
              //logInteralOp(self.currentOperation, @"end current", self.tag);
              if (self.currentOperation != operation) return;
              
                if ([shot isAnimation]) {
                    weakSelf.animatedImageView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
                } else {
                    weakSelf.animatedImageView.image = [UIImage imageWithData:data];
                }
            } failureHandler:^(id data) {
                [weakSelf.activityView stopAnimating];
            } progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                float progress = 0.5 + totalBytesRead*1.f/(totalBytesExpectedToRead + 1)/2;
                weakSelf.animatedImageView.alpha = progress;
            }];
            //logInteralOp(self.currentOperation, @"start current", self.tag);
        }
        weakSelf.animatedImageView.image = [UIImage imageWithData:image];
        weakSelf.animatedImageView.alpha = 0.5;
        
        [weakSelf updateBackgroundColorForView];
        [weakSelf.activityView stopAnimating];
    } failureHandler:^(NSError *error) {
        [weakSelf.activityView stopAnimating];
    }];
//    logInteralOp(self.teaserCurrentOperation, @"start teaser", self);
    
    if (self.avatarCurrentOperation && ![self.avatarCurrentOperation isFinished]) {
        [self.avatarCurrentOperation isCancelled];
    }
    self.avatarCurrentOperation = [[DRApiService instance] requestImageWithUrl: shot.user.avatar_url completionHandler:^(id image, AFHTTPRequestOperation *operation) {
        if (self.avatarCurrentOperation != operation) return;
        weakSelf.avatarImage.image = [UIImage imageWithData:image];
    } failureHandler:nil];
    
    self.nameLabel.text = shot.title;
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@", shot.likes_count ? : @""];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%@", shot.comments_count ? : @""];
    self.viewCountLabel.text = [NSString stringWithFormat:@"%@", shot.views_count ? : @""];
    self.authorNameLabel.text = [NSString stringWithFormat:@"by %@", shot.user.name ? : @""] ;
}

- (void)needDisplay {
    self.animatedImageView.hidden = NO;
}

- (void)updateBackgroundColorForView {
    if (self.animatedImageView.image) {
        CCColorCube *colorCube = [[CCColorCube alloc] init];
        NSArray *imgColors = [colorCube extractColorsFromImage:self.animatedImageView.image flags:0 count:2];
        if (imgColors && [imgColors count] && self.colorBlock) {
            self.colorBlock ([imgColors firstObject]);
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isAnimatingFrame) {
        [self touchesCancelled:touches withEvent:event];
        return;
    }
    _isMoving = YES;
    self.scrollDirection = DRShotCardViewScrollDirectionUnknown;
    self.startY = self.frame.origin.y;
    self.maxY = 0;
    logUi(@" <TOUCH> touchesBegan idx:%d", self.tag);
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    logUi(@" <TOUCH> touchesMoved idx:%d", self.tag);
    
    __block float locx = 0,locy = 0;
    [touches enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
        CGPoint viewTouch = [touch locationInView:self];
        CGPoint prevTouch = [touch previousLocationInView:self];
        locx = viewTouch.x - prevTouch.x;
        locy = viewTouch.y - prevTouch.y;
    }];
    
    CGRect screenRect = [self.parentViewController.view bounds];
    
    if ((self.frame.origin.y + locy + self.frame.size.height) > (screenRect.size.height + 10) || (self.frame.origin.y + locy) < kTopBarViewHeight) {
        return;
    }
    
    
    if (fabs(self.frame.origin.y - self.startY) > self.maxY) {
        self.maxY = self.frame.origin.y - self.startY;
    }
    
    CGFloat likeProgress = (1 - (self.frame.origin.y + locy - kTopBarViewHeight) / (screenRect.size.height - kTopBarViewHeight));
    CGFloat followProgress = (self.frame.origin.y + locy + self.frame.size.height) / screenRect.size.height;
    
    [self.parentViewController updateActionsProgressWithLikeProgress:likeProgress followProgress:followProgress allowAction:NO];
    
    if (!self.isAnimatingFrame) {
        CGPoint newCenter = CGPointMake(self.center.x, self.center.y);
        
        
        if (self.directionLockEnabled) {
            switch (self.scrollDirection) {
                case DRShotCardViewScrollDirectionUnknown: {
                    if (fabs(locx) > fabs(locy)) {
                        self.scrollDirection = DRShotCardViewScrollDirectionHorizontal;
                    } else if (fabs(locx) < fabs(locy)) {
                        self.scrollDirection = DRShotCardViewScrollDirectionVertical;
                    }
                    break;
                }
                case DRShotCardViewScrollDirectionHorizontal: {
                    if (locx != 0) newCenter.x += locx;
                }
                case DRShotCardViewScrollDirectionVertical: {
                    if (locy != 0) newCenter.y += locy;
                }
                default:
                    break;
            }
        } else {
            newCenter.x += locx;
            newCenter.y += locy;
        }
        [UIView beginAnimations:kDragAnimationOnTouchMoveName context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.05];
        self.center = newCenter;
        [UIView commitAnimations];
    } else {
        [self touchesCancelled:touches withEvent:event];
    }
    
}

- (BOOL)directionLockEnabled {
    return NO;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _isMoving = NO;
    
    logUi(@" <TOUCH> touchesEnded idx: %d", NSStringFromCGRect(self.frame), self.tag);
    
    CGRect screenRect = [self.parentViewController.view bounds];
    CGFloat likeProgress = (1 - (self.frame.origin.y - kTopBarViewHeight) / (screenRect.size.height - kTopBarViewHeight));
    CGFloat followProgress = (self.frame.origin.y + self.frame.size.height) / screenRect.size.height;
    
    BOOL success = [self.parentViewController updateActionsProgressWithLikeProgress:likeProgress followProgress:followProgress allowAction:YES];
    if (!success) [self.parentViewController updateActionsProgressWithLikeProgress:0.f followProgress:0.f allowAction:NO];
    
    if (!self.isAnimatingFrame) {
        CGPoint newCenter = CGPointMake(screenRect.size.width / 2, self.parentViewController.cardYPosiyion + self.bounds.size.height / 2);
        
        [UIView beginAnimations:kDragAnimationOnTouchEndName context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.1];
        self.center = newCenter;
        [UIView commitAnimations];
    } else {
        [self touchesCancelled:touches withEvent:event];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    _isMoving = NO;
    [super touchesCancelled:touches withEvent:event];
}

- (void)incrementLikesCounter {
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@", self.currentShot.likes_count ? @([self.currentShot.likes_count intValue] + 1) : @""];
}

@end

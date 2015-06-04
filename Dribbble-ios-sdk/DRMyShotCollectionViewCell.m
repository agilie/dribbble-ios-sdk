//
//  DRMyShotCollectionViewCell.m
//  DribbbleRunner
//
//  Created by Vermillion on 27.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRMyShotCollectionViewCell.h"
#import "DRShot.h"
#import "DRApiService.h"

@interface DRMyShotCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *shotImage;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewsCountLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewCountsLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentCountLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likeCountsLabelWidthConstraint;


@end

static const NSString *kQueueURLconstant = @"DribbbleRunner.agilie";

@implementation DRMyShotCollectionViewCell

- (void)setShotInfo:(DRShot *)shotInfo {
    [self.shotImage setImage:[UIImage imageNamed:@"shot_bg"]];
    _shotInfo = shotInfo;
    
    [self setupUI];
}

- (void)setupUI {
    DRMyShotCollectionViewCell *cell = self;
    if (cell.shotInfo) {
        if ([cell.shotInfo.images.teaser length]) {
            __weak typeof(self)weakSelf = cell;
            [[DRApiService instance] requestImageWithUrl: cell.shotInfo.images.teaser completionHandler:^(id image, AFHTTPRequestOperation *operation) {
                if ([operation.request.URL absoluteString] != cell.shotInfo.images.teaser) return;
                [weakSelf.shotImage setImage:[UIImage imageWithData:image]];
            } failureHandler:^(NSError *error) {
                NSLog(@"%@", error.localizedDescription);
            }];
        } else {
            NSLog(@"No picture");
        }
        
        if (cell.shotInfo.views_count && [cell.shotInfo.views_count isKindOfClass:[NSNumber class]]) {
            NSString *text = [NSString stringWithFormat:@"%i", [cell.shotInfo.views_count intValue]];
            CGFloat width = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, cell.viewsCountLabel.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:cell.viewsCountLabel.font.familyName size:cell.viewsCountLabel.font.pointSize]} context:nil].size.width;
            [self updateConstraintsIfNeeded];
            self.viewCountsLabelWidthConstraint.constant = width + 0.5f;
            [self layoutIfNeeded];
            [cell.viewsCountLabel setText:text];
        }
        if (cell.shotInfo.likes_count && [cell.shotInfo.likes_count isKindOfClass:[NSNumber class]]) {
            
            NSString *text = [NSString stringWithFormat:@"%i", [cell.shotInfo.likes_count intValue]];
            CGFloat width = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, cell.likesCountLabel.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:cell.likesCountLabel.font.familyName size:cell.likesCountLabel.font.pointSize]} context:nil].size.width;
            [self updateConstraintsIfNeeded];
            self.likeCountsLabelWidthConstraint.constant = width;
            [self layoutIfNeeded];
            [cell.likesCountLabel setText:text];
        }
        if (cell.shotInfo.comments_count && [cell.shotInfo.comments_count isKindOfClass:[NSNumber class]]) {
            
            NSString *text = [NSString stringWithFormat:@"%i", [cell.shotInfo.comments_count intValue]];
            CGFloat width = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, cell.commentsCountLabel.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:cell.commentsCountLabel.font.familyName size:cell.commentsCountLabel.font.pointSize]} context:nil].size.width;
            [self updateConstraintsIfNeeded];
            self.commentCountLabelWidthConstraint.constant = width;
            [self layoutIfNeeded];
            [cell.commentsCountLabel setText:text];
        }
    }
}

@end

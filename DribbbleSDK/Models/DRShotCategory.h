//
//  DRShotCategory.h
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRBaseModel.h"
#import "DREnums.h"

@interface DRShotCategory : DRBaseModel

@property(strong, nonatomic) NSString *categoryName;
@property(nonatomic) DRShotCategoryType categoryType;
@property(strong, nonatomic) NSString *categoryValue;

// accessors

+ (NSMutableArray *)allCategories;

+ (DRShotCategory *)categoryWithType:(DRShotCategoryType)categoryType;

+ (DRShotCategory *)featuredShotsCategory;
+ (DRShotCategory *)recentShotsCategory;

- (BOOL)isFeaturedShotsCategory;

@end

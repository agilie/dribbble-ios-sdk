//
//  DRShotCategory.h
//  
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "JSONModel.h"
#import "DREnums.h"

@interface DRShotCategory : JSONModel

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

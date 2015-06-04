//
//  DRShotCategory.h
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DribbbleSDK.h"

@interface DRShotCategory : NSObject

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

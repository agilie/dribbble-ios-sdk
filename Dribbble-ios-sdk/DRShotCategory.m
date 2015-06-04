//
//  DRShotCategory.m
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRShotCategory.h"

@implementation DRShotCategory

#pragma mark - Generating

+ (DRShotCategory *)createCategoryWithName:(NSString *)name type:(DRShotCategoryType)type {
    DRShotCategory *category = [DRShotCategory new];
    category.categoryName = name;
    category.categoryType = type;
    category.categoryValue = [name lowercaseString];
    if ([category.categoryValue rangeOfString:@"gifs"].location != NSNotFound) {
        category.categoryValue = @"animated";
    }
    return category;
}

+ (NSArray *)allCategoriesNames {
    return @[@"Featured", @"Popular", @"Recent", @"Teams", @"Debuts", @"Playoffs", @"Animated GIFs"];
}

+ (NSArray *)allCategoriesTypes {
    return @[@(DRShotCategoryFeaturedShots), @(DRShotCategoryPopular), @(DRShotCategoryRecent), @(DRShotCategoryTeams), @(DRShotCategoryDebuts), @(DRShotCategoryPlayoffs), @(DRShotCategoryGifs)];
}

#pragma mark - Accessors

+ (NSMutableArray *)allCategories {
    static dispatch_once_t once;
    static NSMutableArray *categories;
    dispatch_once(&once, ^{
        categories = [NSMutableArray array];
        [[DRShotCategory allCategoriesTypes] enumerateObjectsUsingBlock:^(NSNumber *type, NSUInteger idx, BOOL *stop) {
            [categories addObject:[DRShotCategory createCategoryWithName:[[DRShotCategory allCategoriesNames] objectAtIndex:idx] type:[type integerValue]]];
        }];
    });
    return categories;
}

+ (DRShotCategory *)categoryWithType:(DRShotCategoryType)categoryType {
    for (DRShotCategory *category in [DRShotCategory allCategories]) {
        if (category.categoryType == categoryType) return category;
    }
    return nil;
}

+ (DRShotCategory *)featuredShotsCategory {
    return [DRShotCategory categoryWithType:DRShotCategoryFeaturedShots];
}

+ (DRShotCategory *)recentShotsCategory {
    return [DRShotCategory categoryWithType:DRShotCategoryRecent];
    
}

- (BOOL)isFeaturedShotsCategory {
    return self.categoryType == DRShotCategoryFeaturedShots;
}

- (BOOL)isEqual:(id)object {
    DRShotCategory *another = (DRShotCategory *)object;
    return (self.categoryType == another.categoryType && [self.categoryName isEqualToString:another.categoryName]);
}

- (NSUInteger)hash {
    return [self.categoryName hash];
}

@end

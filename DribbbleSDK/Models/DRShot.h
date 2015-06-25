//
//  DRShot.h
//  
//
//  Created by zgonik vova on 17.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRArtWork.h"

@class DRImage;

@interface DRShot : DRArtWork

@property (strong, nonatomic) NSNumber *shotId;
@property (strong, nonatomic) NSNumber *width;
@property (strong, nonatomic) NSNumber *height;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString <Optional>*shotDescription;
@property (strong, nonatomic) NSNumber *viewsCount;
@property (strong, nonatomic) NSNumber *likesCount;
@property (strong, nonatomic) NSNumber *commentsCount;
@property (strong, nonatomic) NSNumber *attachmentsCount;
@property (strong, nonatomic) DRImage *images;
@property (strong, nonatomic) NSNumber *reboundsCount;
@property (strong, nonatomic) NSNumber *bucketsCount;
@property (strong, nonatomic) NSString <Optional> *reboundSourceUrl;
@property (strong, nonatomic) NSString <Optional>*htmlUrl;
@property (strong, nonatomic) NSString <Optional>*attachmentsUrl;
@property (strong, nonatomic) NSString <Optional>*bucketsUrl;
@property (strong, nonatomic) NSString <Optional>*commentsUrl;
@property (strong, nonatomic) NSString <Optional>*likesUrl;
@property (strong, nonatomic) NSString <Optional>*projectsUrl;
@property (strong, nonatomic) NSString <Optional>*reboundsUrl;
@property (strong, nonatomic) NSArray *tags;

// helper properties

@property (nonatomic, readonly) NSString <Ignore> *defaultUrl;
@property (nonatomic, copy) NSString <Ignore> *fileType;
@property (nonatomic, readonly) NSNumber <Ignore> *authorityId;

- (BOOL)isAnimation;

@end

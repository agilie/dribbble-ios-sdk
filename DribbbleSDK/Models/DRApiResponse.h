//
//  DRBaseModel.h
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 18.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRApiResponse : NSObject

@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) id object;

+ (instancetype)modelWithError:(NSError *)error;
+ (instancetype)modelWithData:(id)data;
+ (instancetype)modelWithData:(id)data error:(NSError *)error;

@end
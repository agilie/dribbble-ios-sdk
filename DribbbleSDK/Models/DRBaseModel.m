//
//  DRBaseModel.m
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 18.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRBaseModel.h"

@implementation DRBaseModel

+ (instancetype)modelWithError:(NSError *)error {
    DRBaseModel *model = [DRBaseModel new];
    model.error = error;
    return model;
}

+ (instancetype)modelWithData:(id)data {
    DRBaseModel *model = [DRBaseModel new];
    model.object = data;
    return model;
}

+ (instancetype)modelWithData:(id)data error:(NSError *)error {
    DRBaseModel *model = [DRBaseModel new];
    model.object = data;
    model.error = error;
    return model;
}

@end

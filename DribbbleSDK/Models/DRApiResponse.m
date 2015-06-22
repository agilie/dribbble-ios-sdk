//
//  DRBaseModel.m
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 18.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRApiResponse.h"

@implementation DRApiResponse

+ (instancetype)modelWithError:(NSError *)error {
    DRApiResponse *model = [DRApiResponse new];
    model.error = error;
    return model;
}

+ (instancetype)modelWithData:(id)data {
    DRApiResponse *model = [DRApiResponse new];
    model.object = data;
    return model;
}

+ (instancetype)modelWithData:(id)data error:(NSError *)error {
    DRApiResponse *model = [DRApiResponse new];
    model.object = data;
    model.error = error;
    return model;
}

@end

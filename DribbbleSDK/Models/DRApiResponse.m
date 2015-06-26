//
//  DRBaseModel.m
//  
//
//  Created by Vladimir Zgonik on 18.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRApiResponse.h"

@implementation DRApiResponse

+ (instancetype)responseWithError:(NSError *)error {
    DRApiResponse *model = [DRApiResponse new];
    model.error = error;
    return model;
}

+ (instancetype)responseWithObject:(id)data {
    DRApiResponse *model = [DRApiResponse new];
    model.object = data;
    return model;
}

+ (instancetype)responseWithObject:(id)data error:(NSError *)error {
    DRApiResponse *model = [DRApiResponse new];
    model.object = data;
    model.error = error;
    return model;
}

@end

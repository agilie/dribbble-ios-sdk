//
//  DRTransactionModel.m
//  
//
//  Created by zgonik vova on 12.05.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRTransactionModel.h"
#import "DRCombinedJSONKeyMapper.h"

@implementation DRTransactionModel

+ (JSONKeyMapper *)keyMapper {
    return [[DRCombinedJSONKeyMapper alloc] initWithDictionary:@{@"id" : @"transactionId"}];
}

@end

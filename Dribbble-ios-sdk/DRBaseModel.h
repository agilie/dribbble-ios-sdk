//
//  DRBaseModel.h
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 18.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "DRDictionarySerializationProtocol.h"

@interface DRBaseModel : NSObject <DRDictionarySerializationProtocol>

@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) id object;
@property (assign, nonatomic) int code;

+ (instancetype)fromDictionary:(NSDictionary *)dict;
+ (instancetype)modelWithError:(NSError *)error;
+ (instancetype)modelWithData:(id)data;
+ (instancetype)modelWithData:(id)data error:(NSError *)error;

- (NSMutableDictionary *)toDictionary;

@end
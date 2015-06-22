//
//  DRCombinedJSONKeyMapper.m
//  DribbbleSDKDev
//
//  Created by Dmitry Salnikov on 6/22/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRCombinedJSONKeyMapper.h"

@implementation DRCombinedJSONKeyMapper

- (instancetype)initWithDictionary:(NSDictionary *)map {
    
    JSONKeyMapper *camelCaseMapper = [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
    
    NSMutableDictionary* userToModelMap = [NSMutableDictionary dictionaryWithDictionary: map];
    NSMutableDictionary* userToJSONMap  = [NSMutableDictionary dictionaryWithObjects:map.allKeys forKeys:map.allValues];
    
    JSONModelKeyMapBlock toModelBlock = ^NSString*(NSString* keyName) {
        NSString* result = [userToModelMap valueForKeyPath: keyName];
        return result ? result : camelCaseMapper.JSONToModelKeyBlock(keyName);
    };
    
    JSONModelKeyMapBlock toJsonBlock = ^NSString*(NSString* keyName) {
        NSString* result = [userToJSONMap valueForKeyPath: keyName];
        return result ? result : camelCaseMapper.modelToJSONKeyBlock(keyName);
    };
    
    self = [super initWithJSONToModelBlock:toModelBlock modelToJSONBlock:toJsonBlock];
    return self;
}

@end

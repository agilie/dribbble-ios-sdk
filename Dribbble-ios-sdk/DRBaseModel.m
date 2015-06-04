//
//  DRBaseModel.m
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 18.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DRBaseModel.h"

@implementation DRBaseModel

//static const char* getPropertyType(objc_property_t property) {
//    
//    const char *attributes = property_getAttributes(property);
//    char buffer[1 + strlen(attributes)];
//    strcpy(buffer, attributes);
//    
//    char *state = buffer;
//    char *attribute;
//    while ((attribute = strsep(&state, ",")) != NULL) {
//        if (attribute[0] == 'T' && strlen(attribute)>2) {
//            
//            static char newbuffer[100];
//            memset(newbuffer, 0x00, 100);
//            strncpy(newbuffer, (attribute + 3), strlen(attribute)-4);
//            newbuffer[1 + strlen(attribute)-4] = '\n';
//            return newbuffer;
//            
//            
//        }else if (attribute[0] == 'T' && strlen(attribute)==2) {
//            static char newbuffer[100];
//            memset(newbuffer, 0x00, 100);
//            strncpy(newbuffer, (attribute + 1), strlen(attribute)-1);
//            newbuffer[strlen(attribute)-1] = '\n';
//            return newbuffer;
//        }
//    }
//    
//    return "@";
//}
//
//+ (instancetype)fromDictionary:(NSDictionary *)dict {
//    id model = [[[self class] alloc] init];
//    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        if (![[[self class] transientProperties] containsObject:key] && ![key isEqualToString:@"id"]) {
//            NSString *setterStr = [NSString stringWithFormat:@"set%@%@:",
//                                   [[key substringToIndex:1] capitalizedString],
//                                   [key substringFromIndex:1]];
//            
//            id propertyValue = nil;
//            objc_property_t property = class_getProperty([self class], [key cStringUsingEncoding:NSUTF8StringEncoding]);
//            if (property != NULL) {
//                const char* className = getPropertyType(property);
//                Class theClass = objc_getClass([[NSString stringWithUTF8String:className] UTF8String]);
//                
//                if ([theClass conformsToProtocol:@protocol(DRDictionarySerializationProtocol)] ) {
//                    if ([dict obtain:key]) {
//                        if ([[dict objectForKey:key] isKindOfClass:[NSString class]]) {
//                            if ([[dict objectForKey:key] isKindOfClass:[NSString class]] && [[dict objectForKey:key] length] > 0) {
//                                propertyValue = [(id<DRDictionarySerializationProtocol>)theClass fromDictionary:[dict objectForKey:key]];
//                            }
//                        } else {
//                            propertyValue = [(id<DRDictionarySerializationProtocol>)theClass fromDictionary:[dict objectForKey:key]];
//                        }
//                    }
//                    if ([model respondsToSelector:NSSelectorFromString(setterStr)]) {
//                        [model setValue:propertyValue forKey:key];
//                    }
//                } else {
//                    if ([model respondsToSelector:NSSelectorFromString(setterStr)]) {
//                        [model setValue:[dict obtain:key] forKey:key];
//                    }
//                    if ([key isEqualToString:@"id"]) {
//                        [model setValue:[dict obtain:key] forKey:@"transactionId"];
//                    }
//                }
//            }
//        }
//    }];
//    
//    return model;
//}

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

//- (NSMutableDictionary *)toDictionary {
//    NSMutableDictionary *baseDictionary = [NSMutableDictionary dictionary];
//    unsigned int count = 0;
//    objc_property_t *properties = class_copyPropertyList([self class], &count);
//    for (int i = 0; i < count; i++) {
//        objc_property_t property = properties[i];
//        const char* propertyName = property_getName(property);
//        NSString *str = [NSString stringWithUTF8String:propertyName];
//        if ([str isEqualToString:@"superclass"]) {
//            break;
//        }
//        
//        if ([[[self class] transientProperties] containsObject:str]) continue;
//        
//        NSString *dictKey = str;
//        if ([str rangeOfString:@"Id"].location != NSNotFound) {
//            dictKey = @"id";
//        }
//        Class theClass = [[self valueForKey:str] class];  //object_getClass((__bridge id)(property));
//
//        id propertyValue = nil;
//        if ([theClass conformsToProtocol:@protocol(DRDictionarySerializationProtocol)] ) {
//            propertyValue = [(id<DRDictionarySerializationProtocol>)[self valueForKey:str] toDictionary];
//        } else {
//            propertyValue = [self valueForKey:str];
//        }
//        if (propertyValue) {
//            [baseDictionary setObject:propertyValue forKey:dictKey];
//        }
//    }
//    free (properties);
//    return baseDictionary;
//}

+ (NSArray *)transientProperties {
    return @[];
}

@end

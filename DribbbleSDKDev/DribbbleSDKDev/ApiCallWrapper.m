//
//  ApiCallWrapper.m
//  DribbbleSDKDev
//
//  Created by Dmitry Salnikov on 6/24/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "ApiCallWrapper.h"
#import "DribbbleSDK.h"

@implementation ApiCallWrapper

- (void)invokeWithApiClient:(DRApiClient *)client {
    SEL selector = NSSelectorFromString(self.selectorString);
    NSMethodSignature *signature = [[client class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:client];
    [invocation setSelector:selector];
    int index = 2;
    for (__unsafe_unretained id arg in self.args) {
        [invocation setArgument:&arg atIndex:index++];
    }
    
    DRResponseHandler handler = [self.responseHandler copy];
    [invocation retainArguments];
    [invocation setArgument:&handler atIndex:index];
    [invocation invoke];    
}

@end

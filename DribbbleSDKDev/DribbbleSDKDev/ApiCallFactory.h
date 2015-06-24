//
//  ApiCallFactory.h
//  DribbbleSDKDev
//
//  Created by Dmitry Salnikov on 6/24/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiCallWrapper.h"
#import "DribbbleSDK.h"

@interface ApiCallFactory : NSObject

+ (ApiCallWrapper *)apiCallWrapperWithTitle:(NSString *)title selector:(SEL)selector args:(NSArray *)args responseHandler:(DRResponseHandler)responseHandler;

+ (NSArray *)demoApiCallWrappers;

@end

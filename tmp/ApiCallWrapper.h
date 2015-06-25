//
//  ApiCallWrapper.h
//  DribbbleSDKDev
//
//  Created by Dmitry Salnikov on 6/24/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DribbbleSDK.h"

@class DRApiClient;

@interface ApiCallWrapper : NSObject

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) DRResponseHandler responseHandler;
@property (strong, nonatomic) NSArray *args;
@property (copy, nonatomic) NSString *selectorString;

- (void)invokeWithApiClient:(DRApiClient *)client;

@end

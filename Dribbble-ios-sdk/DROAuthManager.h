//
//  DROAuthManager.h
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOAuth2.h"
#import "DribbbleSDK.h"

@class DRApiClient;

@interface DROAuthManager : NSObject

@property (strong, nonatomic) UIWebView *webView;
@property (copy, nonatomic) DRHandler dismissWebViewBlock;
@property (copy, nonatomic) DRHandler progressHUDShowBlock;
@property (copy, nonatomic) DRHandler progressHUDDismissBlock;

- (void)requestOAuth2Login:(UIWebView *)webView completionHandler:(DRCompletionHandler)completion errorHandler:(DRErrorHandler)errorHandler;

@end

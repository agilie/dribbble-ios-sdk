//
//  DROAuthManager.h
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOAuth2.h"

@class DRApiClient;

@interface DROAuthManager : NSObject

@property (strong, nonatomic) UIWebView *webView;
@property (copy, nonatomic) DRHandler dismissWebViewBlock;
@property (copy, nonatomic) DRGeneralErrorHandler passErrorToClientBlock;
@property (copy, nonatomic) DRHandler progressHUDShowBlock;
@property (copy, nonatomic) DRHandler progressHUDDismissBlock;

- (void)pullCheckSumWithCompletionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)applyAccount:(NXOAuth2Account *)account withApiClient:(DRApiClient *)apiClient completionHandler:(DRCompletionHandler)completionHandler failureHandler:(DRErrorHandler)errorHandler;
- (void)requestOAuth2Login:(UIWebView *)webView withApiClient:(DRApiClient *)apiCLient completionHandler:(DRCompletionHandler)completion failureHandler:(DRErrorHandler)errorHandler;

@end

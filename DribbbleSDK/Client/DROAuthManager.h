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

@interface DROAuthManager : NSObject  <UIWebViewDelegate>

@property (copy, nonatomic) DRHandler dismissWebViewHandler;
@property (copy, nonatomic) DRHandler progressHUDShowHandler;
@property (copy, nonatomic) DRHandler progressHUDDismissHandler;

- (void)requestOAuth2Login:(UIWebView *)webView completionHandler:(DRCompletionHandler)completion;

@end

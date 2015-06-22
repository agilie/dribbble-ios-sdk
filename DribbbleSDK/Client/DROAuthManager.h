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
#import "DRApiClientSettings.h"

@interface DROAuthManager : NSObject <UIWebViewDelegate>

@property (copy, nonatomic) DRHandler dismissWebViewHandler;

- (void)authorizeWithWebView:(UIWebView *)webView settings:(DRApiClientSettings *)settings completionHandler:(DRCompletionHandler)completion;

@end

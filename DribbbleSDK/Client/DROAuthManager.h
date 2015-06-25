//
//  DROAuthManager.h
//  
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DribbbleSDK.h"

@class DRApiClientSettings;

@interface DROAuthManager : NSObject <UIWebViewDelegate>

- (void)authorizeWithWebView:(UIWebView *)webView settings:(DRApiClientSettings *)settings authHandler:(DROAuthHandler)authHandler;

@end

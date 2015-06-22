//
//  DROAuthManager.m
//  DribbbleRunner
//
//  Created by Vladimir Zgonik on 31.03.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "DROAuthManager.h"
#import "DRApiClient.h"
#import "DRApiResponse.h"

@interface DROAuthManager ()

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) id<NSObject> authCompletionObserver;
@property (strong, nonatomic) id<NSObject> authErrorObserver;

@property (strong, nonatomic) NSString *redirectUrl;

@end

@implementation DROAuthManager

#pragma mark - OAuth2 Logic

- (void)authorizeWithWebView:(UIWebView *)webView settings:(DRApiClientSettings *)settings completionHandler:(DRCompletionHandler)completion {
    self.webView = webView;
    self.webView.delegate = self;
    NXOAuth2AccountStore *accountStore = [NXOAuth2AccountStore sharedStore];
    [accountStore setClientID:settings.clientId
                       secret:settings.clientSecret
                        scope:[NSSet setWithObjects: @"public", @"write", nil]
             authorizationURL:[NSURL URLWithString:settings.oAuth2AuthorizationUrl]
                     tokenURL:[NSURL URLWithString:settings.oAuth2TokenUrl]
                  redirectURL:[NSURL URLWithString:settings.oAuth2RedirectUrl]
                keyChainGroup:kIDMOAccountType
               forAccountType:kIDMOAccountType];
    self.redirectUrl = settings.oAuth2RedirectUrl;
    
    __weak typeof(self)weakSelf = self;
    [accountStore requestAccessToAccountWithType:kIDMOAccountType withPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:preparedURL];        
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [webView loadRequest:request];
    }];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    if (self.authCompletionObserver) [notificationCenter removeObserver:self.authCompletionObserver];
    if (self.authErrorObserver) [notificationCenter removeObserver:self.authErrorObserver];
    
    self.authCompletionObserver = [notificationCenter addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification object:[NXOAuth2AccountStore sharedStore] queue:nil usingBlock:^(NSNotification *aNotification) {
        NXOAuth2Account *account = [[aNotification userInfo] objectForKey:NXOAuth2AccountStoreNewAccountUserInfoKey];
        logInteral(@"We have token in OAuthManager:%@", account.accessToken.accessToken);
        if (account.accessToken.accessToken) {
            if (completion) completion([DRApiResponse modelWithData:account]);
        } else {
            if (completion) completion([DRApiResponse modelWithError:[NSError errorWithDomain:kInvalidAuthData code:kHttpAuthErrorCode userInfo:nil]]);
        }
        [[NSNotificationCenter defaultCenter] removeObserver:weakSelf.authCompletionObserver];
    }];
    self.authErrorObserver = [notificationCenter addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification object:[NXOAuth2AccountStore sharedStore] queue:nil usingBlock:^(NSNotification *aNotification) {
        NSError *error = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
        if (completion) {
            completion([DRApiResponse modelWithError:error]);
        }
        [[NSNotificationCenter defaultCenter] removeObserver:weakSelf.authErrorObserver];
    }];
}

#pragma mark - WebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (self.progressHUDShowHandler) {
        self.progressHUDShowHandler();
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.progressHUDDismissHandler) self.progressHUDDismissHandler();
    //if the UIWebView is showing our authorization URL, show the UIWebView control
    if ([webView.request.URL.absoluteString rangeOfString:self.redirectUrl options:NSCaseInsensitiveSearch].location != NSNotFound) {
        self.webView.userInteractionEnabled = YES;
        NSDictionary *params = [self grabUrlParameters:webView.request.URL];
        if ([params objectForKey:@"code"]) {
            [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:kIDMOAccountType] enumerateObjectsUsingBlock:^(NXOAuth2Account * obj, NSUInteger idx, BOOL *stop) {
                [[NXOAuth2AccountStore sharedStore] removeAccount:obj];
            }];
            [[NXOAuth2AccountStore sharedStore] handleRedirectURL:webView.request.URL];
        } else {
            self.webView.userInteractionEnabled = NO;
        }
    } else if ([webView.request.URL.absoluteString rangeOfString:kUnacceptableWebViewUrl options:NSCaseInsensitiveSearch].location != NSNotFound) {
        if (self.dismissWebViewHandler) {
            self.dismissWebViewHandler();
            self.dismissWebViewHandler = nil;
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.progressHUDDismissHandler) self.progressHUDDismissHandler();
}

#pragma mark - Helpers

- (NSMutableDictionary *)grabUrlParameters:(NSURL *) url {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *tmpKey = [url query];
    for (NSString *param in [[url query] componentsSeparatedByString:@"="]) {
        if ([tmpKey rangeOfString:param].location == NSNotFound) {
            [params setValue:param forKey:tmpKey];
            tmpKey = nil;
        }
        tmpKey = param;
    }
    return params;
}

@end
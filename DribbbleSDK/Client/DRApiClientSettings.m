//
//  DRApiClientSettings.m
//  
//
//  Created by Dmitry Salnikov on 6/17/15.
//
//

#import "DRApiClientSettings.h"

@implementation DRApiClientSettings

//@synthesize baseUrl = _baseUrl;

- (instancetype)initWithBaseUrl:(NSString *)baseUrl
              oAuth2RedirectUrl:(NSString *)oAuth2RedirectUrl
         oAuth2AuthorizationUrl:(NSString *)oAuth2AuthorizationUrl
                 oAuth2TokenUrl:(NSString *)oAuth2TokenUrl
                       clientId:(NSString *)clientId
                   clientSecret:(NSString *)clientSecret
              clientAccessToken:(NSString *)clientAccessToken {
    
    if (self = [super init]) {
        _baseUrl = baseUrl;
        _oAuth2RedirectUrl = oAuth2RedirectUrl;
        _oAuth2TokenUrl = oAuth2TokenUrl;
        _oAuth2AuthorizationUrl = oAuth2AuthorizationUrl;
        _clientId = clientId;
        _clientSecret = clientSecret;
        _clientAccessToken = clientAccessToken;
    }
    return self;
}

@end

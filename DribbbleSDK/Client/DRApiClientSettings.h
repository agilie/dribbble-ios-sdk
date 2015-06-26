//
//  DRApiClientSettings.h
//  
//
//  Created by Dmitry Salnikov on 6/17/15.
//
//

#import <Foundation/Foundation.h>

@interface DRApiClientSettings : NSObject

@property (strong, nonatomic, readonly) NSString *baseUrl;
@property (strong, nonatomic, readonly) NSString *oAuth2RedirectUrl;
@property (strong, nonatomic, readonly) NSString *oAuth2AuthorizationUrl;
@property (strong, nonatomic, readonly) NSString *oAuth2TokenUrl;

// Dribbble App Settings

@property (strong, nonatomic, readonly) NSSet *scopes;
@property (strong, nonatomic, readonly) NSString *clientId;
@property (strong, nonatomic, readonly) NSString *clientSecret;
@property (strong, nonatomic, readonly) NSString *clientAccessToken;

- (instancetype)initWithBaseUrl:(NSString *)baseUrl
              oAuth2RedirectUrl:(NSString *)oAuth2RedirectUrl
         oAuth2AuthorizationUrl:(NSString *)oAuth2AuthorizationUrl
                 oAuth2TokenUrl:(NSString *)oAuth2TokenUrl
                       clientId:(NSString *)clientId
                   clientSecret:(NSString *)clientSecret
              clientAccessToken:(NSString *)clientAccessToken
                         scopes:(NSSet *)scopes;

@end

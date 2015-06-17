//
//  DRApiClientSettings.h
//  
//
//  Created by Dmitry Salnikov on 6/17/15.
//
//

#import <Foundation/Foundation.h>

@interface DRApiClientSettings : NSObject

@property (strong, readonly) NSString *baseUrl;
@property (nonatomic, copy) NSString *oAuth2RedirectUrl;
@property (nonatomic, copy) NSString *oAuth2AuthorizationUrl;
@property (nonatomic, copy) NSString *oAuth2TokenUrl;

// Dribbble App Settings

@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *clientSecret;
@property (nonatomic, copy) NSString *clientAccessToken;

@end

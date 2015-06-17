//
//  DRLoadDataTestCase.h
//  DribbbleSDK Tests
//
//  Created by zgonik vova on 12.06.15.
//
//

#import <XCTest/XCTest.h>
#import "Expecta.h"

extern NSString * const DribbbleSDKTestsBaseURLString;

@interface DRLoadDataTestCase : XCTestCase

@property (nonatomic, strong, readonly) NSURL *baseURL; 

@end
//
//  DRLink.h
//  
//
//  Created by Vladimir Zgonik on 10.04.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "JSONModel.h"

@interface DRLink : JSONModel

@property (strong, nonatomic) NSString <Optional>*web;
@property (strong, nonatomic) NSString <Optional>*twitter;

@end

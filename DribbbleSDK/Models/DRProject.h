//
//  DRProject.h
//  
//
//  Created by zgonik vova on 23.06.15.
//
//

#import "DRArtWork.h"

@interface DRProject : DRArtWork

@property (strong, nonatomic) NSNumber *projectId;
@property (strong, nonatomic) NSString <Optional>*projectDescription;
@property (strong, nonatomic) NSString <Optional>*name;
@property (strong, nonatomic) NSNumber *shotsCount;

@end

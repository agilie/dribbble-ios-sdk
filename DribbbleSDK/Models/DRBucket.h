//
//  DRBucket.h
//  Pods
//
//  Created by Vermillion on 15.07.15.
//
//

#import "JSONModel.h"

@interface DRBucket : JSONModel

@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSString <Optional>*bucketDescription;
@property (strong, nonatomic) NSNumber *bucketId;
@property (strong, nonatomic) NSString <Optional>*name;
@property (strong, nonatomic) NSNumber *shotsCount;
@property (strong, nonatomic) NSString *updatedAt;

@end

//
//  DRShotAttachment.h
//  
//
//  Created by zgonik vova on 23.06.15.
//
//

#import "JSONModel.h"

@interface DRShotAttachment : JSONModel

@property (strong, nonatomic) NSNumber *attachmentId;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *thumbnailUrl;
@property (strong, nonatomic) NSString *contentType;
@property (strong, nonatomic) NSNumber *size;
@property (strong, nonatomic) NSNumber *viewsCount;
@property (strong, nonatomic) NSString *createdAt;

@end

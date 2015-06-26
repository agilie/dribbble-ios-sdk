//
//  DRArtWork.h
//  
//
//  Created by zgonik vova on 23.06.15.
//
//

#import "JSONModel.h"

@class DRUser, DRTeam;

@interface DRArtWork : JSONModel

@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSString *updatedAt;
@property (strong, nonatomic) DRUser <Optional> *user;
@property (strong, nonatomic) DRTeam <Optional> *team;


@end

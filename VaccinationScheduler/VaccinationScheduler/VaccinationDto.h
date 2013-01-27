//
//  VaccinationDto.h
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VaccinationDto : NSObject
@property (nonatomic)NSInteger vcId;
@property (strong,nonatomic)NSString *name;
@property (nonatomic)NSInteger needTimes;
@property (nonatomic)NSInteger period;
@end

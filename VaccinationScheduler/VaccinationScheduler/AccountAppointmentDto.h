//
//  AccountAppointmentDto.h
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountAppointmentDto : NSObject
@property(strong,nonatomic)NSString *appointment;
@property(strong,nonatomic)NSString *appointmentDate;
@property(nonatomic)NSInteger times;
@property(nonatomic)BOOL isSynced;
@end

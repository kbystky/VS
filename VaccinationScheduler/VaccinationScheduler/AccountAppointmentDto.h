//
//  AccountAppointmentDto.h
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VaccinationDto;
@interface AccountAppointmentDto : NSObject
@property(nonatomic)NSInteger apId;
@property(nonatomic)NSInteger accountId;
@property(nonatomic)NSInteger vcId;
@property(nonatomic)NSInteger times;
@property(strong,nonatomic)NSString *appointmentDate;
@property(strong,nonatomic)NSString *consultationDate;
@property(nonatomic)BOOL isSynced;
@property(strong,nonatomic)VaccinationDto *vaccinationDto;
@end

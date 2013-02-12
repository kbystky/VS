//
//  AccountAppointmentDao.h
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AccountAppointmentDto;
@interface AccountAppointmentDao : NSObject
- (NSArray *)appointmentsDataWithAccountId:(NSInteger)accountid;
- (NSArray *)allAppointmentsData;
- (BOOL)saveAppointmentWithAccountAppointmentDto:(AccountAppointmentDto *)dto;
-(BOOL)updateAppointmentWithAccountAppointmentDto:(AccountAppointmentDto *)dto;
-(BOOL)updateAppointmentWithAccountAppointmentsDto:(NSArray *)appointments;
- (BOOL)removeAppointmentWithAppointmentId:(NSInteger)appointmentId;
-(BOOL)removeAppointmentsWithAccoutId:(NSInteger)accountId;
-(BOOL)removeAppointmentsWithAppointmens:(NSArray *)appointmentsDto;
@end

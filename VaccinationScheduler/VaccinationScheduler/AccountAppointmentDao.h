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
-(NSInteger)timesWithAccountId:(NSInteger)accountid vaccinationName:(NSString *)name;
//-(BOOL)saveAppointmentWithDate:(NSString *)date vaccinationName:(NSString *)name times:(NSInteger)times accountId:(NSInteger)accountid;
-(NSString *)dateWithAccountId:(NSInteger)accountid vaccinationName:(NSString *)name times:(NSInteger)times;
-(BOOL)allDelete;
-(BOOL)deleteWithAccountId:(NSInteger)accountid;


- (NSArray *)appointmentsDataWithAccountId:(NSInteger)accountid;
- (NSArray *)allAppointmentsData;
- (BOOL)saveAppointmentWithAccountAppointmentDto:(AccountAppointmentDto *)dto;
-(BOOL)updateAppointmentWithAccountAppointmentDto:(AccountAppointmentDto *)dto;
- (BOOL)removeAppointmentWithAppointmentId:(NSInteger)appointmentId;
-(BOOL)removeAppointmentsWithAccoutId:(NSInteger)accountId;
@end

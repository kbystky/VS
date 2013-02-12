//
//  LocalNotificationManager.h
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
typedef enum{
    NOTIFICATION_TIMING_TYPE_TODAY=0,
    NOTIFICATION_TIMING_TYPE_PREVIOUSDAY,
    NOTIFICATION_TIMING_TYPE_FORPRESENTATION,
}TypeOfNotification;

#import <Foundation/Foundation.h>

@class AccountAppointmentDto;
@interface LocalNotificationManager : NSObject
- (void)cancelNotificationWithAccountId:(NSInteger)accountId;
-(void)createNotificationWithRecordDate:(NSString *)recDay appointmentDto:(AccountAppointmentDto *)appointmentDto;
-(void)changeNotificationFireDateWithOldAppointmentDto:(AccountAppointmentDto *)oldDto newAppointmentDto:(AccountAppointmentDto *)newDto;
-(void)changeAllNotificationFireDateWithTimingType:(NSInteger)type;
@end

//
//  LocalNotificationManager.m
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "LocalNotificationManager.h"
#import "UserDefaultsManager.h"
#import "StringConst.h"
#import "DateFormatter.h"
#import "AccountInfoDto.h"
#import "AccountAppointmentDto.h"
#import "VaccinationDto.h"
@interface LocalNotificationManager()
{
    UserDefaultsManager *manager;
}
@end

@implementation LocalNotificationManager
-(id)init
{
    self = [super init];
    if(self != nil){
        manager = [[UserDefaultsManager alloc]init];
    }
    return self;
}
//FIXME: for presentation
-(void)createNotificationWithRecordDate:(NSString *)recDay appointmentDto:(AccountAppointmentDto *)appointmentDto
{
    FUNK();
    // FIX: for presentation
    //NSDate *declarationDay =[DateFormatter dateFormatWithString:recDay];
    NSDate *declarationDay  = [NSDate date];

    // アラート通知する日時
    // FIX: for presentation
    //NSInteger fireTiming = manager.notificationTiming;
    //NSDate *dateAlert =  [declarationDay initWithTimeInterval:[self calTimeIntercalWithTimingType:fireTiming declarationDay:declarationDay] sinceDate:declarationDay];
    NSDate *dateAlert = [[NSDate date] addTimeInterval:10];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    // 通知日時を設定
    [localNotification setFireDate:dateAlert];
    [localNotification setTimeZone:[NSTimeZone localTimeZone]];
    [localNotification setSoundName:UILocalNotificationDefaultSoundName];
    // ボタンの設定
    [localNotification setAlertAction:@"開く"];
    // メッセージを設定する
    
    AccountInfoDto *accountDto = [manager accountWithId:appointmentDto.accountId];
    [localNotification setAlertBody:[NSString stringWithFormat:@"%@ちゃんの予防接種の\n予定日が近づいています",accountDto.name]];
    
    NSString *key = [self createUserInfoKeyWithRecordDay:declarationDay appointmentDto:appointmentDto];
    [localNotification setUserInfo:[NSDictionary dictionaryWithObject:@"1" forKey:key]];
    // 登録
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}
-(NSTimeInterval)calTimeIntercalWithTimingType:(NSInteger)type declarationDay:(NSDate *)declarationDay
{
    NSTimeInterval since = [[self notificationFireDateWithTimingType:type declarationDay:declarationDay] timeIntervalSinceDate:declarationDay];
    NSLog(@"time interval %f",since);
    return since;
}
-(NSDate *)notificationFireDateWithTimingType:(NSInteger)type declarationDay:(NSDate *)declarationDay{
    NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit | NSHourCalendarUnit |NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *comps=[cal components:flags fromDate:declarationDay];
    
    NSDateComponents *comps2 = [[NSDateComponents alloc]init];
    
    switch (type) {
            //当日7時
        case NOTIFICATION_TIMING_TYPE_TODAY:
            [comps2 setHour:7];
            [comps2 setDay:[comps day]];
            [comps2 setMonth:[comps month]];
            [comps2 setYear:[comps year]];
            break;
            //前日17時
        case NOTIFICATION_TIMING_TYPE_PREVIOUSDAY:
            [comps2 setHour:17];
            [comps2 setDay:[comps day]-1];
            if([comps day]-1 == 0){
                [comps2 setMonth:[comps month]-1];
            }else{
                [comps2 setMonth:[comps month]];
            }
            [comps2 setYear:[comps year]];
            break;
        case NOTIFICATION_TIMING_TYPE_FORPRESENTATION:
            [comps2 setSecond:[comps second] + 10];
            [comps2 setMinute:[comps minute]];
            [comps2 setHour:[comps hour]];
            [comps2 setDay:[comps day]];
            [comps2 setMonth:[comps month]];
            [comps2 setYear:[comps year]];
            break;
        default:
            break;
    }
    FUNK();
    NSLog(@"%@",[cal dateFromComponents:comps2].description);
    return [cal dateFromComponents:comps2]; 
}

-(NSString *)createUserInfoKeyWithRecordDay:(NSDate *)recDay appointmentDto:(AccountAppointmentDto *)appointment
{
    NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit;
    NSDateComponents *comps=[cal components:flags fromDate:recDay];
    return [NSString stringWithFormat:@"%d_%d_%d_%d_%d_%d",
            appointment.accountId,[comps year],[comps month],[comps day],
            appointment.vcId,appointment.times];
}


// ローカル通知キャンセル
- (void)cancelNotificationWithRecordDate:(NSDate *)recDay{
    // アラート通知をキャンセルする(重複通知対策)
    for (UILocalNotification *notify in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        NSInteger keyId = [[notify.userInfo objectForKey:@"NOTIF_KEY"] intValue];
        if (keyId == 1) {
            [[UIApplication sharedApplication] cancelLocalNotification:notify];
            break;
        }
    }
}

- (void)cancelAllNotification{
    for (UILocalNotification *notify in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        [[UIApplication sharedApplication] cancelLocalNotification:notify];
    }
}

-(void)changeAllNotificationFireDateWithTimingType:(NSInteger)type{
    FUNK();
    for (UILocalNotification *notify in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        
        // アラート通知する日時
        // FIX: for presentation
        //NSInteger fireTiming = manager.notificationTiming;
        //NSDate *dateAlert =  [declarationDay initWithTimeInterval:[self calTimeIntercalWithTimingType:fireTiming declarationDay:declarationDay] sinceDate:declarationDay];
        NSDate *dateAlert = [[NSDate date] addTimeInterval:10];
        
        // 通知日時を設定
        UILocalNotification *newLocalNotification = [[UILocalNotification alloc] init];
        [newLocalNotification setFireDate:dateAlert];
        [newLocalNotification setTimeZone:[NSTimeZone localTimeZone]];
        [newLocalNotification setSoundName:UILocalNotificationDefaultSoundName];
        // ボタンの設定
        [newLocalNotification setAlertAction:@"開く"];
        // メッセージを設定する
        [newLocalNotification setAlertBody:notify.alertBody];
        
        [newLocalNotification setUserInfo:notify.userInfo];
        // 登録・削除
        [[UIApplication sharedApplication] scheduleLocalNotification:newLocalNotification];
        [[UIApplication sharedApplication] cancelLocalNotification:notify];
    }
}

-(NSDate *)dateFormatWithString:(NSString *)string
{
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy/MM/dd"];
    return [df dateFromString:string];
}

@end

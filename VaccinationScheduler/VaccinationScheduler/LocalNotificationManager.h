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
- (void)cancelNotificationWithRecordDate:(NSDate *)recDay;
-(void)createNotificationWithRecordDate:(NSString *)recDay appointmentDto:(AccountAppointmentDto *)appointmentDto;
-(void)changeAllNotificationFireDateWithTimingType:(NSInteger)type;
@end
/*
 -(void)createNotificationWithRecordDate:(NSString *)recDay accountId:(NSInteger)accountId{
 FUNK();
 //プレゼン用 FIX
 //    NSDate *declarationDay =[DateFormatter dateFormatWithString:recDay];
 NSDate *declarationDay  = [NSDate date];
 
 // アラート通知する日時
 NSInteger fireTiming = manager.notificationTiming;
 NSDate *dateAlert =  [declarationDay initWithTimeInterval:[self calTimeIntercalWithTimingType:fireTiming declarationDay:declarationDay] sinceDate:declarationDay];
 
 UILocalNotification *localNotification = [[UILocalNotification alloc] init];
 // 通知日時を設定
 [localNotification setFireDate:dateAlert];
 // タイムゾーンを指定
 [localNotification setTimeZone:[NSTimeZone localTimeZone]];
 // 効果音は標準の効果音を利用
 [localNotification setSoundName:UILocalNotificationDefaultSoundName];
 // ボタンの設定
 [localNotification setAlertAction:@"開く"];
 // メッセージを設定する
 
 AccountInfoDto *accountDto = [manager accountWithId:accountId];
 
 [localNotification setAlertBody:[NSString stringWithFormat:@"%@ちゃんの予防接種の\n予定日が近づいています",accountDto.name]];
 // キーの設定
 NSDictionary *vInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:12],[NSNumber numberWithInt:2],nil]
 forKeys:[NSArray arrayWithObjects:@"id",@"times",nil]];
 NSString *key = [self createUserInfoKeyWithAccountNo:accountId recordDay:declarationDay vaccinationInfo:vInfo];
 [localNotification setUserInfo:[NSDictionary dictionaryWithObject:@"1"
 forKey:key]];
 // 登録
 [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
 }
 
 -(NSString *)createUserInfoKeyWithAccountNo:(NSInteger)no recordDay:(NSDate *)recDay vaccinationInfo:(NSDictionary *)info{
 
 NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
 [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
 NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit;
 NSDateComponents *comps=[cal components:flags fromDate:recDay];
 
 return [NSString stringWithFormat:@"%d_%d_%d_%d_%d_%d",no,[comps year],[comps month],[comps day],[[info objectForKey:@"id"] intValue],[[info objectForKey:@"times"] intValue]];
 }

 */
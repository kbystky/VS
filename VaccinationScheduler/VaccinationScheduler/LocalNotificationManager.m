//
//  LocalNotificationManager.m
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "LocalNotificationManager.h"
#import "UserDefaultsManager.h"
@implementation LocalNotificationManager

-(void)createNotificationWithRecordDate:(NSString *)recDay accountId:(NSInteger)accountId{
    FUNK();

    //プレゼン用 FIX
    //       NSDate *declarationDay = [self dateFormmatWithString:recDay];
    NSDate *declarationDay  = [NSDate date];
    
    // アラート通知する日時
    NSDate *dateAlert =  [declarationDay initWithTimeInterval:[self calTimeIntercalWithTimingType:2 declarationDay:declarationDay] sinceDate:declarationDay];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    // 通知日時を設定
    [localNotification setFireDate:dateAlert];
    // タイムゾーンを指定
    [localNotification setTimeZone:[NSTimeZone localTimeZone]];
    // 効果音は標準の効果音を利用
    [localNotification setSoundName:UILocalNotificationDefaultSoundName];
    // ボタンの設定
    [localNotification setAlertAction:@"Open"];
    // メッセージを設定する
    
    UserDefaultsManager *manager = [[UserDefaultsManager alloc]init];
    NSDictionary *account = [manager accountWithId:accountId];
    
    [localNotification setAlertBody:[NSString stringWithFormat:@"%@ちゃんの予防接種の\n予定日が近づいています",[account objectForKey:[UserDefaultsManager accountNameKey]]]];
    // キーの設定
    NSDictionary *vInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:12],[NSNumber numberWithInt:2],nil] 
                                                      forKeys:[NSArray arrayWithObjects:@"id",@"times",nil]];
    NSString *key = [self createUserInfoKeyWithAccountNo:accountId recordDay:declarationDay vaccinationInfo:vInfo];
    [localNotification setUserInfo:[NSDictionary dictionaryWithObject:@"1" 
                                                               forKey:key]];
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
    return [cal dateFromComponents:comps2];  //10秒
}

-(NSString *)createUserInfoKeyWithAccountNo:(NSInteger)no recordDay:(NSDate *)recDay vaccinationInfo:(NSDictionary *)info{
    
    NSCalendar *cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit;
    NSDateComponents *comps=[cal components:flags fromDate:recDay]; 
    
    return [NSString stringWithFormat:@"%d_%d_%d_%d_%d_%d",no,[comps year],[comps month],[comps day],[[info objectForKey:@"id"] intValue],[[info objectForKey:@"times"] intValue]];    
}

// ローカル通知キャンセル
- (void)cancelNotificationWithRecordDate:(NSDate *)recDay{
    // アラート通知をキャンセルする(重複通知対策)
    for (UILocalNotification *notify in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        NSInteger keyId = [[notify.userInfo objectForKey:@"NOTIF_KEY"] intValue];
        
        if (keyId == 1) {
            [[UIApplication sharedApplication] cancelLocalNotification:notify];
        }
    }
}

- (void)cancelAllNotification{
    for (UILocalNotification *notify in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        [[UIApplication sharedApplication] cancelLocalNotification:notify];
    }
}

-(void)changeAllNotificationFireDateWithTimingType:(NSInteger)type{
    //予定として入っているものをデータベースから取得し登録し直す
    for (UILocalNotification *notify in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        [[UIApplication sharedApplication] cancelLocalNotification:notify];
        //TODO
//        NSDate *pastFireDate = notify.fireDate;
        switch (type) {
                //当日7時
                //ぷら１日して午前7時にする
            case NOTIFICATION_TIMING_TYPE_TODAY:
                
                break;
                
                //前日17時
                //まいな１日して午後5時にする
            case NOTIFICATION_TIMING_TYPE_PREVIOUSDAY:
                break;
            case NOTIFICATION_TIMING_TYPE_FORPRESENTATION:
                break;
            default:
                break;
        }
        
        [notify setFireDate:[NSDate date]];
        [[UIApplication sharedApplication] scheduleLocalNotification:notify];
    }
    
}

-(NSDate *)dateFormmatWithString:(NSString *)string
{
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy/MM/dd"];
    return [df dateFromString:string];
}

@end

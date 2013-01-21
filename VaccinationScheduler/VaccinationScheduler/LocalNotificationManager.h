//
//  LocalNotificationManager.h
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
enum{
    NOTIFICATION_TIMING_TYPE_TODAY,
    NOTIFICATION_TIMING_TYPE_PREVIOUSDAY,
    NOTIFICATION_TIMING_TYPE_FORPRESENTATION,
};
#import <Foundation/Foundation.h>

@interface LocalNotificationManager : NSObject
-(void)createNotificationWithRecordDate:(NSString *)recDay accountId:(NSInteger)accountId;
- (void)cancelNotificationWithRecordDate:(NSDate *)recDay;
@end

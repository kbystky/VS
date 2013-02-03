//
//  Calendar.h
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/02.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Calendar : NSObject
{
    NSCalendar *cal;
    NSInteger year;
    NSInteger month;
//    NSInteger thisYear;
//    NSInteger thisMonth;
}
@property NSInteger year;
@property NSInteger month;
//@property NSInteger thisYear;
//@property NSInteger thisMonth;
//@property NSInteger thisDay;

/************** initialize **************/
-(id)init;
/************** Utility For Create Calender **************/
-(NSInteger)numberOfWeekWithMonth:(NSInteger)m inYear:(NSInteger)y;
-(NSArray *)monthDays;

-(NSArray *)firstDateAndEndDateWithYear:(int)_year month:(int)_month;

/************** cal Action **************/
-(void)tapDayWithDayInfo:(NSDictionary*)info;
-(BOOL)isTapSelectedDayWithTapDayInfo:(NSDictionary *)tapDayInfo selectedDayInfo:(NSDictionary *)selectedDayInfo;
-(void)gotoNext;
-(void)gotoPrev;
@end



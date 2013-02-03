//
//  Calendar.m
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/02.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Calendar.h"
#import "DateFormatter.h"

@interface Calendar()
@end

@implementation Calendar

@synthesize year;
@synthesize month;
//@synthesize thisYear;
//@synthesize thisMonth;
//@synthesize thisDay;

#pragma mark ************** initialize **************
-(id)init{
    FUNK();
    self = [super init];
    
    if(self != nil){
        
        cal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        /*
         ↑でカレンダーにtimezoneを設定しないと
         NSDateComponents するときにグリニッジ標準時になる
         */
        
        [self getTodayInfo];
    }
    return self;
}

-(void)getTodayInfo{
    FUNK();
    // timezoneを設定しないとグリニッジ標準時になる
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone systemTimeZone] secondsFromGMT]];
    
    NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit | NSHourCalendarUnit |NSMinuteCalendarUnit;
    NSDateComponents *comps=[cal components:flags fromDate:today];
    
    year = [comps year];
    month = [comps month];
    //    thisYear = [comps year];
    //    thisMonth = [comps month];
    //    thisDay = [comps day];
}

#pragma mark ************** Utility For Create Calender **************

//月の初日の曜日を求める
-(NSInteger)weekDayOfFirstDayWithMonth:(NSInteger)m inYear:(NSInteger)y{
    FUNK();
    
    NSDateComponents *com = [[NSDateComponents alloc]init];
    [com setDay:1];
    [com setYear:y];
    [com setMonth:m];
    
    //今月の最初の情報
    NSDate *theDay = [cal dateFromComponents:com];
    
    NSDateComponents *weekDayCom = [cal components:NSWeekdayCalendarUnit fromDate:theDay];
    NSLog(@"%d年%d月の月初めの曜日は：%d",y,m,[weekDayCom weekday]);
    return [weekDayCom weekday];
}

//月末の曜日を求める
-(NSInteger)weekDayOfLastDayWithMonth:(NSInteger)m inYear:(NSInteger)y{
    FUNK();
    
    NSDateComponents *weekDayCom =
    [cal components:NSWeekdayCalendarUnit
           fromDate:[self lastDayOfMonthWithMonth:m inYear:y]];
    
    NSLog(@"%d年%d月の月末の曜日は：%d",y,m,[weekDayCom weekday]);
    return [weekDayCom weekday];
}

//月末のNSDateを取得する
-(NSDate *)lastDayOfMonthWithMonth:(NSInteger)m inYear:(NSInteger)y{
    FUNK();
    
    NSDateComponents *com = [[NSDateComponents alloc]init];
    [com setDay:[self numberOfDayOfMonth:m inYear:y]];
    [com setYear:y];
    [com setMonth:m];
    return  [cal dateFromComponents:com];
}


//該当月の日数を求める
-(NSInteger)numberOfDayOfMonth:(NSInteger)m inYear:(NSInteger)y{
    FUNK();
    
    NSDateComponents *com = [[NSDateComponents alloc]init];
    
    [com setDay:1];
    [com setYear:y];
    [com setMonth:m];
    
    NSDate *theDay = [cal dateFromComponents:com];
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit
                              inUnit:NSMonthCalendarUnit
                             forDate:theDay];
    NSLog(@"%d年%d月の日数は：%d",y,m,range.length);
    return range.length;
}

//先月の末日の日付を取得する
-(NSInteger )getLastMonthDay{
    FUNK();
    
    NSDateComponents *com = [[NSDateComponents alloc]init];
    [com setDay:0]; //0を指定すると先月末が取得できる
    [com setYear:year];
    [com setMonth:month];
    
    NSDate *theDay = [cal dateFromComponents:com];
    
    NSUInteger flags =NSDayCalendarUnit | NSHourCalendarUnit |NSMinuteCalendarUnit;
    NSDateComponents *comps=[cal components:flags fromDate:theDay];
    return [comps day];
}

//該当月の週数を求める
-(NSInteger)numberOfWeekWithMonth:(NSInteger)m inYear:(NSInteger)y{
    FUNK();
    
    int colum = 1;
    NSInteger numberOfWeek=1;
    
    NSInteger weekDayOfFirstDay=[self weekDayOfFirstDayWithMonth:month inYear:year];
    for(int i = 1;i  < weekDayOfFirstDay;i++){
        colum++;
    }
    
    int dayOfMonth= [self numberOfDayOfMonth:month inYear:year];
    for(NSInteger i = 1;i <dayOfMonth;i++){
        if(colum == 7){
            colum =0;
            numberOfWeek++;
        }
        colum++;
    }
    return numberOfWeek;
}

-(NSArray *)firstDateAndEndDateWithYear:(int)_year month:(int)_month
{
    FUNK();
    int thisYear = _year;
    int thisMonth = _month;
    
    // first
    int firstYear = 0;
    int firstMonth = 0;
    int firstDay = 0;
    
    // D
    NSInteger weekDayOfFirstDay=[self weekDayOfFirstDayWithMonth:month inYear:year];
    NSInteger lastMonthDay = [self getLastMonthDay];
    firstDay = lastMonthDay - weekDayOfFirstDay + 2;
    if(firstDay < 31){
        // YM
        if(thisMonth == 1){
            firstYear = thisYear - 1;
            firstMonth = 12;
        }else{
            firstYear = thisYear;
            firstMonth = thisMonth - 1;
        }
        
    }else{
        firstDay = 1;
        // YM
        firstYear = thisYear;
        firstMonth = thisMonth;
    }
    
    // last
    int endYear = 0;
    int endMonth = 0;
    int endDay = 0;
    // D
    NSInteger weekDayOfLastDay=[self weekDayOfLastDayWithMonth:month inYear:year];
    for(int i = weekDayOfLastDay+1;i  < 8;i++){
        endDay++;
    }
    if(endDay != 0){
        // YM
        if(thisMonth == 12){
            endYear = thisYear + 1;
            endMonth = 1;
        }else{
            endYear = thisYear;
            endMonth = thisMonth + 1;
        }
    }else{
        // YM
        endYear = thisYear;
        endMonth = thisMonth;
        
        endDay = [self numberOfDayOfMonth:endMonth inYear:endYear];
        
    }
    
    NSString *firstDate = [NSString stringWithFormat:@"%d/%d/%d",firstYear,firstMonth,firstDay];
    
    NSString *endDate = [NSString stringWithFormat:@"%d/%d/%d",endYear,endMonth,endDay];
    return [[NSArray alloc]initWithObjects:firstDate,endDate,nil];
}
#pragma mark ************** create this month days **************

//今月の日付一覧を生成
-(NSArray *)monthDays{
    FUNK();
    
    int colum = 1;
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    NSMutableArray *dayOfPreviousMonth = [[NSMutableArray alloc]init];
    NSMutableArray *dayOfThisMonth = [[NSMutableArray alloc]init];
    NSMutableArray *dayOfNextMonth = [[NSMutableArray alloc]init];
    
    //今月の表示に含まれる先月分を取得
    NSInteger weekDayOfFirstDay=[self weekDayOfFirstDayWithMonth:month inYear:year];
    NSInteger lastMonthDay = [self getLastMonthDay];
    NSMutableString *dayStr2 = [[NSMutableString alloc]initWithCapacity:10];;
    for(int i = 1;i  < weekDayOfFirstDay;i++){
        [dayStr2 appendString:[NSString stringWithFormat:@" %d",lastMonthDay - (weekDayOfFirstDay - i) + 1]];
        [dayOfPreviousMonth addObject:[NSNumber  numberWithInt:lastMonthDay - (weekDayOfFirstDay - i) + 1]];
        colum++;
    }
    //今月の表示
    int dayOfMonth= [self numberOfDayOfMonth:month inYear:year];
    for(NSInteger i = 1;i <=dayOfMonth;i++){
        [dayOfThisMonth addObject:[NSNumber numberWithInt:i]];
        if(colum == 7){
            colum =0;
        }
        colum++;
    }
    
    //今月の表示に含まれる来月分を取得
    NSInteger weekDayOfLastDay=[self weekDayOfLastDayWithMonth:month inYear:year];
    int count =1;
    for(int i = weekDayOfLastDay+1;i  < 8;i++){
        [dayOfNextMonth addObject:[NSNumber numberWithInt:count]];
        count++;
    }
    
    [array addObject:dayOfPreviousMonth];
    [array addObject:dayOfThisMonth];
    [array addObject:dayOfNextMonth];
    return [NSArray arrayWithArray:array];
}

#pragma mark ************** logic for event **************

//月を進める
-(void)gotoNext{
    FUNK();
    
    if(month != 12){
        month+=1;
    }else{
        month = 1;
        year++;
    }
}

//月を戻す
-(void)gotoPrev{
    FUNK();
    
    if(month != 1){
        month-=1;
    }else{
        month = 12;
        year--;
    }
}

//日付がタップされたときの処理
-(void)tapDayWithDayInfo:(NSDictionary*)info{
    FUNK();
    
    //dbアクセス
    int tag = [[[info allKeys] objectAtIndex:0] intValue];
    int tapDay =[[info objectForKey:[NSNumber numberWithInt:tag]] intValue];
    switch (tag) {
        case 1:
            if(month == 1){
                NSLog(@"tap されたのは%d年%d月の%d日です",year-1,12,tapDay);
            }else{
                NSLog(@"tap されたのは%d年%d月の%d日です",year,month-1,tapDay);
            }
            break;
        case 2:
            NSLog(@"tap されたのは%d年%d月の%d日です",year,month,tapDay);
            break;
        case 3:
            if(month == 12){
                NSLog(@"tap されたのは%d年%d月の%d日です",year+1,1,tapDay);
            }else{
                NSLog(@"tap されたのは%d年%d月の%d日です",year,month+1,tapDay);
            }
            break;
        default:
            break;
            
    }
}

-(BOOL)isTapSelectedDayWithTapDayInfo:(NSDictionary *)tapDayInfo selectedDayInfo:(NSDictionary *)selectedDayInfo{
    BOOL result = YES;
    
    if(tapDayInfo.count !=0 &&selectedDayInfo.count !=0){
        
        int newTag = [[[tapDayInfo allKeys] objectAtIndex:0] intValue];
        int tapDay =[[tapDayInfo objectForKey:[NSNumber numberWithInt:newTag]] intValue];
        
        int oldTag = [[[selectedDayInfo allKeys] objectAtIndex:0] intValue];
        int selectedDay =[[selectedDayInfo objectForKey:[NSNumber numberWithInt:oldTag]] intValue];
        
        if(tapDay == selectedDay && newTag == oldTag){
            result = NO;
        }
    }
    return result;
}

@end

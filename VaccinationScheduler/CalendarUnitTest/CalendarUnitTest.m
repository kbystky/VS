//
//  CalendarUnitTest.m
//  CalendarUnitTest
//
//  Created by 拓也 小林 on 12/12/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CalendarUnitTest.h"
#import "Calendar.h"
@implementation CalendarUnitTest
{
    Calendar *cal;
}
- (void)setUp
{
    [super setUp];
    cal = [[Calendar alloc]init];
    // Set-up code here.
}

- (void)tearDown
{
    cal.year = 0;
    cal.month = 0;
    [super tearDown];
}

-(void)testAccesser{
    NSInteger year = 2012;
    NSInteger  month = 12;
    cal.year = year;
    cal.month = month;
    STAssertTrue(year == cal.year,@"");
    STAssertTrue(month == cal.month,@"");
}

- (void)testNumberOfWeek
{
    NSInteger year = 2012;
    NSInteger  month = 12;
    NSInteger numberOfWeek = 6;
    STAssertEquals([cal numberOfWeekWithMonth:month inYear:year],numberOfWeek,@"");

}

@end

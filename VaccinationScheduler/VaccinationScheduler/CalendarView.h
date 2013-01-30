//
//  CalenderView.h
//  TestCalender
//
//  Created by  on 12/11/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{

    PRE=1,THIS,NEXT,

}TypeOfMonth;

typedef enum{

    RETURN=1,SELECT,

}ChangeBgColor;

@interface CalendarView : UIView
{
    BOOL highlighted;
}
-(UIView *)createDayViewWithMonthDays:(NSArray *)monthArray numberOfWeek:(int)numberOfWeek actionTargetWhenViewTapped:(id)target;
-(void)changeDayLabelBackgroundWIthDayInfo:(NSDictionary *)info isType:(int)type;
-(CGSize)calendarViewSize;
@end

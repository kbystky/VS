//
//  CalenderView.h
//  TestCalender
//
//  Created by  on 12/11/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
enum{
    PRE=1,THIS=2,NEXT=3,
};
enum{
    RETURN=1,SELECT=2,
};

@interface CalendarView : UIView
{
    BOOL highlighted;
}
-(UIView *)createDayViewWithMonthDays:(NSArray *)monthArray numberOfWeek:(int)numberOfWeek actionTargetWhenViewTapped:(id)target;
-(void)changeDayLabelBackgroundWIthDayInfo:(NSDictionary *)info isType:(int)type;
@end

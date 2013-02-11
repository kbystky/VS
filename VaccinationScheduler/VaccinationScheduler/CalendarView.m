//
//  CalenderView.m
//  TestCalender
//
//  Created by  on 12/11/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CalendarView.h"
#import <QuartzCore/QuartzCore.h>
#import "AccountAppointmentDto.h"

#define DAYOFWEEK_VIEW_HEIGHT 20

@interface CalendarView()
{
    NSMutableArray *dayArray;
    NSMutableArray *checkExistAppointmentDay;
    UILabel*oneDayView;
    UIView *dayOfWeekBaseView;
    
    CGFloat dayViewHeight;
}
@property (weak, nonatomic) IBOutlet UIButton *previousMonthButton;
@property (weak, nonatomic) IBOutlet UIButton *nextMonthButton;
@property (weak, nonatomic) IBOutlet UILabel *monthYearText;
@property (strong, nonatomic) IBOutlet UIView *dayView;

@end
@implementation CalendarView
@synthesize previousMonthButton;
@synthesize nextMonthButton;
@synthesize monthYearText;
@synthesize dayView;

// Storyboard や NIB からのインスタンス化の場合
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    if (self){
        dayArray =[[NSMutableArray alloc]initWithCapacity:10];
        NSLog(@"def height %f",self.frame.size.height);
        [self createDayOfWeekView];
    }
    return self;
}

-(void)createDayOfWeekView{
    dayOfWeekBaseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, DAYOFWEEK_VIEW_HEIGHT)];
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat cellWidth = SCREEN_WIDTH/7.0;
    CGFloat cellHeight = dayOfWeekBaseView.frame.size.height;
    NSArray *dayOfWeekString = [[NSArray alloc]initWithObjects:@"日",@"月",@"火",@"水",@"木",@"金",@"土", nil];
    for(int i = 0;i < 7;i++){
        UILabel *weekOfDayView = [[UILabel alloc]initWithFrame:CGRectMake(x, y, cellWidth, cellHeight)];
        
        weekOfDayView.text = [dayOfWeekString objectAtIndex:i];
        weekOfDayView.textAlignment = UITextAlignmentCenter;
        
        //背景設定
        UIGraphicsBeginImageContext(weekOfDayView.frame.size);
        if(i == 0){
            //日曜日
            [[UIImage imageNamed:@"sanday_week.png"] drawInRect:weekOfDayView.bounds];
        }else if(i == 6){
            //土曜日
            [[UIImage imageNamed:@"saturday_week.png"] drawInRect:weekOfDayView.bounds];
        }else{
            [[UIImage imageNamed:@"day_week.png"] drawInRect:weekOfDayView.bounds];
        }
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        weekOfDayView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
        
        [dayOfWeekBaseView addSubview:weekOfDayView];
        x+=cellWidth;
    }
    [self addSubview:dayOfWeekBaseView];
}

-(UIView *)createDayViewWithMonthDays:(NSArray *)monthArray numberOfWeek:(int)numberOfWeek actionTargetWhenViewTapped:(id)target{
    //日付のviewの初期化
    /*
     [self subviews]で子ビューのarrayがかえってくるからDayArrayがいらないかも
     */
    if(dayArray.count !=0){
        for(int i = 0; i < dayArray.count;i++){
            [[dayArray objectAtIndex:i] removeFromSuperview];
        }
        [dayArray removeAllObjects];
    }
    
    CGFloat x = 0;
    CGFloat y = dayOfWeekBaseView.frame.size.height;
    CGFloat cellSize = SCREEN_WIDTH/7.0;
    //週のviewを追加する分、calVIewのサイズを大きくする
    dayViewHeight = numberOfWeek * cellSize + DAYOFWEEK_VIEW_HEIGHT;
    self.frame= CGRectMake(0, 0, self.frame.size.width, dayViewHeight);
    int colum = 0;
    
    //先月、今月、来月をarrayindexで識別
    for(int arrayIndex = 0;arrayIndex<3;arrayIndex++){
        for(int i=0;i<[[monthArray objectAtIndex:arrayIndex] count];i++){
            if(colum == 7){
                colum =0;
                y+=cellSize;
                x = 0;
            }
            oneDayView = [[UILabel alloc]initWithFrame:CGRectMake(x, y, cellSize, cellSize)];
            
            //背景設定
            UIGraphicsBeginImageContext(oneDayView.frame.size);
            if(arrayIndex == 0){
                [[UIImage imageNamed:@"otherday.png"] drawInRect:oneDayView.bounds];
            }else if(arrayIndex == 1){
                if(colum == 6){
                    [[UIImage imageNamed:@"saturday.png"] drawInRect:oneDayView.bounds];
                }else if (colum == 0){
                    [[UIImage imageNamed:@"sanday.png"] drawInRect:oneDayView.bounds];
                }else{
                    [[UIImage imageNamed:@"day.png"] drawInRect:oneDayView.bounds];
                }
            }else if(arrayIndex == 2){
                [[UIImage imageNamed:@"otherday.png"] drawInRect:oneDayView.bounds];
            }
            UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            oneDayView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
            
            oneDayView.text = [NSString stringWithFormat:@"%@",[[monthArray objectAtIndex:arrayIndex] objectAtIndex:i]];
            oneDayView.userInteractionEnabled = YES;
            oneDayView.textAlignment = UITextAlignmentCenter;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(tapDayCell:)];
            [oneDayView addGestureRecognizer:tapGesture];
            oneDayView.tag = arrayIndex+1;
            
            [self addSubview:oneDayView];
            [dayArray addObject:oneDayView];
            x+=cellSize;
            colum++;
        }
    }
    return self;
}

- (void)checkAppointmentDayWithAppointment:(NSArray *)appointments thisMonth:(NSInteger)thisMonth
{
    //init
    checkExistAppointmentDay = [[NSMutableArray alloc]initWithCapacity:dayArray.count];
    
    for(AccountAppointmentDto *dto in appointments){
        NSString *appointmentDate = dto.appointmentDate;
        NSArray *splitResult = [appointmentDate componentsSeparatedByString:@"/"];
        // [0]年、[1]月、[2]日
        NSLog(@"split int [0]:%d [1]:%d [2]:%d ",[[splitResult objectAtIndex:0] intValue],[[splitResult objectAtIndex:1] intValue],[[splitResult objectAtIndex:2] intValue]);
        NSLog(@"split string [0]:%@ [1]:%@ [2]:%@",[splitResult objectAtIndex:0],[splitResult objectAtIndex:1],[splitResult objectAtIndex:2]);
        
        int count = 0;
        if([[splitResult objectAtIndex:1] intValue] == thisMonth){
            NSLog(@"今月!");
            for(UILabel *l in dayArray){
                if(l.tag == 2 && [l.text isEqualToString:[NSString stringWithFormat:@"%d",[[splitResult objectAtIndex:2]intValue]]]){
                    UIGraphicsBeginImageContext(l.frame.size);
                    [[UIImage imageNamed:@"targetday.png"] drawInRect:l.bounds];
                    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    l.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
                    NSLog(@"count %d day %d",count,[l.text intValue]);
                    NSLog(@"今月だし、一致");
                    [checkExistAppointmentDay addObject:[NSNumber numberWithInt:[l.text intValue]]];
                    break;
                }
                count++;
            }
        }else{
            NSLog(@"今月!じゃない");
            for(UILabel *l in dayArray){
                if(l.tag != 2 && [l.text isEqualToString:[NSString stringWithFormat:@"%d",[[splitResult objectAtIndex:2]intValue]]]){
                    UIGraphicsBeginImageContext(l.frame.size);
                    [[UIImage imageNamed:@"targetday.png"] drawInRect:l.bounds];
                    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    l.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
                    
                    NSLog(@"今月じゃないけど、一致");
                    [checkExistAppointmentDay addObject:[NSNumber numberWithInt:[l.text intValue]]];
                    break;
                }
                count++;
            }
        }
        NSLog(@"\n\n");
    }
}
-(void)changeDayLabelBackgroundWIthDayInfo:(NSDictionary *)info isType:(int)type{
    FUNK();
    if(info.count ==0){
        return;
    }
    int tag = [[[info allKeys] objectAtIndex:0] intValue];
    int day =[[info objectForKey:[NSNumber numberWithInt:tag]] intValue];
    //背景色の指定
    UIGraphicsBeginImageContext(oneDayView.frame.size);
    
    //色を戻すのか選択されたのか
    if(type == RETURN){
        //予定がある日かチェック
        int count = 1;
        for(UILabel *l in dayArray){
            if([l.text intValue] ==day && l.tag ==tag){
                break;
            }
            count++;
        }
        
        BOOL isTarget = NO;
        for(NSNumber *num in checkExistAppointmentDay){
            if([num intValue] == day){
                [[UIImage imageNamed:@"targetday.png"] drawInRect:oneDayView.bounds];
                isTarget =  YES;
                break;
            }
        }
        //今月かどうか
        if(!isTarget){
            if(tag == THIS){
                //土日・平日の判断
                if(count % 7 == 0){
                    [[UIImage imageNamed:@"saturday.png"] drawInRect:oneDayView.bounds];
                }else if(count % 7 == 1){
                    [[UIImage imageNamed:@"sanday.png"] drawInRect:oneDayView.bounds];
                }else{
                    [[UIImage imageNamed:@"day.png"] drawInRect:oneDayView.bounds];
                }
            }else{
                [[UIImage imageNamed:@"otherday.png"] drawInRect:oneDayView.bounds];
            }
        }
    }else if(type == SELECT){
        [[UIImage imageNamed:@"selectday.png"] drawInRect:oneDayView.bounds];
    }
    //色変更
    for(UILabel *l in dayArray){
        if([l.text intValue] ==day && l.tag ==tag){
            UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            l.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
            break;
        }
    }
}

-(CGSize)calendarViewSize
{
    return CGSizeMake(SCREEN_WIDTH, dayViewHeight);
}


@end

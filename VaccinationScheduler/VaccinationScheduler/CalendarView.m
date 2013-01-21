//
//  CalenderView.m
//  TestCalender
//
//  Created by  on 12/11/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CalendarView.h"
#import <QuartzCore/QuartzCore.h>
@interface CalendarView()
{
    NSMutableArray *dayArray;
    UILabel*oneDayView;
    UIView *dayOfWeekBaseView;
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
    dayOfWeekBaseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 28)];
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat cellWidth = SCREEN_WIDTH/7.0;
    CGFloat cellHeight = dayOfWeekBaseView.frame.size.height;
    NSArray *dayOfWeekString = [[NSArray alloc]initWithObjects:@"日",@"月",@"火",@"水",@"木",@"金",@"土", nil];
    for(int i = 0;i < 7;i++){
        UILabel *weekOfDayView = [[UILabel alloc]initWithFrame:CGRectMake(x, y, cellWidth, cellHeight)];
        weekOfDayView.backgroundColor = [UIColor grayColor];
        weekOfDayView.text = [dayOfWeekString objectAtIndex:i];
        weekOfDayView.textAlignment = UITextAlignmentCenter;
        //quartzcoreでborderつけてます
        [[weekOfDayView layer] setBorderColor:[[UIColor blackColor] CGColor]];
        [[weekOfDayView layer] setBorderWidth:1.0];
        
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
    self.frame= CGRectMake(0, 0, self.frame.size.width, numberOfWeek * cellSize +28);  

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
            
            //先月、今月、来月によって背景を変更
            if(arrayIndex == 0)
                oneDayView.backgroundColor = [UIColor lightGrayColor];
            else if(arrayIndex == 1)
                oneDayView.backgroundColor = [UIColor yellowColor];
            else if(arrayIndex == 2)
                oneDayView.backgroundColor = [UIColor lightGrayColor];
            
            oneDayView.text = [NSString stringWithFormat:@"%@",[[monthArray objectAtIndex:arrayIndex] objectAtIndex:i]];
            oneDayView.userInteractionEnabled = YES;
            oneDayView.textAlignment = UITextAlignmentCenter;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(tapDayCell:)];
            [oneDayView addGestureRecognizer:tapGesture];
            oneDayView.tag = arrayIndex+1;

            //quartzcoreでborderつけてます
            [[oneDayView layer] setBorderColor:[[UIColor blackColor] CGColor]];
            [[oneDayView layer] setBorderWidth:1.0];
            
            [self addSubview:oneDayView];
            [dayArray addObject:oneDayView];
            x+=cellSize;
            colum++;
        }
    }
    return self;
}

-(void)changeDayLabelBackgroundWIthDayInfo:(NSDictionary *)info isType:(int)type{
    
    if(info.count !=0){
        int tag = [[[info allKeys] objectAtIndex:0] intValue];
        int day =[[info objectForKey:[NSNumber numberWithInt:tag]] intValue]; 
        UIColor *bgColor=Nil;
        
        //背景色の指定
        if(type == RETURN){
            switch (tag) {
                case PRE:
                    bgColor = [UIColor lightGrayColor];
                    break;
                case THIS:
                    bgColor = [UIColor yellowColor];
                    break;
                case NEXT:
                    bgColor = [UIColor lightGrayColor];
                    break;
                default:
                    break;
            }
        }else if(type == SELECT){
            bgColor = [UIColor redColor];
        }
        
        //色変更
        for(UILabel *l in dayArray){
            if([l.text intValue] ==day){
                if(l.tag ==tag){
                    l.backgroundColor = bgColor;
                    break;
                }
            }
        }
        
    }
}



@end

//
//  ViewController.m
//  TestCalender
//
//  Created by 拓也 小林 on 12/11/21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CalendarViewController.h"
#import "AppDelegate.h"
#import "Calendar.h"
#import "CalendarView.h"

@interface CalendarViewController ()
{
    NSInteger selectedDay;
    NSInteger selectedMonth;
    NSInteger selectedYear;
    Calendar *cal;
    CalendarView* calView;
    NSMutableDictionary *selectedDayInfo;
    UITableView *tableView;
}
@property (strong,nonatomic) UISegmentedControl *segmentC;
@end

@implementation CalendarViewController
@synthesize segmentC;
NSString *const CALENDARVIEW_NIB_NAME =@"CalendarView";

#pragma mark ************  Life Cycle *************
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createToolBarItem];
    
    cal = [[Calendar alloc]init];
    //xibからカレンダーのレイアウトを取得する
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CALENDARVIEW_NIB_NAME owner: self options: nil];
    calView = [topLevelObjects objectAtIndex:0];
    [self.view addSubview:calView];
    
    [self calShow];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    [super viewWillAppear:YES];
    [self navigationControllerSetting];
    [self navigationBarSetting];
    [self toolbarSetting];
    calView.backgroundColor = [UIColor blueColor];
    NSLog(@"height %f width %f",[calView calendarViewSize].height,[calView calendarViewSize].width);
    NSLog(@"height %f %f %f",
          self.view.frame.size.height,
          self.navigationController.navigationBar.frame.size.height,
          self.navigationController.toolbar.frame.size.height);
    CGFloat tmp = self.view.frame.size.height - (calView.calendarViewSize.height - self.navigationController.navigationBar.frame.size.height);
    NSLog(@"tmp %f",tmp);
    CGRect rect3 = CGRectMake(0,
                              calView.calendarViewSize.height,
                              SCREEN_WIDTH,
                              self.view.frame.size.height - calView.calendarViewSize.height
                              );

    CGRect rect2 = CGRectMake(0,
                              calView.calendarViewSize.height,
                              SCREEN_WIDTH,
                              self.view.frame.size.height -
                              (calView.calendarViewSize.height));

    CGRect rect = CGRectMake(0,
                             calView.calendarViewSize.height + self.navigationController.navigationBar.frame.size.height,
                             SCREEN_WIDTH,
                             self.view.frame.size.height -
                             (self.navigationController.navigationBar.frame.size.height + self.navigationController.toolbar.frame.size.height + calView.calendarViewSize.height));
//    tableView = [[UITableView alloc]initWithFrame:rect];

    UIView *v = [[UIView alloc]initWithFrame:rect3];
    v.backgroundColor = [UIColor redColor];
    [self.view addSubview:v];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark ************  View Setting *************

-(void)navigationControllerSetting
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setToolbarHidden:NO animated:NO];
    //    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    //    self.navigationController.toolbar.translucent = YES;
}

-(void)navigationBarSetting
{
    UIBarButtonItem* previousMonthButton = [[UIBarButtonItem alloc]
                                            initWithTitle:@"<-"
                                            style:UIBarButtonItemStyleBordered
                                            target:self
                                            action:@selector(tapPrev:)];
    UIBarButtonItem* nextMonthButton = [[UIBarButtonItem alloc]
                                        initWithTitle:@"->"
                                        style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(tapNext:)];
    self.navigationItem.leftBarButtonItem = previousMonthButton;
    self.navigationItem.rightBarButtonItem = nextMonthButton;
}

-(void)createToolBarItem{
    
    // スペーサを生成する
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil action:nil];
    
    //SegmentedControl 
    NSArray *array = [[NSArray alloc]initWithObjects:@"カレンダー",@"リスト", nil];
    self.segmentC = [[UISegmentedControl alloc]initWithItems:array];
    self.segmentC.frame = CGRectMake(0, 0, 150, 30);
    self.segmentC.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segmentC.momentary = NO;
    [self.segmentC addTarget:self action:@selector(changeShowType:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *segbtn = [[UIBarButtonItem alloc] initWithCustomView:segmentC];
    // toolbarにボタンとラベルをセットする
    NSArray *items = [NSArray arrayWithObjects: spacer, segbtn, spacer, nil];
    self.toolbarItems = items;
}
-(void)toolbarSetting
{
    self.segmentC.selectedSegmentIndex = 0;
}

#pragma mark ************ SegmentedControl Action *************
//カレンダー表示・リスト表示を切り替える
-(void)changeShowType:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 1){
        AppDelegate* delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [delegate useListViewController];
    }
}

/***************************************************/
#pragma mark ************  Cal Action *************

//カレンダー表示
-(void)calShow{
    selectedDayInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    //年月の表示
    self.navigationItem.title =  [NSString stringWithFormat:@"%d年 %d月",cal.year,cal.month];
    
    //日付のビューを生成
    [calView createDayViewWithMonthDays:[cal monthDays] 
                           numberOfWeek:[cal numberOfWeekWithMonth:cal.month inYear:cal.year] 
             actionTargetWhenViewTapped:self];
    
}

//日付がタップされたときの処理
-(void)tapDayCell:(UIGestureRecognizer *)g{
    UILabel *v = (UILabel *) g.view;
    
    //選択日かどうか
    if([cal isTapSelectedDayWithTapDayInfo:[NSDictionary dictionaryWithObject:v.text forKey:[NSNumber numberWithInt:v.tag]]
                           selectedDayInfo:selectedDayInfo]){
        
        //選択されていた部分を戻す
        [calView changeDayLabelBackgroundWIthDayInfo:selectedDayInfo isType:RETURN];
        [selectedDayInfo removeAllObjects];
        
        //新しく選択された部分を変更する
        [selectedDayInfo setObject:v.text forKey:[NSNumber numberWithInt:v.tag]];
        [calView changeDayLabelBackgroundWIthDayInfo:selectedDayInfo isType:SELECT];
        
        [cal tapDayWithDayInfo:selectedDayInfo];
    }
}

//翌月へ
-(IBAction)tapNext:(id)sender {
    [cal gotoNext];
    [self calShow];
}

//先月へ
- (IBAction)tapPrev:(id)sender {
    [cal gotoPrev];
    [self calShow];
}
/***************************************************/

@end

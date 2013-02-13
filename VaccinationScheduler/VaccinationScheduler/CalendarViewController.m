//
//  ViewController.m
//  TestCalender
//
//  Created by 拓也 小林 on 12/11/21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CalendarViewController.h"
#import "Calendar.h"
#import "CalendarView.h"
#import "AccountAppointmentService.h"
#import "UserDefaultsManager.h"
#import "AccountAppointmentDto.h"
#import "VaccinationDto.h"
#import "AccountInfoDto.h"
#import "VaccinationDto.h"
#import "DetailListViewController.h"

#define CellIdentifier @"myCell"

@interface CalendarViewController ()
{
    NSInteger selectedDay;
    NSInteger selectedMonth;
    NSInteger selectedYear;
    Calendar *cal;
    CalendarView* calView;
    NSMutableDictionary *selectedDayInfo;
    UITableView *tableView;
    NSArray *monthArray;
    NSArray *dataSource;
    CGRect tableViewRect;
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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self navigationControllerSetting];
    [self navigationBarSetting];
    [self toolbarSetting];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self calShow];
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
- (void)createTableView
{
    [tableView removeFromSuperview];
    tableViewRect = CGRectMake(0,
                               calView.calendarViewSize.height,
                               SCREEN_WIDTH,
                               self.view.frame.size.height - calView.calendarViewSize.height
                               );
    
    tableView = [[UITableView alloc]initWithFrame:tableViewRect];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
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

    // set table datasource
    NSArray *firstAndEndDate = [cal firstDateAndEndDateWithYear:cal.year month:cal.month];
    AccountAppointmentService *service = [[AccountAppointmentService alloc]init];
    dataSource = [service monthDataWithStartYMD:[firstAndEndDate objectAtIndex:0] endYM:[firstAndEndDate objectAtIndex:1]];
    [tableView reloadData];
    
    //日付のビューを生成
    [calView createDayViewWithMonthDays:[cal monthDays]
                           numberOfWeek:[cal numberOfWeekWithMonth:cal.month inYear:cal.year]
             actionTargetWhenViewTapped:self];
    [calView checkAppointmentDayWithAppointment:dataSource thisMonth:cal.month];
    
    [self createTableView];
}

//日付がタップされたときの処理
-(void)tapDayCell:(UIGestureRecognizer *)g{
    UILabel *v = (UILabel *) g.view;
    
    //選択日かどうか
    if([cal isTapSelectedDayWithTapDayInfo:[NSDictionary dictionaryWithObject:v.text
                                                                       forKey:[NSNumber numberWithInt:v.tag]]
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

#pragma mark ************  Delegate *************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    AccountAppointmentDto *appointmentDto = (AccountAppointmentDto *)[dataSource objectAtIndex:indexPath.row];
    UserDefaultsManager *manager = [[UserDefaultsManager alloc]init];
    AccountInfoDto *accountDto = [manager accountWithId:appointmentDto.accountId];

    
    cell.textLabel.text = accountDto.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@(%@)",appointmentDto.vaccinationDto.name,appointmentDto.appointmentDate];
    cell.detailTextLabel.font = [UIFont fontWithName:@"AppleGothic" size:12];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // create dto
    AccountAppointmentDto *appointmentDto = (AccountAppointmentDto *)[dataSource objectAtIndex:indexPath.row];
    VaccinationDto *vaccinationDto = appointmentDto.vaccinationDto;
    
    /// get accountInfoDto
    UserDefaultsManager *manager = [[UserDefaultsManager alloc]init];
    AccountInfoDto *accountDto = [manager accountWithId:appointmentDto.accountId];
    
    //選択されたのアカウントDtoをからアポイントメントDto datasourceを生成
    AccountAppointmentService *service = [[AccountAppointmentService alloc]init];
    accountDto.appointmentDto = [service appointmentsDtoWithAccountId:accountDto.accountId];
    
    DetailListViewController *viewController = [[DetailListViewController alloc]initWithAccountInfoDto:accountDto vaccinationDto:vaccinationDto appointmentDto:appointmentDto editType:TYPE_EDIT];
    [self.navigationController pushViewController:viewController animated:YES];
}
@end

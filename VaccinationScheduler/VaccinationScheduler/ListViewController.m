//
//  ListViewController.m
//  VaccinationScheduler
//
//  Created by  on 12/12/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "DetailListViewController.h"

#import "AppDelegate.h"
#import "ActionSheetBuilder.h"
#import "AlertBuilder.h"
#import "UserDefaultsManager.h"

#import "VaccinationDao.h"
#import "VaccinationDto.h"
#import "AccountAppointmentDao.h"
#import "AccountAppointmentDto.h"
/**********/
#import "DatabaseManager.h"
#import "FMDatabase.h"
/**********/

#define CellIdentifier @"myCell"

enum{
    LIST_TYPE_ALL,
    LIST_TYPE_RESERVATION,
}listType;

@interface ListViewController ()
{
    UIActionSheet *actionSheet;
    UIAlertView *alert;
    NSInteger listType;
    NSArray *listDatasource; 
    NSMutableArray *accountsName;
    NSString  *currentAccountName;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) UISegmentedControl *toolBarSegmentC;
@property (strong,nonatomic)UISegmentedControl *listShowTypeSwitchSegmentC;
@end

@implementation ListViewController
//public
@synthesize isAccountExist=_isAccountExist;
//private
@synthesize tableView = _tableView;
@synthesize toolBarSegmentC=_toolBarSegmentC;
@synthesize listShowTypeSwitchSegmentC = _listShowTypeSwitchSegmentC;
#pragma mark *****************  Initialize ******************
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//TODO: datasource取得部分修正
#pragma mark *****************  Life Cycle ******************
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self test];
    actionSheet = nil;
    [self createNavigationBarItem];
    [self createToolBarItem];
    listType = LIST_TYPE_ALL;
    [self tableViewSetting];
    [self navigationBarSetting];
}
-(void)test{
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    NSString * sql = @"CREATE TABLE IF NOT EXISTS  vaccination (name TEXT , times INTEGER);";
    NSLog(@"create %d",[db executeUpdate:sql]);
    sql = @"CREATE TABLE IF NOT EXISTS  account_1 (appointment TEXT , date TEXT, times INTEGER , isSynced BOOL);";
    NSLog(@"create %d",[db executeUpdate:sql]);
    sql = @"CREATE TABLE IF NOT EXISTS  account_2 (appointment TEXT , date TEXT, times INTEGER , isSynced BOOL);";
    NSLog(@"create %d",[db executeUpdate:sql]);
    sql = @"CREATE TABLE IF NOT EXISTS  account_3 (appointment TEXT , date TEXT, times INTEGER , isSynced BOOL);";
    NSLog(@"create %d",[db executeUpdate:sql]);
    
       sql = @"INSERT INTO vaccination (name,times) VALUES (?,?);";
   
       [db executeUpdate:sql,@"B型肝炎ワクチン",[NSNumber numberWithInt:2]];
       [db executeUpdate:sql,@"ロタウイルスワクチン",[NSNumber numberWithInt:3]];
    [db executeUpdate:sql,@"ヒブワクチン",[NSNumber numberWithInt:4]];
    [db executeUpdate:sql,@"小児用肺炎球菌ワクチン",[NSNumber numberWithInt:4]];
    [db executeUpdate:sql,@"四種混合・三種混合",[NSNumber numberWithInt:4]];
    [db executeUpdate:sql,@"不活化ポリオワクチン",[NSNumber numberWithInt:4]];
    [db executeUpdate:sql,@"BCGワクチン",[NSNumber numberWithInt:1]];
    [db executeUpdate:sql,@"MRワクチン",[NSNumber numberWithInt:1]];
    [db executeUpdate:sql,@"おたふくかぜワクチン",[NSNumber numberWithInt:2]];
    [db executeUpdate:sql,@"水痘ワクチン",[NSNumber numberWithInt:2]];
    [db executeUpdate:sql,@"インフルエンザワクチン",[NSNumber numberWithInt:2]];
    [db close];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self navigationControllerSetting];
    [self toolbarSetting];
    
    
    BOOL currentAccountNameIsExist = NO;
    if(!self.isAccountExist) {
        [self createAccountForcibly];
    }else{
        //総アカウントの名前保持
        accountsName = [[NSMutableArray alloc]init];
        NSArray *accounts = [[UserDefaultsManager alloc]init].allAccount;
        for(int i = 0;i<accounts.count;i++){
            NSDictionary *account = [accounts objectAtIndex:i];
            NSString *name = [account objectForKey:[UserDefaultsManager accountNameKey]];
            if([name isEqualToString:currentAccountName]){
                currentAccountNameIsExist = YES;
            }
            [accountsName addObject:name];
        }
        
        if(!currentAccountNameIsExist){
            NSDictionary *account = [accounts objectAtIndex:0];
            currentAccountName = [account objectForKey:[UserDefaultsManager accountNameKey]];            
        }
        self.navigationItem.title =  currentAccountName;
        
        if(self.listShowTypeSwitchSegmentC.selectedSegmentIndex == LIST_TYPE_ALL){
            VaccinationDao *dao = [[VaccinationDao alloc]init];
            listDatasource = [[NSArray alloc]initWithArray:dao.allVaccination];
        }else if(self.listShowTypeSwitchSegmentC.selectedSegmentIndex == LIST_TYPE_RESERVATION){
            AccountAppointmentDao *dao = [[AccountAppointmentDao alloc]init];
            UserDefaultsManager *manager = [[UserDefaultsManager alloc]init];
            NSDictionary *account = [manager accountWithName:currentAccountName];
            listDatasource = [[NSArray alloc]initWithArray:
                              [dao appointmentDtoWithAccountId:[[account objectForKey:[UserDefaultsManager accountIdKey]]intValue]]];
        }
        [self.tableView reloadData];
    }
}
- (void)viewDidUnload
{
    [self setToolBarSegmentC:nil];
    [self setListShowTypeSwitchSegmentC:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/***************************************************/
#pragma mark *****************  View Setting ******************
-(void)navigationControllerSetting{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setToolbarHidden:NO animated:NO];
}
#pragma mark navigation bar
-(void)createNavigationBarItem
{
    
    //segmented control    
    NSArray *array = [[NSArray alloc]initWithObjects:@"一覧",@"予約", nil];
    self.listShowTypeSwitchSegmentC = [[UISegmentedControl alloc]initWithItems:array];
    self.listShowTypeSwitchSegmentC.segmentedControlStyle = UISegmentedControlStyleBar;
    self.listShowTypeSwitchSegmentC.momentary = NO;
    self.listShowTypeSwitchSegmentC.frame = CGRectMake(0, 0, 80, 30);
    [self.listShowTypeSwitchSegmentC addTarget:self action:@selector(changeListShowType:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *segbtn = [[UIBarButtonItem alloc] initWithCustomView:self.listShowTypeSwitchSegmentC];
    self.navigationController.navigationBar.topItem.rightBarButtonItem = segbtn;
    
    //設定ボタン
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc]initWithTitle:@"設定" 
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(tapSettingButton)];
    
    self.navigationController.navigationBar.topItem.leftBarButtonItem = settingButton;
    //遷移先VCの戻るボタンの文字列を変更
    UIBarButtonItem *backBarButtonItem = 
    [[UIBarButtonItem alloc] initWithTitle:@"戻る" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backBarButtonItem];
    
}
#pragma mark navigation bar
-(void)navigationBarSetting
{
    self.listShowTypeSwitchSegmentC.selectedSegmentIndex = 0;
    //アカウントの名前をtitileにセット
    NSDictionary *account = [[[UserDefaultsManager alloc]init] accountWithId:1];
    currentAccountName  =  [account objectForKey:[UserDefaultsManager accountNameKey]];
    self.navigationItem.title =  currentAccountName;
}

#pragma mark tool bar
- (void)createToolBarItem
{
    // スペーサを生成する
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil action:nil];
    
    //account edit button
    UIBarButtonItem *accountEditButton = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                          target:self
                                          action:@selector(tapAccountEditButton)] ;
    
    //SegmentedControl 
    NSArray *array = [[NSArray alloc]initWithObjects:@"カレンダー",@"リスト", nil];
    self.toolBarSegmentC = [[UISegmentedControl alloc]initWithItems:array];
    self.toolBarSegmentC.frame = CGRectMake(0, 0, 150, 30);
    self.toolBarSegmentC.segmentedControlStyle = UISegmentedControlStyleBar;
    self.toolBarSegmentC.momentary = NO;
    [self.toolBarSegmentC addTarget:self action:@selector(changeShowType:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *segbtn = [[UIBarButtonItem alloc] initWithCustomView:self.toolBarSegmentC];
    
    // toolbarにボタンとラベルをセットする
    NSArray *items = [NSArray arrayWithObjects: accountEditButton, spacer, segbtn, spacer,nil];
    self.toolbarItems = items;
}

-(void)toolbarSetting{
    self.toolBarSegmentC.selectedSegmentIndex = 1;
}
#pragma mark table view setting

-(void)tableViewSetting{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark *****************  Button Action ******************
#pragma mark navigation bar action
//一覧表示・予約済み表示を切り替える
- (void)changeListShowType:(UISegmentedControl *)sender
{
    //FIX
    //リストビューデータソース生成
    if(sender.selectedSegmentIndex == LIST_TYPE_ALL){
        VaccinationDao *dao = [[VaccinationDao alloc]init];
        listDatasource = [[NSArray alloc]initWithArray:dao.allVaccination];
    }else if(sender.selectedSegmentIndex == LIST_TYPE_RESERVATION){
        AccountAppointmentDao *dao = [[AccountAppointmentDao alloc]init];
        UserDefaultsManager *manager = [[UserDefaultsManager alloc]init];
        NSDictionary *account = [manager accountWithName:currentAccountName];
        listDatasource = [[NSArray alloc]initWithArray:
                          [dao appointmentDtoWithAccountId:[[account objectForKey:[UserDefaultsManager accountIdKey]] intValue]]];
    }
    [self.tableView reloadData];
}

#pragma mark tool bar action
//カレンダー表示・リスト表示を切り替える
- (void)changeShowType:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 0){
        AppDelegate* delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [delegate useCalendarViewController];
    }
}

- (void)tapAccountEditButton
{
    actionSheet=[ActionSheetBuilder createActionSheet];
    actionSheet.delegate = self;
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

-(void)tapSettingButton
{
    SettingViewController *settingViewController =[[SettingViewController alloc]init];
    settingViewController.delegate = self;
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:settingViewController];
    [self presentModalViewController:navi animated:YES];
}

//TODO: アカウントが変更されたらテーブルビューのデータソースを変更すr
#pragma mark *****************  Delegate ******************
#pragma mark action sheet
-(void)actionSheet:(UIActionSheet *)_actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //新規作成
    if(buttonIndex == ACTIONSHEET_CREATE_ACCOUNT){
        if([[UserDefaultsManager alloc]init].accountCanCreate){
            [self presentModalViewController:[self createAccountVCInstanceWithEditType:EDITTYPE_CREATE accountInfo:nil] animated:YES];
        }else{
            alert = [AlertBuilder createAlertWithType:ALERTTYPE_DEMAND_DELETEACCOUNT];
            alert.delegate = self;
            [alert show];
        }
    }else if(buttonIndex != _actionSheet.cancelButtonIndex){
        //アカウントきりかえ
        [self changeAccount:buttonIndex];
    }
}

#pragma mark alert view
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == ALERTTYPE_CREATEACCOUNTFORCIBLY){
        [self presentModalViewController:[self createAccountVCInstanceWithEditType:EDITTYPE_CREATE accountInfo:nil] animated:YES];
    }
}

#pragma mark custom ViewController delegate
-(void)dismissAccountViewController:(AccountViewController *)viewController
{
    //アカウントが作成されたかどうかのフラグ更新
    self.isAccountExist = [[UserDefaultsManager alloc]init].accountIsExist;
    [viewController dismissModalViewControllerAnimated:YES];
}

-(void)dismissSettingViewController:(SettingViewController *)viewController
{
    //アカウントが作成されたかどうかのフラグ更新
    self.isAccountExist = [[UserDefaultsManager alloc]init].accountIsExist;
    [viewController dismissModalViewControllerAnimated:YES];
}

#pragma mark table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listDatasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if(self.listShowTypeSwitchSegmentC.selectedSegmentIndex == LIST_TYPE_ALL){
        VaccinationDto *dto = [listDatasource objectAtIndex:indexPath.row];
        cell.textLabel.text = dto.name;
    }else if(self.listShowTypeSwitchSegmentC.selectedSegmentIndex == LIST_TYPE_RESERVATION){
        AccountAppointmentDto *dto = [listDatasource objectAtIndex:indexPath.row]; 
        cell.textLabel.text = dto.appointment;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    DetailListViewController *detailListViewController;
    NSDictionary *account = [[[UserDefaultsManager alloc]init] accountWithName:currentAccountName];
    detailListViewController = [[DetailListViewController alloc]initWithAccountId:[[account objectForKey:[UserDefaultsManager accountIdKey]] intValue] 
                                                                  vaccinationName:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    NSLog(@"%@",[tableView cellForRowAtIndexPath:indexPath].textLabel.text);
    //array中のdtoをdetail view controller に渡す
    [self.navigationController pushViewController:detailListViewController animated:YES];
}
#pragma mark *****************  other ******************
#pragma mark account 
//アカウントが無い場合は強制的に作成させる
-(void)createAccountForcibly
{
    alert = [AlertBuilder createAlertWithType:ALERTTYPE_CREATEACCOUNTFORCIBLY];
    alert.delegate = self;
    [alert show];
}

-(void)changeAccount:(NSInteger)accountId
{
    
    NSLog(@"title %@",[accountsName objectAtIndex:accountId-1]);
    currentAccountName  =  [accountsName objectAtIndex:accountId-1];
    self.navigationItem.title =  currentAccountName;
    
    
    if(self.listShowTypeSwitchSegmentC.selectedSegmentIndex == LIST_TYPE_ALL){
        VaccinationDao *dao = [[VaccinationDao alloc]init];
        listDatasource = [[NSArray alloc]initWithArray:dao.allVaccination];
    }else if(self.listShowTypeSwitchSegmentC.selectedSegmentIndex == LIST_TYPE_RESERVATION){
        AccountAppointmentDao *dao = [[AccountAppointmentDao alloc]init];
        UserDefaultsManager *manager = [[UserDefaultsManager alloc]init];
        NSDictionary *account = [manager accountWithName:currentAccountName];
        listDatasource = [[NSArray alloc]initWithArray:
                          [dao appointmentDtoWithAccountId:[[account objectForKey:[UserDefaultsManager accountIdKey]]intValue]]];
    }
    [self.tableView reloadData];
}

#pragma mark create account view controller instance
-(AccountViewController *)createAccountVCInstanceWithEditType:(NSInteger)type accountInfo:(NSDictionary *)accountInfo
{
    AccountViewController *accountViewController = 
    [[AccountViewController alloc]initWithViewControllerType:LIST_VC 
                                                    editType:type
                                                 accountInfo:accountInfo];
    accountViewController.delegate = self;
    return accountViewController;
}

@end

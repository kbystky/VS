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
#import "StringConst.h"

// builder
#import "ActionSheetBuilder.h"
#import "AlertBuilder.h"

// data access
#import "UserDefaultsManager.h"
#import "VaccinationService.h"
#import "AccountAppointmentService.h"

// dto
#import "VaccinationDto.h"
#import "AccountInfoDto.h"
#import "AccountAppointmentDto.h"

/**********/
#import "DatabaseManager.h"
/**********/

#define CellIdentifier @"myCell"

typedef enum{
    LIST_TYPE_ALL=0,
    LIST_TYPE_RESERVATION,
}ListType;

@interface ListViewController ()
{
    UIActionSheet *actionSheet;
    UIAlertView *alert;
    NSInteger listType;
    NSArray *listDatasource;
    NSMutableArray *accountsName;
    NSString  *currentAccountName;
    UserDefaultsManager *manager;
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
    actionSheet = nil;
    listType = LIST_TYPE_ALL;
    manager = [[UserDefaultsManager alloc]init];
    // 各種ビューの生成、設定
    [self createNavigationBarItem];
    [self createToolBarItem];
    [self tableViewSetting];
    [self navigationBarSetting];
}

-(void)viewWillAppear:(BOOL)animated
{
    FUNK(); [super viewWillAppear:YES];
    
    // navigatoin, toolbarの設定
    [self navigationControllerSetting];
    [self toolbarSetting];
    
    BOOL currentAccountNameIsExist = NO;
    //アカウントが存在するかチェック
    if(!self.isAccountExist) {
        
        [self createAccountForcibly];
    }else{
        
        //総アカウントの名前保持
        accountsName = [[NSMutableArray alloc]init];
        NSArray *accounts = manager.allAccount;
        
        for(AccountInfoDto *dto in accounts){
            NSString *name = dto.name;
            if([name isEqualToString:currentAccountName]){
                currentAccountNameIsExist = YES;
            }
            [accountsName addObject:name];
        }
        
        if(!currentAccountNameIsExist){
            AccountInfoDto *account = [accounts objectAtIndex:0];
            currentAccountName = account.name;
        }
        
        self.navigationItem.title =  currentAccountName;
        [self changeListDataSourceWithSelectedSegmentIndex:self.listShowTypeSwitchSegmentC.selectedSegmentIndex];
        
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
    AccountInfoDto *dto = [manager accountWithId:1];
    currentAccountName  =  dto.name;
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
    [self changeListDataSourceWithSelectedSegmentIndex:sender.selectedSegmentIndex];
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
        if(manager.accountCanCreate){
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
    //アカウントの強制作成
    if(alertView.tag == ALERTTYPE_CREATEACCOUNTFORCIBLY){
        [self presentModalViewController:[self createAccountVCInstanceWithEditType:EDITTYPE_CREATE accountInfo:nil] animated:YES];
    }
}

#pragma mark custom ViewController delegate
-(void)dismissAccountViewController:(AccountViewController *)viewController
{
    //アカウントが作成されたかどうかのフラグ更新
    self.isAccountExist = manager.accountIsExist;
    [viewController dismissModalViewControllerAnimated:YES];
}

-(void)dismissSettingViewController:(SettingViewController *)viewController
{
    //アカウントが作成されたかどうかのフラグ更新
    self.isAccountExist = manager.accountIsExist;
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
        cell.textLabel.text = dto.vaccinationDto.name;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.listShowTypeSwitchSegmentC.selectedSegmentIndex == LIST_TYPE_ALL){

        DetailListViewController *detailListViewController;
        AccountInfoDto *accountInfoDto = [manager accountWithName:currentAccountName];
        detailListViewController = [[DetailListViewController alloc]initWithAccountId:accountInfoDto.accountId vaccinationDto:[listDatasource objectAtIndex:indexPath.row]];
        NSLog(@"current name %@ id %d, name %@ id %d",accountInfoDto.name,accountInfoDto.accountId,[[listDatasource objectAtIndex:indexPath.row] name],[[listDatasource objectAtIndex:indexPath.row] vcId]);
        NSLog(@"%@",[tableView cellForRowAtIndexPath:indexPath].textLabel.text);
        //array中のdtoをdetail view controller に渡す
        [self.navigationController pushViewController:detailListViewController animated:YES];
        
    }else if(self.listShowTypeSwitchSegmentC.selectedSegmentIndex == LIST_TYPE_RESERVATION){
        
    }
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
    [self changeListDataSourceWithSelectedSegmentIndex:self.listShowTypeSwitchSegmentC.selectedSegmentIndex];
    [self.tableView reloadData];
}

- (void)changeListDataSourceWithSelectedSegmentIndex:(NSInteger)selectedIndex
{
    FUNK();
    
    if(selectedIndex == LIST_TYPE_ALL){
        
        listDatasource =  [VaccinationService vaccinationData];
        
    }else if(selectedIndex == LIST_TYPE_RESERVATION){
        //選択中のアカウントDtoを生成、サービスから予約状況を取得
        AccountInfoDto *accountInfoDto = [manager accountWithName:currentAccountName];
        AccountAppointmentService *service = [[AccountAppointmentService alloc]init];
        listDatasource = [service appointmentsDtoWithAccountId:accountInfoDto.accountId];
    }
}

#pragma mark create account view controller instance
-(AccountViewController *)createAccountVCInstanceWithEditType:(NSInteger)type accountInfo:(AccountInfoDto *)accountInfoDto
{
    AccountViewController *accountViewController =
    [[AccountViewController alloc]initWithViewControllerType:LIST_VC
                                                    editType:type
                                                 accountInfo:accountInfoDto];
    accountViewController.delegate = self;
    return accountViewController;
}

@end

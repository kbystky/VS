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

typedef enum{
    SECTION_TYPE_NOTYET=0,
    SECTION_TYPE_DONE,
}TableViewSection;

@interface ListViewController ()
{
    UIActionSheet *actionSheet;
    UIAlertView *alert;
    NSInteger listType;
    NSArray *listDatasource;
    NSMutableArray *accountsName;
    NSString  *currentAccountName;
    UserDefaultsManager *manager;
    
    AccountInfoDto *currentAccountInfoDto;
    NSArray *accountsDto;
    NSArray *vaccinationsDto;
    NSArray *appointmentsDto;
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

#pragma mark *****************  Life Cycle ******************
- (void)viewDidLoad
{
    [super viewDidLoad];
    actionSheet = nil;
    vaccinationsDto = nil;
    appointmentsDto = nil;
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
    
    //アカウントが存在するかチェック
    if(!self.isAccountExist) {
        [self createAccountForcibly];
    }else{
        /*
         ・総アカウントdtoの取得
         ・選択されているアカウントが削除されていないかのチェック
         ・datasource の生成
         */
        
        BOOL currentAccountNameIsExist = NO;
        //総アカウントDtoの取得
        accountsDto = manager.allAccount;
        
        //現在表示中のアカウントが存在するかチェック(アカウントが選択中に削除されたとき用)
        for(AccountInfoDto *dto in accountsDto){
            NSString *name = dto.name;
            if([name isEqualToString:currentAccountInfoDto.name]){
                currentAccountNameIsExist = YES;
                break;
            }
        }
        //あった場合
        if(!currentAccountNameIsExist){
            AccountInfoDto *dto = [accountsDto objectAtIndex:0];
            currentAccountInfoDto = dto;
        }else{
            //無かった場合はappointmentsDtoを初期化する
            appointmentsDto = nil;
        }
        
        self.navigationItem.title =  currentAccountInfoDto.name;
        
        //テーブルの listdata 初期化
        if(vaccinationsDto == nil){
            vaccinationsDto = [[NSArray alloc]initWithArray:[VaccinationService vaccinationData]];
        }
        
        if(appointmentsDto == nil){
            //選択中のアカウントDtoをからアポイントメントDto datasourceを生成
            AccountAppointmentService *service = [[AccountAppointmentService alloc]init];
            appointmentsDto = [service appointmentsDtoWithAccountId:currentAccountInfoDto.accountId];
        }
        
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
        appointmentsDto = nil;
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
    if(section == SECTION_TYPE_DONE){
        return [[listDatasource objectAtIndex:SECTION_TYPE_DONE] count];
    }else if(section == SECTION_TYPE_NOTYET){
        return [[listDatasource objectAtIndex:SECTION_TYPE_NOTYET] count];
    }
    return listDatasource.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(self.listShowTypeSwitchSegmentC.selectedSegmentIndex == LIST_TYPE_ALL){
        
        if(indexPath.section== SECTION_TYPE_DONE){
            VaccinationDto *dto = [[listDatasource objectAtIndex:SECTION_TYPE_DONE] objectAtIndex:indexPath.row];
            cell.textLabel.text = dto.name;
            cell.userInteractionEnabled = NO;
        }else if(indexPath.section == SECTION_TYPE_NOTYET){
            VaccinationDto *dto = [[listDatasource objectAtIndex:SECTION_TYPE_NOTYET] objectAtIndex:indexPath.row];
            cell.textLabel.text = dto.name;
        }
        
    }else if(self.listShowTypeSwitchSegmentC.selectedSegmentIndex == LIST_TYPE_RESERVATION){

        NSArray *divSectionArray;
        if(indexPath.section== SECTION_TYPE_DONE){
            divSectionArray = [listDatasource objectAtIndex:SECTION_TYPE_DONE];
        }else if(indexPath.section == SECTION_TYPE_NOTYET){
            divSectionArray = [listDatasource objectAtIndex:SECTION_TYPE_NOTYET];
        }
        AccountAppointmentDto *dto = [divSectionArray objectAtIndex:indexPath.row];
        cell.textLabel.text = dto.vaccinationDto.name;
        NSLog(@"index path %d label :%@",indexPath.row ,dto.vaccinationDto.name);
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger type = 0;
    DetailListViewController *detailListViewController;
    currentAccountInfoDto.appointmentDto = [[NSArray alloc]initWithArray:appointmentsDto];
    
    if(self.listShowTypeSwitchSegmentC.selectedSegmentIndex == LIST_TYPE_RESERVATION){
        type = TYPE_EDIT;
        NSLog(@"section : %d   row : %d",indexPath.section,indexPath.row);
        
        //選択されたappDtoからvaccinationDto を生成し引数に渡す
        AccountAppointmentDto *selectedDto = [[listDatasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSLog(@"selected %d %d",selectedDto.vcId,selectedDto.times);
        VaccinationDto *dto;
        for(VaccinationDto *d in vaccinationsDto){
            if(d.vcId == selectedDto.vcId){
                dto = d;
                break;
            }
        }
        detailListViewController = [[DetailListViewController alloc]initWithAccountInfoDto:currentAccountInfoDto vaccinationDto:dto appointmentDto:selectedDto editType:type];
        
    }else if(self.listShowTypeSwitchSegmentC.selectedSegmentIndex == LIST_TYPE_ALL){
        if(indexPath.section== SECTION_TYPE_DONE){
            // なんもしない
        }else if(indexPath.section == SECTION_TYPE_NOTYET){
            type = TYPE_CREATE;
            VaccinationDto *dto = [[listDatasource objectAtIndex:SECTION_TYPE_NOTYET] objectAtIndex:indexPath.row];
            detailListViewController = [[DetailListViewController alloc]initWithAccountInfoDto:currentAccountInfoDto vaccinationDto:dto editType:type];
        }
    }
    [self.navigationController pushViewController:detailListViewController animated:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.listShowTypeSwitchSegmentC.selectedSegmentIndex == LIST_TYPE_ALL){
        if(section == SECTION_TYPE_DONE){
            return @"完了";
        }else if(section == SECTION_TYPE_NOTYET){
            return @"未完了";
        }
    }
    if(self.listShowTypeSwitchSegmentC.selectedSegmentIndex == LIST_TYPE_RESERVATION){
        if(section == SECTION_TYPE_DONE){
            return @"実施日入力済み";
        }else if(section == SECTION_TYPE_NOTYET){
            return @"実施日未入力";
        }
    }
    return nil;
}
#pragma mark *****************  other ******************
#pragma mark account

//アカウントが無い場合は強制的に作成させる
-(void)createAccountForcibly
{
    FUNK();
    alert = [AlertBuilder createAlertWithType:ALERTTYPE_CREATEACCOUNTFORCIBLY];
    alert.delegate = self;
    [alert show];
}

-(void)changeAccount:(NSInteger)accountId
{
    FUNK();
    NSLog(@"change account %@",[accountsDto objectAtIndex:accountId - 1]);
    
    //選択されたdtoをcurrentに保持、title変更
    currentAccountInfoDto = [accountsDto objectAtIndex:accountId - 1];
    self.navigationItem.title = currentAccountInfoDto.name;
    
    //選択中のアカウントDtoをからアポイントメントDto datasourceを生成
    AccountAppointmentService *service = [[AccountAppointmentService alloc]init];
    appointmentsDto = [service appointmentsDtoWithAccountId:currentAccountInfoDto.accountId];
    
    [self changeListDataSourceWithSelectedSegmentIndex:self.listShowTypeSwitchSegmentC.selectedSegmentIndex];
    [self.tableView reloadData];
}

- (void)changeListDataSourceWithSelectedSegmentIndex:(NSInteger)selectedIndex
{
    FUNK();
    if(selectedIndex == LIST_TYPE_ALL){
        NSLog(@"change source all");
        listDatasource =  vaccinationsDto;
        [self categorizeVaccination];
    }else if(selectedIndex == LIST_TYPE_RESERVATION){
        NSLog(@"change source appoiintment");
        listDatasource = appointmentsDto;
        [self categorizeAppointment];
    }
}

#pragma mark create account view controller instance
-(AccountViewController *)createAccountVCInstanceWithEditType:(NSInteger)type accountInfo:(AccountInfoDto *)_accountInfoDto
{
    FUNK();
    AccountViewController *accountViewController =
    [[AccountViewController alloc]initWithViewControllerType:LIST_VC
                                                    editType:type
                                                 accountInfo:_accountInfoDto];
    accountViewController.delegate = self;
    return accountViewController;
}

#pragma mark vaccinations
- (void)categorizeVaccination
{
    FUNK();
    // vaccinationを抽出
    //一致するappointmentを抽出
    //回数比較
    NSMutableArray *doneVaccination = [[NSMutableArray alloc]init];
    NSMutableArray *notYeyVaccination = [[NSMutableArray alloc]init];
    int count = 0;
    for(VaccinationDto *vaccinationDto in vaccinationsDto){
        for(AccountAppointmentDto *appointmentDto in appointmentsDto){
            if(vaccinationDto.vcId == appointmentDto.vcId){
                count++;
            }
        }
        
        if(count == vaccinationDto.needTimes){
            [doneVaccination addObject:vaccinationDto];
        }else{
            [notYeyVaccination addObject:vaccinationDto];
        }
        count = 0;
    }
    listDatasource = [[NSArray alloc]initWithObjects:notYeyVaccination,doneVaccination, nil];
}

- (void)categorizeAppointment
{
    FUNK();
    NSMutableArray *doneVaccination = [[NSMutableArray alloc]init];
    NSMutableArray *notYeyVaccination = [[NSMutableArray alloc]init];
    for(AccountAppointmentDto *appointmentDto in appointmentsDto){
        if(appointmentDto.consultationDate.length == 0){
            [notYeyVaccination addObject:appointmentDto];
        }else{
            [doneVaccination addObject:appointmentDto];
        }
    }
    listDatasource = [[NSArray alloc]initWithObjects:notYeyVaccination,doneVaccination, nil];
}

@end















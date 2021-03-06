//
//  SettingViewController.m
//  VaccinationScheduler
//
//  Created by  on 12/12/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "UserDefaultsManager.h"

#import "AccountViewController.h"
#import "GCalSyncViewController.h"
#import "NotificationSettingViewController.h"
#import "AccountSettingCell.h"
#import "LocalNotificationManager.h"
#import "StringConst.h"
#import "AccountInfoDto.h"
typedef enum{
    SECTION_ACCOUNT=0,
    SECTION_GCAL_SYNC,
    SECTION_NOTIFICATION
}TypeOfSection;

#define SettingAccountCell @"accountCell"

@interface SettingViewController ()
{
    NSArray *accountDataSource;
    UserDefaultsManager *manager;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingViewController
@synthesize tableView;
@synthesize delegate = _delegate;
- (id)init
{
    self = [super init];
    
    if(self != nil){
        manager = [[UserDefaultsManager alloc]init];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    FUNK();
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self navigationControllerSetting];
    [self createNavigationBarItem];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self createDataSource];
    [tableView reloadData];    
    
}
- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)navigationControllerSetting{
    FUNK();
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

#pragma mark navigation bar
-(void)createNavigationBarItem
{
    self.navigationItem.title = @"設定";
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc]initWithTitle:@"完了" 
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(tapBack:)];
    
    self.navigationController.navigationBar.topItem.rightBarButtonItem = settingButton;
}

-(void)createDataSource
{
    accountDataSource = manager.allAccount;
}
- (IBAction)tapBack:(id)sender {
    //delegateメソッドを呼ぶ
    [self.delegate dismissSettingViewController:self];
}

#pragma mark table view delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == SECTION_ACCOUNT){
        return  manager.numberOfAccount;
    }
    if(section == SECTION_GCAL_SYNC){
        return 1;
    }
    if(section == SECTION_NOTIFICATION){
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == SECTION_ACCOUNT){
        AccountSettingCell *acCell = [[AccountSettingCell alloc]init];
        AccountInfoDto *dto = [accountDataSource objectAtIndex:indexPath.row];
        acCell.textLabel.text = dto.name;
        return acCell;
    }
    
    UITableViewCell *cell = nil;
    if(indexPath.section == SECTION_GCAL_SYNC){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SettingAccountCell];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Google Calendarと同期";
    }
    if(indexPath.section == SECTION_NOTIFICATION){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SettingAccountCell];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"通知のタイミング";
        cell.detailTextLabel.text = [self notificationDetailString];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SECTION_ACCOUNT){
        AccountInfoDto *dto = [accountDataSource objectAtIndex:indexPath.row];
        AccountViewController *accountViewController =
        [[AccountViewController alloc]initWithViewControllerType:LIST_VC 
                                                        editType:EDITTYPE_EDIT
                                                     accountInfo:dto];
        accountViewController.delegate = self;
        [self.navigationController pushViewController:accountViewController animated:YES];
        return;
    }
    
    if(indexPath.section == SECTION_GCAL_SYNC){
        GCalSyncViewController *gCalSyncViewController = [[GCalSyncViewController alloc]init];
        [self.navigationController pushViewController:gCalSyncViewController animated:YES];
        return;
    }
    
    if(indexPath.section == SECTION_NOTIFICATION){
        NotificationSettingViewController *notificationSettingViewController = [[NotificationSettingViewController alloc]init];
        [self.navigationController pushViewController:notificationSettingViewController animated:YES];
        return;
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == SECTION_ACCOUNT){
        return @"アカウント";
    }
    if(section == SECTION_GCAL_SYNC){
        return @"同期";
    }
    if(section == SECTION_NOTIFICATION){
        return @"通知";
    }
    return nil;
}

//TODO: FIX部分は開発用コードなので削除する
#pragma mark custom ViewController delegate
-(void)dismissAccountViewController:(AccountViewController *)viewController
{
    [viewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark notification detail string

-(NSString *)notificationDetailString{
    FUNK();
    NSInteger type = manager.notificationTiming;
    switch (type) {
        case NOTIFICATION_TIMING_TYPE_TODAY:
            return @"当日 7時";
            break;
        case NOTIFICATION_TIMING_TYPE_PREVIOUSDAY:
            return @"前日 17時";
            break;
        case NOTIFICATION_TIMING_TYPE_FORPRESENTATION:
            return @"プレゼン用に10秒後";
            break;
        default:
            break;
    }
    return nil;
}

@end


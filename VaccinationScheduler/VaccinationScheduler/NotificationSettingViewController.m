//
//  NotificationSettingViewController.m
//  VaccinationScheduler
//
//  Created by  on 12/12/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NotificationSettingViewController.h"
#import "UserDefaultsManager.h"
#import "LocalNotificationManager.h"

@interface NotificationSettingViewController ()
{
    NSInteger notificatoinTimingType;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NotificationSettingViewController
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UserDefaultsManager *manager = [[UserDefaultsManager alloc]init];                                
    notificatoinTimingType = manager.notificationTiming;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    if(indexPath.row == 0){
        cell.textLabel.text = @"当日";
        cell.detailTextLabel.text = @"当日の7時に通知します";
    }    
    if(indexPath.row == 1){
        cell.textLabel.text = @"前日";
        cell.detailTextLabel.text = @"前日の17時に通知します";
    }    
    if(indexPath.row == 2){
        cell.textLabel.text = @"発表用";
        cell.detailTextLabel.text = @"設定した10秒後に通知します";
    }    
    if(indexPath.row == notificatoinTimingType){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryNone){
        NSLog(@"NONE tap");
        if(indexPath.row == 0 ){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self saveNotificationTimingTypeWithSelectedType:indexPath.row];
            
            indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType =UITableViewCellAccessoryNone;
            indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType =UITableViewCellAccessoryNone;
        }else
        if(indexPath.row == 1 ){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self saveNotificationTimingTypeWithSelectedType:indexPath.row];
            
            indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType =UITableViewCellAccessoryNone;
            indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType =UITableViewCellAccessoryNone;
        }else    
        if(indexPath.row == 2 ){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self saveNotificationTimingTypeWithSelectedType:indexPath.row];
            
            indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType =UITableViewCellAccessoryNone;
            indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType =UITableViewCellAccessoryNone;
        }
  }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"通知";
    }
    return nil;
}

-(void)saveNotificationTimingTypeWithSelectedType:(NSInteger)type{
    UserDefaultsManager *manager = [[UserDefaultsManager alloc]init];
    [manager saveNotificationTimingWithTimingType:type];
}

@end

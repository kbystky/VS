//
//  GCalSyncViewController.m
//  VaccinationScheduler
//
//  Created by  on 12/12/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

enum {
    SECTION_ACCOUNT,
    SECTION_DO_SYNC,
    SECTION_REMOVE_SAVE_DATA
};
enum {
    ROW_INDEX_ID,
    ROW_INDEX_PASSWORD,
};

#import "GCalSyncViewController.h"
#import "UserDefaultsManager.h"
#import "AlertBuilder.h"
#import "GData.h"
#import "SyncGoogleCalendarManager.h"

@interface GCalSyncViewController ()
{
    UserDefaultsManager *manager;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UITextField *idTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@end

@implementation GCalSyncViewController
@synthesize tableView = _tableView;
@synthesize idTextField = _idTextField;
@synthesize passwordTextField = _passwordTextField;

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
    FUNK();
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    manager = [[UserDefaultsManager alloc]init];
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

#pragma mark table view delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == SECTION_ACCOUNT){
        return  2;
    }
    if(section == SECTION_DO_SYNC){
        return 1;
    }
    
    if(section == SECTION_REMOVE_SAVE_DATA){
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"dele");
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //IDとパスワードイベントハンドラ
    if(indexPath.section == SECTION_ACCOUNT){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(indexPath.row == ROW_INDEX_ID){
            [self.idTextField removeFromSuperview];
            self.idTextField = [[UITextField alloc]initWithFrame:CGRectMake(120, 12, 150, 30)];
            self.idTextField.returnKeyType = UIReturnKeyDone; // ReturnキーをDoneに変える
            self.idTextField.delegate = self;
            self.idTextField.tag = [indexPath row];
            self.idTextField.placeholder = @"mail address";
            self.idTextField.keyboardType = UIKeyboardTypeASCIICapable;
            self.idTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            cell.textLabel.text = @"ID";
            [cell.contentView addSubview:self.idTextField];
        }else if(indexPath.row == ROW_INDEX_PASSWORD){
            [self.passwordTextField removeFromSuperview];
            self.passwordTextField = [[UITextField alloc]initWithFrame:CGRectMake(120, 12, 150, 30)];
            self.passwordTextField.returnKeyType = UIReturnKeyDone; // ReturnキーをDoneに変える
            self.passwordTextField.delegate = self;
            self.passwordTextField.tag = [indexPath row];
            self.passwordTextField.placeholder = @"パスワード";
            self.passwordTextField.secureTextEntry = YES;
            self.passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;
            self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            cell.textLabel.text = @"パスワード";
            [cell.contentView addSubview:self.passwordTextField];
        }
        if(manager.googleAccountDataIsExist){
            NSDictionary *googleAccountData = manager.googleAccountData;
            self.idTextField.text = [googleAccountData objectForKey:[UserDefaultsManager googleAccountIdKey]];
            self.passwordTextField.text = [googleAccountData objectForKey:[UserDefaultsManager googleAccountPassKey]];
        }else{
        }
    }
    
    if(indexPath.section == SECTION_DO_SYNC){
        cell.textLabel.text = @"同期する";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    
    if(indexPath.section == SECTION_REMOVE_SAVE_DATA){
        cell.textLabel.text = @"履歴を削除する";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SECTION_ACCOUNT){
        //IDとパスワードイベントハンドラ    
        if(indexPath.row == ROW_INDEX_ID){
            //idのtextFieldにフォーカスを当てる
            [self.idTextField becomeFirstResponder];
        }
        if(indexPath.row == ROW_INDEX_PASSWORD){
            //パスワードのtextFieldにフォーカスを当てる
            [self.passwordTextField becomeFirstResponder];
        }
    }
    if(indexPath.section == SECTION_DO_SYNC){
        
        if(self.idTextField.text.length !=0 && self.passwordTextField.text.length !=0){
            //アカウント情報を取得
            manager = [[UserDefaultsManager alloc]init];
            if(!manager.googleAccountDataIsExist){
                [manager saveGoogleAccountDataWithId:self.idTextField.text password:self.passwordTextField.text];
            }
            //同期を実行
            //インジケーター出して
            //GCalロジックのチケット取得メソッドよんで(同期処理)
            //errorはハンドリングして
            //戻ってきます
            SyncGoogleCalendarManager *syncGCalManager = [[SyncGoogleCalendarManager alloc]init];
            [syncGCalManager syncGCalWithAccountId:1 vaccinationName:@"test"];
        }else{
            UIAlertView *alert = [AlertBuilder createAlertWithType:ALERTTYPE_DEMAND_FILLACCOUNTINFO];
            [alert show];
        }
        [self performSelector:@selector(_deselectTableRow:) withObject:tableView afterDelay:0.1f];
    }
    
    //履歴を削除する
    if(indexPath.section == SECTION_REMOVE_SAVE_DATA){
        manager = [[UserDefaultsManager alloc]init];
        [manager removeGoogleAccountData];
        [self.tableView reloadData];
        [self performSelector:@selector(_deselectTableRow:) withObject:tableView afterDelay:0.1f];
    }
    
}

- (void) _deselectTableRow:(UITableView *)tableView {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == SECTION_ACCOUNT){
        return @"Googleアカウント";
    }
    return nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // 入力された情報をセーブする
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    if (textField.tag == 0) {
    //        [defaults setObject:textField.text forKey:@"USERNAME"];
    //    } else if (textField.tag == 1) {
    //        [defaults setObject:textField.text forKey:@"PASSWORD"];
    //    }
}

// キーボードを隠す
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end

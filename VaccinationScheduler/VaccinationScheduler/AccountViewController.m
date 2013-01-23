//
//  AccountViewController.m
//  VaccinationScheduler
//
//  Created by  on 12/12/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AccountViewController.h"
#import "UserDefaultsManager.h"
#import "AlertBuilder.h"
#import "AccountAppointmentDao.h"
#import "StringConst.h"
#import "DateFormatter.h"
#import "AccountInfoDto.h"
@interface AccountViewController ()
{
    NSInteger selectedAccountId;
    NSString *selectedAccountName;
    UserDefaultsManager *manager;
}
@property(nonatomic)NSInteger previousViewControllerType;
@property(nonatomic)NSInteger editType;
//@property(strong,nonatomic)NSDictionary *accountInfo;
@property(strong,nonatomic)AccountInfoDto *accountInfoDto;
@property (strong, nonatomic) IBOutlet UILabel *nameText;
@property (strong, nonatomic) IBOutlet UILabel *birthDayText;
@property (strong, nonatomic) IBOutlet UITextField *nameTextFiled;
@property (strong, nonatomic) IBOutlet UITextField *birthDayTextField;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@property(strong, nonatomic) UIActionSheet *pickerViewPopup;
@property(strong, nonatomic) UIDatePicker *datePicker;

@end

@implementation AccountViewController
//public
@synthesize delegate = _delegate;
//private
@synthesize accountInfoDto = _accountInfoDto;
@synthesize previousViewControllerType = _previousViewControllerType;
@synthesize editType = _editType;
@synthesize nameText = _nameText;
@synthesize birthDayText = _birthDayText;
@synthesize nameTextFiled = _nameTextFiled;
@synthesize birthDayTextField = _birthDayTextField;
@synthesize cancelButton = _cancelButton;
@synthesize pickerViewPopup = _pickerViewPopup;
@synthesize datePicker = _datePicker;

//TODO:編集用にDtoも受け取る必要があry
#pragma mark ************  Initialize *************
-(id)initWithViewControllerType:(NSInteger)vcType editType:(NSInteger)editType accountId:(NSInteger)accountId{
    self = [super init];
    if(self){
        manager = [[UserDefaultsManager alloc]init];
        self.previousViewControllerType =vcType;
        self.editType = editType;
        selectedAccountId = accountId;
    }
    return self;
}
-(id)initWithViewControllerType:(NSInteger)vcType editType:(NSInteger)editType accountInfo:(AccountInfoDto *)accountInfo{
    self = [super init];
    if(self){
        manager = [[UserDefaultsManager alloc]init];
        self.previousViewControllerType =vcType;
        self.editType = editType;
        self.accountInfoDto = accountInfo;
    }
    return self;
}

//TODO:編集の時は最初からtextFieldに値を入れる
#pragma mark ************  Life Cycle *************
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameTextFiled.delegate = self;
    self.nameTextFiled.returnKeyType = UIReturnKeyDone;
    self.birthDayTextField.delegate = self;
    if(self.editType == EDITTYPE_EDIT){
        [self setParamToTextFiled];
        [self.cancelButton setTitle:@"削除" forState:UIControlStateNormal];
        self.title = @"アカウント";
    }
}

- (void)viewDidUnload
{
    [self setNameTextFiled:nil];
    [self setBirthDayTextField:nil];
    [self setNameText:nil];
    [self setBirthDayText:nil];
    [self setPickerViewPopup:nil];
    [self setDatePicker:nil];
    [self setCancelButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//TODO: 新規作成と編集の処理を分ける必要あり
#pragma mark ************  Action *************
- (IBAction)tapFinishButton:(id)sender {
    if(self.nameTextFiled.text.length == 0 || self.birthDayTextField.text.length == 0){
        UIAlertView *alert = [AlertBuilder createAlertWithType:ALERTTYPE_DEMAND_FILLACCOUNTINFO];
        [alert show];
        return;
    }
    
    //新規作成
    
    if(self.editType == EDITTYPE_CREATE){
        //del
        //        [manager createAccountWithName:self.nameTextFiled.text
        //                              birthDay:self.birthDayTextField.text];
        
        AccountInfoDto *dto = [[AccountInfoDto alloc]initWithAccountId:0 name:self.nameTextFiled.text birthDay:self.birthDayTextField.text];
        [manager saveAccount:dto];
    }else{
        //        //編集
        //        NSArray *obj = [NSArray arrayWithObjects:[NSNumber numberWithInt:self.accountInfo.accountId],self.nameTextFiled.text,self.birthDayTextField.text, nil];
        //        NSArray *key = [NSArray arrayWithObjects:KEY_ID, KEY_NAME,KEY_BIRTHDAY,nil];
        //        NSDictionary *info = [NSDictionary dictionaryWithObjects:obj
        //                                                         forKeys:key];
        //        [manager saveAccountWithAccountInfo:info];
        
    }
    //delegateメソッドを呼ぶ
    [self.delegate dismissAccountViewController:self];
}

- (IBAction)tapCancelButton:(id)sender {
    FUNK();
    if(self.editType == EDITTYPE_EDIT){
        
        UIAlertView *alert = [AlertBuilder createAlertWithType:ALERTTYPE_CHECK_DELETE];
        alert.delegate = self;
        [alert show];
        
    }else if(self.editType == EDITTYPE_CREATE){
        [self.delegate dismissAccountViewController:self];
        
    }
}


-(void)showPicker {
    self.pickerViewPopup = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    // Add the picker
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,44,0,0)];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    //既に誕生日入力済みの場合はピッカーで選択しておく
    if(self.birthDayTextField.text.length != 0){
        self.datePicker.date = [DateFormatter dateFormatWithString:self.birthDayTextField.text];
    }
    
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    [pickerToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"完了"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(closePicker:)];
    [barItems addObject:doneBtn];
    [pickerToolbar setItems:barItems animated:YES];
    
    [self.pickerViewPopup addSubview:pickerToolbar];
    [self.pickerViewPopup addSubview:self.datePicker];
    [self.pickerViewPopup showInView:self.view];
    [self.pickerViewPopup setBounds:CGRectMake(0,0,320, 400)];
}

-(BOOL)closePicker:(id)sender {
    self.birthDayTextField.text = [DateFormatter dateFormatWithDate:self.datePicker.date];
    [self.pickerViewPopup dismissWithClickedButtonIndex:0 animated:YES];
    return YES;
}

#pragma mark ************  Delegate *************
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([textField isEqual:self.birthDayTextField]){
        [self showPicker];
        return NO;
    }else{
        return YES;
    }
}

//キーボードを消す
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == ALERTTYPE_CHECK_DELETE && buttonIndex == BUTTON_INDEX_OK){
        //アカウント削除
        [manager removeAccount:self.accountInfoDto];
        
        AccountAppointmentDao *dao = [[AccountAppointmentDao alloc]init];
        //
        //        NSDictionary *account  =      [self.accountInfoDto objectForKey:self.nameTextFiled.text] ;
        //        NSInteger accountId = [[account objectForKey:KEY_ID] intValue];
        //        [dao deleteWithAccountId:accountId];
        
        [dao deleteWithAccountId:self.accountInfoDto.accountId];
        
        //[[UserDefaultsManager alloc]init] accountWithName:[self.accountInfo objectForKey:self.nameTextFiled.text] objectForKey:[UserDefaultsManager KEY_ID_INT]intValue]
        //delegateメソッドを呼ぶ
        [self.delegate dismissAccountViewController:self];
    }
}

#pragma mark ************  other *************
-(void)setParamToTextFiled{
    //    self.nameTextFiled.text = [self.accountInfo objectForKey:KEY_NAME];
    //    self.birthDayTextField.text = [self.accountInfo objectForKey:KEY_BIRTHDAY];
    self.nameTextFiled.text = self.accountInfoDto.name;
    self.birthDayTextField.text =self.accountInfoDto.birthDay;
}
@end

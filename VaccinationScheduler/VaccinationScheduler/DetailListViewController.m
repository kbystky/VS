//
//  DetailViewController.m
//  VaccinationScheduler
//
//  Created by  on 12/12/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailListViewController.h"
#import "AccountAppointmentDao.h"
#import "AccountAppointmentService.h"
#import "AccountInfoDto.h"
#import "VaccinationDao.h"
#import "AlertBuilder.h"
#import "LocalNotificationManager.h"
#import "DateFormatter.h"
#import "AccountAppointmentDto.h"

@interface DetailListViewController ()
{
    AccountAppointmentDto *appointmentDto;
    VaccinationDto *vaccinationDto;
    NSInteger accountId;
    NSString *vaccinationName;
    AccountInfoDto *accountInfoDto;
    NSInteger type;
    BOOL wantClearTextField;
    UITextField *selectedTextField;
}
@property (strong, nonatomic) IBOutlet UILabel *vaccinationNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalTimesLabel;
@property (strong, nonatomic) IBOutlet UILabel *finishTimesLable;
@property (strong, nonatomic) IBOutlet UITextField *appointmentDayTextField;
@property (strong, nonatomic) IBOutlet UITextField *consultationDayTextField;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIButton *addButton;

@property(strong, nonatomic) UIActionSheet *pickerViewPopup;
@property(strong, nonatomic) UIDatePicker *datePicker;
@end

@implementation DetailListViewController
@synthesize vaccinationNameLabel;
@synthesize totalTimesLabel;
@synthesize finishTimesLable;
@synthesize appointmentDayTextField;
@synthesize pickerViewPopup = _pickerViewPopup;
@synthesize datePicker = _datePicker;

#pragma mark *****************  Initialize ******************
-(id)initWithAccountInfoDto:(AccountInfoDto *)_accountInfoDto vaccinationDto:(VaccinationDto *)_vaccinationDto editType:(NSInteger)_type
{
    self = [super init];
    if(self){
        FUNK();
        accountInfoDto = _accountInfoDto;
        vaccinationDto = _vaccinationDto;
        type =_type;
        NSLog(@"account id %d",accountInfoDto.accountId);
    }
    return self;
}

-(id)initWithAccountInfoDto:(AccountInfoDto *)_accountInfoDto vaccinationDto:(VaccinationDto *)_vaccinationDto appointmentDto:(AccountAppointmentDto *)_appointmentDto editType:(int)_type
{
    self = [super init];
    if(self){
        FUNK();
        accountInfoDto = _accountInfoDto;
        vaccinationDto = _vaccinationDto;
        appointmentDto = _appointmentDto;
        type =_type;
        NSLog(@"account id %d",accountInfoDto.accountId);
    }
    return self;
}

#pragma mark *****************  Life Cycle ******************
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self viewSetting];
    self.appointmentDayTextField.delegate =self;
    self.consultationDayTextField.delegate =self;
    self.appointmentDayTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.consultationDayTextField.clearButtonMode = UITextFieldViewModeAlways;
    wantClearTextField = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
}

- (void)viewDidUnload
{
    [self setTotalTimesLabel:nil];
    [self setFinishTimesLable:nil];
    [self setVaccinationNameLabel:nil];
    [self setAppointmentDayTextField:nil];
    [self setDeleteButton:nil];
    [self setAddButton:nil];
    [self setConsultationDayTextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark *****************  View Setting ******************
-(void)viewSetting{
    self.vaccinationNameLabel.text = vaccinationDto.name;
    self.totalTimesLabel.text = [NSString stringWithFormat:@"%d",vaccinationDto.needTimes];
    FUNK();
    if(type == TYPE_EDIT){
        //予約編集
        NSLog(@"EDIT TYPE");
        //TODO:これまでの受診回数を表示でいいかな？
        //        NSInteger appointmentTimes = [self countOfConsultationTimes];
        NSInteger appointmentTimes = appointmentDto.times;
        NSLog(@"appointmenttimes %d",appointmentTimes);
        self.finishTimesLable.text = [NSString stringWithFormat:@"%d",appointmentTimes];
        //やっぱ何回目の受診かを表示の方が良いね
        
        self.appointmentDayTextField.text =appointmentDto.appointmentDate;
        self.consultationDayTextField.text =appointmentDto.consultationDate;
        
    }else if (type == TYPE_CREATE){
        //新規予約作成
        //これまでの受診回数を表示
        NSInteger appointmentTimes = [self countOfConsultationTimes];
        self.finishTimesLable.text = [NSString stringWithFormat:@"%d",appointmentTimes + 1];
        
        // 削除ボタンの削除、登録ボタンの移動
        [self.deleteButton removeFromSuperview];
        CGRect addBtnFrame = self.addButton.frame;
        self.addButton.frame = CGRectMake(123, addBtnFrame.origin.y, addBtnFrame.size.width,addBtnFrame.size.height );
    }
}

- (IBAction)addAppointment:(id)sender {
    // 予約日が入力済みなら登録する
    if(self.appointmentDayTextField.text.length != 0){
        
        // 更新
        AccountAppointmentService *service = [[AccountAppointmentService alloc]init];
        if(type == TYPE_EDIT){
            [service updateAppointmentWithCurrentAppointmentDto:appointmentDto
                                             newAppointmentDate:self.appointmentDayTextField.text
                                            newConsultationDate:self.consultationDayTextField.text];
            // notification に再登録
            
        }else if (type == TYPE_CREATE){
     
            // 一日の受診回数をチェック
            if(![service canSaveAppointmentTimesWithAppointmentDay:self.appointmentDayTextField.text accountId:accountInfoDto.accountId]){
                [[AlertBuilder createAlertWithType:ALERTTYPE_NOT_SAVE_APPOINTMENT_TIMES] show];
                return;
            }
            if(![service checkPeriodFromLastTimeWithVaccinationtDto:vaccinationDto appointmentDay:self.appointmentDayTextField.text accountId:accountInfoDto.accountId]){
                [[AlertBuilder createAlertWithType:ALERTTYPE_NOT_SAVE_APPOINTMENT_PERIOD] show];
                return;
            }
            //登録
            [service saveAppointmentWithAccountId:accountInfoDto.accountId
                                            times:[self.finishTimesLable.text intValue]
                                  appointmentDate:self.appointmentDayTextField.text
                                 consultationDate:self.consultationDayTextField.text
                                   vaccinationDto:vaccinationDto];
            
            //notificationに登録
            AccountAppointmentDto *saveAppointmentDto = [[AccountAppointmentDto alloc]init];
            saveAppointmentDto.accountId =accountInfoDto.accountId;
            saveAppointmentDto.times = [self.finishTimesLable.text intValue];
            saveAppointmentDto.appointmentDate= self.appointmentDayTextField.text;
            saveAppointmentDto.vcId = vaccinationDto.vcId;
            
            LocalNotificationManager *manager = [[LocalNotificationManager alloc]init];
            [manager createNotificationWithRecordDate:self.appointmentDayTextField.text appointmentDto:saveAppointmentDto];
        }

        [self.navigationController popViewControllerAnimated:YES];
        return;
    }else{
        [[AlertBuilder createAlertWithType:ALERTTYPE_DEMAND_FILLINFO] show];
    }
}

- (IBAction)deleteButtonTap:(id)sender {
    UIAlertView *alert = [AlertBuilder createAlertWithType:ALERTTYPE_DELETE_APPOINTMENT];
    alert.delegate = self;
    [alert show];
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
    
    if([selectedTextField isEqual:self.appointmentDayTextField]){
        if(self.appointmentDayTextField.text.length != 0){
            self.datePicker.date = [DateFormatter dateFormatWithString:self.appointmentDayTextField.text];
        }
    }else{
        if(self.consultationDayTextField.text.length != 0){
            self.datePicker.date = [DateFormatter dateFormatWithString:self.consultationDayTextField.text];
        }
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
    if([selectedTextField isEqual:self.appointmentDayTextField]){
        self.appointmentDayTextField.text = [DateFormatter dateFormatWithDate:self.datePicker.date];
    }else{
        self.consultationDayTextField.text = [DateFormatter dateFormatWithDate:self.datePicker.date];
    }
    [self.pickerViewPopup dismissWithClickedButtonIndex:0 animated:YES];
    return YES;
}
#pragma mark ************  Delegate *************
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    FUNK();
    if([textField isEqual:self.appointmentDayTextField] || [textField isEqual:self.consultationDayTextField]){
        if(!wantClearTextField){
            selectedTextField = textField;
            [self showPicker];
        }
        wantClearTextField = NO;
        return NO;
    }else{
        wantClearTextField = NO;
        return YES;
    }
}
-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    FUNK();    NSLog(@"clear");
    wantClearTextField = YES;
    return YES;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    FUNK();
    if(alertView.tag == ALERTTYPE_DELETE_APPOINTMENT && buttonIndex == BUTTON_INDEX_OK){
        AccountAppointmentService *service = [[AccountAppointmentService alloc]init];
        [service removeAppointmentWithAppointmentDto:appointmentDto];
        
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
}
#pragma mark *****************  other ******************
- (NSInteger)countOfConsultationTimes
{
    FUNK();
    NSInteger times = 0;
    for(AccountAppointmentDto *dto in accountInfoDto.appointmentDto){
        NSLog(@"appoID : %d  vacciID : %d",dto.vcId,vaccinationDto.vcId);
        if(dto.vcId == vaccinationDto.vcId){
            times++;
        }
    }
    return times;
}

@end

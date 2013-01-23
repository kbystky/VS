//
//  DetailViewController.m
//  VaccinationScheduler
//
//  Created by  on 12/12/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailListViewController.h"
#import "AccountAppointmentDao.h"
#import "VaccinationDao.h"
#import "AlertBuilder.h"
#import "LocalNotificationManager.h"
#import "DateFormatter.h"
@interface DetailListViewController ()
{
    AccountAppointmentDto *appointmentDto;
    VaccinationDto *vaccinationDto;
    NSInteger accountId;
    NSString *vaccinationName;
}
@property (strong, nonatomic) IBOutlet UILabel *vaccinationNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalTimesLabel;
@property (strong, nonatomic) IBOutlet UILabel *finishTimesLable;
@property (strong, nonatomic) IBOutlet UITextField *appointmentDayTextField;

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

-(id)initWithAccountId:(NSInteger)_accountId vaccinationName:(NSString *)name{
    self = [super init];
    if(self){
        accountId = _accountId;
        FUNK();
        NSLog(@"account id %d",accountId);
        vaccinationName = name;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appointmentDayTextField.delegate =self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self viewSetting];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidUnload
{
    [self setTotalTimesLabel:nil];
    [self setFinishTimesLable:nil];
    [self setVaccinationNameLabel:nil];
    [self setAppointmentDayTextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewSetting{
    self.vaccinationNameLabel.text = vaccinationName;
    AccountAppointmentDao *appointmentDao = [[AccountAppointmentDao alloc]init];
    NSInteger appointmentTimes =  [appointmentDao timesWithAccountId:accountId vaccinationName:vaccinationName];
    NSLog(@"appointmenttimes %d",appointmentTimes);
    if(appointmentTimes>10){
        appointmentTimes =0;
    }
//    NSLog(@"appointmenttimes %d",appointmentTimes);
    self.finishTimesLable.text = [NSString stringWithFormat:@"%d",appointmentTimes];

    if(appointmentTimes != 0){
       self.appointmentDayTextField.text = [appointmentDao dateWithAccountId:accountId vaccinationName:vaccinationName times:[self.finishTimesLable.text intValue]];
    }
}
- (IBAction)addAppointment:(id)sender {
    AccountAppointmentDao *appointmentDao = [[AccountAppointmentDao alloc]init];
    if(self.appointmentDayTextField.text.length != 0){
        [appointmentDao saveAppointmentWithDate:self.appointmentDayTextField.text vaccinationName:self.vaccinationNameLabel.text times:[self.finishTimesLable.text intValue] accountId:accountId];
        LocalNotificationManager *manager = [[LocalNotificationManager alloc]init];
        [manager createNotificationWithRecordDate:self.appointmentDayTextField.text accountId:accountId];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [[AlertBuilder createAlertWithType:ALERTTYPE_DEMAND_FILLINFO] show];
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
    
    if(self.appointmentDayTextField.text.length != 0){
        self.datePicker.date = [DateFormatter dateFormatWithString:self.appointmentDayTextField.text];
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
    self.appointmentDayTextField.text = [DateFormatter dateFormatWithDate:self.datePicker.date];
    [self.pickerViewPopup dismissWithClickedButtonIndex:0 animated:YES];
    return YES;
}

#pragma mark ************  Delegate *************
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([textField isEqual:self.appointmentDayTextField]){
        [self showPicker];
        return NO;
    }else{
        return YES;
    }
}

@end

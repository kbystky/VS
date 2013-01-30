//
//  DetailViewController.h
//  VaccinationScheduler
//
//  Created by  on 12/12/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountAppointmentDto.h"
#import "VaccinationDto.h"
typedef enum{
    TYPE_EDIT=1,
    TYPE_CREATE
}CalledType;

@class AccountInfoDto;
@interface DetailListViewController : UIViewController<UITextFieldDelegate,UIActionSheetDelegate>
-(id)initWithAccountInfoDto:(AccountInfoDto *)_accountInfoDto vaccinationDto:(VaccinationDto *)_vaccinationDto editType:(NSInteger)_type;
-(id)initWithAccountInfoDto:(AccountInfoDto *)_accountInfoDto vaccinationDto:(VaccinationDto *)_vaccinationDto appointmentDto:(AccountAppointmentDto *)_appointmentDto editType:(int)_type;
@end

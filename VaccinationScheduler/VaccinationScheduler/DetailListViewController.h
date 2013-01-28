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
-(id)initWithAccountId:(NSInteger)_accountId vaccinationName:(NSString *)name;
-(id)initWithAccountId:(NSInteger)_accountId vaccinationDto:(VaccinationDto *)dto;
-(id)initWithAccountInfoDto:(AccountInfoDto *)_accountInfoDto vaccinationDto:(VaccinationDto *)dto editType:(NSInteger)_type;
-(id)initWithAccountInfoDto:(AccountInfoDto *)_accountInfoDto vaccinationDto:(VaccinationDto *)dto selectAppointmentIndex:(NSInteger)index editType:(int)_type;
@end

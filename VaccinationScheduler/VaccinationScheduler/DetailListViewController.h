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

@interface DetailListViewController : UIViewController<UITextFieldDelegate,UIActionSheetDelegate>
-(id)initWithAccountId:(NSInteger)_accountId vaccinationName:(NSString *)name;
@end

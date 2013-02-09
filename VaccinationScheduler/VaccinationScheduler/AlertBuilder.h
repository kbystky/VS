//
//  AlertBuilder.h
//  VaccinationScheduler
//
//  Created by  on 12/12/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
typedef enum{
    ALERTTYPE_CREATEACCOUNTFORCIBLY=1,
    ALERTTYPE_DEMAND_DELETEACCOUNT,
    ALERTTYPE_DEMAND_FILLACCOUNTINFO,
    ALERTTYPE_DELETE_ACCOUNT,
    ALERTTYPE_DEMAND_FILLINFO,
    ALERTTYPE_DELETE_APPOINTMENT,
}AlertType;

typedef enum{
    BUTTON_INDEX_CANCEL,
    BUTTON_INDEX_OK
}AlertButtonIndex;

#import <Foundation/Foundation.h>

@interface AlertBuilder : NSObject

+(UIAlertView*)createAlertWithType:(NSInteger)alertType;

@end

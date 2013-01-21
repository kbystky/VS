//
//  AlertBuilder.h
//  VaccinationScheduler
//
//  Created by  on 12/12/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
enum{
    ALERTTYPE_CREATEACCOUNTFORCIBLY,
    ALERTTYPE_DEMAND_DELETEACCOUNT,
    ALERTTYPE_DEMAND_FILLACCOUNTINFO,
    ALERTTYPE_CHECK_DELETE,
    ALERTTYPE_DEMAND_FILLINFO,

};
enum{
    BUTTON_INDEX_CANCEL,
    BUTTON_INDEX_OK
};
#import <Foundation/Foundation.h>

@interface AlertBuilder : NSObject

+(UIAlertView*)createAlertWithType:(NSInteger)alertType;

@end

//
//  ActionSheetBuilder.h
//  VaccinationScheduler
//
//  Created by  on 12/12/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
enum
{
    ACTIONSHEET_CREATE_ACCOUNT,
}actionsheetConst;

#import <Foundation/Foundation.h>

@interface ActionSheetBuilder : NSObject

+(UIActionSheet *)createActionSheet;

@end

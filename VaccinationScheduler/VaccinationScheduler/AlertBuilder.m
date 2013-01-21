//
//  AlertBuilder.m
//  VaccinationScheduler
//
//  Created by  on 12/12/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AlertBuilder.h"

@implementation AlertBuilder
+(UIAlertView*)createAlertWithType:(NSInteger)alertType{
    UIAlertView  *alert;
    
    alert = [[UIAlertView alloc] initWithTitle:[self alertTitleWithAlertType:alertType]
                                       message:[self alertMessageWithAlertType:alertType]
                                      delegate:nil
                             cancelButtonTitle:[self alertCancelButtonTitleWithAlertType:alertType]
                             otherButtonTitles:[self alertOtherButtonTitleWithAlertType:alertType],nil];
    alert.tag = alertType; 
    return alert;
}

+(NSString *)alertTitleWithAlertType:(NSInteger)type{
    NSString *title=nil;
    switch (type) {
        case ALERTTYPE_CREATEACCOUNTFORCIBLY:
            title = @"アカウントが存在しません";
            break;
        case ALERTTYPE_DEMAND_DELETEACCOUNT:
            title = @"アカウント数が上限です";
            break;
        case ALERTTYPE_DEMAND_FILLACCOUNTINFO | ALERTTYPE_DEMAND_FILLINFO:
            title = @"未入力の項目があります";
            break;
        case ALERTTYPE_CHECK_DELETE:
            title = @"アカウントを削除しても\nよろしいですか？";
            break;
    }
    return title; 
}

+(NSString *)alertMessageWithAlertType:(NSInteger)type{
    NSString *message=nil;
    switch (type) {
            
        case ALERTTYPE_CREATEACCOUNTFORCIBLY:
            message = @"アカウントを作成してください。";
            break;
        case ALERTTYPE_DEMAND_DELETEACCOUNT:
            message = @"新規にアカウントを作成するには\n設定画面からアカウントを\n削除してください。";
            break;
        case ALERTTYPE_DEMAND_FILLACCOUNTINFO:
            message = @"アカウントの情報を入力してください。";
            break;
        case ALERTTYPE_CHECK_DELETE:
            message = @"アカウントを削除すると予約情報\nなどがすべて削除されます。";
            break;
        case ALERTTYPE_DEMAND_FILLINFO:
            message = @"予約日を入力してください。";
            break;

    }
    return message; 
}

+(NSString *)alertCancelButtonTitleWithAlertType:(NSInteger)type{
    NSString *title=nil;
    switch (type) {
        case ALERTTYPE_CHECK_DELETE:
            title = @"キャンセル";
            break;
    }
    return title; 
}

+(NSString *)alertOtherButtonTitleWithAlertType:(NSInteger)type{
    FUNK();
    NSString *title=nil;
    switch (type) {
        case ALERTTYPE_CREATEACCOUNTFORCIBLY:
            title = @"OK";
            break;
        case ALERTTYPE_DEMAND_DELETEACCOUNT:
            title = @"OK";
            break;
        case ALERTTYPE_DEMAND_FILLACCOUNTINFO:
            title = @"OK";
            break;
        case ALERTTYPE_CHECK_DELETE:
            title = @"OK";
            break;
        case ALERTTYPE_DEMAND_FILLINFO:
            title = @"OK";
            break;
            
    }
    return title; 
}
@end

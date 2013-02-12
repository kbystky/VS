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
        case ALERTTYPE_DEMAND_FILLACCOUNTINFO:
            title = @"未入力の項目があります";
            break;
        case ALERTTYPE_DEMAND_FILLINFO:
            title = @"未入力の項目があります";
            break;
        case ALERTTYPE_DELETE_ACCOUNT:
            title = @"アカウントを削除しても\nよろしいですか？";
            break;
        case ALERTTYPE_DELETE_APPOINTMENT:
            title = @"予約を削除しても\nよろしいですか？";
            break;
        case ALERTTYPE_NOT_SAVE_APPOINTMENT_TIMES:
            title = @"予約を登録できません";
            break;
        case ALERTTYPE_NOT_SAVE_APPOINTMENT_PERIOD:
            title = @"予約を登録できません";
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
            message = @"アカウント情報を入力してください。";
            break;
        case ALERTTYPE_DELETE_ACCOUNT:
            message = @"アカウントを削除すると予約情報\nなどがすべて削除されます。";
            break;
        case ALERTTYPE_DEMAND_FILLINFO:
            message = @"予約日を入力してください。";
            break;
        case ALERTTYPE_DELETE_APPOINTMENT:
            message = @"削除された予約情報は復元できません。また、この予防接種の削除以降の予約情報も削除されます。";
            break;
        case ALERTTYPE_NOT_SAVE_APPOINTMENT_TIMES:
            message = @"一日に２回以上予防接種を受けることは出来ません。";
            break;
        case ALERTTYPE_NOT_SAVE_APPOINTMENT_PERIOD:
            message = @"前回の接種から十分な期間が経っていません。";
            break;
            
    }
    return message;
}

+(NSString *)alertCancelButtonTitleWithAlertType:(NSInteger)type{
    if(type == ALERTTYPE_DELETE_ACCOUNT || type == ALERTTYPE_DELETE_APPOINTMENT){
        return @"キャンセル";
    }
    return nil;
}

+(NSString *)alertOtherButtonTitleWithAlertType:(NSInteger)type{
    FUNK();
    return @"OK";
}
@end

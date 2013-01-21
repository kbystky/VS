//
//  ActionSheetBuilder.m
//  VaccinationScheduler
//
//  Created by  on 12/12/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ActionSheetBuilder.h"
#import "UserDefaultsManager.h"
@implementation ActionSheetBuilder

+(UIActionSheet *)createActionSheet{
    UIActionSheet *sheet = [[UIActionSheet alloc]init];
    sheet.title = @"アカウント";
    FUNK();
    NSArray *accounts = [[UserDefaultsManager alloc]init].allAccount;

    NSLog(@"acc num %d",accounts.count);
    //ボタンの数は動的にアカウント数から数える
    [sheet addButtonWithTitle:@"アカウント追加"];
    int i;
    for(i = 0;i<accounts.count;i++){
        NSDictionary *account = [accounts objectAtIndex:i];
        [sheet addButtonWithTitle:[account objectForKey:[UserDefaultsManager accountNameKey]]];
    }
    [sheet addButtonWithTitle:@"キャンセル"];
//    sheet.destructiveButtonIndex = DESTRUCTIVEBUTTON_INDEX;
    sheet.cancelButtonIndex = i+1;
    return sheet;
}

@end

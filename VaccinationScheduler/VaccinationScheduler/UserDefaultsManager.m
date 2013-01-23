//
//  UserDefaultsManager.m
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#define  MAX_NUMBER_OF_ACCOUNT 3

#import "UserDefaultsManager.h"
#import "StringConst.h"
#import "AccountInfoDto.h"
@interface UserDefaultsManager()
{
    NSUserDefaults *defaults;
}
@end

@implementation UserDefaultsManager

#pragma mark - ******  ******
NSString *const KEY_ACCOUNTS_MUDIC =@"accounts";
NSString *const KEY_NOTIFICATION_TIMING_TYPE =@"notification_type";

#pragma mark - ****** initialize ******

-(id)init
{
    self = [super init];
    if(self != nil){
        defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

#pragma mark - ******  ******
-(void)saveAccount:(AccountInfoDto *)accountInfoDto
{
    FUNK();
    if(accountInfoDto.accountId == 0){
        [self createNewAccount:accountInfoDto];
    }else{
        [self editAccount:accountInfoDto];
    }
}

-(void)removeAccount:(AccountInfoDto *)accountInfoDto
{
    
}
// データ新規作成
-(void)createNewAccount:(AccountInfoDto *)accountInfoDto
{
    FUNK();    NSMutableDictionary *accounts;
    NSInteger accountId = 1;
    if(![self accountIsExist]){
        //一度もアカウントが登録されて無いときにベースとなるdicを生成
        accounts = [[NSMutableDictionary alloc]init];
    }else{
        accounts = [[defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC] mutableCopy];
        //キャストじゃなくてmutablecopy
        BOOL accountIdNotExist = YES;
        for(int i = 1;i<=MAX_NUMBER_OF_ACCOUNT;i++){
            for(NSString *key in [accounts allKeys]){
                AccountInfoDto *dto = (AccountInfoDto *)[accounts objectForKey:key];
                if(dto.accountId == i){
                    accountIdNotExist = NO;
                    break;
                }
            }
            if(accountIdNotExist){
                NSLog(@"new id %d",i);
                accountId = i;
                break;
            }
            accountIdNotExist = YES;
        }
    }
    accountInfoDto.accountId = accountId;
    
    // archive
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accountInfoDto];
    [accounts setObject:data forKey:[KEY_ACCOUNT_NUMBER_PREFIX stringByAppendingFormat:@"%d",accountId]];
    [defaults setObject:accounts forKey:KEY_ACCOUNTS_MUDIC];
    [defaults synchronize];
}
// データ編集
-(void)editAccount:(AccountInfoDto *)accountInfoDto
{
    
}


//アカウント生成
-(void)createAccountWithName:(NSString *)name birthDay:(NSString *)birthDay{
    NSMutableDictionary *accounts;
    NSInteger accountId = 1;
    if(![self accountIsExist]){
        //一度もアカウントが登録されて無いときにベースとなるdicを生成
        accounts = [[NSMutableDictionary alloc]init];
    } else {
        //キャストじゃなくてmutablecopy
        accounts = [[defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC] mutableCopy];
        BOOL accountIdNotExist = YES;
        for(int i = 1;i<=MAX_NUMBER_OF_ACCOUNT;i++){
            for(NSString *key in [accounts allKeys]){
                NSMutableDictionary *ac = [accounts objectForKey:key];
                if([[ac objectForKey:KEY_ID] intValue] == i){
                    accountIdNotExist = NO;
                    break;
                }
            }
            if(accountIdNotExist){
                NSLog(@"new id %d",i);
                accountId = i;
                break;
            }
            accountIdNotExist = YES;
        }
    }
    
    NSArray *obj = [NSArray arrayWithObjects:[NSNumber numberWithInt:accountId],name,birthDay,nil];
    NSArray *key = [NSArray arrayWithObjects:KEY_ID,KEY_NAME,KEY_BIRTHDAY,nil];
    NSDictionary *account = [NSDictionary dictionaryWithObjects:obj forKeys:key];
    
    [accounts setObject:account forKey:[KEY_ACCOUNT_NUMBER_PREFIX stringByAppendingFormat:@"%d",accountId]];
    
    [defaults setObject:accounts forKey:KEY_ACCOUNTS_MUDIC];
    NSLog(@"add  name:%@  birthday:%@  id:%d",name,birthDay,accountId);
    [defaults synchronize];
}

//アカウント情報保存(編集)
-(void)saveAccountWithAccountInfo:(NSDictionary *)info{
    FUNK();
    //infoからname birthを抽出
    NSInteger accountId = [[info objectForKey:KEY_ID] intValue];
    //userdefaultからaccountsを抽出
    NSMutableDictionary *accounts = (NSMutableDictionary*) [defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC];
    
    //nameが一致するaccountをaccountsから抽出、変更、(元々を削除？)
    NSMutableDictionary *newAccounts = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *account;
    for( NSString *key in [accounts allKeys]){
        //mutablecopyしないと２回目以降imutable accessで落ちる
        account = [[accounts objectForKey:key] mutableCopy];
        
        if([[account objectForKey:KEY_ID] intValue] == accountId ){
            [account setObject:[info objectForKey:KEY_NAME] forKey:KEY_NAME];
            [account setObject:[info objectForKey:KEY_BIRTHDAY] forKey:KEY_BIRTHDAY];
        }
        [newAccounts setObject:account forKey:[KEY_ACCOUNT_NUMBER_PREFIX stringByAppendingFormat:@"%d",[[account objectForKey:KEY_ID] intValue]]];
    }
    
    [defaults setObject:newAccounts forKey:KEY_ACCOUNTS_MUDIC];
    [defaults synchronize];
}

//アカウント削除
-(void)removeAccountWithAccountInfo:(NSDictionary *)info{
    FUNK();
    //infoからname birthを抽出
    NSInteger accountId = [[info objectForKey:KEY_ID] intValue];
    //userdefaultからaccountsを抽出
    NSMutableDictionary *accounts = (NSMutableDictionary*) [defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC];
    
    //nameが一致するaccountをaccountsから抽出、変更、(元々を削除？)
    NSMutableDictionary *newAccounts = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *account;
    for( NSString *key in [accounts allKeys]){
        //mutablecopyしないと２回目以降imutable accessで落ちる
        account = [[accounts objectForKey:key] mutableCopy];
        NSLog(@"acc id %d",[[account objectForKey:KEY_ID] intValue]);
        if([[account objectForKey:KEY_ID] intValue] == accountId){
            NSLog(@"remove");
            continue;
        }
        [newAccounts setObject:account forKey:[KEY_ACCOUNT_NUMBER_PREFIX stringByAppendingFormat:@"%d",[[account objectForKey:KEY_ID] intValue]]];
    }
    
    [defaults setObject:newAccounts forKey:KEY_ACCOUNTS_MUDIC];
    [defaults synchronize];
}


//アカウント情報保存(編集)
-(NSArray *)allAccount{
    NSMutableDictionary *accounts = (NSMutableDictionary*) [defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    NSArray *keys = [accounts allKeys];
    for(NSString *key in keys){
        AccountInfoDto *dto = [NSKeyedUnarchiver unarchiveObjectWithData:[accounts objectForKey:key]];
        [array addObject:dto];
    }

    //idでソート
    NSSortDescriptor *sortDispId = [[NSSortDescriptor alloc] initWithKey:@"accountId" ascending:YES];
    NSArray *sortDescArray = [NSArray arrayWithObjects:sortDispId, nil];
    array = [NSMutableArray arrayWithArray:[array sortedArrayUsingDescriptors:sortDescArray]];
    return array;
}

//アカウント取得
-(AccountInfoDto *)accountWithId:(NSInteger)accountId
{
    FUNK();
    NSMutableDictionary *accounts = (NSMutableDictionary*) [defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC];
    NSArray *keys = [accounts allKeys];
    for(NSString *key in keys){
        AccountInfoDto *dto = [NSKeyedUnarchiver unarchiveObjectWithData:[accounts objectForKey:key]];

        if(dto.accountId == accountId){
            return dto;
        }
    }
    return nil;
}
//    NSMutableDictionary  *accounts = (NSMutableDictionary*) [defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC];
//    NSArray *keys = [accounts allKeys];
//    NSDictionary *account;
//    for(NSString *key in keys){
//        account = [accounts objectForKey:key];
//        if([[account objectForKey:KEY_ID] intValue] == accountId){
//            return account;
//        }
//    }
//    return nil;
//}

//アカウント取得
-(AccountInfoDto *)accountWithName:(NSString *)accountName
{
    FUNK();
    NSMutableDictionary *accounts = (NSMutableDictionary*) [defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC];
    NSArray *keys = [accounts allKeys];
    for(NSString *key in keys){
        AccountInfoDto *dto = [NSKeyedUnarchiver unarchiveObjectWithData:[accounts objectForKey:key]];
        
        if([dto.name isEqualToString:accountName]){
            return dto;
        }
    }
//    NSMutableDictionary *accounts = (NSMutableDictionary*) [defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC];
//    NSArray *keys = [accounts allKeys];
//    NSDictionary *account;
//    for(NSString *key in keys){
//        account = [accounts objectForKey:key];
//        if([[account objectForKey:KEY_NAME] isEqualToString:accountName]){
//            return account;
//        }
//    }
    return nil;
}
//アカウントが存在するか
-(BOOL)accountIsExist{
    NSDictionary *accounts = (NSDictionary *)[defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC];
    return accounts.count != 0;
}

//アカウントを作成できるか
-(BOOL)accountCanCreate{
    NSDictionary *accounts = (NSDictionary *)[defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC];
    return accounts.count +1 <= MAX_NUMBER_OF_ACCOUNT;
}

//アカウント数
-(NSInteger)numberOfAccount{
    NSDictionary *accounts = (NSDictionary *)[defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC];
    return accounts.count;
}

#pragma mark - ****** Google Accont ******

- (BOOL)googleAccountDataIsExist{
    NSString *gId = (NSString *)[defaults stringForKey:KEY_GOOGLE_ID];
    NSString *gPassword = (NSString *)[defaults stringForKey:KEY_GOOGLE_PASS];
    return gId.length !=0 && gPassword.length !=0;
}

- (BOOL)saveGoogleAccountDataWithId:(NSString *)gId password:(NSString *)gPass
{
    [defaults setObject:gId forKey:KEY_GOOGLE_ID];
    [defaults setObject:gPass forKey:KEY_GOOGLE_PASS];
    BOOL successful = [defaults synchronize];
    if (successful) {
        return YES;
    }else{
        return NO;
    }
}

- (NSDictionary *)googleAccountData
{
    NSString *gId = (NSString *)[defaults stringForKey:KEY_GOOGLE_ID];
    NSString *gPass = (NSString *)[defaults stringForKey:KEY_GOOGLE_PASS];
    
    NSArray *obj = [NSArray arrayWithObjects:gId,gPass, nil];
    NSArray *key = [NSArray arrayWithObjects:KEY_GOOGLE_ID,KEY_GOOGLE_PASS, nil];
    
    return [NSDictionary dictionaryWithObjects:obj forKeys:key];
}

-(void)removeGoogleAccountData
{
    [defaults removeObjectForKey:KEY_GOOGLE_ID];
    [defaults removeObjectForKey:KEY_GOOGLE_PASS];
}

#pragma mark - ****** Notification setting ******
-(BOOL)saveNotificationTimingWithTimingType:(NSInteger)type{
    [defaults setObject:[NSNumber numberWithInt:type] forKey:KEY_NOTIFICATION_TIMING_TYPE];
    BOOL successful = [defaults synchronize];
    if (successful) {
        return YES;
    }else{
        return NO;
    }
}

-(NSInteger)notificationTiming
{
    return [defaults integerForKey:KEY_NOTIFICATION_TIMING_TYPE] ;
}

@end

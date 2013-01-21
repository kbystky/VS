//
//  UserDefaultsManager.m
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
enum{
    MAX_NUMBER_OF_ACCOUNT = 3
};
#import "UserDefaultsManager.h"
@interface UserDefaultsManager()
{
    NSUserDefaults *defaults;
}
@end

@implementation UserDefaultsManager

#pragma mark - ******  ******
static  NSString *const KEY_ID_INT =@"id";
static  NSString *const KEY_NAME_STR =@"name";
static NSString *const KEY_BIRTHDAY_STR =@"birthday";

NSString *const KEY_ACCOUNTS_MUDIC =@"accounts";
static NSString *const KEY_ACCOUNT_NUMBER_PREFIX =@"account_";

static  NSString *const KEY_GOOGLE_ID =@"google_id";
static  NSString *const KEY_GOOGLE_PASS =@"google_password";

static  NSString *const KEY_NOTIFICATION_TIMING_TYPE =@"notification_type";


+(NSString *)accountIdKey{
    return KEY_ID_INT;
}
+(NSString *)accountNameKey{
    return KEY_NAME_STR;
}

+(NSString *)accountBirthdayKey{
    return KEY_BIRTHDAY_STR;
}
+(NSString *)accountNumberPrefix{
    return KEY_ACCOUNT_NUMBER_PREFIX;
}
+(NSString *)googleAccountIdKey{
    return KEY_GOOGLE_ID;
}
+(NSString *)googleAccountPassKey{
    return KEY_GOOGLE_PASS;
}
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

//アカウント生成
-(BOOL)createAccountWithName:(NSString *)name birthDay:(NSString *)birthDay{
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
                if([[ac objectForKey:KEY_ID_INT] intValue] == i){
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
    NSArray *key = [NSArray arrayWithObjects:KEY_ID_INT,KEY_NAME_STR,KEY_BIRTHDAY_STR,nil]; 
    NSDictionary *account = [NSDictionary dictionaryWithObjects:obj forKeys:key];
    
    [accounts setObject:account forKey:[KEY_ACCOUNT_NUMBER_PREFIX stringByAppendingFormat:@"%d",accountId]];
    
    [defaults setObject:accounts forKey:KEY_ACCOUNTS_MUDIC];
    NSLog(@"add  name:%@  birthday:%@  id:%d",name,birthDay,accountId);    
    BOOL successful = [defaults synchronize];
    if (successful) {
        return YES;
    }else{
        return NO;
    }   
}

//アカウント情報保存(編集)
-(BOOL)saveAccountWithAccountInfo:(NSDictionary *)info{
    FUNK();
    //infoからname birthを抽出
    NSInteger accountId = [[info objectForKey:KEY_ID_INT] intValue];
    //userdefaultからaccountsを抽出
    NSMutableDictionary *accounts = (NSMutableDictionary*) [defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC]; 
    
    //nameが一致するaccountをaccountsから抽出、変更、(元々を削除？)
    NSMutableDictionary *newAccounts = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *account;
    for( NSString *key in [accounts allKeys]){
        //mutablecopyしないと２回目以降imutable accessで落ちる
        account = [[accounts objectForKey:key] mutableCopy];
        
        if([[account objectForKey:KEY_ID_INT] intValue] == accountId ){
            [account setObject:[info objectForKey:KEY_NAME_STR] forKey:KEY_NAME_STR];
            [account setObject:[info objectForKey:KEY_BIRTHDAY_STR] forKey:KEY_BIRTHDAY_STR];
        }
        [newAccounts setObject:account forKey:[KEY_ACCOUNT_NUMBER_PREFIX stringByAppendingFormat:@"%d",[[account objectForKey:KEY_ID_INT] intValue]]];
    }
    
    [defaults setObject:newAccounts forKey:KEY_ACCOUNTS_MUDIC];
    BOOL successful = [defaults synchronize];
    if (successful) {
        return YES;
    }else{
        return NO;
    }   
}

//アカウント削除
-(BOOL)removeAccountWithAccountInfo:(NSDictionary *)info{
    FUNK();
    //infoからname birthを抽出
    NSInteger accountId = [[info objectForKey:KEY_ID_INT] intValue];
    //userdefaultからaccountsを抽出
    NSMutableDictionary *accounts = (NSMutableDictionary*) [defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC]; 
    
    //nameが一致するaccountをaccountsから抽出、変更、(元々を削除？)
    NSMutableDictionary *newAccounts = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *account;
    for( NSString *key in [accounts allKeys]){
        //mutablecopyしないと２回目以降imutable accessで落ちる
        account = [[accounts objectForKey:key] mutableCopy];
        NSLog(@"acc id %d",[[account objectForKey:KEY_ID_INT] intValue]);
        if([[account objectForKey:KEY_ID_INT] intValue] == accountId){
            NSLog(@"remove");        
            continue;
        }
        [newAccounts setObject:account forKey:[KEY_ACCOUNT_NUMBER_PREFIX stringByAppendingFormat:@"%d",[[account objectForKey:KEY_ID_INT] intValue]]];
    }
    
    [defaults setObject:newAccounts forKey:KEY_ACCOUNTS_MUDIC];
    BOOL successful = [defaults synchronize];
    if (successful) {
        return YES;
    }else{
        return NO;
    }   
}


//アカウント情報保存(編集)
-(NSArray *)allAccount{
    NSMutableDictionary *accounts = (NSMutableDictionary*) [defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC]; 
    NSMutableArray *array = [[NSMutableArray alloc]init];
    NSArray *keys = [accounts allKeys];
    for(NSString *key in keys){
        [array addObject:[accounts objectForKey:key]];
    }
    
    //idでソート
    NSSortDescriptor *sortDispId = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];  
    NSArray *sortDescArray = [NSArray arrayWithObjects:sortDispId, nil];  
    array = [NSMutableArray arrayWithArray:[array sortedArrayUsingDescriptors:sortDescArray]];
    
    return array;
}

//アカウント取得
-(NSDictionary *)accountWithId:(NSInteger)accountId
{
    FUNK();
    NSLog(@"id %d",accountId);
    NSMutableDictionary *accounts = (NSMutableDictionary*) [defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC]; 
    NSArray *keys = [accounts allKeys];
    NSDictionary *account;
    for(NSString *key in keys){
        account = [accounts objectForKey:key];
        if([[account objectForKey:KEY_ID_INT] intValue] == accountId){
            return account;
        }
    }
    return nil;
}

//アカウント取得
-(NSDictionary *)accountWithName:(NSString *)accountName
{
    FUNK();
    NSMutableDictionary *accounts = (NSMutableDictionary*) [defaults dictionaryForKey:KEY_ACCOUNTS_MUDIC]; 
    NSArray *keys = [accounts allKeys];
    NSDictionary *account;
    for(NSString *key in keys){
        account = [accounts objectForKey:key];
        if([[account objectForKey:KEY_NAME_STR] isEqualToString:accountName]){
            return account;
        }
    }
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

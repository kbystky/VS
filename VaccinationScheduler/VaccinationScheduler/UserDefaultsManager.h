//
//  UserDefaultsManager.h
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsManager : NSObject
-(id)init;
+(NSString *)accountIdKey;
+(NSString *)accountNameKey;
+(NSString *)accountBirthdayKey;
+(NSString *)accountNumberPrefix;
+(NSString *)googleAccountIdKey;
+(NSString *)googleAccountPassKey;


-(BOOL)createAccountWithName:(NSString *)name birthDay:(NSString *)birthDay;
-(BOOL)saveAccountWithAccountInfo:(NSDictionary *)info;
-(BOOL)removeAccountWithAccountInfo:(NSDictionary *)info;
-(NSArray *)allAccount;
-(NSDictionary *)accountWithId:(NSInteger)accountId;
-(NSDictionary *)accountWithName:(NSString *)accountName;
-(BOOL)accountIsExist;
-(BOOL)accountCanCreate;
-(NSInteger)numberOfAccount;

- (BOOL)googleAccountDataIsExist;
- (BOOL)saveGoogleAccountDataWithId:(NSString *)gId password:(NSString *)gPass;
- (NSDictionary *)googleAccountData;
-(void)removeGoogleAccountData;

-(BOOL)saveNotificationTimingWithTimingType:(NSInteger)type;
-(NSInteger)notificationTiming;
@end


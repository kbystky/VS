//
//  UserDefaultsManager.h
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AccountInfoDto;
@interface UserDefaultsManager : NSObject
-(id)init;

//-(void)createAccountWithName:(NSString *)name birthDay:(NSString *)birthDay;
//-(void)saveAccountWithAccountInfo:(NSDictionary *)info;
//-(void)removeAccountWithAccountInfo:(NSDictionary *)info;

-(void)saveAccount:(AccountInfoDto *)accountInfoDto;
-(void)removeAccount:(AccountInfoDto *)accountInfoDto;

-(NSArray *)allAccount;
-(AccountInfoDto *)accountWithId:(NSInteger)accountId;
-(AccountInfoDto *)accountWithName:(NSString *)accountName;
-(BOOL)accountIsExist;
-(BOOL)accountCanCreate;
-(NSInteger)numberOfAccount;

- (BOOL)googleAccountDataIsExist;
- (BOOL)saveGoogleAccountDataWithId:(NSString *)gId password:(NSString *)gPass;
- (NSDictionary *)googleAccountData;
-(void)removeGoogleAccountData;

-(void)saveNotificationTimingWithTimingType:(NSInteger)type;
-(NSInteger)notificationTiming;
@end


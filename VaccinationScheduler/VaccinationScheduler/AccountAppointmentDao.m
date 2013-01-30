//
//  AccountAppointmentDao.m
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import "AccountAppointmentDao.h"
#import "AccountAppointmentDto.h"
#import "FMDatabase.h"
#import "DatabaseManager.h"
#import "UserDefaultsManager.h"
#import "StringConst.h"
#define DBNAME @"appointment"

@implementation AccountAppointmentDao

- (NSArray *)appointmentsDataWithAccountId:(NSInteger)accountid{
    NSMutableArray *appointment = [[NSMutableArray alloc]init];
    
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    NSString *sql = [NSString stringWithFormat:@"SELECT id,accountId,vaccinationId,times,appointmentDate,consultationDate,isSynced FROM appointment WHERE accountId = %d",accountid];
    
    //データ取得
    FMResultSet *results = [db executeQuery:sql];
    while([results next]){
        AccountAppointmentDto *dto = [[AccountAppointmentDto alloc]init];
        dto.apId = [results intForColumnIndex:0];
        dto.accountId = [results intForColumnIndex:1];
        dto.vcId = [results intForColumnIndex:2];
        dto.times = [results intForColumnIndex:3];
        dto.appointmentDate = [results stringForColumnIndex:4];
        if([dto.consultationDate isEqualToString:@"nodata"]){
            dto.consultationDate = nil;
        }else{
            dto.consultationDate = [results stringForColumnIndex:5];
        }
        dto.isSynced = [results boolForColumnIndex:6];
        [appointment addObject:dto];
    }
    
    [db close];
    return appointment;
}

-(BOOL)saveAppointmentWithAccountAppointmentDto:(AccountAppointmentDto *)dto{
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    
    FUNK();
    [self Logger:dto];
    
    if([dto.consultationDate isEqual:nil]){
        dto.consultationDate = @"nodata";
    }
    
    NSString *sql = @"INSERT INTO appointment (accountId,vaccinationId,times,appointmentDate,consultationDate,isSynced) VALUES (?,?,?,?,?,?);";
    
    BOOL result = [db executeUpdate:sql,
                   [NSNumber numberWithInt:dto.accountId],
                   [NSNumber numberWithInt:dto.vcId],
                   [NSNumber numberWithInt:dto.times],
                   dto.appointmentDate,
                   dto.consultationDate,
                   [NSNumber numberWithBool:dto.isSynced]];
    
    NSLog(@"result %d",result);
    [db close];
    return result;
}

//指定された予約の削除
-(BOOL)removeAppointmentWithAppointmentId:(NSInteger)appointmentId
{
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    
    NSString  *sql = @"DELETE FROM appointment where id = ?";
    BOOL result = [db executeUpdate:sql,[NSNumber numberWithInt:appointmentId]];
    
    [db close];
    return result;
}

//アカウント削除時に対応するデータを削除する
-(BOOL)removeAppointmentsWithAccoutId:(NSInteger)accountId
{
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    
    NSString  *sql = @"DELETE FROM appointment where accountId = ?";
    BOOL result = [db executeUpdate:sql,[NSNumber numberWithInt:accountId]];
    
    [db close];
    return result;
}
/*********** other **********/
- (void)Logger:(AccountAppointmentDto *)dto
{
    NSLog(@"accountId %d",dto.accountId);
    NSLog(@"vcId %d",dto.vcId);
    NSLog(@"current times %d",dto.times);
    NSLog(@"appointmentDate %@",dto.appointmentDate);
    NSLog(@"consultationDate %@",dto.consultationDate);
    NSLog(@"isSynced %d",dto.isSynced);
    NSLog(@"vcDto %@",dto.vaccinationDto);
}
/*********** old ***********/

-(NSInteger)timesWithAccountId:(NSInteger)accountid vaccinationName:(NSString *)name{
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    NSString *sql = [NSString stringWithFormat:@"SELECT times FROM %@%d where appointment = ?;",KEY_ACCOUNT_NUMBER_PREFIX,accountid];
    NSInteger times;
    //データ取得
    FMResultSet *results = [db executeQuery:sql,name];
    while([results next]){
        times = [results intForColumnIndex:0];
    }
    [db close];
    return times;
}


-(NSString *)dateWithAccountId:(NSInteger)accountid vaccinationName:(NSString *)name times:(NSInteger)times{
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    NSString *sql = [NSString stringWithFormat:@"SELECT date FROM %@%d WHERE appointment = ?",KEY_ACCOUNT_NUMBER_PREFIX,accountid];
    //データ取得
    NSString *date;
    FMResultSet *results = [db executeQuery:sql,name];
    while([results next]){
        date = [results stringForColumnIndex:0];
    }
    [db close];
    return date;
}


-(BOOL)allDelete{
    
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    BOOL result;
    for(int i =1; i<4;i++){
        NSString  * sql = [NSString stringWithFormat:@"DELETE FROM %@%d",KEY_ACCOUNT_NUMBER_PREFIX,i];
        
        result = [db executeUpdate:sql];
    }
    [db close];
    return result;
    
}
@end

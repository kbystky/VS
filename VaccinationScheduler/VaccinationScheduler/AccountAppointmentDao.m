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
@implementation AccountAppointmentDao
-(NSArray *)appointmentDtoWithAccountId:(NSInteger)accountid{
    NSMutableArray *appointment = [[NSMutableArray alloc]init];
    
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    NSString *sql = [NSString stringWithFormat:@"SELECT appointment,times,isSynced FROM %@%d;",[UserDefaultsManager accountNumberPrefix],accountid];
    
    //データ取得
    FMResultSet *results = [db executeQuery:sql];
    while([results next]){
        AccountAppointmentDto *dto = [[AccountAppointmentDto alloc]init];
        dto.appointment = [results stringForColumnIndex:0];
        dto.times = [results intForColumnIndex:1];
        dto.isSynced = [results boolForColumnIndex:2];
        [appointment addObject:dto];
    }
    [db close];
    return appointment;
}

-(NSInteger)timesWithAccountId:(NSInteger)accountid vaccinationName:(NSString *)name{
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    NSString *sql = [NSString stringWithFormat:@"SELECT times FROM %@%d where appointment = ?;",[UserDefaultsManager accountNumberPrefix],accountid];
    NSInteger times;    
    //データ取得
    FMResultSet *results = [db executeQuery:sql,name];
    while([results next]){
        times = [results intForColumnIndex:0];
    }
    [db close];
    return times;
}

-(BOOL)saveAppointmentWithDate:(NSString *)date vaccinationName:(NSString *)name times:(NSInteger)times accountId:(NSInteger)accountid{
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    
    NSString  * sql = [NSString stringWithFormat:@"INSERT INTO %@%d (appointment,date,times,isSynced) VALUES (?,?,?,?);",[UserDefaultsManager accountNumberPrefix],accountid];
    
    BOOL result = [db executeUpdate:sql,name,date,[NSNumber numberWithInt:times+1],[NSNumber numberWithBool:NO]];
    [db close];
    return result;
}

-(NSString *)dateWithAccountId:(NSInteger)accountid vaccinationName:(NSString *)name times:(NSInteger)times{
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    NSString *sql = [NSString stringWithFormat:@"SELECT date FROM %@%d WHERE appointment = ?",[UserDefaultsManager accountNumberPrefix],accountid];
    //データ取得
    NSString *date;
    FMResultSet *results = [db executeQuery:sql,name];
    while([results next]){
        date = [results stringForColumnIndex:0];
    }
    [db close];
    return date;
}

-(BOOL)deleteWithAccountId:(NSInteger)accountid{
    
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    BOOL result;
    NSString  * sql = [NSString stringWithFormat:@"DELETE FROM %@%d",[UserDefaultsManager accountNumberPrefix],accountid];
    
    result = [db executeUpdate:sql];
    [db close];
    return result;
    
}

-(BOOL)allDelete{
    
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    BOOL result;
    for(int i =1; i<4;i++){
        NSString  * sql = [NSString stringWithFormat:@"DELETE FROM %@%d",[UserDefaultsManager accountNumberPrefix],i];
        
        result = [db executeUpdate:sql];
    }
    [db close];
    return result;
    
}
@end

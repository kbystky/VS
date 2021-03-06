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
#import "VaccinationService.h"
#import "VaccinationDto.h"

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

- (NSArray *)allAppointmentsData
{
    NSMutableArray *appointments = [[NSMutableArray alloc]init];
    
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    NSString *sql = [NSString stringWithFormat:@"SELECT id,accountId,vaccinationId,times,appointmentDate,consultationDate,isSynced FROM appointment"];
    
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
        [appointments addObject:dto];
    }
    [db close];
    
    // set vaccinationDto
    NSArray *vaccinations = [VaccinationService vaccinationData];
    for(AccountAppointmentDto *aDto in appointments){
        for(VaccinationDto *vDto in vaccinations){
            if(aDto.vcId == vDto.vcId){
                aDto.vaccinationDto = vDto;
                break;
            }
        }
    }
    return appointments;
}

-(BOOL)saveAppointmentWithAccountAppointmentDto:(AccountAppointmentDto *)dto
{
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
                   [dto appointmentDate],
                   [dto consultationDate],
                   [NSNumber numberWithBool:dto.isSynced]];

    [db close];
    return result;
}

-(BOOL)updateAppointmentWithAccountAppointmentDto:(AccountAppointmentDto *)dto
{
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    FUNK();[self Logger:dto];
    
    if([dto.consultationDate isEqual:nil]){
        dto.consultationDate = @"nodata";
    }
    NSString *sql = @"UPDATE appointment SET accountId = ? , vaccinationId = ? , times = ? , appointmentDate = ? , consultationDate = ? , isSynced = ? WHERE id = ?";
    BOOL result = [db executeUpdate:sql,
                   [NSNumber numberWithInt:dto.accountId],
                   [NSNumber numberWithInt:dto.vcId],
                   [NSNumber numberWithInt:dto.times],
                   dto.appointmentDate,
                   dto.consultationDate,
                   [NSNumber numberWithBool:dto.isSynced],
                   [NSNumber numberWithInt:dto.apId]];
    
    NSLog(@"result %d",result);
    [db close];
    return result;
}

-(BOOL)updateAppointmentWithAccountAppointmentsDto:(NSArray *)appointments
{
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];

    [db beginTransaction];
    
    BOOL isSucceeded = YES;
    NSString *sql = @"UPDATE appointment SET accountId = ? , vaccinationId = ? , times = ? , appointmentDate = ? , consultationDate = ? , isSynced = ? WHERE id = ?";
    for(AccountAppointmentDto* dto in appointments){
        if(![db executeUpdate:sql,
             [NSNumber numberWithInt:dto.accountId],
             [NSNumber numberWithInt:dto.vcId],
             [NSNumber numberWithInt:dto.times],
             dto.appointmentDate,
             dto.consultationDate,
             [NSNumber numberWithBool:dto.isSynced],
             [NSNumber numberWithInt:dto.apId]]){
            isSucceeded = NO;
            break;
        }
    }
    
    if(isSucceeded){
        [db commit];
    }else{
        [db rollback];
    }

    [db close];
    return isSucceeded;
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

-(BOOL)removeAppointmentsWithAppointmens:(NSArray *)appointmentsDto
{
    FUNK();
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];

    [db beginTransaction];
    
    BOOL isSucceeded = YES;
    NSString  *sql = @"DELETE FROM appointment where id = ?";
    for(AccountAppointmentDto* dto in appointmentsDto){
        NSLog(@"apid %d",dto.apId);
        if(![db executeUpdate:sql, [NSNumber numberWithInt:dto.apId]]){
            isSucceeded = NO;
            break;
        }
    }

    if(isSucceeded){
        [db commit];
    }else{
        [db rollback];
    }
    
    [db close];
    return isSucceeded;
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
#pragma mark - *********** other **********
- (void)Logger:(AccountAppointmentDto *)dto
{
    NSLog(@"apId %d",dto.apId);
    NSLog(@"accountId %d",dto.accountId);
    NSLog(@"vcId %d",dto.vcId);
    NSLog(@"current times %d",dto.times);
    NSLog(@"appointmentDate %@",dto.appointmentDate);
    NSLog(@"consultationDate %@",dto.consultationDate);
    NSLog(@"isSynced %d",dto.isSynced);
    NSLog(@"vcDto %@",dto.vaccinationDto);
}
@end

//
//  VaccinaionDao.m
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VaccinationDao.h"
#import "VaccinationDto.h"
#import "FMDatabase.h"
#import "DatabaseManager.h"

@implementation VaccinationDao


-(NSArray *)allVaccination{
    NSMutableArray *vaccinations = [[NSMutableArray alloc]init];
    
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];

    if(![db open]){
        return nil;
    }
    
    NSString *sql = @"SELECT id,name,needTimes,period FROM vaccination";
    
    //データ取得
    FMResultSet *results = [db executeQuery:sql];
    while([results next]){
        VaccinationDto *dto = [[VaccinationDto alloc]init];
        dto.vcId = [results intForColumnIndex:0];
        dto.name = [results stringForColumnIndex:1];
        dto.needTimes = [results intForColumnIndex:2];
        dto.period = [results intForColumnIndex:3];
        [vaccinations addObject:dto];
    }

    if(![db close]){
        return nil;
    }
    return vaccinations;
}

- (NSArray *)vaccinationsWithvaccinationId:(NSArray *)vcId
{
    NSMutableArray *vaccinationsDto = [[NSMutableArray alloc]init];
    
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    
    if(![db open]){
        return nil;
    }
    
    NSString *sql = @"SELECT id,name,needTimes,period FROM vaccination";
    
    //データ取得
    FMResultSet *results = [db executeQuery:sql];
    while([results next]){
        VaccinationDto *dto = [[VaccinationDto alloc]init];
        dto.vcId = [results intForColumnIndex:0];
        dto.name = [results stringForColumnIndex:1];
        dto.needTimes = [results intForColumnIndex:2];
        dto.period = [results intForColumnIndex:3];
        [vaccinationsDto addObject:dto];
    }
    
    if(![db close]){
        return nil;
    }

    NSMutableArray *vaccinations = [[NSMutableArray alloc]init];

    int _id;
    for(NSNumber *i in vcId){
        _id = [i intValue];
        for(VaccinationDto *dto in vaccinationsDto){
            if(dto.vcId == _id){
                [vaccinations addObject:dto];
                break;
            }
        }
    }
    return vaccinations;
}
@end

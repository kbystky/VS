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
    NSMutableArray *vaccination = [[NSMutableArray alloc]init];
    
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    NSString *sql = @"SELECT name,times FROM vaccination";
    
    //データ取得
    FMResultSet *results = [db executeQuery:sql];
    while([results next]){
        VaccinationDto *dto = [[VaccinationDto alloc]init];
        dto.name = [results stringForColumnIndex:0];
        dto.times = [results intForColumnIndex:1];
        [vaccination addObject:dto];
    }
    [db close];
    return vaccination;
}
@end

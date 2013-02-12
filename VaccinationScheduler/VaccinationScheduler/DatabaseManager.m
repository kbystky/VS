//
//  DatabaseManager.m
//  VaccinationScheduler
//
//  Created by  on 12/12/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DatabaseManager.h"
#import "FMDatabase.h"

@implementation DatabaseManager

+ (FMDatabase *)createInstanceWithDbName:(NSString *)dbName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dir= [paths objectAtIndex:0];
    NSString *databasePath = [dir stringByAppendingPathComponent:dbName];
    return [[FMDatabase alloc] initWithPath:databasePath];
}

-(void)createVaccinationList{
 /*
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    [db open];
    NSString * sql = @"CREATE TABLE IF NOT EXISTS  vaccination (name TEXT , times INTEGER);";
    NSLog(@"create %d",[db executeUpdate:sql]);
    sql = @"CREATE TABLE IF NOT EXISTS  account_1 (appointment TEXT , date TEXT, times INTEGER , isSynced BOOL);";
    NSLog(@"create %d",[db executeUpdate:sql]);
    sql = @"CREATE TABLE IF NOT EXISTS  account_2 (appointment TEXT , date TEXT, times INTEGER , isSynced BOOL);";
    NSLog(@"create %d",[db executeUpdate:sql]);
    sql = @"CREATE TABLE IF NOT EXISTS  account_3 (appointment TEXT , date TEXT, times INTEGER , isSynced BOOL);";
    NSLog(@"create %d",[db executeUpdate:sql]);
    
    sql = @"INSERT INTO vaccination (name,times) VALUES (?,?);";
    
    [db executeUpdate:sql,@"B型肝炎ワクチン",[NSNumber numberWithInt:2]];
    [db executeUpdate:sql,@"ロタウイルスワクチン",[NSNumber numberWithInt:3]];
    [db executeUpdate:sql,@"ヒブワクチン",[NSNumber numberWithInt:4]];
    [db executeUpdate:sql,@"小児用肺炎球菌ワクチン",[NSNumber numberWithInt:4]];
    [db executeUpdate:sql,@"四種混合・三種混合",[NSNumber numberWithInt:4]];
    [db executeUpdate:sql,@"不活化ポリオワクチン",[NSNumber numberWithInt:4]];
    [db executeUpdate:sql,@"BCGワクチン",[NSNumber numberWithInt:1]];
    [db executeUpdate:sql,@"MRワクチン",[NSNumber numberWithInt:1]];
    [db executeUpdate:sql,@"おたふくかぜワクチン",[NSNumber numberWithInt:2]];
    [db executeUpdate:sql,@"水痘ワクチン",[NSNumber numberWithInt:2]];
    [db executeUpdate:sql,@"インフルエンザワクチン",[NSNumber numberWithInt:2]];
[db close];
*/
  }

+ (void)createNewTable
{
/*
    FMDatabase *db =  [DatabaseManager createInstanceWithDbName:@"vaccinationScheduler.db"];
    
    [db open];
    NSString * sql;
    sql = @"CREATE TABLE IF NOT EXISTS appointment (id INTEGER PRIMARY KEY AUTOINCREMENT ,accountId INTEGER , vaccinationId INTEGER , times INTEGER , appointmentDate TEXT , consultationDate TEXT , isSynced BOOL);";
    NSLog(@"create %d",[db executeUpdate:sql]);
*/
/*
    // initialize vc table
     sql = @"CREATE TABLE IF NOT EXISTS  vaccination ( id INTEGER PRIMARY KEY AUTOINCREMENT , name TEXT, needTimes INTEGER , period INTEGER);";
     NSLog(@"create %d",[db executeUpdate:sql]);
     sql = @"INSERT INTO vaccination (name , needTimes , period) VALUES (?,?,?);";
     [db executeUpdate:sql,@"B型肝炎ワクチン",[NSNumber numberWithInt:2],[NSNumber numberWithInt:60]];
     [db executeUpdate:sql,@"ロタウイルスワクチン",[NSNumber numberWithInt:3],[NSNumber numberWithInt:60]];
     [db executeUpdate:sql,@"ヒブワクチン",[NSNumber numberWithInt:4],[NSNumber numberWithInt:60]];
     [db executeUpdate:sql,@"小児用肺炎球菌ワクチン",[NSNumber numberWithInt:4],[NSNumber numberWithInt:60]];
     [db executeUpdate:sql,@"四種混合・三種混合",[NSNumber numberWithInt:4],[NSNumber numberWithInt:60]];
     [db executeUpdate:sql,@"不活化ポリオワクチン",[NSNumber numberWithInt:4],[NSNumber numberWithInt:60]];
     [db executeUpdate:sql,@"BCGワクチン",[NSNumber numberWithInt:1],[NSNumber numberWithInt:60]];
     [db executeUpdate:sql,@"MRワクチン",[NSNumber numberWithInt:1],[NSNumber numberWithInt:60]];
     [db executeUpdate:sql,@"おたふくかぜワクチン",[NSNumber numberWithInt:2],[NSNumber numberWithInt:60]];
     [db executeUpdate:sql,@"水痘ワクチン",[NSNumber numberWithInt:2],[NSNumber numberWithInt:60]];
     [db executeUpdate:sql,@"インフルエンザワクチン",[NSNumber numberWithInt:2],[NSNumber numberWithInt:60]];
    [db close];
 */
}
@end

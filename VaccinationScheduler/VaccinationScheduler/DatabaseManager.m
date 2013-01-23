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
    FUNK();
    NSLog(@"%@\n%@",paths,databasePath);
    return [[FMDatabase alloc] initWithPath:databasePath];
}

@end

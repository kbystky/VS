//
//  DatabaseManager.h
//  VaccinationScheduler
//
//  Created by  on 12/12/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;
@interface DatabaseManager : NSObject

+ (FMDatabase *)createInstanceWithDbName:(NSString *)dbName;

@end

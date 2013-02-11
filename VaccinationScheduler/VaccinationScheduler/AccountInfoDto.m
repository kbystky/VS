//
//  AccountInfoDto.m
//  VaccinationScheduler
//
//  Created by  on 12/12/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AccountInfoDto.h"
#define ID @"accountId"
#define NAME @"name"
#define BIRTHDAY @"birthday"
#define APPOINTMENT @"appointment"

@implementation AccountInfoDto
@synthesize name = _name;
@synthesize birthDay = _birthDay;
@synthesize accountId = _accountId;
@synthesize appointmentDto = _appointmentDto;

-(id)initWithAccountId:(NSInteger)accountId name:(NSString *)name birthDay:(NSString *)birthDay
{
    self = [super init];
    self.accountId = accountId;
    self.name = name;
    self.birthDay = birthDay;
    return self;
}

// for Archiver and Unarchiver
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self){
        self.name = [aDecoder decodeObjectForKey:NAME];
        self.accountId = [aDecoder decodeIntegerForKey:ID];
        self.birthDay = [aDecoder decodeObjectForKey:BIRTHDAY];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:NAME];
    [aCoder encodeInteger:self.accountId forKey:ID];
    [aCoder encodeObject:self.birthDay forKey:BIRTHDAY];
}

@end

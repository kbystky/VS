//
//  AccountInfoDto.m
//  VaccinationScheduler
//
//  Created by  on 12/12/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AccountInfoDto.h"

@implementation AccountInfoDto
@synthesize name = _name;
@synthesize birthDay = _birthDay;
@synthesize accountId = _accountId;

NSString *const CODEKEY_ID = @"accountId";
NSString *const CODEKEY_BIRTHDAY = @"birthDay";
NSString *const CODEKEY_NAME = @"name";

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
        self.name = [aDecoder decodeObjectForKey:CODEKEY_NAME];
        self.accountId = [aDecoder decodeIntegerForKey:CODEKEY_ID];
        self.birthDay = [aDecoder decodeObjectForKey:CODEKEY_BIRTHDAY];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:CODEKEY_NAME];
    [aCoder encodeInteger:self.accountId forKey:CODEKEY_ID];
    [aCoder encodeObject:self.name forKey:CODEKEY_BIRTHDAY];
}

@end

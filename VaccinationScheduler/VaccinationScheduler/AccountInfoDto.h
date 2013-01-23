//
//  AccountInfoDto.h
//  VaccinationScheduler
//
//  Created by  on 12/12/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountInfoDto : NSObject<NSCoding>
{
NSString *_name;
NSString *_birthDay;
NSInteger _accountId;
}
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *birthDay;
@property(nonatomic)NSInteger accountId;

-(id)initWithAccountId:(NSInteger)accountId name:(NSString *)name birthDay:(NSString *)birthDay;

@end

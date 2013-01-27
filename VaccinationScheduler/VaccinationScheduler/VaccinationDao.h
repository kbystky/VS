//
//  VaccinaionDao.h
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VaccinationDao : NSObject
-(NSArray *)allVaccination;
- (NSArray *)vaccinationsWithvaccinationId:(NSArray *)vcId;
@end

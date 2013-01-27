//
//  VaccinationService.m
//  VaccinationScheduler
//
//  Created by 小林 拓也 on 13/01/27.
//
//

#import "VaccinationService.h"
#import "VaccinationDao.h"

@implementation VaccinationService

+ (NSArray *)vaccinationData
{
    //dao コール
    VaccinationDao *dao = [[VaccinationDao alloc]init];
    return [dao allVaccination];
}

@end

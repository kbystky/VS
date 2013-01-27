//
//  AccountAppointmentService.m
//  VaccinationScheduler
//
//  Created by 小林 拓也 on 13/01/27.
//
//

#import "AccountAppointmentService.h"
#import "AccountAppointmentDao.h"
#import "AccountAppointmentDto.h"

#import "VaccinationDao.h"
#import "VaccinationDto.h"

@interface AccountAppointmentService()
{
    AccountAppointmentDao *dao;
}
@end
@implementation AccountAppointmentService
AccountAppointmentService *sharedInstance = nil;

-(id)init
{
    if(sharedInstance == nil){
        sharedInstance = [super init];
        if(self != nil){
            dao =[[AccountAppointmentDao alloc]init];
        }
    }
    return sharedInstance;
}

- (NSArray *)appointmentsDtoWithAccountId:(NSInteger)accountid
{
    //appointment dtoの取得
    NSArray *appointmentsDto = [dao appointmentsDataWithAccountId:accountid];

    //dbに登録してあるvcIDを抽出
    NSMutableArray *vaccinationsId = [[NSMutableArray alloc]init];
    for(AccountAppointmentDto *dto in appointmentsDto){
        [vaccinationsId  addObject:[NSNumber numberWithInt:dto.vcId]];
    }

    //vcIDを使用して、一致するvcDtoを取得しappointmentDtoの完成
    VaccinationDao *vaccinationDao = [[VaccinationDao alloc]init];
    NSArray *vaccinations = [vaccinationDao vaccinationsWithvaccinationId:vaccinationsId];
    for(AccountAppointmentDto *aaDto in appointmentsDto){
        for(VaccinationDto *vcDto in vaccinations){
            aaDto.vaccinationDto = vcDto;
        }
    }
    return appointmentsDto;
}

- (void)saveAppointmentWithAccountId:(NSInteger)accountid times:(NSInteger)times  appointmentDate:(NSString *)appointmentDate  consultationDate:(NSString *)consultationDate vaccinationDto:(VaccinationDto *)vcDto
{
    
    AccountAppointmentDto *dto = [[AccountAppointmentDto alloc]init];
    dto.accountId = accountid;
    //vcidを探す？引数でdtoを受け取るのも可
    dto.vcId = vcDto.vcId;
    dto.times = times;
    dto.appointmentDate = appointmentDate;
    dto.consultationDate = consultationDate;
    dto.isSynced = NO;
    dto.vaccinationDto = vcDto;
    [dao saveAppointmentWithAccountAppointmentDto:dto];
}

- (void)removeAppointmentWith
{
    
}

@end

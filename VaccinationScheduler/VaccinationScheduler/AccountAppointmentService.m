//
//  AccountAppointmentService.m
//  VaccinationScheduler
//
//  Created by 小林 拓也 on 13/01/27.
//
//年齢

#import "AccountAppointmentService.h"
#import "AccountAppointmentDao.h"
#import "AccountAppointmentDto.h"

#import "VaccinationDao.h"
#import "VaccinationDto.h"
#import "DateFormatter.h"

@interface AccountAppointmentService()
{
    
}
@end
@implementation AccountAppointmentService
AccountAppointmentService *sharedInstance = nil;
AccountAppointmentDao *dao = nil;
-(id)init
{
    if(sharedInstance == nil || dao == nil){
        sharedInstance = [super init];
        if(self != nil){
            dao =[[AccountAppointmentDao alloc]init];
        }
    }
    return sharedInstance;
}

- (NSArray *)appointmentsDtoWithAccountId:(NSInteger)accountid
{
    FUNK();
    //appointment dtoの取得
    NSArray *appointmentsDto = [dao appointmentsDataWithAccountId:accountid];
    
    /***/
    for(AccountAppointmentDto *d in appointmentsDto){
        [self Logger:d];
    }
    /***/
    
    //dbに登録してあるvcIDを抽出
    NSMutableArray *vaccinationsId = [[NSMutableArray alloc]init];
    for(AccountAppointmentDto *dto in appointmentsDto){
        [vaccinationsId  addObject:[NSNumber numberWithInt:dto.vcId]];
    }
    
    //vcIDを使用して、一致するvcDtoを取得しappointmentDtoの完成
    VaccinationDao *vaccinationDao = [[VaccinationDao alloc]init];
    NSArray *vaccinations = [vaccinationDao vaccinationsWithvaccinationId:vaccinationsId];
    
    int index = 0;
    for(AccountAppointmentDto *aaDto in appointmentsDto){
        aaDto.vaccinationDto = [vaccinations objectAtIndex:index];
        index++;
    }
    
    return appointmentsDto;
}
- (void)Logger:(AccountAppointmentDto *)dto
{
    FUNK();
    NSLog(@"\n/********** Logger ************/\n");
    NSLog(@"accountId %d",dto.accountId);
    NSLog(@"vcId %d",dto.vcId);
    NSLog(@"current times %d",dto.times);
    NSLog(@"appointmentDate %@",dto.appointmentDate);
    NSLog(@"consultationDate %@",dto.consultationDate);
    NSLog(@"isSynced %d",dto.isSynced);
    NSLog(@"vcDto %@",dto.vaccinationDto);
    NSLog(@"/******************************/");
}

- (void)saveAppointmentWithAccountId:(NSInteger)accountid times:(NSInteger)times  appointmentDate:(NSString *)appointmentDate  consultationDate:(NSString *)consultationDate vaccinationDto:(VaccinationDto *)vcDto
{
    
    AccountAppointmentDto *dto = [[AccountAppointmentDto alloc]init];
    dto.accountId = accountid;
    dto.vcId = vcDto.vcId;
    dto.times = times + 1; //引数の値は現在の終了回数なので +1 する
    dto.appointmentDate = appointmentDate;
    dto.consultationDate = consultationDate;
    dto.isSynced = NO;
    dto.vaccinationDto = vcDto;
    [dao saveAppointmentWithAccountAppointmentDto:dto];
}

- (void)updateAppointmentWithCurrentAppointmentDto:(AccountAppointmentDto *)dto newAppointmentDate:(NSString *)appointmentDate  newConsultationDate:(NSString *)consultationDate
//AccountId:(NSInteger)accountid times:(NSInteger)times  appointmentDate:(NSString *)appointmentDate  consultationDate:(NSString *)consultationDate vaccinationDto:(VaccinationDto *)vcDto
{
    dto.appointmentDate = appointmentDate;
    dto.consultationDate = consultationDate;
    [dao updateAppointmentWithAccountAppointmentDto:dto];
}

- (void)removeAppointmentWithAppointmentDto:(AccountAppointmentDto *)dto
{
    [dao removeAppointmentWithAppointmentId:dto.apId];
}

- (void)removeAppointmentWithAccountId:(NSInteger)accountId
{
    [dao removeAppointmentsWithAccoutId:accountId];
}

/** for calendar **/
- (NSArray *)monthDataWithStartYMD:(NSString *)startYmd endYM:(NSString *)endYmd
{
    FUNK();

    NSMutableArray *result = [[NSMutableArray alloc]init];
    
    //date に変換
    NSDate *startDate = [DateFormatter dateFormatWithString:startYmd];
    NSDate *endDate = [DateFormatter dateFormatWithString:endYmd];
    
    // Daoから全Appointmentを取得
    AccountAppointmentDao *dao = [[AccountAppointmentDao alloc]init];
    NSArray *appointments = [dao allAppointmentsData];

    // 各Appointmentの日付をNSDAteに変換・比較
    for(AccountAppointmentDto *dto in appointments){
        // check startDate <= dto.appDate <= endDate
        NSDate *appDate =[DateFormatter dateFormatWithString:dto.appointmentDate];
        if([self checkDateIsEarlierWithTargetDate:appDate compareDate:endDate] &&
           [self checkDateIsLaterWithTargetDate:appDate compareDate:startDate]){
            [result addObject:dto];
        }
    }

    for(AccountAppointmentDto *dto in result){[self Logger:dto];}

    //dbに登録してあるvcIDを抽出
    NSMutableArray *vaccinationsId = [[NSMutableArray alloc]init];
    for(AccountAppointmentDto *dto in result){
        [vaccinationsId  addObject:[NSNumber numberWithInt:dto.vcId]];
    }
    
    //vcIDを使用して、一致するvcDtoを取得しappointmentDtoの完成
    VaccinationDao *vaccinationDao = [[VaccinationDao alloc]init];
    NSArray *vaccinations = [vaccinationDao vaccinationsWithvaccinationId:vaccinationsId];
    
    int index = 0;
    for(AccountAppointmentDto *aaDto in result){
        aaDto.vaccinationDto = [vaccinations objectAtIndex:index];
        index++;
    }

    return result;
}

- (BOOL)checkDateIsEarlierWithTargetDate:(NSDate *)tDate compareDate:(NSDate *)comDate
{
    NSComparisonResult result = [tDate compare:comDate];
    if(result == NSOrderedDescending){
        return NO;
    }
    return YES;
}

- (BOOL)checkDateIsLaterWithTargetDate:(NSDate *)tDate compareDate:(NSDate *)comDate
{
    NSComparisonResult result = [tDate compare:comDate];
    if(result == NSOrderedAscending){
        return NO;
    }
    return YES;
}







@end

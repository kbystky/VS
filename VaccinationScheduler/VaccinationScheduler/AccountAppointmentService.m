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
    NSLog(@"accountId %d",dto.accountId);
    NSLog(@"vcId %d",dto.vcId);
    NSLog(@"current times %d",dto.times);
    NSLog(@"appointmentDate %@",dto.appointmentDate);
    NSLog(@"consultationDate %@",dto.consultationDate);
    NSLog(@"isSynced %d",dto.isSynced);
    NSLog(@"vcDto %@",dto.vaccinationDto);
}

- (void)saveAppointmentWithAccountId:(NSInteger)accountid times:(NSInteger)times  appointmentDate:(NSString *)appointmentDate  consultationDate:(NSString *)consultationDate vaccinationDto:(VaccinationDto *)vcDto
{
    
    AccountAppointmentDto *dto = [[AccountAppointmentDto alloc]init];
    dto.accountId = accountid;
    //vcidを探す？引数でdtoを受け取るのも可
    dto.vcId = vcDto.vcId;
    dto.times = times + 1; //引数の値は現在の終了回数なので +1 する
    dto.appointmentDate = appointmentDate;
    dto.consultationDate = consultationDate;
    dto.isSynced = NO;
    dto.vaccinationDto = vcDto;
    [dao saveAppointmentWithAccountAppointmentDto:dto];
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
    NSLog(@"\nstring  start : %@ \nend : %@",startYmd,endYmd);
    
    //date に変換
    NSDate *startDate = [DateFormatter dateFormatWithString:startYmd];
    NSDate *endDate = [DateFormatter dateFormatWithString:endYmd];
    NSLog(@"\nstart : %@ \nend : %@",startDate,endDate);
    
    //過去未来の比較でいけるかも
    //http://cheesememo.blog39.fc2.com/blog-entry-329.htmlもあやしい
    /*
     NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
     [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
     NSDate *dateA = [inputDateFormatter dateFromString:@"2000/03/01 00:00:00"];
     NSDate *dateB = [inputDateFormatter dateFromString:@"2000/03/03 00:00:00"];
     
     // 2つの日付のうち、より過去の日を返す
     NSLog(@"%@, %@ -> %@", dateA, dateB, [dateA earlierDate:dateB]);
     // 2つの日付のうち、より未来の日を返す
     NSLog(@"%@, %@ -> %@", dateA, dateB, [dateA laterDate:dateB]);

     //result
     //2000-03-01 00:00:00 +0900, 2000-03-03 00:00:00 +0900 -> 2000-03-01 00:00:00 +0900
     //2000-03-01 00:00:00 +0900, 2000-03-03 00:00:00 +0900 -> 2000-03-03 00:00:00 +0900
     */
    return [NSArray array];
}









@end

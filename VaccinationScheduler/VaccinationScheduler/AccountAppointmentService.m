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

- (NSArray *)allAppointmentsData
{
    return [dao allAppointmentsData];
}

- (NSArray *)notSyncAppointmentsData
{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    NSArray *appointments = [dao allAppointmentsData];
    for(AccountAppointmentDto *dto in appointments){
        if(dto.isSynced == NO){
            [result addObject:[dto mutableCopy]];
        }
    }
    
    return result;
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
    dto.times = times;
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
    //その予約が最新か確認する
    //最新でなかったら以降の予約も削除が必要
    //全予約取得
    NSArray *appointments = [dao allAppointmentsData];
    NSMutableArray *targetAppointments = [[NSMutableArray alloc]init];
    NSMutableArray *deleteAppointments = [[NSMutableArray alloc]init];
    BOOL isNewestAppointment = YES;
    
    for(AccountAppointmentDto *appDto in appointments){
        //アカウントと接種が一致
        if(dto.accountId == appDto.accountId && dto.vcId == appDto.vcId){
            [targetAppointments addObject:appDto];
        }
    }
    
    for(AccountAppointmentDto *appDto in targetAppointments){
        if(appDto.times > dto.times){
            [deleteAppointments addObject:appDto];
            isNewestAppointment = NO;
        }
        NSLog(@"%d %d %d",appDto.apId,appDto.vcId,appDto.accountId);
    }
    
    if(isNewestAppointment){
        [dao removeAppointmentWithAppointmentId:dto.apId];
    }else{
        [deleteAppointments addObject:dto];
        [dao removeAppointmentsWithAppointmens:deleteAppointments];
    }
    
}

- (void)removeAppointmentWithAccountId:(NSInteger)accountId
{
    [dao removeAppointmentsWithAccoutId:accountId];
}
/** check **/
//一日の接種可能数は大丈夫か？
- (BOOL)canSaveAppointmentTimesWithAppointmentDay:(NSString *)appointmentDay accountId:(NSInteger)accountId
{
    // Daoから全Appointmentを取得
    NSArray *appointments = [dao allAppointmentsData];
    int times = 0;
    for(AccountAppointmentDto *dto in appointments){
        if(dto.accountId == accountId && [dto.appointmentDate isEqualToString:appointmentDay]){
            times++;
        }
    }
    if(times == 2){
        return NO;
    }
    return YES;
}

//一日の接種可能数は大丈夫か？
- (BOOL)isSaveAppointmentSameDayWithAppointmentDay:(NSString *)appointmentDay accountId:(NSInteger)accountId
{
    // Daoから全Appointmentを取得
    NSArray *appointments = [dao allAppointmentsData];

    for(AccountAppointmentDto *dto in appointments){
        if(dto.accountId == accountId && [dto.appointmentDate isEqualToString:appointmentDay]){
            return YES;
        }
    }
    return NO;
}

//期間のちぇっく
- (BOOL)checkPeriodFromLastTimeWithVaccinationtDto:(VaccinationDto *)vaccinationDto appointmentDay:(NSString *)appointmentDay accountId:(NSInteger)accountId
{
    // Daoから全Appointmentを取得
    NSArray *appointments = [dao allAppointmentsData];
    
    NSString *newestAppointmentDay = nil;
    VaccinationDto *newestVaccinationDto = nil;

    //最新の登録情報を取得
    for(AccountAppointmentDto *dto in appointments){
        if(dto.accountId != accountId){
            continue;
        }
        if(newestAppointmentDay == nil){
            newestAppointmentDay = dto.appointmentDate;
            newestVaccinationDto = dto.vaccinationDto;
            continue;
        }
        NSLog(@"/*************** dto %@",dto.appointmentDate);
        NSLog(@"/*************** new vc id %d  day %@",newestVaccinationDto.vcId,newestAppointmentDay);
        NSComparisonResult result = [newestAppointmentDay compare : dto.appointmentDate];
        //日付が一緒 && 現在のvcDtoより必要待機期間が長かったら更新
        if(result ==NSOrderedSame && newestVaccinationDto.period < dto.vaccinationDto.period){
            NSLog(@"/************ 待機時間更新");
                newestVaccinationDto = dto.vaccinationDto;
                continue;
        }
        if(result == NSOrderedAscending){
            NSLog(@"/************ こうしん");
            newestAppointmentDay = dto.appointmentDate;
            newestVaccinationDto = dto.vaccinationDto;
        }
    }
    NSLog(@"/*************** vc id %d %@",newestVaccinationDto.vcId,newestAppointmentDay);
    //vaccinationから期間を取得
    //最新の日数から期間分離れているかどうか
    return [self checkDateRangeWithNewestDay:newestAppointmentDay targetDay:appointmentDay period:newestVaccinationDto.period];
}

//期間チェック用
-(BOOL)checkDateRangeWithNewestDay:(NSString *)newestDay targetDay:(NSString *)targetDay period:(NSInteger)period
{
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
	[inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
	NSDate *newestDate = [inputDateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",newestDay]];
	NSDate *targetDate = [inputDateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",targetDay]];
	NSTimeInterval since = [newestDate timeIntervalSinceDate:targetDate];
    NSLog(@"/************** since %f  period %d sabun %d",since/(24*60*60),period,period + (int)since/(24*60*60));
    if(period + (int)(since/(24*60*60)) == 0){
        NSLog(@"/********OK");
        return YES;
    }
    NSLog(@"/********NO");
    return NO;
}
/** for Gcalendar **/
- (void)syncCompleteWithAppointments:(NSArray *)appointments
{
    for(AccountAppointmentDto *dto in appointments){
        dto.isSynced = YES;
    }
    
    [dao updateAppointmentWithAccountAppointmentsDto:appointments];
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

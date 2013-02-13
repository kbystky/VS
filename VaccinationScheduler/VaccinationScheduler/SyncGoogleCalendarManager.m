//
//  SyncGoogleCalendarManager.m
//  VaccinationScheduler
//
//  Created by  on 12/12/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//



#import "SyncGoogleCalendarManager.h"
#import "GData.h"
#import "UserDefaultsManager.h"
#import "SVProgressHUD.h"
#import "StringConst.h"
#import "AccountInfoDto.h"
#import "AccountAppointmentDto.h"
#import "AccountAppointmentService.h"
#import "StringConst.h"
#import "DateFormatter.h"
#import "VaccinationDto.h"

@interface SyncGoogleCalendarManager()
{
    NSURL *tmpURL;
    NSInteger finishedFetchAppointmentIndex;
    NSMutableArray *appointments;
    NSMutableArray *completeSyncAppointment;
}

@end
@implementation SyncGoogleCalendarManager

static SyncGoogleCalendarManager *manager = nil;
static GDataServiceGoogleCalendar *service = nil;

+ (id)sharedManager
{
    @synchronized(self){
        if(manager == nil){
            manager = [[SyncGoogleCalendarManager alloc]init];
            service = [[GDataServiceGoogleCalendar alloc] init];
            [service setServiceShouldFollowNextLinks:YES];
            [service setShouldServiceFeedsIgnoreUnknowns:YES];
            
            // ログイン情報
            UserDefaultsManager *userDefaultManager = [[UserDefaultsManager alloc]init];
            NSDictionary *gAccountData = [userDefaultManager googleAccountData];
            [service setUserCredentialsWithUsername:[gAccountData objectForKey:KEY_GOOGLE_ID] password:[gAccountData objectForKey:KEY_GOOGLE_PASS]];
        }
        return manager;
    }
    return nil;
}

/** 登録するカレンダーのURLを取得する**/
-(void)syncGoogleCalendar
{
    NSLog(@"check");
    [SVProgressHUD showWithStatus:@"同期中です" maskType:SVProgressHUDMaskTypeGradient];
   
    if(![self createAppointmentsData]){
        [SVProgressHUD showErrorWithStatus:@"同期する\n情報がありません"];
        return;
    }

    // 全てのカレンダーを取得するURL
    NSURL *feedURL = [NSURL URLWithString:kGDataGoogleCalendarDefaultAllCalendarsFeed];
    GDataServiceTicket *ticket;
    ticket = [service fetchFeedWithURL:feedURL
                              delegate:self
                     didFinishSelector:@selector(ticket:finishedWithFeed:error:)];
}

-(void)ticket:(GDataServiceTicket *) ticket finishedWithFeed:(GDataFeedCalendar *)feed error:(NSError *)error {
    FUNK();
    //ネットワークつながっていない場合とか、アカウントが違う場合とかで処理かえたい
    if (error || [[feed entries] count] == 0) {
        for(NSString *key in[[error userInfo]allKeys]){
            NSLog(@"key is %@" ,key);
            NSLog(@"error is %@" ,[[error userInfo] objectForKey:key]);
        }
        [SVProgressHUD showErrorWithStatus:@"同期失敗．．．"];
        return;
    }else{
        NSLog(@"success feed");
    }
    
    // カレンダーデータがある場合
    for (GDataEntryCalendar *calendar in [feed entries]){
        //title
        GDataTextConstruct *titleTextConstruct = [calendar title];
        NSString *calendarTitle = [titleTextConstruct stringValue];
        NSLog(@"title %@",calendarTitle);
        
        //url
        GDataLink *link = [calendar alternateLink];
        NSString *tmp = [link URL].description;
        NSString *mainCalUrlSuffix = @"gmail.com/private/full";
        NSString *subCalUrlSuffix = @"group.calendar.google.com/private/full";
        if([tmp hasSuffix:mainCalUrlSuffix] || [tmp hasSuffix:subCalUrlSuffix]){
            NSLog(@"true   LINK %@",[link URL]);
            tmpURL = [link URL];
            [self startFetch];
            break;
        }else{
            NSLog(@"false");
            continue;
        }
        tmpURL = [link URL];
        if (link == nil) {
            continue;
        }
    }
}

- (void)startFetch
{
    completeSyncAppointment = [[NSMutableArray alloc]init];
    [self createAndFetchEvent];
}

- (BOOL)createAppointmentsData
{
    AccountAppointmentService *appService = [[AccountAppointmentService alloc]init];
    appointments = [NSMutableArray arrayWithArray:[appService notSyncAppointmentsData]];

    if(appointments.count == 0){
        return NO;
    }
    return YES;
}

- (void)createAndFetchEvent
{
    // make a new event
    GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];

    // fetch target dto
    AccountAppointmentDto *appointmentDto = [appointments objectAtIndex:0];
    // create account
    UserDefaultsManager *userDefaultManager = [[UserDefaultsManager alloc]init];
    AccountInfoDto *accountInfoDto = [userDefaultManager accountWithId:appointmentDto.accountId];

    // title
    NSString *title =[NSString stringWithFormat:@"%@の予防接種",accountInfoDto.name];
    [newEvent setTitle:[GDataTextConstruct textConstructWithString:title]];
    
    //description
    NSString *_description =[NSString stringWithFormat:@"予防接種名：%@（%d回目）",appointmentDto.vaccinationDto.name,appointmentDto.times];
    [newEvent setContent:[GDataEntryContent textConstructWithString:_description]];
    
    //開始、終了時間を指定する(00:00~00:00にすれば終日になる)
    NSDate *startDate = [self dateWithString:appointmentDto.appointmentDate];
    
    GDataDateTime *startDateTime = [GDataDateTime dateTimeWithDate:startDate
                                                          timeZone:[NSTimeZone systemTimeZone]];
    GDataDateTime *endDateTime = [GDataDateTime dateTimeWithDate:[startDate initWithTimeInterval:60*60*24 sinceDate:startDate]
                                                        timeZone:[NSTimeZone systemTimeZone]];
    
    GDataWhen *when = [GDataWhen whenWithStartTime:startDateTime endTime:endDateTime];
    [newEvent addTime:when];
    
    [self fetchEventWithEvent:newEvent];
}
-(void)fetchEventWithEvent:(GDataEntryCalendarEvent *)event
{
    if (event) {
        [service fetchEntryByInsertingEntry:event
                                 forFeedURL:tmpURL
                                   delegate:self
                          didFinishSelector:@selector(ticket:finishedWithObject:error:)];
    }
}
//イベント追加処理後のコールバック
- (void)ticket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object error:(NSError *)error
{
    if (error) {
        for(NSString *key in[[error userInfo]allKeys]){
            NSLog(@"key is %@" ,key);
            NSLog(@"error is %@" ,[[error userInfo] objectForKey:key]);
        }
        [SVProgressHUD showErrorWithStatus:@"同期失敗．．．"];
        AccountAppointmentService *appointmentService = [[AccountAppointmentService alloc]init];
        [appointmentService syncCompleteWithAppointments:completeSyncAppointment];
        return;
    }
    //NSLog(@"success");
    
    // すべての予約を同期し終えたら完了する
    // そうでない場合は引き続き同期
    if(appointments.count >= 1){
        //arrayの先頭要素を削除
        [completeSyncAppointment addObject:[appointments objectAtIndex:0]];
        [appointments removeObjectAtIndex:0];
        if(appointments.count != 0){
            [self createAndFetchEvent];
            return;
        }
    }
    
    AccountAppointmentService *appointmentService = [[AccountAppointmentService alloc]init];
    [appointmentService syncCompleteWithAppointments:completeSyncAppointment];

    [SVProgressHUD dismiss];
    [SVProgressHUD showSuccessWithStatus:@"同期完了！"];
}

-(NSDate *)dateWithString:(NSString *)str
{
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
	[inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
	return [inputDateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",str]];
}
@end
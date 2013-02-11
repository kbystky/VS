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

@interface SyncGoogleCalendarManager()
{
    NSURL *tmpURL;
    NSInteger accountId;
    NSString *vName;
    NSInteger finishedFetchAppointmentIndex;
    NSMutableArray *appointments;
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
            NSLog(@"/************** create new!! *****************/");
            service = [[GDataServiceGoogleCalendar alloc] init];
            [service setServiceShouldFollowNextLinks:YES];
            [service setShouldServiceFeedsIgnoreUnknowns:YES];
            // ログイン情報
            [service setUserCredentialsWithUsername:@"kotaku0216@gmail.com"
                                           password:@"5112131tk"];
        }
        return manager;
    }
    return nil;
}

/** 登録するカレンダーのURLを取得する**/
-(void)syncGCalWithAccountId:(NSInteger)_accoutId vaccinationName:(NSString *)_vName{
    FUNK();
    [SVProgressHUD showWithStatus:@"同期中です" maskType:SVProgressHUDMaskTypeGradient];
    
    accountId = _accoutId;
    vName = _vName;
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

- (void)startFetch{
    FUNK();
    [self createAppointmentsData];
    [self createAndFetchEvent];
}

- (void)createAppointmentsData
{
    AccountAppointmentService *appService = [[AccountAppointmentService alloc]init];
    appointments = [NSMutableArray arrayWithArray:[appService allAppointmentsData]];
}

- (void)createAndFetchEvent
{
    // make a new event
    GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];
    
    // set a title, description, and author
    UserDefaultsManager *manager = [[UserDefaultsManager alloc]init];
    AccountInfoDto *accountInfoDto = [manager accountWithId:accountId];
    
    NSString *title =[NSString stringWithFormat:@"%@の予防接種",accountInfoDto.name];
    [newEvent setTitle:[GDataTextConstruct textConstructWithString:title]];
    
    //description
    [newEvent setContent:[GDataEntryContent textConstructWithString:@"test content"]];
    
    //開始、終了時間を指定する(00:00~00:00にすれば終日になる)
    NSDate *anHourFromNow = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    GDataDateTime *startDateTime = [GDataDateTime dateTimeWithDate:[NSDate date]
                                                          timeZone:[NSTimeZone systemTimeZone]];
    GDataDateTime *endDateTime = [GDataDateTime dateTimeWithDate:anHourFromNow
                                                        timeZone:[NSTimeZone systemTimeZone]];
    GDataWhen *when = [GDataWhen whenWithStartTime:startDateTime
                                           endTime:endDateTime];
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
- (void)ticket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object error:(NSError *)error {
    FUNK();
    
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"同期失敗．．．"];
        return;
    }
    NSLog(@"success");
    
    // すべての予約を同期し終えたら完了する
    // そうでない場合は引き続き同期
    if(appointments.count != 0){
        //arrayの先頭要素を削除
        [appointments removeObjectAtIndex:0];
        [self createAndFetchEvent];
        return;
    }
    
    [SVProgressHUD dismiss];
    [SVProgressHUD showSuccessWithStatus:@"同期完了！"];
}


@end
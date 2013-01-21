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
@interface SyncGoogleCalendarManager()
{
    NSURL *tmpURL;
    NSInteger accountId;
    NSString *vName;
}

@end
@implementation SyncGoogleCalendarManager
- (GDataServiceGoogleCalendar *)calendarService {
    
    //一回しか作られない
    static GDataServiceGoogleCalendar* service = nil;
    
    if (!service) {
        NSLog(@"/************** create new!! *****************/");
        
        service = [[GDataServiceGoogleCalendar alloc] init];
        
        //        [service setUserAgent:@"SampleCalendarApp"];
        //        [service setShouldCacheDatedData:YES];
        [service setServiceShouldFollowNextLinks:YES];
        [service setShouldServiceFeedsIgnoreUnknowns:YES];
        // ログイン情報
        [service setUserCredentialsWithUsername:@"kotaku0216@gmail.com"
                                       password:@"5112131tk"];
    }
    
    return service;
}

- (void)syncGCalImp{
    
    /***/
    // make a new event
    GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];
    
    // set a title, description, and author
    UserDefaultsManager *manager = [[UserDefaultsManager alloc]init];
    NSDictionary *account  = [manager accountWithId:accountId];
    NSString *accountName =  [account objectForKey:[UserDefaultsManager accountNameKey]];
    [newEvent setTitle:
     [GDataTextConstruct textConstructWithString:
      [NSString stringWithFormat:@"<予防接種：%@>　%@",vName,accountName]]];
    //    
    //    [newEvent setSummary:[GDataTextConstruct textConstructWithString:@"Description of sample added event"]];
    //    GDataPerson *authorPerson = [GDataPerson personWithName:@"Fred Flintstone"
    //                                                      email:@"test@test.com"];
    //    [newEvent addAuthor:authorPerson];
    // start time now, end time in an hour, reminder 10 minutes before
    NSDate *anHourFromNow = [NSDate dateWithTimeIntervalSinceNow:60*60];
    //開始、終了時間を指定しないと終日になる
    GDataDateTime *startDateTime = [GDataDateTime dateTimeWithDate:[NSDate date]
                                                          timeZone:[NSTimeZone systemTimeZone]];
    GDataDateTime *endDateTime = [GDataDateTime dateTimeWithDate:anHourFromNow
                                                        timeZone:[NSTimeZone systemTimeZone]];
    //    GDataReminder *reminder = [GDataReminder reminder];
    //    [reminder setMinutes:@"10"];
    GDataWhen *when = [GDataWhen whenWithStartTime:startDateTime
                                           endTime:endDateTime];
    
    //    [when addReminders:reminder];
    [newEvent addTime:when];
    /***/
    
    /***/
    // insert the event into the selected calendar
    GDataEntryCalendarEvent *event = newEvent;
    if (event) {
        GDataServiceGoogleCalendar *service = [self calendarService];
        [service fetchEntryByInsertingEntry:event 
                                 forFeedURL:tmpURL
                                   delegate:self 
                          didFinishSelector:@selector(ticket:finishedWithObject:error:)];
    }
}

//イベント追加処理後のコールバック
- (void)ticket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object error:(NSError *)error {
    NSLog(@"test in!!!");
    
    //ネットワークつながっていない場合とか、アカウントが違う場合とかで処理かえたい
    if (error) {
        //        NSLog(@"fetch error: %@", error);
        //        NSLog(@"error is %@" ,[[error userInfo] objectForKey:@"Error"]);
        for(NSString *key in[[error userInfo]allKeys]){
            NSLog(@"key is %@" ,key);
            NSLog(@"error is %@" ,[[error userInfo] objectForKey:key]);
            
        }
        // 4.読み込みに失敗した旨を表示し、SVProgressHUDを非表示にする
        [SVProgressHUD showErrorWithStatus:@"同期失敗．．．"];
        return;
    }else{
        NSLog(@"success");
        // 3.SVProgressHUDを非表示にする
        [SVProgressHUD dismiss];
        // 3'.読み込みに成功した旨を表示し、SVProgressHUDを非表示にする
        [SVProgressHUD showSuccessWithStatus:@"同期完了！"];
    }
} 

/** 登録するカレンダーのURLを取得する**/
-(void)syncGCalWithAccountId:(NSInteger)_accoutId vaccinationName:(NSString *)_vName{
    
    // 2.SVProgressHUDを表示する
    //[SVProgressHUD show];
    // 2'.表示するメッセージに「ロード中です」を指定して、アラートビューを表示したときのようなオーバーレイを表示
    [SVProgressHUD showWithStatus:@"同期中です" maskType:SVProgressHUDMaskTypeGradient];    
    
    
    accountId = _accoutId;
    vName = _vName;
    
    GDataServiceGoogleCalendar *gDataSrviceCalendar = [self calendarService];
    // 全てのカレンダーを取得するURL
    NSURL *feedURL = [NSURL URLWithString:kGDataGoogleCalendarDefaultAllCalendarsFeed];
    
    GDataServiceTicket *ticket;
    ticket = [gDataSrviceCalendar fetchFeedWithURL:feedURL
                                          delegate:self
                                 didFinishSelector:@selector(ticket:finishedWithFeed:error:)];
}
-(void)ticket:(GDataServiceTicket *) ticket finishedWithFeed:(GDataFeedCalendar *)feed error:(NSError *)error {
    
    //ネットワークつながっていない場合とか、アカウントが違う場合とかで処理かえたい
    if (error || [[feed entries] count] == 0) {
        //        NSLog(@"fetch error: %@", error);
        //        NSLog(@"error is %@" ,[[error userInfo] objectForKey:@"Error"]);
        for(NSString *key in[[error userInfo]allKeys]){
            NSLog(@"key is %@" ,key);
            NSLog(@"error is %@" ,[[error userInfo] objectForKey:key]);
            
        }
        return;
    }else{
        NSLog(@"success");
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
            [self syncGCalImp];
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

@end

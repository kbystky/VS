//
//  SyncGoogleCalendarManager.h
//  VaccinationScheduler
//
//  Created by  on 12/12/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GDataServiceGoogleCalendar;
@interface SyncGoogleCalendarManager : NSObject

-(void)syncGoogleCalendar;

+ (id)sharedManager;

@end

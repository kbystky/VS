//
//  AppDelegate.h
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/02.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalendarViewController;
@class ListViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CalendarViewController *calendarviewController;
@property (strong, nonatomic) ListViewController *listViewController;
@property (strong, nonatomic)  UINavigationController *naviController;

@property(nonatomic) BOOL isAccountExist;

-(void)useListViewController;
-(void)useCalendarViewController;

@end

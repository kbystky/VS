//
//  AppDelegate.m
//  VaccinationScheduler
//
//  Created by 拓也 小林 on 12/12/02.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CalendarViewController.h"
#import "ListViewController.h"

#import "UserDefaultsManager.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize calendarviewController = _calendarviewController;
@synthesize listViewController = _listViewController;
@synthesize naviController = _naviController;
@synthesize isAccountExist = _isAccountExist;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.calendarviewController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil];
    self.listViewController = [[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil];
    
    //アカウントがあるかチェック
    {
        UserDefaultsManager *udManager = [[UserDefaultsManager alloc]init];
        self.listViewController.isAccountExist = udManager.accountIsExist;
    }
    self.naviController = [[UINavigationController alloc]initWithRootViewController:self.listViewController];
    self.window.rootViewController = self.naviController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)useListViewController
{
    self.naviController = [[UINavigationController alloc]initWithRootViewController:self.listViewController];
    
    self.window.rootViewController = self.naviController;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.naviController.view cache:YES];
    [UIView commitAnimations]; 
}

-(void)useCalendarViewController
{
    
    self.naviController = [[UINavigationController alloc]initWithRootViewController:self.calendarviewController];
    
    self.window.rootViewController = self.naviController;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.naviController.view cache:YES];
    [UIView commitAnimations]; 
}

@end

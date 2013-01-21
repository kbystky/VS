//
//  SettingViewController.h
//  VaccinationScheduler
//
//  Created by  on 12/12/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol settingViewControllerDelegate;
@interface SettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(weak,nonatomic)id delegate;

@end

@protocol settingViewControllerDelegate <NSObject>

- (void)dismissSettingViewController:(SettingViewController *)viewController;

@end
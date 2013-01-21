//
//  ListViewController.h
//  VaccinationScheduler
//
//  Created by  on 12/12/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//dismissを呼び出し元で行うために.hでimportする
#import "AccountViewController.h"
#import "SettingViewController.h"

@interface ListViewController : UIViewController<UIActionSheetDelegate,accountViewControllerDelegate,settingViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>
@property BOOL isAccountExist;
@end

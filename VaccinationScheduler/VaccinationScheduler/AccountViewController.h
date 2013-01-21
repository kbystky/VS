//
//  AccountViewController.h
//  VaccinationScheduler
//
//  Created by  on 12/12/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
enum{
    LIST_VC
}previousVCType;
enum{
    EDITTYPE_CREATE,
    EDITTYPE_EDIT
}editType;

@protocol accountViewControllerDelegate;
@interface AccountViewController : UIViewController<UITextFieldDelegate,UIActionSheetDelegate,UIAlertViewDelegate>

-(id)initWithViewControllerType:(NSInteger)vcType editType:(NSInteger)editType accountId:(NSInteger)accountId;
-(id)initWithViewControllerType:(NSInteger)vcType editType:(NSInteger)editType accountInfo:(NSDictionary *)accountInfo;
@property(weak,nonatomic)id delegate;
@end

//プロトコル
@protocol accountViewControllerDelegate<NSObject>
//デリゲートメソッド
- (void)dismissAccountViewController:(AccountViewController *)viewController;
@end

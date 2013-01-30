//
//  AccountViewController.h
//  VaccinationScheduler
//
//  Created by  on 12/12/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    LIST_VC=1
}PreviousVCType;

typedef enum{
    EDITTYPE_CREATE=1,
    EDITTYPE_EDIT
}EditType;

@protocol accountViewControllerDelegate;
@class AccountInfoDto;

@interface AccountViewController : UIViewController<UITextFieldDelegate,UIActionSheetDelegate,UIAlertViewDelegate>

-(id)initWithViewControllerType:(NSInteger)vcType editType:(NSInteger)editType accountInfo:(AccountInfoDto *)accountInfo;

@property(weak,nonatomic)id delegate;
@end


//プロトコル
@protocol accountViewControllerDelegate<NSObject>
//デリゲートメソッド
- (void)dismissAccountViewController:(AccountViewController *)viewController;
@end

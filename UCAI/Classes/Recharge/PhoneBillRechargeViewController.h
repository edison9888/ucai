//
//  PhoneBillRechargeViewController.h
//  UCAI
//
//  Created by  on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MBProgressHUD.h"

@interface PhoneBillRechargeViewController : UIViewController<UIAlertViewDelegate,UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ABPeoplePickerNavigationControllerDelegate,MBProgressHUDDelegate>{
    @private
    NSUInteger _rechargeType;
    MBProgressHUD *_hud;
}

@property(nonatomic,retain) UITableView *rechargeTableView;
@property(nonatomic,retain) UITextField *phoneTextField;

//检查并保存所输入的注册资料是否合法
//0-合法;
//1-未输入手机号码;
//2-未输入有效的手机号码;
- (int) checkAndSaveIn;

//rechargeType:”1”-10元, ”2”-20元, ”3”-30元, ”4”-50元, ”5”-100元, ”6”-200, ”7”-300元
- (NSData*)generatePhoneBillRechargeRequestPostXMLData:(NSUInteger) rechargeType;

@end

//
//  MemberLoginViewController.h
//  UCAI
//
//  Created by  on 11-12-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface MemberLoginViewController : UIViewController<UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,MBProgressHUDDelegate>{
  @private
    NSUInteger _loginComeFromType;  //因何种原因解发进入登陆页面
                                    //1-主页导航栏上的登陆按钮;2-游客点击会员中心按钮进入主页面;3-会员查询订单时;4-领取或购买优惠劵时
    MBProgressHUD *_hud;
}

@property (nonatomic, retain) UIScrollView *loginScrollView;
@property (nonatomic, retain) UITableView *loginTableView;
@property (nonatomic, retain) UITextField *loginNameTextField;
@property (nonatomic, retain) UITextField *loginCodeTextField;

@property (nonatomic, retain) UIButton *saveLoginNameCheckbox;
@property (nonatomic, retain) UIButton *saveLoginPasswordCheckbox;
@property (nonatomic, retain) UIButton *autoLoginCheckbox;

- (MemberLoginViewController *)initWithComeFromType:(NSUInteger) loginComeFromType;

//检查并保存所输入的登陆帐号与登陆密码是否合法
//0-合法;1-未输入帐号;2-未输入密码
- (int)checkAndSaveIn;

// 会员登陆POST数据拼装函数
- (NSData*)generateMemberLoginRequestPostXMLData;		// 会员登陆 XML Request

@end

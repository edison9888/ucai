//
//  CouponOrderSendViewController.h
//  UCAI
//
//  Created by  on 11-12-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CouponOrderSendViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>{
    NSString *_couponOrderId;
    MBProgressHUD *_hud;
}

@property(nonatomic,retain) UITextField *phoneField;

- (CouponOrderSendViewController *)initWithCouponOrderId:(NSString *)orderId;

//检查并保存所输入的登陆帐号与登陆密码是否合法
//0-合法;
//1-未输入手机号码;
//2-手机号码格式不正确;
- (int) checkAndSaveIn;

- (NSData*)generateCouponOrderSendRequestPostXMLData;

@end

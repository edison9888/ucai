//
//  AllinTelPayViewController.h
//  UCAI
//
//  Created by  on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface AllinTelPayViewController : UIViewController<UIActionSheetDelegate,UITextFieldDelegate,MBProgressHUDDelegate>{
    @private
    NSString *_payType;
    NSString *_orderID;
    NSString *_orderPrice;
    MBProgressHUD *_hud;
}

@property(nonatomic,retain) UIScrollView *payScrollView;
@property(nonatomic,retain) UITextField *bankCardNOContentField;
@property(nonatomic,retain) UITextField *identityNOContentField;
@property(nonatomic,retain) UITextField *phoneNOContentField;

//orderID:订单ID
//price:支付金额
//type:支付类型：”1”-机票，”2”-易商卡充值，”3”-优惠劵，”4”-油菜籽，”5”-拍卖订单，”6”-火车值，”7”-酒店订单，”8”-手机充值订单
- (AllinTelPayViewController *)initWithOrderID:(NSString *)orderID andCouponPrice:(NSString *)price andType:(NSString *)type;

//检查并保存所输入的注册资料是否合法
//0-合法;
//1-未输入银行卡号;
//2-未输入身份证号;
//3-身份证号格式不正确;
//4-未输入手机号码;
//5-未输入有效的手机号码;
- (int) checkAndSaveIn;

- (NSData*)generateAllinTelPayRequestPostXMLData;

@end

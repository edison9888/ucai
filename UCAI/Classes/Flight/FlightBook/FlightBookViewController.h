//
//  FlightBookViewController.h
//  UCAI
//
//  Created by  on 12-1-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface FlightBookViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,MBProgressHUDDelegate>{
    @private
    MBProgressHUD *_hud;
    
    NSDictionary *_flightCompanyDic;
}

@property (nonatomic,retain) UITableView * bookTableView;
@property (nonatomic,retain) NSMutableArray * customers;

@property (nonatomic,retain) UITextField * contactNameLabel;
@property (nonatomic,retain) UITextField * contactPhoneLabel;

@property (nonatomic,retain) UIButton * bookButton;

@property (nonatomic,retain) UIView * confirmView;

//检查并保存所输入的登陆帐号与登陆密码是否合法
//0-合法;
//1-未输入旅客信息
//2-儿童或婴儿不可单独订票
//3-儿童加婴儿的总人数不可超过成人的人数
//4-未输入联系人姓名
//5-未输入联系手机号
//6-未输入有效的手机号码;
//
- (int) checkAndSaveIn;

//计算订单总价
- (CGFloat) calculateOrderTotalPrice;

// 机票下单POST数据拼装函数
- (NSData*)generateFlightBookRequestPostXMLData;

@end

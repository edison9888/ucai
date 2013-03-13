//
//  RootViewController.h
//  JingDuTianXia
//
//  Created by Chen Menglin on 4/10/11.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#define LOGIN_ALERTVIEW_TAG 123

@interface RootViewController : UIViewController<UIAlertViewDelegate,UIActionSheetDelegate,UIScrollViewDelegate,MBProgressHUDDelegate>{
    @private
    // To be used when scrolls originate from the UIPageControl
    BOOL _pageControlUsed;
    MBProgressHUD *_hud;
}

@property (nonatomic,retain) UIImageView *bgImageView;
@property (nonatomic,retain) UIButton * phoneButton;
@property (nonatomic,retain) UIScrollView *rootScrollView;
@property (nonatomic,retain) UIPageControl *rootPageControl;


// 九宫格视图对应的按键响应函数

// 酒店订购
- (IBAction)hotelButtonPressed:(id)sender;                      

// 机票业务
- (IBAction)flightButtonPressed:(id)sender;                         

// 列车时刻
- (IBAction)trainButtonPressed:(id)sender;                      

// 我的订单
- (IBAction)myOrderButtonPressed:(id)sender;               

// 会员中心
- (IBAction)memberButtonPressed:(id)sender;                 

// 优惠劵
- (IBAction)couponsButtonPressed:(id)sender;    

// 手机充值
- (IBAction)phoneRechargeButtonPressed:(id)sender;  

// 天气
- (IBAction)weatherButtonPressed:(id)sender;   

// 问题反馈
- (IBAction)questionButtonPressed:(id)sender;   

// 优付宝
- (IBAction)bestPayCardButtonPressed:(id)sender; 

// 每次视图重新出现时都调用，来显示当前的用户名
- (void)viewUserName;

@end

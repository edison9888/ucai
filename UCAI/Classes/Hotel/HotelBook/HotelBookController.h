//
//	酒店预订控制界面
//  HotelBookController.h
//  JingDuTianXia
//
//  Created by Piosa on 11-11-10.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#define kCellLeftTag 101
#define kCellRightTag 102

#define kConfirmScrollViewTag	201
#define kConfirmBackButtonTag	202
#define kConfirmCommitButtonTag 203

@interface HotelBookController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,MBProgressHUDDelegate> {
	
	NSString * _cityCode;				//城市代码
	NSString * _hotelName;				//酒店名称
	NSString * _hotelCode;				//酒店代码
	NSString * _roomName;				//房型名称
	NSString * _roomCode;				//房型代码
	NSString * _inDate;					//入住时间
	NSString * _outDate;				//退房时间
	NSString * _paymentType;			//支付类型
	NSString * _ratePlanCode;			//价格计划代码
	NSString * _vendorCode;				//供应商代码
	NSString * _totalAmount;			//单间单天的价格
	
	UITableView * _bookTableView; //酒店预订信息填写表
	NSMutableArray * _guests;			//旅客列表
	
	UITextField * _contactNameLabel;	//联系人姓名
	UITextField * _contactPhoneLabel;	//联系人手机号
	
	UILabel * _hotelLastTimeLabel;	//最晚到店时间
	UILabel * _hotelRoomCounterLabel; //预订房间数量
	
	UIButton * _bookButton;				//订购按钮
	
	UIView * _confirmView;				//订单确认视图
    
    MBProgressHUD *_hud;
}

@property (nonatomic,copy) NSString * cityCode;
@property (nonatomic,copy) NSString * hotelName;
@property (nonatomic,copy) NSString * hotelCode;
@property (nonatomic,copy) NSString * roomName;
@property (nonatomic,copy) NSString * roomCode;
@property (nonatomic,copy) NSString * inDate;
@property (nonatomic,copy) NSString * outDate;
@property (nonatomic,copy) NSString * paymentType;
@property (nonatomic,copy) NSString * ratePlanCode;
@property (nonatomic,copy) NSString * vendorCode;
@property (nonatomic,copy) NSString * totalAmount;

@property (nonatomic,retain) UITableView * bookTableView;
@property (nonatomic,retain) NSMutableArray * guests;

@property (nonatomic,retain) UITextField * contactNameLabel;
@property (nonatomic,retain) UITextField * contactPhoneLabel;

@property (nonatomic,retain) UILabel * hotelLastTimeLabel;
@property (nonatomic,retain) UILabel * hotelRoomCounterLabel;

@property (nonatomic,retain) UIButton * bookButton;

@property (nonatomic,retain) UIView * confirmView;

//检查并保存所输入的登陆帐号与登陆密码是否合法
//0-合法;
//1-未输入旅客信息
//2-未输入联系人姓名
//3-未输入联系手机号
//4-未输入有效的手机号码;
//
- (int) checkAndSaveIn;

// 酒店下单POST数据拼装函数
- (NSData*)generateHotelBookRequestPostXMLData;

@end

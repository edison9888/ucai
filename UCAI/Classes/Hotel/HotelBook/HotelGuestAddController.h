//
//  HotelGuestAddController.h
//  JingDuTianXia
//
//  Created by Piosa on 11-11-15.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HotelBookController;

@interface HotelGuestAddController : UITableViewController {

	UITextField * _guestNameField;		//旅客姓名
	UITextField * _guestPhoneField;		//旅客手机
	
	HotelBookController * _hotelBookController;
}

@property (nonatomic, retain) UITextField * guestNameField;
@property (nonatomic, retain) UITextField * guestPhoneField;

@property (nonatomic, retain) HotelBookController * hotelBookController;


//检查并保存所输入的登陆帐号与登陆密码是否合法
//0-合法;
//1-未输入姓名;
//2-未输入手机号码;
//3-未输入密码;
- (int) checkAndSaveIn;
@end

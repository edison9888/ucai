//
//  FlightBookingViewController.h
//  UCAI
//
//  Created by  on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "StaticConf.h"

typedef enum {
    UCAIFlightReserveDateTypeGoStarted,  //预约去程开始日期
    UCAIFlightReserveDateTypeGoEnd,      //预约去程结束日期
    UCAIFlightReserveDateTypeBackStarted,//预约回程开始日期
    UCAIFlightReserveDateTypeBackEnd   //预约回程结束日期
} UCAIFlightReserveDateType;

@interface FlightReserveViewController : UIViewController<UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,MBProgressHUDDelegate>{
    @private
    UCAIFlightLineStyle _flightLineType; //航程类型
    UCAIFlightReserveDateType _flightReserveDateType; //选择日期类型
    MBProgressHUD *_hud;
}

@property(nonatomic,retain) UIButton * bigLeftSegmentControlButton;
@property(nonatomic,retain) UIButton * bigRightSegmentControlButton;

@property(nonatomic,retain) UILabel * startedCityShowlabel; //出发城市显示标签
@property(nonatomic,retain) UILabel * arrivedCityShowlabel; //到达城市显示标签
@property(nonatomic,copy) NSString * startCityCode;        //出发城市三字码
@property(nonatomic,copy) NSString * arrivedCityCode;      //到达城市三字码

@property(nonatomic,retain) UILabel * goStartedDateShowlabel;   //去程开始日期显示标签
@property(nonatomic,retain) UILabel * goEndDateShowlabel;      //去程结束日期显示标签
@property(nonatomic,retain) UILabel * backStartedDateShowlabel; //回程开始日期显示标签
@property(nonatomic,retain) UILabel * backEndDateShowlabel;     //回程结束日期显示标签

@property(nonatomic,retain) UILabel * dayOfWeekShowlabel;   //周几显示标签
@property(nonatomic,assign) NSUInteger week;                //周几

@property(nonatomic,retain) UILabel * discountChoiceShowlabel;  //折扣显示标签
@property(nonatomic,assign) NSUInteger discount;                //折扣

@property(nonatomic,retain) UIButton * priceCheckBoxButton;
@property(nonatomic,retain) UIButton * discountCheckBoxButton;

@property(nonatomic,retain) UITextField * maxPriceTextField;
@property(nonatomic,retain) UITextField * linkManNameTextField;
@property(nonatomic,retain) UITextField * linkManIDnumberTextField;
@property(nonatomic,retain) UITextField * linkManPhoneTextField;
@property(nonatomic,retain) UITextField * linkManTelTextField;
@property(nonatomic,retain) UITextField * linkManEmailTextField;

@property(nonatomic,retain) UIButton * commitButton;

@property(nonatomic,retain) UITableView *reserveTableView;

@property(nonatomic, retain) UIToolbar *dateBar;
@property(nonatomic, retain) UIDatePicker *datePicker;

//检查并保存所输入信息是否合法
//0-合法;
//1-未输入期望最高价格;
//2-未输入联系姓名;
//3-所输入身份证格式错误;
//4-未输入手机号码;
//5-未输入有效手机号码;
//6-所输入电子邮箱格式错误;
- (int)checkAndSaveIn;

- (NSData*)generateFlightBookingRequestPostXMLData;

@end

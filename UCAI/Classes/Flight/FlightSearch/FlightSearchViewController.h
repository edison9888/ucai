//
//  FlightSearchViewController.h
//  UCAI
//
//  Created by  on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "StaticConf.h"

typedef enum {
    UCAIFlightReserveDateTypeGo,        //定购去程日期
    UCAIFlightReserveDateTypeBack,      //定购回程日期
} UCAIFlightBookingDateType;

@interface FlightSearchViewController : UIViewController<UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,MBProgressHUDDelegate>{
@private
    UCAIFlightLineStyle _flightLineType; //航程类型
    UCAIFlightBookingDateType _flightBookingDateType; //选择日期类型
    MBProgressHUD *_hud;
}

@property(nonatomic,retain) UIButton * bigLeftSegmentControlButton;
@property(nonatomic,retain) UIButton * bigRightSegmentControlButton;

@property(nonatomic,retain) UILabel * startedCityShowlabel; //出发城市显示标签
@property(nonatomic,retain) UILabel * arrivedCityShowlabel; //到达城市显示标签
@property(nonatomic,copy) NSString * startCityCode;        //出发城市三字码
@property(nonatomic,copy) NSString * arrivedCityCode;      //到达城市三字码

@property(nonatomic,retain) UILabel * goDateShowlabel; //出发日期显示标签
@property(nonatomic,retain) UILabel * backDateShowlabel; //返回日期显示标签
@property(nonatomic,retain) UILabel * flightCompanyShowlabel; //航空公司显示标签
@property(nonatomic,copy) NSString * flightCompanyCode;      //航空公司代码

@property(nonatomic,retain) UITableView *searchTableView;
@property(nonatomic,retain) UIButton * searchButton;

@property(nonatomic, retain) UIToolbar *dateBar;
@property(nonatomic, retain) UIDatePicker *datePicker;

- (NSData*)generateFlightBookingRequestPostXMLData;


@end

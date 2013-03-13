//
//  HotelSearchController.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-18.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class HotelListSearchRequest;

@interface HotelSearchController : UIViewController <UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate> {
    UITableView * _hotelSearchTableView;        //酒店查询条件列表
    
	UILabel * _cityLabel;				//入住城市显示标签
	UILabel * _checkInDataLabel;		//入住日期显示标签
	UILabel * _checkOutDataLabel;		//离店日期显示标签
	UILabel * _rankLabel;				//酒店星级显示标签
	UILabel * _priceRateLabel;		//酒店价格显示标签
	
	UITextField * _hotelNameField;	//酒店名称输入框
	
	NSString * _cityCode;				//入住城市代码
	NSString * _hotelRank;			//酒店星级
	NSString * _maxPriceRate;			//酒店最高价格
	NSString * _minPriceRate;			//酒店最低价格
	
	UIToolbar * _dateBar;				//入住与离店日期的日期选择界面工具框
	UIDatePicker * _datePicker;		//入住与离店日期的日期滚轮选择器
	
	BOOL  _isCheckInDateSelect;		//是否选择入住日期的标识,YES:选择入住日期;NO:选择离店日期
	
	HotelListSearchRequest * _hotelListSearchRequest; //查询请求参数
    
    MBProgressHUD *_hud;
}

@property(nonatomic, retain) UITableView * hotelSearchTableView;
@property(nonatomic, retain) UILabel *cityLabel;
@property(nonatomic, retain) UILabel *checkInDataLabel;
@property(nonatomic, retain) UILabel *checkOutDataLabel;
@property(nonatomic, retain) UILabel *rankLabel;
@property(nonatomic, retain) UILabel *priceRateLabel;

@property(nonatomic, retain) UITextField *hotelNameField;

@property(nonatomic, copy) NSString *cityCode;
@property(nonatomic, copy) NSString *hotelRank;
@property(nonatomic, copy) NSString *maxPriceRate;
@property(nonatomic, copy) NSString *minPriceRate;

@property(nonatomic, retain) UIToolbar *dateBar;
@property(nonatomic, retain) UIDatePicker *datePicker;

@property(nonatomic) BOOL isCheckInDateSelect;

@property (nonatomic, retain) HotelListSearchRequest *hotelListSearchRequest;

// 酒店列表查询POST数据拼装函数
//orderBy:
//星级低到高：STARLTH，
//星级高到低：STARHTL，
//价格低到高：PRICELTH，
//价格高到低：PRICEHTL
//currentPage:查询页数
- (NSData*)generateHotelListSearchRequestPostXMLData:(NSString *)orderBy pageNO:(NSInteger)searchPage;

@end

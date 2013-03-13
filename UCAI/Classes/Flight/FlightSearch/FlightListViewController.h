//
//  FlightListViewController.h
//  UCAI
//
//  Created by  on 12-1-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIPiosaTableViewCell.h"

#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"
#import "StaticConf.h"

@class ASIFormDataRequest;
@class FlightListSearchResponseModel;

@interface FlightListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate,UIPiosaTableViewCellDelegate>{
    @private
    UCAIFlightLineStyle _flightLineType; //航程类型
    
	EGORefreshTableHeaderView *_refreshHeaderView;  //拉动加载视图
    BOOL _reloading;								//加载视图更新标识
    
    MBProgressHUD *_hud;
    NSDictionary *_flightCompanyDic;
    NSDictionary *_flightSeatDic;
}

@property(nonatomic, copy) NSString *startedDate;
@property(nonatomic, copy) NSString *startedCityName;
@property(nonatomic, copy) NSString *arrivedCityName;
@property(nonatomic, copy) NSString *startCityCode;        //出发城市三字码
@property(nonatomic, copy) NSString *arrivedCityCode;      //到达城市三字码
@property(nonatomic, copy) NSString *searchCompanyCode;    //搜索航空公司代码

@property(nonatomic, retain) UILabel * startedDateLabel;    //出发日期标签
@property(nonatomic, retain) UILabel * countLabel;          //计数结果标签

@property(nonatomic, retain) UIButton * sortLeftSegmentControlButton;        //排序左按钮
@property(nonatomic, retain) UIButton * sortRightSegmentControlButton;       //排序右按钮
@property(nonatomic, copy)   NSString *lastSegmentTitle;    //老排序选择控件被选中的控件标题
@property(nonatomic, assign) NSInteger lastSegmentTag;      //老排序选择控件被选中的控件标签
@property(nonatomic, copy)   NSString *sortOrder;           //老排序顺序:”1”-从低到高;”2”-从高到低
@property(nonatomic, assign) NSInteger newSegmentTag;       //新排序选择控件被选中的控件标签
@property(nonatomic, copy)   NSString *reSortOrder;         //新排序顺序:”1”-从低到高;”2”-从高到低

@property(nonatomic, retain) UITableView *flightListTableView;

@property(nonatomic, retain) FlightListSearchResponseModel *flightListSearchResponseModel;

@property(nonatomic, retain) ASIFormDataRequest *req;                   // 网络请求
@property(nonatomic, assign) NSInteger requestType;                     //网络请求类型:1-列表加载更多;2-重新排序;3-查询反程航班数据;4-查询前一天航班；5-查询后一天航班
@property(nonatomic, retain) NSDate *loadDate;                          //酒店列表查询时间

- (FlightListViewController *)initWithFlightLineStyle:(UCAIFlightLineStyle) flightLineType;

- (void)reloadTableViewDataSource; 
- (void)doneLoadingTableViewData; 

- (NSData*)generateFlightBookingRequestPostXMLData:(NSString *)pageIndex sortType:(NSString *)sortType sortOrder:(NSString *)sortOrder;

@end

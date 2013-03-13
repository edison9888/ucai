//
//  HotelListController.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-21.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#import "EGORefreshTableHeaderView.h"

@class HotelListSearchResponse;
@class HotelSearchController;
@class ASIFormDataRequest;
@class HotelListSearchRequest;

@interface HotelListController : UIViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate> {
  @private
	EGORefreshTableHeaderView *_refreshHeaderView;  //拉动加载视图
    BOOL _reloading;								//加载视图更新标识
    MBProgressHUD *_hud;
}

@property(nonatomic, retain) HotelSearchController *hotelSearchController;      //酒店列表查询控制器
@property(nonatomic, retain) HotelListSearchRequest *hotelListSearchRequest;    //酒店列表查询请求参数
@property(nonatomic, retain) HotelListSearchResponse *hotelListSearchResponse;  //酒店列表数据来源

@property(nonatomic, retain) NSString *cityName;            //城市名称

@property(nonatomic, retain) UIView *titleShowView;
@property(nonatomic, retain) UILabel *cityLabel;            //入住城市显示标签
@property(nonatomic, retain) UILabel *checkInDataLabel;     //入住日期显示标签
@property(nonatomic, retain) UILabel *checkOutDataLabel;    //离店日期显示标签
@property(nonatomic, retain) UILabel *hotelCountLabel;      //酒店总数显示标签

@property(nonatomic, retain) UIView *segmentView;           //排序选择的分隔视图
@property(nonatomic, retain) UIButton * sortLeftSegmentControlButton;        //排序左按钮
@property(nonatomic, retain) UIButton * sortRightSegmentControlButton;       //排序右按钮
@property(nonatomic, copy)   NSString *lastSegmentTitle;    //老排序选择控件被选中的控件标题
@property(nonatomic, assign) NSInteger lastSegmentTag;      //老排序选择控件被选中的控件标签
@property(nonatomic, copy)   NSString *orderBy;             //老排序参数 星级低到高：STARLTH，星级高到低：STARHTL，价格低到高：PRICELTH，价格高到低：PRICEHTL
@property(nonatomic, assign) NSInteger newSegmentTag;       //新排序选择控件被选中的控件标签
@property(nonatomic, copy)   NSString *reOrderBy;           //新排序参数

@property(nonatomic, retain) UITableView *hotelListTableView;           //酒店列表视图

@property(nonatomic, retain) ASIFormDataRequest *req;                   // 网络请求
@property(nonatomic, assign) NSInteger requestType;                     //网络请求类型:1-列表加载更多;2-重新排序;3-加载酒店详情
@property(nonatomic, retain) NSDate *loadDate;                          //酒店列表查询时间

- (void)reloadTableViewDataSource; 
- (void)doneLoadingTableViewData; 

// 酒店列表查询POST数据拼装函数
- (NSData*)generateHotelListSearchRequestPostXMLData:(HotelListSearchRequest *)request;

// 酒店详情查询POST数据拼装函数
// hotelCode:酒店代码
- (NSData*)generateHotelSingleSearchRequestPostXMLData:(NSString *)hotelCode;

@end

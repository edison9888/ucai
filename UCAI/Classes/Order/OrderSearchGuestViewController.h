//
//  OrderSearchGuestViewController.h
//  JingDuTianXia
//
//  Created by  on 11-11-30.
//  Copyright (c) 2011年 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

@class ASIFormDataRequest;
@class HotelOrderListSearchResponseModel;
@class FlightOrderListSearchResponseModel;

@interface OrderSearchGuestViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate>{
    EGORefreshTableHeaderView *_hotelRefreshHeaderView;  //酒店订单列表拉动加载视图
    BOOL _hotelReloading;								//酒店订单列表加载视图更新标识
    
    EGORefreshTableHeaderView *_flightRefreshHeaderView;  //机票订单列表拉动加载视图
    BOOL _flightReloading;								//机票订单列表加载视图更新标识
    
    NSInteger _requestType;		//网络请求类型:1-酒店订单列表查询;2-酒店订单列表加载更多;	
                                //          3-机票订单列表查询;4-机票订单列表加载更多;
    
    MBProgressHUD *_hud;
}

@property(nonatomic,retain) UIButton * bigLeftSegmentControlButton;
@property(nonatomic,retain) UIButton * bigRightSegmentControlButton;

@property(nonatomic,retain) UITextField * contactNameField;
@property(nonatomic,retain) UITextField * contactPhoneField;

@property(nonatomic,retain) UIButton * searchButton;

@property(nonatomic,retain) UITableView * hotelTableView;
@property(nonatomic,retain) UITableView * flightTableView;

@property(nonatomic,retain) HotelOrderListSearchResponseModel *hotelOrderListSearchResponseModel; //酒店订单列表查询信息
@property(nonatomic,retain) FlightOrderListSearchResponseModel *flightOrderListSearchResponseModel; //机票订单列表查询信息

@property(nonatomic,retain) ASIFormDataRequest *req;			// 网络请求

@property(nonatomic,copy) NSString * lastContractNameForSearchHotleOrderList;
@property(nonatomic,copy) NSString * lastContractPhoneForSearchHotleOrderList;

@property(nonatomic,copy) NSString * lastContractNameForSearchFlightOrderList;
@property(nonatomic,copy) NSString * lastContractPhoneForSearchFlightOrderList;

//检查并保存所输入的登陆帐号与登陆密码是否合法
//0-合法;
//1-未输入联系人姓名
//2-未输入联系手机号
//3-未输入有效的手机号码;
//
- (int) checkAndSaveIn;

- (void)reloadTableViewDataSource:(EGORefreshTableHeaderView *) eGORefreshTableHeaderView;
- (void)doneLoadingTableViewData:(EGORefreshTableHeaderView *) eGORefreshTableHeaderView;

// 机票订单列表查询POST数据拼装函数
- (NSData*)generateFlightOrderListSearchRequestPostXMLData:(NSString *) pageIndex ;

// 酒店订单列表查询POST数据拼装函数
- (NSData*)generateHotelOrderListSearchRequestPostXMLData:(NSString *) pageIndex ;

@end

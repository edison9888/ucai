//
//  OrderSearchMemberViewController.h
//  UCAI
//
//  Created by  on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

@class ASIFormDataRequest;
@class HotelOrderListSearchResponseModel;
@class FlightOrderListSearchResponseModel;

@interface OrderSearchMemberViewController : UIViewController  <UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate>{
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

@property(nonatomic,retain) UITableView * hotelTableView;
@property(nonatomic,retain) UITableView * flightTableView;

@property(nonatomic,retain) HotelOrderListSearchResponseModel *hotelOrderListSearchResponseModel; //酒店订单列表查询信息
@property(nonatomic,retain) FlightOrderListSearchResponseModel *flightOrderListSearchResponseModel; //机票订单列表查询信息

@property(nonatomic,retain) ASIFormDataRequest *req;			// 网络请求

- (void)reloadTableViewDataSource:(EGORefreshTableHeaderView *) eGORefreshTableHeaderView;
- (void)doneLoadingTableViewData:(EGORefreshTableHeaderView *) eGORefreshTableHeaderView;

- (void)searchOrderList;

// 机票订单列表查询POST数据拼装函数
- (NSData*)generateFlightOrderListSearchRequestPostXMLData:(NSString *) pageIndex ;

// 酒店订单列表查询POST数据拼装函数
- (NSData*)generateHotelOrderListSearchRequestPostXMLData:(NSString *) pageIndex ;

@end

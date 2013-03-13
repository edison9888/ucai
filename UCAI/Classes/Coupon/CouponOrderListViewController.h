//
//  CouponOrderListViewController.h
//  UCAI
//
//  Created by  on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "CouponOrderListSearchResponseModel.h"
#import "MBProgressHUD.h"

@class ASIFormDataRequest;

@interface CouponOrderListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate>{
@private
    NSUInteger _couponListType;
	EGORefreshTableHeaderView *_refreshHeaderView;  //拉动加载视图
    BOOL _reloading;								//加载视图更新标识
    MBProgressHUD *_hud;
}

@property (nonatomic,retain) UILabel * couponOrderListCountLabel;
@property (nonatomic,retain) UITableView * couponOrderListTableView;
@property (nonatomic,retain) ASIFormDataRequest *req;			// 网络请求
@property (nonatomic,retain) CouponOrderListSearchResponseModel *couponOrderListSearchResponseModel;

@property(nonatomic, assign) NSInteger requestType;          //网络请求类型:1-刷新列表;2-列表加载更多;

- (NSData*)generateCouponOrderListSearchRequestPostXMLData:(NSString *) pageIndex;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end

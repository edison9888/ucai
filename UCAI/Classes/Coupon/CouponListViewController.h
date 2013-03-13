//
//  CouponFreeListViewController.h
//  UCAI
//
//  Created by  on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

@class CouponListSearchResponseModel;

@class ASIFormDataRequest;

@interface CouponListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate>{
    @private
    NSUInteger _couponListType;
	EGORefreshTableHeaderView *_refreshHeaderView;  //拉动加载视图
    BOOL _reloading;								//加载视图更新标识
    MBProgressHUD *_hud;
}

@property (nonatomic,retain) UILabel * couponListCountLabel;
@property (nonatomic,retain) UITableView * couponListTableView;
@property (nonatomic,retain) ASIFormDataRequest *req;			// 网络请求
@property (nonatomic,retain) CouponListSearchResponseModel *couponListSearchResponseModel;

@property(nonatomic, assign) NSInteger requestType;          //网络请求类型:1-刷新列表;2-列表加载更多;

//根据所要查询的优惠劵类型初始化优惠劵种类查询列表控制器
//couponType:1-免费，2-购买
- (CouponListViewController *)initWithCouponType:(NSUInteger) couponListType;


- (NSData*)generateCouponListSearchRequestPostXMLData:(NSString *) pageIndex;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end

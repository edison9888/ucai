//
//  FlightBookSucceedCouponChoiceViewController.h
//  UCAI
//
//  Created by  on 12-2-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

@class FlightBookSucceedViewController;
@class CouponValidQueryResponseModel;
@class ASIFormDataRequest;

@interface FlightBookSucceedCouponChoiceViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate>{
@private
    NSMutableArray *_selectedCouponNOArray;
    UITableView *_couponChoiceTableView;
    NSUInteger _maxUsedCount;
    float _couponPriceAmount;
    
    EGORefreshTableHeaderView *_refreshHeaderView;  //拉动加载视图
    BOOL _reloading;								//加载视图更新标识
    
    MBProgressHUD *_hud;
}

@property(nonatomic,retain) FlightBookSucceedViewController *flightBookSucceedViewController;
@property(nonatomic,retain) CouponValidQueryResponseModel *couponValidQueryResponseModel;

@property(nonatomic,retain) UILabel *couponCounterLabel;
@property(nonatomic,retain) UILabel *usedCounterLabel;
@property(nonatomic,retain) UILabel *couponPriceAmountContentLabel;

@property (nonatomic,retain) ASIFormDataRequest *req;			// 网络请求
@property(nonatomic, assign) NSInteger requestType;          //网络请求类型:1-刷新列表;2-列表加载更多;

//coupons:已经选择的优惠劵号，用逗号隔开
- (FlightBookSucceedCouponChoiceViewController *)initWithMaxUsedCount:(NSUInteger)maxUsedCount;

- (NSData*)generateCouponValidQueryRequestPostXMLData:(NSString *) pageIndex;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end

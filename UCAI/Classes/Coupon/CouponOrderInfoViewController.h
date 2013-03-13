//
//  CouponOrderInfoViewController.h
//  UCAI
//
//  Created by  on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModelBackgroundView.h"
#import "UIView-ModalAnimationHelper.h"
#import "MBProgressHUD.h"

@class CouponOrderInfoSearchResponseModel;

@interface CouponOrderInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ModelBackgroundViewDelegate,MBProgressHUDDelegate>{
    @private
    MBProgressHUD *_hud;
}

@property(nonatomic,copy) NSString * orderId;
@property(nonatomic,retain) UITableView * couponOrderInfoTableView;

@property(nonatomic,retain) UILabel * orderIDContentLabel;
@property(nonatomic,retain) UILabel * orderPriceContentLabel;
@property(nonatomic,retain) UILabel * orderPayStatusContentLabel;
@property(nonatomic,retain) UILabel * couponNameContentLabel;
@property(nonatomic,retain) UILabel * orderTypeContentLabel;
@property(nonatomic,retain) UILabel * expirationTimeContentLabel;

@property(nonatomic,retain) UILabel * couponPriceContentLabel;

@property(nonatomic,retain) UILabel * businessNameContentLabel;
@property(nonatomic,retain) UILabel * businessTelContentLabel;
@property(nonatomic,retain) UILabel * businessAddressContentLabel;

@property(nonatomic,retain) CouponOrderInfoSearchResponseModel *couponOrderInfoSearchResponseModel;

@property(nonatomic,retain) ModelBackgroundView *modelBGView;
@property(nonatomic,retain) UIView *modelButtonView;

- (CouponOrderInfoViewController *)initWithOrderId:(NSString *)orderId;

- (NSData*)generateCouponOrderInfoSearchRequestPostXMLData;

@end

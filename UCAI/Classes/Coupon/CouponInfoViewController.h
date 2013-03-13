//
//  CouponInfoViewController.h
//  UCAI
//
//  Created by  on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class UIHTTPImageView;

@interface CouponInfoViewController : UIViewController<MBProgressHUDDelegate>{
    @private
    NSString *_couponID;
    NSUInteger _couponType;
    MBProgressHUD *_hud;
}

@property (nonatomic,assign) NSUInteger couponBuyCount;    // 优惠劵购买张数

@property (nonatomic,retain) UIHTTPImageView *couponImageView;
@property (nonatomic,retain) UILabel *couponNameLabel;
@property (nonatomic,retain) UILabel *couponPriceLabel;
@property (nonatomic,retain) UILabel *couponPopularityLabel;
@property (nonatomic,retain) UILabel *couponTypeLabel;
@property (nonatomic,retain) UILabel *couponEndTimeLabel;
@property (nonatomic,retain) UILabel *couponSellPriceLabel;
@property (nonatomic,retain) UIButton *couponBuyCountChoiceButton;
@property (nonatomic,retain) UIButton *couponGetButton;

@property (nonatomic,retain) UIScrollView *couponInfoScrollView;

@property(nonatomic, assign) NSInteger requestType;          //网络请求类型:1-查询详情;2-下单;

//couponID:优惠劵ID
//couponType:1-免费，2-购买
- (CouponInfoViewController *)initWithCouponID:(NSString *)couponID couponType:(NSUInteger) couponType;

- (NSData*)generateCouponInfoSearchRequestPostXMLData;
- (NSData*)generateCouponBookingSearchRequestPostXMLData;

@end

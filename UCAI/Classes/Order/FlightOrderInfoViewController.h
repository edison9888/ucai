//
//  FlightOrderInfoViewController.h
//  UCAI
//
//  Created by  on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ModelBackgroundView.h"
#import "UIView-ModalAnimationHelper.h"
#import "MBProgressHUD.h"

@class FlightOrderInfoSearchResponseModel;

@interface FlightOrderInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ModelBackgroundViewDelegate,MBProgressHUDDelegate>{
    @protected
    NSUInteger _adultCount;
    
    MBProgressHUD *_hud;
    
    NSDictionary *_flightCompanyDic;
}


@property(nonatomic,copy) NSString * orderId;

@property(nonatomic,retain) UITableView * flightOrderInfoTableView;

@property(nonatomic,retain) UILabel * orderIDContentLabel;
@property(nonatomic,retain) UILabel * orderPriceContentLabel;
@property(nonatomic,retain) UILabel * orderPayStatusContentLabel;
@property(nonatomic,retain) UILabel * orderTimeContentLabel;
@property(nonatomic,retain) UILabel * orderTypeContentLabel;

@property(nonatomic,retain) UILabel * linkNameContentLabel;  //联系人姓名
@property(nonatomic,retain) UILabel * linkMobileContentLabel;//联系人手机号码

@property(nonatomic,retain) NSString * couponPriceAmount;//优惠劵使用额
@property(nonatomic,retain) UILabel * couponPriceAmountContentLabel;//优惠劵使用额
@property(nonatomic,retain) UILabel * couponUsedShowLabel;
@property(nonatomic,retain) UILabel * couponUsedContentLabel;
@property(nonatomic,retain) NSString * couponUsedIDs;

@property(nonatomic,retain) UIButton * payButton;

@property(nonatomic,retain) FlightOrderInfoSearchResponseModel *flightOrderInfoSearchResponseModel;

@property(nonatomic,retain) ModelBackgroundView *modelBGView;
@property(nonatomic,retain) UIView *modelButtonView;


- (NSData*)generateFlightOrderInfoSearchRequestPostXMLData;

@end

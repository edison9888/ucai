//
//  FlightBookSucceedViewController.h
//  UCAI
//
//  Created by  on 12-2-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ModelBackgroundView.h"
#import "UIView-ModalAnimationHelper.h"

@interface FlightBookSucceedViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,ModelBackgroundViewDelegate>{
    @protected
    NSUInteger _adultCount;
}

@property (nonatomic,retain) NSMutableArray * customers;

@property (nonatomic,copy) NSString * flightOrderID;     //订单ID
@property (nonatomic,copy) NSString * flightOrderPrice;  //订单总额

@property(nonatomic,retain) NSString * couponPriceAmount;//优惠劵使用额
@property(nonatomic,retain) UILabel * couponPriceAmountContentLabel;//优惠劵使用额
@property(nonatomic,retain) UILabel * couponUsedShowLabel;
@property(nonatomic,retain) UILabel * couponUsedContentLabel;
@property(nonatomic,retain) NSString * couponUsedIDs;

@property(nonatomic,retain) UITableView * flightOrderInfoTableView;

@property(nonatomic,retain) UIButton * payButton;

@property(nonatomic,retain) ModelBackgroundView *modelBGView;
@property(nonatomic,retain) UIView *modelButtonView;

@end

//
//  CouponBookResultViewController.h
//  UCAI
//
//  Created by  on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModelBackgroundView.h"
#import "UIView-ModalAnimationHelper.h"

@interface CouponBookResultViewController : UIViewController<UIActionSheetDelegate,ModelBackgroundViewDelegate>{
    @private
    NSString *_couponOrderID;
    NSString *_couponCount;
    NSString *_couponPrice;
}

@property(nonatomic,retain) ModelBackgroundView *modelBGView;
@property(nonatomic,retain) UIView *modelButtonView;

- (CouponBookResultViewController *)initWithOrderID:(NSString *)orderID andCouponCount:(NSString *)count andCouponPrice:(NSString *)price;

@end

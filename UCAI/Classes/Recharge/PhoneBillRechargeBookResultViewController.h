//
//  PhoneBillRechargeBookResultViewController.h
//  UCAI
//
//  Created by  on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ModelBackgroundView.h"
#import "UIView-ModalAnimationHelper.h"

@class PhoneBillRechargeResponseModel;

@interface PhoneBillRechargeBookResultViewController : UIViewController<UIActionSheetDelegate,ModelBackgroundViewDelegate>{
    @private
    NSString *_phone;
    NSUInteger _rechargeType;
    PhoneBillRechargeResponseModel *_phoneBillRechargeResponseModel;
}

@property(nonatomic,retain) ModelBackgroundView *modelBGView;
@property(nonatomic,retain) UIView *modelButtonView;

//model:下单返回结果
//phone:充值手机号码
//rechargeType:充值类型”1”-10元, ”2”-20元, ”3”-30元, ”4”-50元, ”5”-100元, ”6”-200, ”7”-300元
- (PhoneBillRechargeBookResultViewController *)initWithResponse:(PhoneBillRechargeResponseModel *)model phone:(NSString *)phone rechargeType:(NSUInteger)type;

@end

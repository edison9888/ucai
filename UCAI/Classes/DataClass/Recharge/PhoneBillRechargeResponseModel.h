//
//  PhoneBillRechargeResponseModel.h
//  UCAI
//
//  Created by  on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneBillRechargeResponseModel : NSObject

@property (nonatomic, copy) NSString *resultCode;      // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;   // 返回结果信息

@property (nonatomic, copy) NSString *orderID;           //订单号
@property (nonatomic, copy) NSString *orderCharge;      //订单支付金额
@property (nonatomic, copy) NSString *cardType;         //充值手机卡类型
@property (nonatomic, copy) NSString *cardAttribution;   //充值手机号归属地

@end

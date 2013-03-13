//
//  CouponBookingResponseModel.h
//  UCAI
//
//  Created by  on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponBookingResponseModel : NSObject

@property (nonatomic, copy) NSString *resultCode;      // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;   // 返回结果信息

@property (nonatomic, copy) NSString *orderID;      // 订单号
@property (nonatomic, copy) NSString *payPrice;   // 订单应付金额

@end

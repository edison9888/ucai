//
//  CouponSendResponseModel.h
//  UCAI
//
//  Created by  on 11-12-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponSendResponseModel : NSObject

@property (nonatomic, copy) NSString *resultCode;      // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;   // 返回结果信息

@property (nonatomic, copy) NSString *remainingCount;           // 此优惠劵订单剩余的发送次数


@end

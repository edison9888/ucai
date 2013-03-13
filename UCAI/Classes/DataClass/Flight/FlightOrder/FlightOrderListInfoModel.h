//
//  FlightOrderListInfoModel.h
//  UCAI
//
//  Created by  on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightOrderListInfoModel : NSObject

@property (nonatomic, copy) NSString *orderID;      // 订单号
@property (nonatomic, copy) NSString *orderStatus;  // 订单状态
@property (nonatomic, copy) NSString *orderTime;    // 订单时间
@property (nonatomic, copy) NSString *orderPrice;   // 订单价格
@property (nonatomic, copy) NSString *orderType;   // 航程类型:1-单程,2-往返
@property (nonatomic, copy) NSString *fromCity;   // 出发城市名称
@property (nonatomic, copy) NSString *toCity;   // 到达城市名称

@end

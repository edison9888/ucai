//
//  FlightBookResponseModel.h
//  UCAI
//
//  Created by  on 12-2-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightBookResponseModel : NSObject

@property (nonatomic, copy) NSString *resultCode;       // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;    // 返回结果信息
@property (nonatomic, copy) NSString *orderNo;          // 订单编号
@property (nonatomic, copy) NSString *orderTime;        // 下单时间YYYY-MM-DD HH:MM:SS
@property (nonatomic, copy) NSString *orderPrice;       // 订单应付总价(油菜票面价+机场建设费+燃油费+保险费)

@end

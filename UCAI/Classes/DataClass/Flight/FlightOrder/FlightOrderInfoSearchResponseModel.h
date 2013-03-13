//
//  FlightOrderInfoSearchResponseModel.h
//  UCAI
//
//  Created by  on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightOrderCustomerInfo : NSObject

@property (nonatomic, copy) NSString *name;             // 姓名
@property (nonatomic, copy) NSString *certificateNo;   // 证件号 
@property (nonatomic, copy) NSString *type;            // 乘机人类型 

@end

@interface FlightOrderFlightingInfo : NSObject

@property (nonatomic, copy) NSString *dptCode;      // 起飞机场三字码
@property (nonatomic, copy) NSString *dptName;      // 起飞机场名字
@property (nonatomic, copy) NSString *arrCode;      // 到达机场三字码
@property (nonatomic, copy) NSString *arrName;      // 到达机场名字
@property (nonatomic, copy) NSString *fromDate;     // 出发日期
@property (nonatomic, copy) NSString *fromTime;     // 起飞时间
@property (nonatomic, copy) NSString *toTime;       // 到达时间
@property (nonatomic, copy) NSString *companyCode;  // 航空公司编码
@property (nonatomic, copy) NSString *companyName;  // 航空公司名字
@property (nonatomic, copy) NSString *flightNo;     // 航班号
@property (nonatomic, copy) NSString *classCode;    // 舱位类别
@property (nonatomic, copy) NSString *flightType;   // 飞机机型
@property (nonatomic, copy) NSString *price;        // 机票价格
@property (nonatomic, copy) NSString *tax;          // 燃油附加费
@property (nonatomic, copy) NSString *airTax;       // 机场建设费

@end


@interface FlightOrderInfoSearchResponseModel : NSObject

@property (nonatomic, copy) NSString *resultCode;      // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;   // 返回结果信息

@property (nonatomic, copy) NSString *orderTime;        // 下单时间
@property (nonatomic, copy) NSString *orderPayStatus;   // 订单支付状态
@property (nonatomic, copy) NSString *orderPayPrice;    // 订单价格

@property (nonatomic, copy) NSString *linkmanName;      // 联系人姓名
@property (nonatomic, copy) NSString *linkmanMobile;    // 联系人手机号
@property (nonatomic, copy) NSString *linkmanEmail;     // 联系人电子邮箱

@property (nonatomic, retain) NSMutableArray *customers;    // 乘客列表(FlightOrderCustomerInfo)
@property (nonatomic, retain) NSMutableArray *flights;      // 航班列表(FlightOrderFlightingInfo)



@end

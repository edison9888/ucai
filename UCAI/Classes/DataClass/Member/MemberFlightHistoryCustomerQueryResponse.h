//
//  MemberFlightHistoryCustomerQueryResponse.h
//  UCAI
//
//  Created by  on 12-2-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightHistoryCustomer : NSObject 

@property(nonatomic,copy) NSString * customerID;
@property(nonatomic,copy) NSString * customerName; //姓名
@property(nonatomic,copy) NSString * customerType; //乘机人类型(1.成人，2.儿童，3.婴儿)
@property(nonatomic,copy) NSString * certificateType; //证件类型,必填 “1”-身份证;“2”-军官证;“3”-港澳通行证;“4”-护照;“5”台胞证-;“6”-士兵证;“7”-回乡证;“8”-其他;
@property(nonatomic,copy) NSString * certificateNo; //证件号码
@property(nonatomic,copy) NSString * secureNum; //航程保险份数

@end


@interface MemberFlightHistoryCustomerQueryResponse : NSObject

@property (nonatomic, copy) NSString *resultCode;       // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;    // 返回结果信息

@property (nonatomic, retain) NSMutableArray *historyCustomers; //历史乘机人列表(FlightHistoryCustomer)

@end

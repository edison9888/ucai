//
//  FlightOrderListSearchResponseModel.h
//  UCAI
//
//  Created by  on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightOrderListSearchResponseModel : NSObject

@property (nonatomic, copy) NSString *resultCode;      // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;   // 返回结果信息
@property (nonatomic, retain) NSMutableArray *orders;   // 机票订单列表

@property (nonatomic, copy) NSString * currentPage;     //当前请求页,从1开始
@property (nonatomic, copy) NSString * pageSize;     //每页显示记录数
@property (nonatomic, copy) NSString * count;     //总记录数

@end

//
//  CouponOrderListSearchResponseModel.h
//  UCAI
//
//  Created by  on 11-12-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponOrderListInfoModel : NSObject 

@property (nonatomic, copy) NSString *orderID;           //优惠劵ID
@property (nonatomic, copy) NSString *couponName;         //优惠劵名称
@property (nonatomic, copy) NSString *couponPrice;        //单张优惠劵购买金额
@property (nonatomic, copy) NSString *couponAmount;      //优惠劵张数
@property (nonatomic, copy) NSString *payPrice;    //订单应付金额
@property (nonatomic, copy) NSString *isPay;   //订单状态：0-未支付，1-已支付，2-支付等待中

@end

@interface CouponOrderListSearchResponseModel : NSObject

@property (nonatomic, copy) NSString *resultCode;      // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;   // 返回结果信息

@property(nonatomic,retain) NSMutableArray * couponOrderArray; // 订单列表数据(CouponOrderListInfoModel)

@property (nonatomic, copy) NSString * currentPage;     //当前请求页,从1开始
@property (nonatomic, copy) NSString * pageSize;     //每页显示记录数
@property (nonatomic, copy) NSString * count;     //总记录数

@end

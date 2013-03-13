//
//  CouponOrderInfoSearchResponseModel.h
//  UCAI
//
//  Created by  on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponInfo : NSObject

@property (nonatomic, copy) NSString *couponNO;      // 优惠劵码
@property (nonatomic, copy) NSString *status;   // 优惠劵状态：”1”-可用,”2”-占用,”3”-已使用,”4”-过期

@end

@interface CouponOrderInfoSearchResponseModel : NSObject

@property (nonatomic, copy) NSString *resultCode;      // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;   // 返回结果信息

@property (nonatomic, copy) NSString *orderID;           //优惠劵ID
@property (nonatomic, copy) NSString *couponName;         //优惠劵名称
@property (nonatomic, copy) NSString *typeID;        //优惠劵类型标识: “1”-机票，“2”-酒店
@property (nonatomic, copy) NSString *typeName;        //优惠劵类型名称
@property (nonatomic, copy) NSString *price;        //优惠劵金额
@property (nonatomic, copy) NSString *couponPrice;        //单张优惠劵购买金额
@property (nonatomic, copy) NSString *couponAmount;      //优惠劵张数
@property (nonatomic, copy) NSString *payPrice;    //订单应付金额
@property (nonatomic, copy) NSString *isPay;   //订单状态：0-未支付，1-已支付，2-支付等待中
@property (nonatomic, copy) NSString *expirationTime;       //优惠劵使用的过期时间(yyyy-MM-dd hh:mm:ss)

@property (nonatomic, retain) NSMutableArray *couponArray;    //优惠劵列表

@property (nonatomic, copy) NSString *businessName;         //所属商家名称
@property (nonatomic, copy) NSString *businessTel;          //商家联系电话
@property (nonatomic, copy) NSString *businessAddress;      //商家地址

@end

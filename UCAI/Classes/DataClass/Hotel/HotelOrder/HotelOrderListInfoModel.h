//
//  HotelOrderListInfoModel.h
//  JingDuTianXia
//
//  Created by  on 11-11-30.
//  Copyright (c) 2011年 __JingDuTianXia__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotelOrderListInfoModel : NSObject

@property(nonatomic,copy) NSString * orderId;       //订单id
@property(nonatomic,copy) NSString * tpsOrderId;    //第三方系统订单id,查询订单详情时需要
@property(nonatomic,copy) NSString * hotelName;     //酒店名称
@property(nonatomic,copy) NSString * amount;        //金额
@property(nonatomic,copy) NSString * resStatus;     //订单状态
@property(nonatomic,copy) NSString * payStatus;     //支付状态1：已支付 0或空值（值长度为0）：未支付
@property(nonatomic,copy) NSString * bookTime;     //订单时间yyyy-MM-dd hh:mm:ss


@end

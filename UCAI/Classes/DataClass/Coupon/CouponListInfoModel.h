//
//  CouponListInfoModel.h
//  UCAI
//
//  Created by  on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponListInfoModel : NSObject

@property (nonatomic, copy) NSString *couponID;           //优惠劵ID
@property (nonatomic, copy) NSString *couponName;         //优惠劵名称
@property (nonatomic, copy) NSString *couponType;         //优惠劵类型
@property (nonatomic, copy) NSString *couponPrice;        //优惠劵金额
@property (nonatomic, copy) NSString *couponEndTime;      //优惠劵领取或购买的结束时间(yyyy-MM-dd hh:mm:ss)
@property (nonatomic, copy) NSString *couponSellPrice;    //销售价格
@property (nonatomic, copy) NSString *couponPopularity;   //人气指数
@property (nonatomic, copy) NSString *couponImage;        //优惠劵图片

@end

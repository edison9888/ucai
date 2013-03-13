//
//  CouponInfoSearchResponseModel.h
//  UCAI
//
//  Created by  on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponInfoSearchResponseModel : NSObject

@property (nonatomic, copy) NSString *resultCode;      // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;   // 返回结果信息

@property (nonatomic, copy) NSString *couponID;           //优惠劵ID
@property (nonatomic, copy) NSString *couponName;         //优惠劵名称
@property (nonatomic, copy) NSString *couponType;         //优惠劵类型
@property (nonatomic, copy) NSString *couponPrice;        //优惠劵金额
@property (nonatomic, copy) NSString *couponEndTime;      //优惠劵领取或购买的结束时间(yyyy-MM-dd hh:mm:ss)
@property (nonatomic, copy) NSString *couponSellPrice;    //销售价格
@property (nonatomic, copy) NSString *couponPopularity;   //人气指数
@property (nonatomic, copy) NSString *couponImage;        //优惠劵图片

@property (nonatomic, copy) NSString *couponPeriod;       //有效期(月数)
@property (nonatomic, copy) NSString *couponCondition;    //优惠劵使用条件
@property (nonatomic, copy) NSString *couponMethod;       //优惠劵使用方法
@property (nonatomic, copy) NSString *couponDetail;       //优惠劵详细说明

@property (nonatomic, copy) NSString *businessName;         //所属商家名称
@property (nonatomic, copy) NSString *cityName;             //所在城市名称
@property (nonatomic, copy) NSString *businessWebsite;      //商家网站名称
@property (nonatomic, copy) NSString *businessTel;          //商家联系电话
@property (nonatomic, copy) NSString *businessContact;      //商家联系人
@property (nonatomic, copy) NSString *businessAddress;      //商家地址



@end

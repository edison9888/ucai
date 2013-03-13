//
//  HotelOrderInfoSearchResponseModel.h
//  UCAI
//
//  Created by  on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotelOrderInfoSearchResponseModel : NSObject

@property(nonatomic,copy) NSString * resultCode;// 返回结果编码:1-成功,0-失败
@property(nonatomic,copy) NSString * resultMessage;// 返回结果信息

@property(nonatomic,copy) NSString * amount;//金额
@property(nonatomic,copy) NSString * hotelName;//酒店名称
@property(nonatomic,copy) NSString * bookingTime;//订购时间
@property(nonatomic,copy) NSString * inDate;//入住日期, yyyyMMdd
@property(nonatomic,copy) NSString * outDate;//离店日期, yyyyMMdd
@property(nonatomic,copy) NSString * stayDay;//入住天数
@property(nonatomic,copy) NSString * earlyTime;//最早到店时间,HHmmss
@property(nonatomic,copy) NSString * lateTime;//最晚到店时间,HHmmss
@property(nonatomic,copy) NSString * roomName;//房型名称
@property(nonatomic,copy) NSString * roomNum;//房间数量
@property(nonatomic,copy) NSString * tel;//酒店联系电话
@property(nonatomic,copy) NSString * guests;//入住人信息（姓名/手机|姓名/手机|姓名/手机|）
@property(nonatomic,copy) NSString * linkName;//联系人姓名
@property(nonatomic,copy) NSString * linkTel;//联系人电话
@property(nonatomic,copy) NSString * linkMobile;//客人手机
@property(nonatomic,copy) NSString * linkEmail;//电子邮件
@property(nonatomic,copy) NSString * resStatus;//订单状态
@property(nonatomic,copy) NSString * payStatus;//支付状态 1：已支付 0或空值（值长度为0）：未支付
@property(nonatomic,copy) NSString * payment;//客户订单支付方式（对我们）0前台现付，1网银支付 2 支付宝 3信用卡 4银联付款 5 前台现付 6指纹识别 7优付宝 8易商卡

@end

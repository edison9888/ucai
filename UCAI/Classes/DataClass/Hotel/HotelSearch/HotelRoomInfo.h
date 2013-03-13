//
//  HotelRoomInfo.h
//  JingDuTianXia
//
//  Created by Piosa on 11-11-3.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HotelRoomInfo : NSObject {

	NSString * _roomTypeName;		//房型名称
	NSString * _roomTypeCode;		//房型代码
	NSString * _roomBedType;		//床型
	NSString * _roomVendorCode;		//供应商代码
	NSString * _roomDescription;	//房型描述
	NSString * _roomInternet;		//是否可上网；Y:可以，N:不可以
	NSString * _roomTotalPrice;		//总价
	NSString * _roomPayment;		//支付方式：T:前台支付,S:代收现付,Y:预付
	NSString * _roomRatePlanCode;	//价格计划代码
	NSString * _roomAmountPrice;	//销售价
	NSString * _roomDisplayPrice;	//门市价
	NSString * _roomFreeMealCount;	//含早餐数；1表示1早，2表示2早。－1表示有早
}

@property(nonatomic,copy) NSString * roomTypeName;
@property(nonatomic,copy) NSString * roomTypeCode;
@property(nonatomic,copy) NSString * roomBedType;
@property(nonatomic,copy) NSString * roomVendorCode;
@property(nonatomic,copy) NSString * roomDescription;
@property(nonatomic,copy) NSString * roomInternet;
@property(nonatomic,copy) NSString * roomTotalPrice;	
@property(nonatomic,copy) NSString * roomPayment;
@property(nonatomic,copy) NSString * roomRatePlanCode;
@property(nonatomic,copy) NSString * roomAmountPrice;
@property(nonatomic,copy) NSString * roomDisplayPrice;
@property(nonatomic,copy) NSString * roomFreeMealCount;

@end

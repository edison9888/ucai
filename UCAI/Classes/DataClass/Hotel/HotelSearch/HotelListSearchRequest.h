//
//  HotelListSearchRequest.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-27.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HotelListSearchRequest : UIView {

	NSString *hotelCheckInDate;		//入住日期
	NSString *hotelCheckOutDate;	//离店日期
	NSString *hotelCityCode;		//入住城市代码
	NSString *hotelName;		//酒店名称
	NSString *hotelDistrict;			
	NSString *hotelRank;			//酒店星级
	NSString *hotelMaxRate;			//酒店最高价格
	NSString *hotelMinRate;			//酒店最低价格
	NSString *hotelPageNo;			//查询页数
	NSString *hotelOrderBy;			//排序参数
}

@property(nonatomic, copy) NSString *hotelCheckInDate;		
@property(nonatomic, copy) NSString *hotelCheckOutDate;		
@property(nonatomic, copy) NSString *hotelCityCode;			
@property(nonatomic, copy) NSString *hotelName;		
@property(nonatomic, copy) NSString *hotelDistrict;			
@property(nonatomic, copy) NSString *hotelRank;			
@property(nonatomic, copy) NSString *hotelMaxRate;			
@property(nonatomic, copy) NSString *hotelMinRate;			
@property(nonatomic, copy) NSString *hotelPageNo;			
@property(nonatomic, copy) NSString *hotelOrderBy;			

@end

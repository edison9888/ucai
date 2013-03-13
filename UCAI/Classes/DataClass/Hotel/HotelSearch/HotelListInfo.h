//
//  HotelListInfo.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-20.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HotelListInfo : NSObject {
	NSString *hotelCode;	//酒店代码
	NSString *hotelName;	//酒店名称
	NSString *hotelMinRate;	//最低价格
	NSString *hotelImage;	//酒店图片
	NSString *hotelRank;	//星级 1-5星:1S、2S、3S、4S、5S； 1-5准星级：1A、2A、3A、4A、5A
	NSString *hoteladdress;	//酒店地址
	NSString *hotelLongDesc;//酒店介绍
	NSString *hotelPor;		//地标位置
	NSString *hotelDistrict;//行政区
}

@property (nonatomic, copy) NSString *hotelCode;
@property (nonatomic, copy) NSString *hotelName;
@property (nonatomic, copy) NSString *hotelMinRate;
@property (nonatomic, copy) NSString *hotelImage;
@property (nonatomic, copy) NSString *hotelRank;
@property (nonatomic, copy) NSString *hotelAddress;
@property (nonatomic, copy) NSString *hotelLongDesc;
@property (nonatomic, copy) NSString *hotelPor;
@property (nonatomic, copy) NSString *hotelDistrict;

@end

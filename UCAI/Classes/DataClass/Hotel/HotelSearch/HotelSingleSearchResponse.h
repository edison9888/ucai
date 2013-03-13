//
//  HotelSingleSearchResponse.h
//  JingDuTianXia
//
//  Created by Piosa on 11-11-1.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HotelSingleSearchResponse : NSObject {
	NSString * _result_code;		// 返回结果编码:1-成功,0-失败
	NSString * _result_message;	// 返回结果信息
	
	NSString * _hotelName;		// 酒店名称
	NSString * _hotelCode;		// 酒店编码
	NSString * _hotelRank;		// 酒店星级
	NSString * _hotelAddress;	// 酒店地址
	NSString * _hotelOpenDate;	// 开业时间
	NSString * _hotelFitment;	// 装修时间
	NSString * _hotelTel;		// 酒店电话
	NSString * _hotelFax;		// 酒店传真
	NSString * _hotelRoomCount;	// 房间数量
	NSString * _hotelLongDesc;	// 酒店详细信息
	NSString * _hotelLongitude;	// 酒店经度
	NSString * _hotelLatitude;	// 酒店纬度
	NSString * _cityCode;		// 酒店所在城市编码
	NSString * _hotelVicinity;	// 酒店周围环境
	NSString * _hotelTraffic;	// 酒店周围交通
	NSString * _hotelPOR;		// 酒店地标位置
	NSString * _hotelSER;		// 酒店服务
	NSString * _hotelCAT;		// 酒店餐饮
	NSString * _hotelREC;		// 酒店休闲娱乐
	NSString * _hotelImage;		// 酒店图片
	NSString * _hotelDistrict;	// 酒店行政区
	
	NSMutableArray * _hotelRoomArray;		// 酒店房型列表
	
}

@property (nonatomic,copy) NSString *result_code;
@property (nonatomic,copy) NSString *result_message;

@property (nonatomic,copy) NSString * hotelName;
@property (nonatomic,copy) NSString * hotelCode;
@property (nonatomic,copy) NSString * hotelRank;
@property (nonatomic,copy) NSString * hotelAddress;
@property (nonatomic,copy) NSString * hotelOpenDate;
@property (nonatomic,copy) NSString * hotelFitment;
@property (nonatomic,copy) NSString * hotelTel;
@property (nonatomic,copy) NSString * hotelFax;
@property (nonatomic,copy) NSString * hotelRoomCount;
@property (nonatomic,copy) NSString * hotelLongDesc;
@property (nonatomic,copy) NSString * hotelLongitude;
@property (nonatomic,copy) NSString * hotelLatitude;
@property (nonatomic,copy) NSString * cityCode;
@property (nonatomic,copy) NSString * hotelVicinity;
@property (nonatomic,copy) NSString * hotelTraffic;
@property (nonatomic,copy) NSString * hotelPOR;
@property (nonatomic,copy) NSString * hotelSER;
@property (nonatomic,copy) NSString * hotelCAT;
@property (nonatomic,copy) NSString * hotelREC;
@property (nonatomic,copy) NSString * hotelImage;
@property (nonatomic,copy) NSString * hotelDistrict;

@property (nonatomic,retain) NSMutableArray * hotelRoomArray;



@end

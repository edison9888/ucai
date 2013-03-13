//
//  HotelListSearchResponse.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-20.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HotelListSearchResponse : NSObject {
	NSString *result_code;		// 返回结果编码:1-成功,0-失败
	NSString *result_message;	// 返回结果信息
	
	NSString *cityCode;			// 城市代码
	NSString *checkInDate;		// 入住日期:yyyy-MM-dd
	NSString *checkOutDate;		// 退房日期:yyyy-MM-dd
	
	NSString *totalPageNum;		// 总页数
	NSString *totalNum;			// 酒店总数
	NSString *curPage;		// 当前页
	
	NSMutableArray *hotelArray;	// 酒店列表
}

@property (nonatomic, copy) NSString *result_code;
@property (nonatomic, copy) NSString *result_message;

@property (nonatomic, copy) NSString *cityCode;
@property (nonatomic, copy) NSString *checkInDate;
@property (nonatomic, copy) NSString *checkOutDate;

@property (nonatomic, copy) NSString *totalPageNum;
@property (nonatomic, copy) NSString *totalNum;
@property (nonatomic, copy) NSString *curPage;

@property (nonatomic, retain) NSMutableArray *hotelArray;

@end

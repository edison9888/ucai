//
//  HotelBookResponse.h
//  JingDuTianXia
//
//  Created by Piosa on 11-11-22.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HotelBookResponse : NSObject {
	NSString * _result_code;	// 返回结果编码:1-成功,0-失败
	NSString * _result_message;	// 返回结果信息
	
	NSString * _orderNo;		// 订单编号
	NSString * _amount;			// 金额
	NSString * _inDate;			// 入住日期, yyyyMMdd
	NSString * _outDate;		// 离店日期, yyyyMMdd
	NSString * _earlyTime;		// 最早到店时间,HHmm
	NSString * _lateTime;		// 最晚到店时间,HHmm
	NSString * _hotelName;		// 酒店名称
	NSString * _roomName;		// 房型名称
	NSString * _roomNum;		// 房间数量
	NSString * _linkman;		// 联系人姓名
	NSString * _linkTel;		// 联系人电话
	NSString * _mobile;			// 联系人手机
	NSString * _email;			// 联系人邮箱
}

@property(nonatomic,retain) NSString * result_code;
@property(nonatomic,retain) NSString * result_message;

@property(nonatomic,retain) NSString * orderNo;
@property(nonatomic,retain) NSString * amount;
@property(nonatomic,retain) NSString * inDate;
@property(nonatomic,retain) NSString * outDate;
@property(nonatomic,retain) NSString * earlyTime;
@property(nonatomic,retain) NSString * lateTime;
@property(nonatomic,retain) NSString * hotelName;
@property(nonatomic,retain) NSString * roomName;
@property(nonatomic,retain) NSString * roomNum;
@property(nonatomic,retain) NSString * linkman;
@property(nonatomic,retain) NSString * linkTel;
@property(nonatomic,retain) NSString * mobile;
@property(nonatomic,retain) NSString * email;

@end

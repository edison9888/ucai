//
//  HotelBookResponse.m
//  JingDuTianXia
//
//  Created by Piosa on 11-11-22.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "HotelBookResponse.h"


@implementation HotelBookResponse

@synthesize result_code = _result_code;
@synthesize result_message = _result_message;

@synthesize orderNo = _orderNo;
@synthesize amount = _amount;
@synthesize inDate = _inDate;
@synthesize outDate = _outDate;
@synthesize earlyTime = _earlyTime;
@synthesize lateTime = _lateTime;
@synthesize hotelName = _hotelName;
@synthesize roomName = _roomName;
@synthesize roomNum = _roomNum;
@synthesize linkman = _linkman;
@synthesize linkTel = _linkTel;
@synthesize mobile = _mobile;
@synthesize email = _email;

-(void) dealloc {
	[_result_code release];
	[_result_message release];	
	[_orderNo release];
	[_amount release];
	[_inDate release];
	[_outDate release];
	[_earlyTime release];
	[_lateTime release];
	[_hotelName release];
	[_roomName release];
	[_roomNum release];
	[_linkman release];
	[_linkTel release];
	[_mobile release];
	[_email release];
	[super dealloc];
}

@end

//
//  HotelRoomInfo.m
//  JingDuTianXia
//
//  Created by Piosa on 11-11-3.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "HotelRoomInfo.h"


@implementation HotelRoomInfo

@synthesize roomTypeName = _roomTypeName;
@synthesize roomTypeCode = _roomTypeCode;
@synthesize roomBedType = _roomBedType;
@synthesize roomVendorCode = _roomVendorCode;
@synthesize roomDescription = _roomDescription;
@synthesize roomInternet = _roomInternet;
@synthesize roomTotalPrice = _roomTotalPrice;	
@synthesize roomPayment = _roomPayment;
@synthesize roomRatePlanCode = _roomRatePlanCode;
@synthesize roomAmountPrice = _roomAmountPrice;
@synthesize roomDisplayPrice = _roomDisplayPrice;
@synthesize roomFreeMealCount = _roomFreeMealCount;

- (void) dealloc{
	
	[_roomTypeName release];
	[_roomTypeCode release];
	[_roomBedType release];
	[_roomVendorCode release];
	[_roomDescription release];
	[_roomInternet release];
	[_roomTotalPrice release];	
	[_roomPayment release];
	[_roomRatePlanCode release];
	[_roomAmountPrice release];
	[_roomDisplayPrice release];
	[_roomFreeMealCount release];
	
	[super dealloc];
}

@end

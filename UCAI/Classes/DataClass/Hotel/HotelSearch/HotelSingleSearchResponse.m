//
//  HotelSingleSearchResponse.m
//  JingDuTianXia
//
//  Created by Piosa on 11-11-1.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "HotelSingleSearchResponse.h"


@implementation HotelSingleSearchResponse

@synthesize result_code = _result_code;
@synthesize result_message = _result_message;

@synthesize hotelName = _hotelName;
@synthesize hotelCode = _hotelCode;
@synthesize hotelRank = _hotelRank;
@synthesize hotelAddress = _hotelAddress;
@synthesize hotelOpenDate = _hotelOpenDate;
@synthesize hotelFitment = _hotelFitment;
@synthesize hotelTel = _hotelTel;
@synthesize hotelFax = _hotelFax;
@synthesize hotelRoomCount = _hotelRoomCount;
@synthesize hotelLongDesc = _hotelLongDesc;
@synthesize hotelLongitude = _hotelLongitude;
@synthesize hotelLatitude = _hotelLatitude;
@synthesize cityCode = _cityCode;
@synthesize hotelVicinity = _hotelVicinity;
@synthesize hotelTraffic = _hotelTraffic;
@synthesize hotelPOR = _hotelPOR;
@synthesize hotelSER = _hotelSER;
@synthesize hotelCAT = _hotelCAT;
@synthesize hotelREC = _hotelREC;
@synthesize hotelImage = _hotelImage;
@synthesize hotelDistrict = _hotelDistrict;
@synthesize hotelRoomArray = _hotelRoomArray;

- (void)dealloc{
	[_result_code release];
	[_result_message release];
	
	[_hotelName release];
	[_hotelCode release];
	[_hotelRank release];
	[_hotelAddress release];
	[_hotelOpenDate release];
	[_hotelFitment release];
	[_hotelTel release];
	[_hotelFax release];
	[_hotelRoomCount release];
	[_hotelLongDesc release];
	[_hotelLongitude release];
	[_hotelLatitude release];
	[_cityCode release];
	[_hotelVicinity release];
	[_hotelTraffic release];
	[_hotelPOR release];
	[_hotelSER release];
	[_hotelCAT release];
	[_hotelREC release];
	[_hotelImage release];
	[_hotelDistrict release];
	
	[_hotelRoomArray release];
	
	[super dealloc];
}

@end

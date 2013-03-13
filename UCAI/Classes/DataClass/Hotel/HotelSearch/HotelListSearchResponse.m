//
//  HotelListSearchResponse.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-20.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "HotelListSearchResponse.h"


@implementation HotelListSearchResponse

@synthesize result_code;
@synthesize result_message;

@synthesize cityCode;
@synthesize checkInDate;
@synthesize checkOutDate;

@synthesize totalPageNum;
@synthesize totalNum;
@synthesize curPage;

@synthesize hotelArray;

- (void) dealloc{
	[self.result_code release];
	[self.result_message release];
	
	[self.cityCode release];
	[self.checkInDate release];
	[self.checkOutDate release];
	
	[self.totalPageNum release];
	[self.totalNum release];
	[self.curPage release];
	
	[super dealloc];
}

@end

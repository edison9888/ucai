//
//  HotelListInfo.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-20.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "HotelListInfo.h"


@implementation HotelListInfo

@synthesize hotelCode;
@synthesize hotelName;
@synthesize hotelMinRate;
@synthesize hotelImage;
@synthesize hotelRank;
@synthesize hotelAddress;
@synthesize hotelLongDesc;
@synthesize hotelPor;
@synthesize hotelDistrict;

- (void)dealloc{
	
	[self.hotelCode release];
	[self.hotelName release];
	[self.hotelMinRate release];
	[self.hotelImage release];
	[self.hotelRank release];
	[self.hotelAddress release];
	[self.hotelLongDesc release];
	[self.hotelPor release];
	[self.hotelDistrict release];
	
	[super dealloc];
}

@end

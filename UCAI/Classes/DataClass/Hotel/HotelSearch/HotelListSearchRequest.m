//
//  HotelListSearchRequest.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-27.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "HotelListSearchRequest.h"


@implementation HotelListSearchRequest

@synthesize hotelCheckInDate;		
@synthesize hotelCheckOutDate;		
@synthesize hotelCityCode;			
@synthesize hotelName;		
@synthesize hotelDistrict;			
@synthesize hotelRank;			
@synthesize hotelMaxRate;			
@synthesize hotelMinRate;			
@synthesize hotelPageNo;			
@synthesize hotelOrderBy;	


- (void)dealloc {
    [super dealloc];
}


@end

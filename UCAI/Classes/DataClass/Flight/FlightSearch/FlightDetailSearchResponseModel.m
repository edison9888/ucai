//
//  FlightDetailSearchResponseModel.m
//  UCAI
//
//  Created by  on 12-1-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FlightDetailSearchResponseModel.h"

@implementation FlightClassSeat

@synthesize price;
@synthesize rebate;
@synthesize classType;
@synthesize classCode;
@synthesize status;
@synthesize scgd;
@synthesize tpgd;
@synthesize qzgd;
@synthesize bz;
@synthesize ucaiPrice;
@synthesize save;

- (void)dealloc
{
	self.price = nil;
	self.rebate = nil;
	self.classType = nil;
	self.classCode = nil;
	self.status = nil;
	self.scgd = nil;
	self.tpgd = nil;
	self.qzgd = nil;
	self.bz = nil;
	self.ucaiPrice = nil;
	self.save = nil;
	[super dealloc];
}

@end

@implementation FlightDetailSearchResponseModel

@synthesize resultCode = _resultCode;	
@synthesize resultMessage = _resultMessage;

@synthesize flightID;
@synthesize flightCode;
@synthesize companyCode;
@synthesize companyName;
@synthesize fromTime;
@synthesize toTime;
@synthesize fromAirportCode;
@synthesize fromAirportName;
@synthesize toAirportCode;
@synthesize toAirportName;
@synthesize plantype;
@synthesize stopNum;
@synthesize meal;
@synthesize tax;
@synthesize airTax;
@synthesize yPrice;
@synthesize eTicket;
@synthesize classSeats;

- (void)dealloc
{
	self.resultCode = nil;	
	self.resultMessage = nil;
	self.flightID = nil;
	self.flightCode = nil;
	self.companyCode = nil;
	self.companyName = nil;
	self.fromTime = nil;
	self.toTime = nil;
	self.fromAirportCode = nil;
	self.fromAirportName = nil;
	self.toAirportCode = nil;
	self.toAirportName = nil;
	self.plantype = nil;
	self.stopNum = nil;
	self.meal = nil;
	self.tax = nil;
	self.airTax = nil;
	self.yPrice = nil;
	self.eTicket = nil;
	self.classSeats = nil;
	[super dealloc];
}

@end

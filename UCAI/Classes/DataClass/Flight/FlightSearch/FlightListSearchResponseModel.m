//
//  FlightListSearchResponseModel.m
//  UCAI
//
//  Created by  on 12-1-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FlightListSearchResponseModel.h"

@implementation CheapestFlight

@synthesize classCode = _classCode;
@synthesize classType = _classType;
@synthesize status = _status;
@synthesize price = _price;
@synthesize rebate = _rebate;
@synthesize scgd = _scgd;
@synthesize tpgd = _tpgd;
@synthesize qzgd = _qzgd;
@synthesize bz = _bz;
@synthesize ucaiPrice = _ucaiPrice;
@synthesize save = _save;

- (void)dealloc
{
	self.classCode = nil;
	self.classType = nil;
	self.status = nil;
	self.price = nil;
	self.rebate = nil;
	self.scgd = nil;
	self.tpgd = nil;
	self.qzgd = nil;
	self.bz = nil;
	self.ucaiPrice = nil;
	self.save = nil;
	[super dealloc];
}

@end

@implementation FLightListInfoModel

@synthesize flightID = _flightID;
@synthesize flightCode = _flightCode;
@synthesize companyCode = _companyCode;
@synthesize companyName = _companyName;
@synthesize fromTime = _fromTime;
@synthesize toTime = _toTime;
@synthesize fromAirportCode = _fromAirportCode;
@synthesize fromAirportName = _fromAirportName;
@synthesize toAirportCode = _toAirportCode;
@synthesize toAirportName = _toAirportName;
@synthesize plantype = _plantype;
@synthesize stopNum = _stopNum;
@synthesize meal = _meal;
@synthesize tax = _tax;
@synthesize airTax = _airTax;
@synthesize yPrice = _yPrice;
@synthesize eTicket = _eTicket;
@synthesize cheapest = _cheapest;

- (void)dealloc
{
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
	self.cheapest = nil;
	[super dealloc];
}
@end


@implementation FlightListSearchResponseModel

@synthesize resultCode = _resultCode;	
@synthesize resultMessage = _resultMessage;
@synthesize currentPage = _currentPage;
@synthesize pageSize = _pageSize;
@synthesize count = _count;
@synthesize flights = _flights;

- (void)dealloc
{
	self.resultCode = nil;	
	self.resultMessage = nil;
	self.currentPage = nil;
	self.pageSize = nil;
	self.count = nil;
	self.flights = nil;
	[super dealloc];
}

@end

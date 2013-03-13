//
//  FlightOrderInfoSearchResponseModel.m
//  UCAI
//
//  Created by  on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FlightOrderInfoSearchResponseModel.h"

@implementation FlightOrderCustomerInfo

@synthesize name = _name;
@synthesize certificateNo = _certificateNo;
@synthesize type = _type;

- (void)dealloc
{
	[self.name release];
	[self.certificateNo release];
	[self.type release];
	[super dealloc];
}

@end

@implementation FlightOrderFlightingInfo

@synthesize dptCode = _dptCode;
@synthesize dptName = _dptName;
@synthesize arrCode = _arrCode;
@synthesize arrName = _arrName;
@synthesize fromDate = _fromDate;
@synthesize fromTime = _fromTime;
@synthesize toTime = _toTime;
@synthesize companyCode = _companyCode;
@synthesize companyName = _companyName;
@synthesize flightNo = _flightNo;
@synthesize classCode = _classCode;
@synthesize flightType = _flightType;
@synthesize price = _price;
@synthesize tax = _tax;
@synthesize airTax = _airTax;

- (void)dealloc
{
	[self.dptCode release];
	[self.dptName release];
	[self.arrCode release];
	[self.arrName release];
	[self.fromDate release];
	[self.fromTime release];
	[self.toTime release];
	[self.companyCode release];
	[self.companyName release];
	[self.flightNo release];
	[self.classCode release];
	[self.flightType release];
	[self.price release];
	[self.tax release];
	[self.airTax release];
    
	[super dealloc];
}

@end

@implementation FlightOrderInfoSearchResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;
@synthesize orderTime = _orderTime;
@synthesize orderPayStatus = _orderPayStatus;
@synthesize orderPayPrice = _orderPayPrice;
@synthesize linkmanName = _linkmanName;
@synthesize linkmanMobile = _linkmanMobile;
@synthesize linkmanEmail = _linkmanEmail;
@synthesize customers = _customers;
@synthesize flights = _flights;

- (void)dealloc
{
    [self.resultCode release];
    [self.resultMessage release];
	[self.orderTime release];
	[self.orderPayStatus release];
	[self.orderPayPrice release];
	[self.linkmanName release];
	[self.linkmanMobile release];
	[self.linkmanEmail release];
	[self.customers release];
	[self.flights release];
	[super dealloc];
}

@end

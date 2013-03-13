//
//  FlightOrderListInfoModel.m
//  UCAI
//
//  Created by  on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FlightOrderListInfoModel.h"

@implementation FlightOrderListInfoModel

@synthesize orderID = _orderID;
@synthesize orderStatus = _orderStatus;
@synthesize orderTime = _orderTime;
@synthesize orderPrice = _orderPrice;
@synthesize orderType = _orderType;
@synthesize fromCity = _fromCity;
@synthesize toCity = _toCity;

- (void)dealloc
{
	[self.orderID release];
	[self.orderStatus release];
	[self.orderTime release];
	[self.orderPrice release];
    [self.orderType release];
    [self.fromCity release];
    [self.toCity release];
	[super dealloc];
}

@end

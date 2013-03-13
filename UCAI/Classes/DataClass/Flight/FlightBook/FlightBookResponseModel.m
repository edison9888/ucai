//
//  FlightBookResponseModel.m
//  UCAI
//
//  Created by  on 12-2-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FlightBookResponseModel.h"

@implementation FlightBookResponseModel

@synthesize resultCode;
@synthesize resultMessage;
@synthesize orderNo;
@synthesize orderTime;
@synthesize orderPrice;

- (void)dealloc
{
	self.resultCode = nil;
	self.resultMessage = nil;
	self.orderNo = nil;
	self.orderTime = nil;
	self.orderPrice = nil;
	[super dealloc];
}

@end

//
//  FlightReserveResponseModel.m
//  UCAI
//
//  Created by  on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FlightReserveResponseModel.h"

@implementation FlightReserveResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;

- (void)dealloc
{
	[self.resultCode release];
	[self.resultMessage release];
	[super dealloc];
}

@end

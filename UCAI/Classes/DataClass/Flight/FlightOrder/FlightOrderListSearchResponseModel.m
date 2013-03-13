//
//  FlightOrderListSearchResponseModel.m
//  UCAI
//
//  Created by  on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FlightOrderListSearchResponseModel.h"

@implementation FlightOrderListSearchResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;
@synthesize orders = _orders;

@synthesize currentPage = _currentPage;
@synthesize pageSize = _pageSize;
@synthesize count = _count;

- (void)dealloc
{
	[self.resultCode release];
	[self.resultMessage release];
	[self.orders release];
    
    [self.currentPage release];
    [self.pageSize release];
    [self.count release];
	[super dealloc];
}


@end

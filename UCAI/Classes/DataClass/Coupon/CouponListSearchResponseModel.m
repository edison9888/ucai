//
//  CouponListSearchResponseModel.m
//  UCAI
//
//  Created by  on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CouponListSearchResponseModel.h"

@implementation CouponListSearchResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;
@synthesize couponArray = _couponArray;

@synthesize currentPage = _currentPage;
@synthesize pageSize = _pageSize;
@synthesize count = _count;

- (void)dealloc
{
	[self.resultCode release];
	[self.resultMessage release];
	[self.couponArray release];
    
    [self.currentPage release];
    [self.pageSize release];
    [self.count release];
	[super dealloc];
}

@end

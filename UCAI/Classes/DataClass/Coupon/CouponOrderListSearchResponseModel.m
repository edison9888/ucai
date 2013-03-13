//
//  CouponOrderListSearchResponseModel.m
//  UCAI
//
//  Created by  on 11-12-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CouponOrderListSearchResponseModel.h"

@implementation CouponOrderListInfoModel

@synthesize orderID = _orderID;
@synthesize couponName = _couponName;
@synthesize couponPrice = _couponPrice;
@synthesize couponAmount = _couponAmount;
@synthesize payPrice = _payPrice;
@synthesize isPay = _isPay;

- (void)dealloc{
    [_orderID release];
    [_couponName release];
    [_couponPrice release];
    [_couponAmount release];
    [_payPrice release];
    [_isPay release];
    [super dealloc];
}

@end

@implementation CouponOrderListSearchResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;
@synthesize couponOrderArray = _couponOrderArray;
@synthesize currentPage = _currentPage;
@synthesize pageSize = _pageSize;
@synthesize count = _count;

- (void)dealloc
{
	[self.resultCode release];
	[self.resultMessage release];
	[self.couponOrderArray release];
    [self.currentPage release];
    [self.pageSize release];
    [self.count release];
	[super dealloc];
}

@end

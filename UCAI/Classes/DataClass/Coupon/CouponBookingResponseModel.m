//
//  CouponBookingResponseModel.m
//  UCAI
//
//  Created by  on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CouponBookingResponseModel.h"

@implementation CouponBookingResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;

@synthesize orderID = _orderID;      // 订单号
@synthesize payPrice = _payPrice;   // 订单应付金额

- (void)dealloc
{
	[self.resultCode release];
	[self.resultMessage release];
    
    [self.orderID release];
	[self.payPrice release];
    
    [super dealloc];
}

@end

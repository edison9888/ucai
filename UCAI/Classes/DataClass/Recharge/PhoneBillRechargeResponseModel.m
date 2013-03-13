//
//  PhoneBillRechargeResponseModel.m
//  UCAI
//
//  Created by  on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PhoneBillRechargeResponseModel.h"

@implementation PhoneBillRechargeResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;

@synthesize orderID = _orderID;
@synthesize orderCharge = _orderCharge;
@synthesize cardType = _cardType;
@synthesize cardAttribution = _cardAttribution;

- (void)dealloc
{
	[self.resultCode release];
	[self.resultMessage release];
    
    [self.orderID release];
	[self.orderCharge release];
    [self.cardType release];
	[self.cardAttribution release];
    
    [super dealloc];
}

@end

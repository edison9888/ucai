//
//  CouponOrderInfoSearchResponseModel.m
//  UCAI
//
//  Created by  on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CouponOrderInfoSearchResponseModel.h"

@implementation CouponInfo

@synthesize couponNO = _couponNO;
@synthesize status = _status;

- (void)dealloc{
    [self.couponNO release];
    [self.status release];
    [super dealloc];
}

@end

@implementation CouponOrderInfoSearchResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;

@synthesize orderID = _orderID;
@synthesize couponName = _couponName;
@synthesize typeID = _typeID;
@synthesize typeName = _typeName;
@synthesize price = _price;
@synthesize couponPrice = _couponPrice;
@synthesize couponAmount = _couponAmount;
@synthesize payPrice = _payPrice;
@synthesize isPay = _isPay;
@synthesize expirationTime = _expirationTime;

@synthesize couponArray = _couponArray;

@synthesize businessName = _businessName;
@synthesize businessTel = _businessTel;
@synthesize businessAddress = _businessAddress;

- (void)dealloc {
    [self.resultCode release];
    [self.resultMessage release];
    
    [self.orderID release];
    [self.couponName release];
    [self.typeID release];
    [self.typeName release];
    [self.price release];
    [self.couponPrice release];
    [self.couponAmount release];
    [self.payPrice release];
    [self.isPay release];
    [self.expirationTime release];
    
    [self.couponArray release];
    
    [self.businessName release];
    [self.businessTel release];
    [self.businessAddress release];
    [super dealloc];
}

@end

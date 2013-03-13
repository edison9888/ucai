//
//  CouponInfoSearchResponseModel.m
//  UCAI
//
//  Created by  on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CouponInfoSearchResponseModel.h"

@implementation CouponInfoSearchResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;

@synthesize couponID = _couponID;
@synthesize couponName = couponName;
@synthesize couponType = _couponType;
@synthesize couponPrice = _couponPrice;
@synthesize couponEndTime = _couponEndTime; 
@synthesize couponSellPrice = _couponSellPrice;
@synthesize couponPopularity = _couponPopularity;
@synthesize couponImage = _couponImage;

@synthesize couponPeriod;
@synthesize couponCondition;
@synthesize couponMethod;
@synthesize couponDetail;

@synthesize businessName = _businessName;
@synthesize cityName = _cityName;
@synthesize businessWebsite = _businessWebsite;
@synthesize businessTel = _businessTel;
@synthesize businessContact = _businessContact;
@synthesize businessAddress = _businessAddress;



- (void)dealloc
{
	[self.resultCode release];
	[self.resultMessage release];
    
    [self.couponID release];
	[self.couponName release];
	[self.couponType release];
    [self.couponPrice release];
    [self.couponEndTime release];
    [self.couponSellPrice release];
    [self.couponPopularity release];
    [self.couponImage release];
    
    [self.couponPeriod release];
    [self.couponCondition release];
    [self.couponMethod release];
    [self.couponDetail release];
    
    [self.businessName release];
    [self.cityName release];
    [self.businessWebsite release];
    [self.businessTel release];
    [self.businessContact release];
    [self.businessAddress release];
    
    [super dealloc];
}

@end

//
//  CouponListInfoModel.m
//  UCAI
//
//  Created by  on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CouponListInfoModel.h"

@implementation CouponListInfoModel

@synthesize couponID = _couponID;
@synthesize couponName = couponName;
@synthesize couponType = _couponType;
@synthesize couponPrice = _couponPrice;
@synthesize couponEndTime = _couponEndTime; 
@synthesize couponSellPrice = _couponSellPrice;
@synthesize couponPopularity = _couponPopularity;
@synthesize couponImage = _couponImage;

- (void)dealloc
{
	[self.couponID release];
	[self.couponName release];
	[self.couponType release];
    [self.couponPrice release];
    [self.couponEndTime release];
    [self.couponSellPrice release];
    [self.couponPopularity release];
    [self.couponImage release];
	[super dealloc];
}

@end

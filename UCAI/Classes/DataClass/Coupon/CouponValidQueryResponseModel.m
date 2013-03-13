//
//  CouponValidQueryResponseModel.m
//  UCAI
//
//  Created by  on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CouponValidQueryResponseModel.h"

@implementation ValidCoupon

@synthesize couponId = _couponId;
@synthesize couponName = _couponName;
@synthesize couponPrice = _couponPrice;
@synthesize couponNO = _couponNO;

- (void)dealloc {
    [self.couponId release];
    [self.couponName release];
    [self.couponPrice release];
    [self.couponNO release];
}

@end

@implementation CouponValidQueryResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;
@synthesize validCouponArray = _validCouponArray;
@synthesize currentPage = _currentPage;
@synthesize pageSize = _pageSize;
@synthesize count = _count;

- (void)dealloc {
    [self.resultCode release];
    [self.resultMessage release];
    [self.validCouponArray release];
    [self.currentPage release];
    [self.pageSize release];
    [self.count release];
}

@end

//
//  CouponSendResponseModel.m
//  UCAI
//
//  Created by  on 11-12-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CouponSendResponseModel.h"

@implementation CouponSendResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;

@synthesize remainingCount = _remainingCount;

- (void)dealloc {
    [self.resultCode release];
    [self.resultMessage release];
    
    [self.remainingCount release];
}

@end

//
//  HotelOrderListInfoModel.m
//  JingDuTianXia
//
//  Created by  on 11-11-30.
//  Copyright (c) 2011年 __JingDuTianXia__. All rights reserved.
//

#import "HotelOrderListInfoModel.h"

@implementation HotelOrderListInfoModel

@synthesize orderId = _orderId;       
@synthesize tpsOrderId = _tpsOrderId;    
@synthesize hotelName = _hotelName;
@synthesize amount = _amount;
@synthesize resStatus = _resStatus;
@synthesize payStatus = _payStatus;
@synthesize bookTime = _bookTime;

- (void) dealloc{
    [self.orderId release];
    [self.tpsOrderId release];
    [self.hotelName release];
    [self.amount release];
    [self.resStatus release];
    [self.payStatus release];
    [self.bookTime release];
    [super dealloc];   
}

@end

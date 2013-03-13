//
//  FlightCustomer.m
//  UCAI
//
//  Created by  on 12-1-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FlightCustomer.h"

@implementation FlightCustomer

@synthesize customerName = _customerName;
@synthesize customerType = _customerType;
@synthesize certificateType = _certificateType;
@synthesize certificateNo = _certificateNo;
@synthesize secureNum = _secureNum;

- (void)dealloc{
    [self.customerName release];
    [self.customerType release];
    [self.certificateType release];
    [self.certificateNo release];
    [self.secureNum release];
    [super dealloc];
}

@end

//
//  MemberFlightHistoryCustomerQueryResponse.m
//  UCAI
//
//  Created by  on 12-2-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MemberFlightHistoryCustomerQueryResponse.h"

@implementation FlightHistoryCustomer

@synthesize customerID = _customerID;
@synthesize customerName = _customerName;
@synthesize customerType = _customerType;
@synthesize certificateType = _certificateType;
@synthesize certificateNo = _certificateNo;
@synthesize secureNum = _secureNum;

- (void)dealloc{
    [self.customerID release];
    [self.customerName release];
    [self.customerType release];
    [self.certificateType release];
    [self.certificateNo release];
    [self.secureNum release];
    [super dealloc];
}

@end

@implementation MemberFlightHistoryCustomerQueryResponse

@synthesize resultCode = _resultCode; 
@synthesize resultMessage = _resultMessage;
@synthesize historyCustomers = _historyCustomers;

- (void)dealloc{
    [self.resultCode release];
    [self.resultMessage release];
    [self.historyCustomers release];
    [super dealloc];
}

@end

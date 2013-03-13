//
//  MemberFlightHistoryCustomerDeleteResponse.m
//  UCAI
//
//  Created by  on 12-2-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MemberFlightHistoryCustomerDeleteResponse.h"

@implementation MemberFlightHistoryCustomerDeleteResponse

@synthesize resultCode = _resultCode; 
@synthesize resultMessage = _resultMessage;

- (void)dealloc{
    [self.resultCode release];
    [self.resultMessage release];
    [super dealloc];
}

@end

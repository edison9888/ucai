//
//  MemberInfoQueryResponse.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-11.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "MemberInfoQueryResponse.h"


@implementation MemberInfoQueryResponse

@synthesize result_code;	
@synthesize result_message;

@synthesize registerName;
@synthesize cardNO;
@synthesize realName;
@synthesize sex;
@synthesize phone;
@synthesize phoneVerifyStatus;
@synthesize eMail;
@synthesize contactTel;
@synthesize idNumber;
@synthesize rapeseedAmount;
@synthesize exchangeRapeseedAmount;

- (void)dealloc{
	[self.result_code release];
	[self.result_message release];
	
	[self.registerName release];
	[self.cardNO release];
	[self.realName release];
	[self.sex release];
	[self.phone release];
	[self.phoneVerifyStatus release];
	[self.eMail release];
	[self.contactTel release];
	[self.idNumber release];
	[self.rapeseedAmount release];
	[self.exchangeRapeseedAmount release];
	[super dealloc];
}

@end

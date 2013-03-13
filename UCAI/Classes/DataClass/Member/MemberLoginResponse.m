//
//  MemberLoginResponse.m
//  JingDuTianXia
//
//  Created by admin on 11-9-26.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "MemberLoginResponse.h"


@implementation MemberLoginResponse

@synthesize result_code;	
@synthesize result_message;
@synthesize memberID;
@synthesize registerName;
@synthesize cardNO;
@synthesize realName;
@synthesize sex;
@synthesize phone;
@synthesize phoneVerifyStatus;
@synthesize eMail;
@synthesize contactTel;
@synthesize contactAddress;
@synthesize idNumber;
@synthesize accPoints;
@synthesize usablePoints;
@synthesize eCardNO;
@synthesize eCardUserName;
@synthesize eCardStatus;

- (void)dealloc
{
	result_code = nil;	
	result_message = nil;
	memberID = nil;
	registerName = nil;
	cardNO = nil;
	realName = nil;
	sex = nil;
	phone = nil;
	phoneVerifyStatus = nil;
	eMail = nil;
	contactTel = nil;
	contactAddress = nil;
	idNumber = nil;
	accPoints = nil;
	usablePoints = nil;
	eCardNO = nil;
	eCardUserName = nil;
	eCardStatus = nil;
	
	[super dealloc];
}


@end

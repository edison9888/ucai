//
//  MemberRegisterResponse.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-8.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "MemberRegisterResponse.h"


@implementation MemberRegisterResponse

@synthesize result_code;	
@synthesize result_message;
@synthesize memberName;
@synthesize memberID;
@synthesize cardNO;

- (void)dealloc
{
	result_code = nil;	
	result_message = nil;
	
	memberName = nil;
	memberID = nil;
	cardNO = nil;
		
	[super dealloc];
}


@end

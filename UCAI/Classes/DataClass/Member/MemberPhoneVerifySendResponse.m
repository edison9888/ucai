//
//  MemberPhoneVerifySendResponse.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-15.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "MemberPhoneVerifySendResponse.h"


@implementation MemberPhoneVerifySendResponse

@synthesize result_code;	
@synthesize result_message;

@synthesize loseEffTime;

- (void)dealloc{
	[self.result_code release];
	[self.result_message release];
	
	[self.loseEffTime release];
	[super dealloc];
}

@end

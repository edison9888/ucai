//
//  MemberPasswordModifyResponse.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-17.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "MemberPasswordModifyResponse.h"


@implementation MemberPasswordModifyResponse

@synthesize result_code;	
@synthesize result_message;

- (void)dealloc{
	[self.result_code release];
	[self.result_message release];
	[super dealloc];
}

@end

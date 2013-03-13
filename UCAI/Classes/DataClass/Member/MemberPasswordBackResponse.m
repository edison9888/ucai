//
//  MemberPasswordBackResponse.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-9.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "MemberPasswordBackResponse.h"


@implementation MemberPasswordBackResponse

@synthesize result_code;	
@synthesize result_message;

- (void)dealloc{
	[self.result_code release];
	[self.result_message release];
	[super dealloc];
}
@end

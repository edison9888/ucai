//
//  MemberInfoModifyResponse.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-17.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "MemberInfoModifyResponse.h"


@implementation MemberInfoModifyResponse

@synthesize result_code;	
@synthesize result_message;

@synthesize realName;					
@synthesize sex;						
@synthesize phone;					
@synthesize eMail;					
@synthesize contactTel;				
@synthesize idNumber;					
@synthesize rapeseedAmount;			
@synthesize exchangeRapeseedAmount;	

- (void)dealloc{
	[self.result_code release];
	[self.result_message release];
	
	[self.realName release];
	[self.sex release];
	[self.phone release];
	[self.eMail release];
	[self.contactTel release];
	[self.idNumber release];
	[self.rapeseedAmount release];
	[self.exchangeRapeseedAmount release];
}

@end

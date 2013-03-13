//
//  AllinTelPayResponseModel.m
//  UCAI
//
//  Created by  on 11-12-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AllinTelPayResponseModel.h"

@implementation AllinTelPayResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;

@synthesize allinID = _allinID;
@synthesize allinCreatetime = _allinCreatetime;

- (void)dealloc
{
	[self.resultCode release];
	[self.resultMessage release];
    
    [self.allinID release];
	[self.allinCreatetime release];
    
    [super dealloc];
}

@end

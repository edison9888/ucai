//
//  FeedbackCommitResponseModel.m
//  UCAI
//
//  Created by  on 12-1-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedbackCommitResponseModel.h"

@implementation FeedbackCommitResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;

- (void)dealloc
{
	[self.resultCode release];
	[self.resultMessage release];
    [super dealloc];
}

@end

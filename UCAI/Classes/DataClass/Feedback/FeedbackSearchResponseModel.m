//
//  FeedbackSearchResponseModel.m
//  UCAI
//
//  Created by  on 12-1-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedbackSearchResponseModel.h"

@implementation FeedbackSuggestion

@synthesize suggestionType = _suggestionType;
@synthesize suggestionCommitContent = _suggestionCommitContent;
@synthesize suggestionCommitTime = _suggestionCommitTime;
@synthesize suggestionReplyContent = _suggestionReplyContent;

-(void)dealloc{
    [self.suggestionType release];
    [self.suggestionCommitContent release];
    [self.suggestionCommitTime release];
    [self.suggestionReplyContent release];
    [super dealloc];
}

@end


@implementation FeedbackSearchResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;
@synthesize suggestions = _suggestions;
@synthesize currentPage = _currentPage;
@synthesize pageSize = _pageSize;
@synthesize count = _count;

- (void)dealloc
{
	[self.resultCode release];
	[self.resultMessage release];
    [self.suggestions release];
    [self.currentPage release];
    [self.pageSize release];
    [self.count release];
	[super dealloc];
}


@end

//
//  TrainSearchResponseModel.m
//  UCAI
//
//  Created by  on 12-1-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TrainSearchResponseModel.h"

@implementation TrainData

@synthesize ID;	
@synthesize TrainCode;
@synthesize TrainType;
@synthesize StartCity;
@synthesize StartTime;
@synthesize EndCity;
@synthesize EndTime;
@synthesize Distance;
@synthesize CostTime;
@synthesize YZ;
@synthesize RZ;
@synthesize RZ1;
@synthesize RZ2;
@synthesize YWS;
@synthesize YWZ;
@synthesize YWX;
@synthesize RWS;
@synthesize RWX;
@synthesize GWS;
@synthesize GWX;

- (void) dealloc 
{
	self.ID = nil;
	self.TrainCode = nil;
	self.TrainType = nil;
	self.StartCity = nil;
	self.StartTime = nil;
	self.EndCity = nil;
	self.EndTime = nil;
	self.Distance = nil;
	self.CostTime = nil;
	self.YZ = nil;
	self.RZ = nil;
	self.RZ1 = nil;
	self.RZ2 = nil;
	self.YWS = nil;
	self.YWZ = nil;
	self.YWX = nil;
	self.RWS = nil;
	self.RWX = nil;
	self.GWS = nil;
	self.GWX = nil;
	[super dealloc];
}
@end


@implementation TrainSearchResponseModel

@synthesize sDate = _sDate;
@synthesize sType = _sType;
@synthesize searchCode = _searchCode;
@synthesize errInfo = _errInfo;
@synthesize iCount = _iCount;
@synthesize data = _data;

- (void)dealloc {
    [self.sDate release];
    [self.sType release];
    [self.searchCode release];
    [self.errInfo release];
    [self.iCount release];
    [self.data release];
    [super dealloc];
}


@end

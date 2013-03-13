//
//  HotelGuest.m
//  JingDuTianXia
//
//  Created by Piosa on 11-11-15.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "HotelGuest.h"


@implementation HotelGuest

@synthesize guestName = _guestName;
@synthesize guestPhone = _guestPhone;

- (NSString *)toCommitString{
	return [NSString stringWithFormat:@"%@/%@",self.guestName,self.guestPhone];
}

- (void) dealloc {
	[_guestName release];
	[_guestPhone release];
	
	[super dealloc];
}

@end

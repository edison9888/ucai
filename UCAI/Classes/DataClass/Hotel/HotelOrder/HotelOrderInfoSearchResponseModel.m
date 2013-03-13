//
//  HotelOrderInfoSearchResponseModel.m
//  UCAI
//
//  Created by  on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HotelOrderInfoSearchResponseModel.h"

@implementation HotelOrderInfoSearchResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;

@synthesize amount = _amount;
@synthesize hotelName = _hotelName;
@synthesize bookingTime = _bookingTime;
@synthesize inDate = _inDate;
@synthesize outDate = _outDate;
@synthesize stayDay = _stayDay;
@synthesize earlyTime = _earlyTime;
@synthesize lateTime = _lateTime;
@synthesize roomName = _roomName;
@synthesize roomNum = _roomNum;
@synthesize tel = _tel;
@synthesize guests = _guests;
@synthesize linkName = _linkName;
@synthesize linkTel = _linkTel;
@synthesize linkMobile = _linkMobile;
@synthesize linkEmail = _linkEmail;
@synthesize resStatus = _resStatus;
@synthesize payStatus = _payStatus;
@synthesize payment = _payment;

-(void)dealloc{
    [self.resultCode release];
    [self.resultMessage release];
    
    [self.amount release];
    [self.hotelName release];
    [self.bookingTime release];
    [self.inDate release];
    [self.outDate release];
    [self.stayDay release];
    [self.earlyTime release];
    [self.lateTime release];
    [self.roomName release];
    [self.roomNum release];
    [self.tel release];
    [self.guests release];
    [self.linkName release];
    [self.linkTel release];
    [self.linkMobile release];
    [self.linkEmail release];
    [self.resStatus release];
    [self.payStatus release];
    [self.payment release];

    [super dealloc];
}

@end

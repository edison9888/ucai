//
//  HotelOrderListSearchResponseModel.m
//  JingDuTianXia
//
//  Created by  on 11-11-30.
//  Copyright (c) 2011年 __JingDuTianXia__. All rights reserved.
//

#import "HotelOrderListSearchResponseModel.h"

@implementation HotelOrderListSearchResponseModel

@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;

@synthesize hotelOrderArray = _hotelOrderArray;

@synthesize orderNum = _orderNum;// 订单总数
@synthesize pageIndex = _pageIndex;// 当前页数
@synthesize pageSize = _pageSize;// 每页数量

-(void)dealloc{
    [self.resultCode release];
    [self.resultMessage release];
    [self.hotelOrderArray release];
    [self.orderNum release];
    [self.pageIndex release];
    [self.pageSize release];
    [super dealloc];
}

@end

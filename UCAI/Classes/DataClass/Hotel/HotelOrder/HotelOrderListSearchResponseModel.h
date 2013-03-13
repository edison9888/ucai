//
//  HotelOrderListSearchResponseModel.h
//  JingDuTianXia
//
//  Created by  on 11-11-30.
//  Copyright (c) 2011年 __JingDuTianXia__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotelOrderListSearchResponseModel : NSObject

@property(nonatomic,copy) NSString * resultCode;// 返回结果编码:1-成功,0-失败
@property(nonatomic,copy) NSString * resultMessage;// 返回结果信息

@property(nonatomic,retain) NSMutableArray * hotelOrderArray; // 订单列表数据(HotelOrderListInfoModel)

@property(nonatomic,copy) NSString * orderNum;// 订单总数
@property(nonatomic,copy) NSString * pageIndex;// 当前页数
@property(nonatomic,copy) NSString * pageSize;// 每页数量

@end

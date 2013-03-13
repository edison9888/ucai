//
//  HotelGuest.h
//  JingDuTianXia
//
//  Created by Piosa on 11-11-15.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HotelGuest : NSObject {
	NSString * _guestName;
	NSString * _guestPhone;
}

@property (nonatomic,copy) NSString * guestName;
@property (nonatomic,copy) NSString * guestPhone;

//输出适合提交酒店订单数据的字符串格式
- (NSString *)toCommitString;

@end

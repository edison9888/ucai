//
//  MemberFlightHistoryCustomerDeleteResponse.h
//  UCAI
//
//  Created by  on 12-2-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemberFlightHistoryCustomerDeleteResponse : NSObject

@property (nonatomic, copy) NSString *resultCode;       // 返回结果编码:1-成功,2-失败
@property (nonatomic, copy) NSString *resultMessage;    // 返回结果信息

@end

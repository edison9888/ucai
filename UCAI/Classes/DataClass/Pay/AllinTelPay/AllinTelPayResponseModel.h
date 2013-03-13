//
//  AllinTelPayResponseModel.h
//  UCAI
//
//  Created by  on 11-12-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AllinTelPayResponseModel : NSObject

@property (nonatomic, copy) NSString *resultCode;      // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;   // 返回结果信息

@property (nonatomic, copy) NSString *allinID;           //交易流水号
@property (nonatomic, copy) NSString *allinCreatetime;   //交易的时间 yyyy-MM-dd hh:mm:ss

@end

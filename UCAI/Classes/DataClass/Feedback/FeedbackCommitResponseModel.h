//
//  FeedbackCommitResponseModel.h
//  UCAI
//
//  Created by  on 12-1-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedbackCommitResponseModel : NSObject

@property (nonatomic, copy) NSString *resultCode;      // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;   // 返回结果信息

@end

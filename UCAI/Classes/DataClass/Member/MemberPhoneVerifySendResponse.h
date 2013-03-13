//
//  MemberPhoneVerifySendResponse.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-15.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 会员手机号码验证码请求后的返回结果
 */
@interface MemberPhoneVerifySendResponse : NSObject {
	NSString *result_code;				// 返回结果编码:0-成功,1-失败
	NSString *result_message;			// 返回结果信息
	
	NSString *loseEffTime;				// 验证码失效时间(分钟)
}

@property (nonatomic, copy) NSString *result_code;	
@property (nonatomic, copy) NSString *result_message;

@property (nonatomic,copy) NSString *loseEffTime;

@end

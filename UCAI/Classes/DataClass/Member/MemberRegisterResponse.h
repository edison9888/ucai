//
//  MemberRegisterResponse.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-8.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MemberRegisterResponse : NSObject {
	NSString *result_code;		// 返回结果编码:0-成功,1-失败
	NSString *result_message;	// 返回结果信息
	
	// 以下是 result_body
	NSString *memberName; //用户名(注册名)
	NSString *memberID; //会员ID
	NSString *cardNO; //会员卡号
}

@property (nonatomic, copy) NSString *result_code;	
@property (nonatomic, copy) NSString *result_message;

@property (nonatomic, copy) NSString *memberName;
@property (nonatomic, copy) NSString *memberID;
@property (nonatomic, copy) NSString *cardNO;

@end

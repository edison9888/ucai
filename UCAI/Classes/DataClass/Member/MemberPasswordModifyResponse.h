//
//  MemberPasswordModifyResponse.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-17.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MemberPasswordModifyResponse : NSObject {
	NSString *result_code;		// 返回结果编码:0-成功,1-失败
	NSString *result_message;	// 返回结果信息
}

@property (nonatomic, copy) NSString *result_code;	
@property (nonatomic, copy) NSString *result_message;

@end

//
//  MemberInfoModifyResponse.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-17.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MemberInfoModifyResponse : NSObject {
	NSString *result_code;				// 返回结果编码:0-成功,1-失败
	NSString *result_message;			// 返回结果信息
	
	NSString *realName;					// 修改成功后的真实姓名
	NSString *sex;						// 修改成功后的性别:F-男，M-女
	NSString *phone;					// 修改成功后的移动电话
	NSString *eMail;					// 修改成功后的电子邮箱
	NSString *contactTel;				// 修改成功后的联系电话
	NSString *idNumber;					// 修改成功后的身份证号
	NSString *rapeseedAmount;			// 会员现有油菜籽数量
	NSString *exchangeRapeseedAmount;	// 会员现有可用于总的优惠劵的油菜籽数量
}

@property (nonatomic, copy) NSString *result_code;	
@property (nonatomic, copy) NSString *result_message;

@property (nonatomic, copy) NSString *realName;					
@property (nonatomic, copy) NSString *sex;						
@property (nonatomic, copy) NSString *phone;					
@property (nonatomic, copy) NSString *eMail;					
@property (nonatomic, copy) NSString *contactTel;				
@property (nonatomic, copy) NSString *idNumber;					
@property (nonatomic, copy) NSString *rapeseedAmount;			
@property (nonatomic, copy) NSString *exchangeRapeseedAmount;	

@end




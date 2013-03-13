//
//  MemberInfoQueryResponse.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-11.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MemberInfoQueryResponse : NSObject {
	NSString *result_code;				// 返回结果编码:0-成功,1-失败
	NSString *result_message;			// 返回结果信息
	
	NSString *registerName;				// 注册用户名
	NSString *cardNO;					// 会员卡号
	NSString *realName;					// 真实姓名
	NSString *sex;						// 性别:F-男，M-女
	NSString *phone;					// 移动电话
	NSString *phoneVerifyStatus;		// 移动电话难标志:"0"-已验证,"1"-未验证
	NSString *eMail;					// 电子邮箱
	NSString *contactTel;				// 联系电话
	NSString *idNumber;					// 身分证号
	NSString *rapeseedAmount;			// 会员现有油菜籽数量
	NSString *exchangeRapeseedAmount;	// 会员可用于兑换优惠劵的油菜籽数量
}

@property (nonatomic, copy) NSString *result_code;	
@property (nonatomic, copy) NSString *result_message;

@property (nonatomic,copy) NSString *registerName;
@property (nonatomic,copy) NSString *cardNO;
@property (nonatomic,copy) NSString *realName;
@property (nonatomic,copy) NSString *sex;
@property (nonatomic,copy) NSString *phone;
@property (nonatomic,copy) NSString *phoneVerifyStatus;
@property (nonatomic,copy) NSString *eMail;
@property (nonatomic,copy) NSString *contactTel;
@property (nonatomic,copy) NSString *idNumber;
@property (nonatomic,copy) NSString *rapeseedAmount;
@property (nonatomic,copy) NSString *exchangeRapeseedAmount;

@end

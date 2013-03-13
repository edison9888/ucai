//
//  MemberLoginResponse.h
//  JingDuTianXia
//
//  Created by admin on 11-9-26.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MemberLoginResponse : NSObject {
	NSString *result_code;		// 返回结果编码:0-成功,1-失败
	NSString *result_message;	// 返回结果信息
	
	// 以下是 result_body
	NSString *memberID;	// 会员ID
	NSString *registerName;		// 用户名
	NSString *cardNO;			// 会员卡号
	NSString *realName;	// 真实姓名
	NSString *sex; //性别:F-男,M-女
	NSString *phone; //移动电话
	NSString *phoneVerifyStatus; //移动电话验证标志:"0"-已验证,"1"-未验证
	NSString *eMail; //电子邮箱
	NSString *contactTel; //联系电话
	NSString *contactAddress; //联系地址
	NSString *idNumber; //身份证号
	NSString *accPoints; //累积积分
	NSString *usablePoints; //可用积分
	
	//以下是易商卡的信息
	NSString *eCardNO;//易商卡号
	NSString *eCardUserName;//易商卡持卡人名称
	NSString *eCardStatus;//易商卡激活状态:0-未激活,1-已激活,2-冻结
	
}

@property (nonatomic, copy) NSString *result_code;	
@property (nonatomic, copy) NSString *result_message;

@property (nonatomic, copy) NSString *memberID;
@property (nonatomic, copy) NSString *registerName;
@property (nonatomic, copy) NSString *cardNO;
@property (nonatomic, copy) NSString *realName;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *phoneVerifyStatus;
@property (nonatomic, copy) NSString *eMail;
@property (nonatomic, copy) NSString *contactTel;
@property (nonatomic, copy) NSString *contactAddress;
@property (nonatomic, copy) NSString *idNumber;
@property (nonatomic, copy) NSString *accPoints;
@property (nonatomic, copy) NSString *usablePoints;

@property (nonatomic, copy) NSString *eCardNO;
@property (nonatomic, copy) NSString *eCardUserName;
@property (nonatomic, copy) NSString *eCardStatus;

@end

//
//  MemberInfoViewController.h
//  UCAI
//
//  Created by  on 12-2-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class MemberInfoQueryResponse;

@interface MemberInfoViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,MBProgressHUDDelegate>{
    @private
    MBProgressHUD *_hud;
    BOOL isEditing;
}

@property(nonatomic, retain) UITableView * memberInfoTableView;

@property (nonatomic, copy) NSString *realNameString;
@property (nonatomic, copy) NSString *sexString;
@property (nonatomic, copy) NSString *phoneString;
@property (nonatomic, copy) NSString *verifyCodeString;
@property (nonatomic, copy) NSString *eMailString;
@property (nonatomic, copy) NSString *contactTelString;
@property (nonatomic, copy) NSString *idNumberString;

@property (nonatomic, retain) UITextField *realNameTextField;
@property (nonatomic, retain) UITextField *phoneTextField;
@property (nonatomic, retain) UITextField *verifyCodeTextField;
@property (nonatomic, retain) UITextField *eMailTextField;
@property (nonatomic, retain) UITextField *contactTelTextField;
@property (nonatomic, retain) UITextField *idNumberTextField;

@property (nonatomic, assign) NSInteger requestType;    //网络请求类型:1-查询会员资料请求;2-修改会员资料请求;3-手机号码验证码获取请求
@property (nonatomic, retain) MemberInfoQueryResponse *memberInfoQueryResponse;

@property (nonatomic, retain) UIButton *manCheckbox;
@property (nonatomic, retain) UIButton *womanCheckbox;

@property (nonatomic, retain) UIButton *editOrSaveButton;

@property (nonatomic, assign) NSInteger numberOfRows;

// 查询会员资料
- (void)memberInfoQuery;

// 会员资料查询POST数据拼装函数
- (NSData*)generateMemberInfoQueryRequestPostXMLData;

// 会员手机号码验证码请求POST数据拼装函数
- (NSData*)generateMemberPhoneVerifyRequestPostXMLData;

// 会员资料修改请求POST数据拼装函数
- (NSData*)generateMemberInfoModifyRequestPostXMLData;

//检查并保存所输入的会员资料是否合法
//0-合法;
//1-未输入真实姓名;
//2-未输入手机号码;
//3-手机号码格式不正确;
//4-未输入验证码;
//5-电子邮箱格式不正确;
//6-身份证号格式不正确;
- (int) checkAndSaveIn;

@end

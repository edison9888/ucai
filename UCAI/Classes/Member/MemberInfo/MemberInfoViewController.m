//
//  MemberInfoViewController.m
//  UCAI
//
//  Created by  on 12-2-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MemberInfoViewController.h"
#import "MemberInfoQueryResponse.h"
#import "MemberInfoModifyResponse.h"
#import "MemberPhoneVerifySendResponse.h"

#import "PiosaFileManager.h"
#import "ResponseParser.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "StaticConf.h"
#import "CommonTools.h"

#define kHUDhiddenTag 101 //只需要消失提交框
#define kHUDhiddenAndPopTag 102 //需要在提交框消失后退出视图

#define kRegisterNameLabel 201
#define kCardNOLabel 202
#define kRealNameLabel 203
#define kSexLabel 204
#define kPhoneLabel 205
#define kVerifyLabel 206
#define kEMailLabel 207
#define kContactTelLabel 208
#define kIdNumberLabel 209

#define kRealNameTextFieldTag 303
#define kManCheckBoxTag 401
#define kManButtonTag 402
#define kWomanCheckBoxTag 403
#define kWomanButtonTag 404
#define kPhoneTextFieldTag 305
#define kVerifyTextFieldTag 306
#define kEMailTextFieldTag 307
#define kContactTelTextFieldTag 308
#define kIdNumberTextFieldTag 309

@implementation MemberInfoViewController

@synthesize memberInfoTableView = _memberInfoTableView;

@synthesize realNameString = _realNameString;
@synthesize sexString = _sexString;
@synthesize phoneString = _phoneString;
@synthesize verifyCodeString = _verifyCodeString;
@synthesize eMailString = _eMailString;
@synthesize contactTelString = _contactTelString;
@synthesize idNumberString = _idNumberString;

@synthesize realNameTextField = _realNameTextField;
@synthesize phoneTextField = _phoneTextField;
@synthesize verifyCodeTextField = _verifyCodeTextField;
@synthesize eMailTextField = _eMailTextField;
@synthesize contactTelTextField = _contactTelTextField;
@synthesize idNumberTextField = _idNumberTextField;
@synthesize requestType = _requestType;
@synthesize memberInfoQueryResponse = _memberInfoQueryResponse;

@synthesize manCheckbox = _manCheckbox;
@synthesize womanCheckbox = _womanCheckbox;

@synthesize editOrSaveButton =_editOrSaveButton;

@synthesize numberOfRows = _numberOfRows;

- (void)dealloc{
    [self.memberInfoTableView release];
    [self.realNameString release];
    [self.sexString release];
    [self.phoneString release];
    [self.verifyCodeString release];
    [self.eMailString release];
    [self.contactTelString release];
    [self.idNumberString release];
    [self.realNameTextField release];
    [self.phoneTextField release];
    [self.verifyCodeTextField release];
    [self.eMailTextField release];
    [self.contactTelTextField release];
    [self.idNumberTextField release];
    [self.memberInfoQueryResponse release];
    [self.manCheckbox release];
    [self.womanCheckbox release];
    [self.editOrSaveButton release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom

- (void)phoneCall{
    if ([[UIApplication  sharedApplication] canOpenURL:[NSURL  URLWithString:@"tel://4006840060"]]) {
        UIActionSheet * phoneActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拨打电话40068 40060" otherButtonTitles:nil, nil];
        phoneActionSheet.delegate = self;
        [phoneActionSheet showInView:[UIApplication sharedApplication].keyWindow];
		[phoneActionSheet release];
    }
}

- (void)backOrHome:(UIButton *) button
{
    switch (button.tag) {
        case 101:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 102:
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
    }
}

//响应文本输入框的完成按钮操作，用于收回键盘
- (IBAction)textFieldDone:(id)sender{
	self.memberInfoTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)memberInfoQuery{
	self.requestType = 1;
    
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"加载中...";
    _hud.tag = kHUDhiddenAndPopTag;
    [_hud show:YES];
    
    NSString * requestString = [[NSString alloc] initWithData:[self generateMemberInfoQueryRequestPostXMLData] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",requestString);
    [requestString release];
	
	ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: MEMBER_INFO_QUERY_ADDRESS]] autorelease];
	[req addRequestHeader:@"API-Version" value:API_VERSION];
	req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
	[req appendPostData:[self generateMemberInfoQueryRequestPostXMLData]];
	[req setDelegate:self];
	[req startAsynchronous]; // 执行异步post
}

- (NSData*)generateMemberInfoQueryRequestPostXMLData{
	NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
	
	//编辑会员资料查询请求的xml数据
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"memberID" stringValue:[memberDict objectForKey:@"memberID"]]];
    [requestElement addChild:conditionElement];
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    
    NSData *xmlData = document.XMLData;
	return xmlData;
}

// 会员资料修改请求POST数据拼装函数
- (NSData*)generateMemberInfoModifyRequestPostXMLData{
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
	
	//编辑会员资料修改请求的xml数据
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"memberID" stringValue:[memberDict objectForKey:@"memberID"]]];
	[conditionElement addChild:[GDataXMLNode elementWithName:@"realName" stringValue:self.realNameString]];
	[conditionElement addChild:[GDataXMLNode elementWithName:@"sex" stringValue:self.sexString]];
	[conditionElement addChild:[GDataXMLNode elementWithName:@"phone" stringValue:self.phoneString]];
	[conditionElement addChild:[GDataXMLNode elementWithName:@"phoneVerifyCode" stringValue:self.verifyCodeString]];
	[conditionElement addChild:[GDataXMLNode elementWithName:@"eMail" stringValue:self.eMailString]];
	[conditionElement addChild:[GDataXMLNode elementWithName:@"contactTel" stringValue:self.contactTelString]];
	[conditionElement addChild:[GDataXMLNode elementWithName:@"idNumber" stringValue:self.idNumberString]];
    [requestElement addChild:conditionElement];
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    
    NSData *xmlData = document.XMLData;
	return xmlData;
}

- (NSData*)generateMemberPhoneVerifyRequestPostXMLData{
	NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
	
	//编辑会员手机号码验证码请求的xml数据
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"memberID" stringValue:[memberDict objectForKey:@"memberID"]]];
	[conditionElement addChild:[GDataXMLNode elementWithName:@"phone" stringValue:self.phoneTextField.text]];
    [requestElement addChild:conditionElement];
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    
    NSData *xmlData = document.XMLData;
	return xmlData;
}

- (void)editButtonPress{
    if (isEditing) {
        int check = [self checkAndSaveIn];
        
        NSString * showMes = nil;
        NSString * deShowMes = nil;
        switch (check) {
            case 1:
                showMes = @"您似乎还未输入真实姓名";
                break;
            case 2:
                showMes = @"您似乎还未输入手机号码";
                break;
            case 3:
                showMes = @"请输入有效的手机号码";
                break;
            case 4:
                showMes = @"您似乎还未输入手机验证码";
                break;
            case 5:
                showMes = @"您输入的邮箱地址有误";
                deShowMes = @"正确格式:jindu@hotmail.com";
                break;
            case 6:
                showMes = @"请输入有效的身份证号";
                break;
        }
        
        if (check != 0) {;
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            hud.bgRGB = [PiosaColorManager progressColor];
            [self.navigationController.view addSubview:hud];
            hud.delegate = self;
            NSString *exclamationImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"exclamation" inDirectory:@"CommonView/ProgressView"];
            UIImageView *exclamationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:exclamationImagePath]];
            exclamationImageView.frame = CGRectMake(0, 0, 37, 37);
            hud.customView = exclamationImageView;
            [exclamationImageView release];
            //hud.opacity = 1.0;
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = showMes;
            hud.detailsLabelText = deShowMes;
            hud.tag = kHUDhiddenTag;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
        } else {
            self.requestType = 2;
            
            _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            _hud.bgRGB = [PiosaColorManager progressColor];
            [self.navigationController.view addSubview:_hud];
            _hud.delegate = self;
            _hud.minSize = CGSizeMake(135.f, 135.f);
            _hud.labelText = @"修改中...";
            _hud.tag = kHUDhiddenTag;
            [_hud show:YES];
            
            NSString * requestString = [[NSString alloc] initWithData:[self generateMemberInfoModifyRequestPostXMLData] encoding:NSUTF8StringEncoding];
            NSLog(@"%@",requestString);
            [requestString release];
            
            NSString *url = MEMBER_INFO_MODIFY_ADDRESS;
            ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: url]] autorelease];
            [req addRequestHeader:@"API-Version" value:API_VERSION];
            req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
            [req appendPostData:[self generateMemberInfoModifyRequestPostXMLData]];
            [req setDelegate:self];
            [req startAsynchronous]; // 执行异步post
            [url release];
        }
    }else{
        isEditing = YES;
        
        if ([@"0" isEqualToString:self.memberInfoQueryResponse.phoneVerifyStatus]) {
            self.numberOfRows = 7;
        }else{
            self.numberOfRows = 8;
        }
        
        [self.memberInfoTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.editOrSaveButton setTitle:@"保  存" forState:UIControlStateNormal];
    }
}

//响应性别选项的复选框
-(void)checkboxClick:(UIButton *)btn
{
	self.manCheckbox.selected = !self.manCheckbox.selected;
	self.womanCheckbox.selected = !self.womanCheckbox.selected;
    
    if (self.manCheckbox.selected) {
        self.sexString = @"F";
    } else {
        self.sexString = @"M";
    }
}

- (int) checkAndSaveIn{
	if (self.realNameTextField.text == nil || [self.realNameTextField.text length]==0) {
		return 1;
	}
	if (self.phoneTextField.text == nil || [self.phoneTextField.text length]==0) {
		return 2;
	} else {
		if (![CommonTools verifyPhoneFormat:self.phoneTextField.text]) {
			return 3;
		}
	}
	if (self.numberOfRows == 8) {
		if (self.verifyCodeTextField.text == nil || [self.verifyCodeTextField.text length]==0) {
			return 4;
		}
	} else {
		// 当验证栏没出现时，就是可以不进行手机号码验证
		self.verifyCodeTextField.text = @"";
	}
    
	if (self.eMailTextField.text!=nil && [self.eMailTextField.text length]!=0) {
		if (![CommonTools verifyEmailFormat:self.eMailTextField.text]){
			return 5;
		}
	}
	if (self.idNumberTextField.text!=nil && [self.idNumberTextField.text length]!=0) {
		if (![CommonTools verifyIDNumberFormat:self.idNumberTextField.text]){
			return 6;
		}
	}
	return 0;
}

//响应获取手机验证码按钮
-(void)sendVerifyCode{
	if ([CommonTools verifyPhoneFormat:self.phoneTextField.text]) {
		//手机号码格式验证通过，进行验证码请求
		self.requestType = 3;
        
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _hud.bgRGB = [PiosaColorManager progressColor];
        [self.navigationController.view addSubview:_hud];
        _hud.delegate = self;
        _hud.minSize = CGSizeMake(135.f, 135.f);
        _hud.labelText = @"请求中...";
        _hud.tag = kHUDhiddenTag;
        [_hud show:YES];
		
		NSString *url = MEMBER_PHONE_VERIFY_ADDRESS;
		ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: url]] autorelease];
		[req addRequestHeader:@"API-Version" value:API_VERSION];
		req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
		[req appendPostData:[self generateMemberPhoneVerifyRequestPostXMLData]];
		[req setDelegate:self];
		[req startAsynchronous]; // 执行异步post
		[url release];
	} else {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        hud.bgRGB = [PiosaColorManager progressColor];
        [self.navigationController.view addSubview:hud];
        hud.delegate = self;
        NSString *exclamationImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"exclamation" inDirectory:@"CommonView/ProgressView"];
        UIImageView *exclamationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:exclamationImagePath]];
        exclamationImageView.frame = CGRectMake(0, 0, 37, 37);
        hud.customView = exclamationImageView;
        [exclamationImageView release];
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = @"请输入正确的手机号码";
        hud.tag = kHUDhiddenTag;
        [hud show:YES];
        [hud hide:YES afterDelay:2];
	}
}

#pragma mark - View lifecycle
- (void)loadView
{
    [super loadView];
    
    self.title = @"会员资料";
    
    //返回按钮
    NSString *backButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"backButton_normal" inDirectory:@"CommonView/NavigationItem"];
    NSString *backButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"backButton_highlighted" inDirectory:@"CommonView/NavigationItem"];
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    backButton.tag = 101;
    [backButton setBackgroundImage:[UIImage imageNamed:backButtonNormalPath] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:backButtonHighlightedPath] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backOrHome:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    [backBarButtonItem release];
    [backButton release];
    
    //主页按钮
    NSString *homeButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"homeButton_normal" inDirectory:@"CommonView/NavigationItem"];
    NSString *homeButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"homeButton_highlighted" inDirectory:@"CommonView/NavigationItem"];
    UIButton * homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    homeButton.tag = 102;
    [homeButton setBackgroundImage:[UIImage imageNamed:homeButtonNormalPath] forState:UIControlStateNormal];
    [homeButton setBackgroundImage:[UIImage imageNamed:homeButtonHighlightedPath] forState:UIControlStateHighlighted];
    [homeButton addTarget:self action:@selector(backOrHome:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *homeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
    self.navigationItem.rightBarButtonItem = homeBarButtonItem;
    [homeBarButtonItem release];
    [homeButton release];
    
	//设置背景图片
    NSString *bgPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"background" inDirectory:@"CommonView"];
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bgPath]];
    bgImageView.frame = CGRectMake(0, 0, 320, 416);
	[self.view addSubview:bgImageView];
	[bgImageView release];
    
    UITableView * tempTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 386) style:UITableViewStyleGrouped];
    tempTableView.dataSource = self;
    tempTableView.delegate = self;
    tempTableView.backgroundColor = [UIColor clearColor];
    self.memberInfoTableView = tempTableView;
    [self.view addSubview:tempTableView];
    [tempTableView release];
    
    //底部视图的设置
    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 386, 320, 30)];
    bottomView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    UIButton * phoneButton = [[UIButton alloc] initWithFrame:CGRectMake(82, 2, 156, 26)];
    NSString *phonecallButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"phonecall_normal" inDirectory:@"CommonView/BottomItem"];
    NSString *phonecallButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"phonecall_highlighted" inDirectory:@"CommonView/BottomItem"];
    [phoneButton setImage:[UIImage imageNamed:phonecallButtonNormalPath] forState:UIControlStateNormal];
    [phoneButton setImage:[UIImage imageNamed:phonecallButtonHighlightedPath] forState:UIControlStateHighlighted];
    [phoneButton addTarget:self action:@selector(phoneCall) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:phoneButton];
    [self.view addSubview:bottomView];
    [phoneButton release];
    [bottomView release];
    
    isEditing = NO;
    [self memberInfoQuery];
    
    self.numberOfRows = 7;
}

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应 : 但可能是错误响应, 如 404，或查询结果为空，则不跳转到下一个机票展示页面
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);
	
    // 关闭加载框
    [_hud hide:YES];
	switch (self.requestType) {
		case 1:
			//会员资料查询请求返回信息
			if ((responseString != nil) && [responseString length] > 0) {
				MemberInfoQueryResponse *memberInfoQueryResponse = [ResponseParser loadMemberInfoQueryResponse:[request responseData]];
				
				if (memberInfoQueryResponse.result_code == nil || [memberInfoQueryResponse.result_code length] == 0 || [memberInfoQueryResponse.result_code intValue] != 0) {
					// 查询失败
                    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                    hud.bgRGB = [PiosaColorManager progressColor];
                    [self.navigationController.view addSubview:hud];
                    hud.delegate = self;
                    hud.minSize = CGSizeMake(135.f, 135.f);
                    NSString *exclamationImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"exclamation" inDirectory:@"CommonView/ProgressView"];
                    UIImageView *exclamationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:exclamationImagePath]];
                    exclamationImageView.frame = CGRectMake(0, 0, 37, 37);
                    hud.customView = exclamationImageView;
                    [exclamationImageView release];
                    hud.opacity = 1.0;
                    hud.mode = MBProgressHUDModeCustomView;
                    hud.labelText = memberInfoQueryResponse.result_message;
                    hud.tag = kHUDhiddenTag;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
				} else {
					//查询成功
                    _hud.tag = kHUDhiddenTag;
                    self.memberInfoQueryResponse = memberInfoQueryResponse;
                    [self.memberInfoTableView reloadData];  
				}
			}
			break;
		case 2:
			//会员资料修改请求返回信息
			if ((responseString != nil) && [responseString length] > 0) {
				MemberInfoModifyResponse *memberInfoModifyResponse = [ResponseParser loadMemberInfoModifyResponse:[request responseData]];
				
				if (memberInfoModifyResponse.result_code == nil || [memberInfoModifyResponse.result_code length] == 0 || [memberInfoModifyResponse.result_code intValue] != 0) {
					// 修改失败
                    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                    hud.bgRGB = [PiosaColorManager progressColor];
                    [self.navigationController.view addSubview:hud];
                    hud.delegate = self;
                    hud.minSize = CGSizeMake(135.f, 135.f);
                    NSString *exclamationImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"exclamation" inDirectory:@"CommonView/ProgressView"];
                    UIImageView *exclamationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:exclamationImagePath]];
                    exclamationImageView.frame = CGRectMake(0, 0, 37, 37);
                    hud.customView = exclamationImageView;
                    [exclamationImageView release];
                    hud.opacity = 1.0;
                    hud.mode = MBProgressHUDModeCustomView;
                    hud.labelText = memberInfoModifyResponse.result_message;
                    hud.tag = kHUDhiddenTag;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
				} else {
					//修改成功
					self.numberOfRows = 7;
                    self.memberInfoQueryResponse.realName = memberInfoModifyResponse.realName;
                    self.memberInfoQueryResponse.sex = memberInfoModifyResponse.sex;
                    self.memberInfoQueryResponse.phone = memberInfoModifyResponse.phone;
                    self.memberInfoQueryResponse.phoneVerifyStatus = @"0";
                    self.memberInfoQueryResponse.eMail = memberInfoModifyResponse.eMail;
                    self.memberInfoQueryResponse.contactTel = memberInfoModifyResponse.contactTel;
                    self.memberInfoQueryResponse.idNumber = memberInfoModifyResponse.idNumber;

                    isEditing = NO;
                    self.numberOfRows = 7;
                    [self.memberInfoTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                    [self.editOrSaveButton setTitle:@"编  辑" forState:UIControlStateNormal];
				}
			}
			break;
		case 3:
			//手机验证码请求返回信息
			if ((responseString != nil) && [responseString length] > 0) {
				MemberPhoneVerifySendResponse *memberPhoneVerifySendResponse = [ResponseParser loadMemberPhoneVerifySendResponse:[request responseData]];
				
				if (memberPhoneVerifySendResponse.result_code == nil || [memberPhoneVerifySendResponse.result_code length] == 0 || [memberPhoneVerifySendResponse.result_code intValue] != 0) {
					// 查询失败
                    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                    hud.bgRGB = [PiosaColorManager progressColor];
                    [self.navigationController.view addSubview:hud];
                    hud.delegate = self;
                    hud.minSize = CGSizeMake(135.f, 135.f);
                    NSString *exclamationImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"exclamation" inDirectory:@"CommonView/ProgressView"];
                    UIImageView *exclamationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:exclamationImagePath]];
                    exclamationImageView.frame = CGRectMake(0, 0, 37, 37);
                    hud.customView = exclamationImageView;
                    [exclamationImageView release];
                    hud.opacity = 1.0;
                    hud.mode = MBProgressHUDModeCustomView;
                    hud.labelText = memberPhoneVerifySendResponse.result_message;
                    hud.tag = kHUDhiddenTag;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
				} else {
					//查询成功
                    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                    hud.bgRGB = [PiosaColorManager progressColor];
                    [self.navigationController.view addSubview:hud];
                    hud.delegate = self;
                    hud.minSize = CGSizeMake(135.f, 135.f);
                    NSString *tickImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"tick" inDirectory:@"CommonView/ProgressView"];
                    UIImageView *tickImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:tickImagePath]];
                    tickImageView.frame = CGRectMake(0, 0, 37, 37);
                    hud.customView = tickImageView;
                    [tickImageView release];
                    hud.opacity = 1.0;
                    hud.mode = MBProgressHUDModeCustomView;
                    hud.labelText = @"手机验证码已发送!";
                    NSString *mes = [[NSString alloc] initWithFormat:@"验证码有效时间为%d分钟",[memberPhoneVerifySendResponse.loseEffTime intValue]];
                    hud.detailsLabelText = mes;
                    [mes release];
                    hud.tag = kHUDhiddenTag;
                    [hud show:YES];
                    [hud hide:YES afterDelay:4];
				}
			}
			break;
	}
}

// 网络无响应
- (void)requestFailed:(ASIFormDataRequest *)request
{
	// 提示用户打开网络联接
    NSString *badFaceImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"badFace" inDirectory:@"CommonView/ProgressView"];
    UIImageView *badFaceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:badFaceImagePath]];
    badFaceImageView.frame = CGRectMake(0, 0, 37, 37);
    _hud.customView = badFaceImageView;
    [badFaceImageView release];
	_hud.mode = MBProgressHUDModeCustomView;
	_hud.labelText = @"网络连接失败啦";
    [_hud hide:YES afterDelay:3];
}

#pragma mark -
#pragma mark Text Field Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (isEditing) {
        self.editOrSaveButton.enabled = NO;
        switch (textField.tag) {
            case kRealNameTextFieldTag:
                self.memberInfoTableView.contentOffset = CGPointMake(0, 58);
                break;
            case kPhoneTextFieldTag:
                self.memberInfoTableView.contentOffset = CGPointMake(0, 108);
                break;
            case kVerifyTextFieldTag:
                self.memberInfoTableView.contentOffset = CGPointMake(0, 155);
                break;
            case kEMailTextFieldTag:
                self.memberInfoTableView.contentOffset = CGPointMake(0, 233);
                break;
            case kContactTelTextFieldTag:
                self.memberInfoTableView.contentOffset = CGPointMake(0, 243);
                break;
            case kIdNumberTextFieldTag:
                self.memberInfoTableView.contentOffset = CGPointMake(0, 323);
                break;
        }
        
        self.memberInfoTableView.contentInset = UIEdgeInsetsMake(0, 0, 220, 0);
    }
}

//手机输入栏结束编辑时
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (isEditing) {
        self.editOrSaveButton.enabled = YES;
        
        self.memberInfoTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        switch (textField.tag) {
            case kRealNameTextFieldTag:
                self.realNameString = self.realNameTextField.text;
                break;
            case kPhoneTextFieldTag:
                self.phoneString = self.phoneTextField.text;
                break;
            case kVerifyTextFieldTag:
                self.verifyCodeString = self.verifyCodeTextField.text;
                break;
            case kEMailTextFieldTag:
                self.eMailString = self.eMailTextField.text;
                break;
            case kContactTelTextFieldTag:
                self.contactTelString = self.contactTelTextField.text;
                break;
            case kIdNumberTextFieldTag:
                self.idNumberString = self.idNumberTextField.text;
                break;
        }
        
        if (self.numberOfRows == 7 && ![self.phoneString isEqualToString:self.memberInfoQueryResponse.phone] && self.phoneString!=nil) { //验证栏未展开
            //已经验证过的手机号码做修改
            NSArray *indexArray = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:4 inSection:1],nil];
            self.numberOfRows=8;
            [self.memberInfoTableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationTop];
        } else if (self.numberOfRows == 8) { //验证栏已展开
            //当已经展开验证栏，并且结束手机栏的编辑时
            if ([self.phoneString isEqualToString:self.memberInfoQueryResponse.phone] && [@"0" isEqualToString:self.memberInfoQueryResponse.phoneVerifyStatus]) {
                //用户修改后的手机号码与原有手机号码相同，并且原手机号码已经验证
                //收回验证栏
                NSArray *indexArray = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:4 inSection:1],nil];
                self.numberOfRows=7;
                [self.memberInfoTableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationTop];
            }
        }
    }
}

#pragma mark - UITableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 0:
			return 3;
			break;
		case 1:
			return self.numberOfRows;
			break;
		default:
			return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSUInteger realRow = indexPath.row;
    
    if (self.numberOfRows == 7 && realRow >= 4 && indexPath.section == 1) {
        realRow++;
    }
    
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", realRow, indexPath.section];
    
    UILabel *registerNameLabelTemp;
    UILabel *cardNOLabelTemp;
    UILabel *realNameLabelTemp;
    UILabel *sexLabelTemp;
    UILabel *phoneLabelTemp;
    UILabel *verifyLabelTemp;
    UILabel *eMailLabelTemp;
    UILabel *contactTelLabelTemp;
    UILabel *idNumberLabelTemp;
    
    UITextField *realNameTextFieldTemp;
    UIButton *manCheckboxTemp;
    UIButton *manButtonTemp;
    UIButton *womanCheckboxTemp;
    UIButton *womanButtonTemp;
    UITextField *phoneTextFieldTemp;
    UITextField *verifyTextFieldTemp;
    UITextField *eMailTextFieldTemp;
    UITextField *contactTelTextFieldTemp;
    UITextField *idNumberTextFieldTemp;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont systemFontOfSize:18];
                        cell.textLabel.text = @"会员信息";
                        break;
                    case 1:{
                        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 80, 25)];
                        labelName.backgroundColor = [UIColor clearColor];
                        labelName.textAlignment = UITextAlignmentRight;
                        labelName.text = @"用户名:";
                        [cell.contentView addSubview:labelName];
                        [labelName release];
                        
                        UILabel * registerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 200, 25)];
                        registerNameLabel.backgroundColor = [UIColor clearColor];
                        registerNameLabel.textColor = [UIColor grayColor];
                        registerNameLabel.tag = kRegisterNameLabel;
                        registerNameLabelTemp = registerNameLabel;
                        [cell.contentView addSubview:registerNameLabel];
                        [registerNameLabel release];
                    }
                        break;
                    case 2:{
                        UILabel *labelCardNO = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 80, 25)];
                        labelCardNO.backgroundColor = [UIColor clearColor];
                        labelCardNO.textAlignment = UITextAlignmentRight;
                        labelCardNO.text = @"会员卡号:";
                        [cell.contentView addSubview:labelCardNO];
                        [labelCardNO release];
                        
                        UILabel * cardNOLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 200, 25)];
                        cardNOLabel.backgroundColor = [UIColor clearColor];
                        cardNOLabel.textColor = [UIColor grayColor];
                        cardNOLabel.tag = kCardNOLabel;
                        cardNOLabelTemp = cardNOLabel;
                        [cell.contentView addSubview:cardNOLabel];
                        [cardNOLabel release];
                    }
                        break;
                }
                break;
            case 1:
                switch (realRow) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont systemFontOfSize:18];
                        cell.textLabel.text = @"真实信息";
                        
                        UIButton * editButton = [[UIButton alloc] initWithFrame:CGRectMake(230, 4, 60, 28)];
                        NSString *loginOutButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"loginOut_normal" inDirectory:@"RootView"];
                        NSString *loginOutButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"loginOut_highlighted" inDirectory:@"RootView"];
                        [editButton setBackgroundImage:[UIImage imageNamed:loginOutButtonNormalPath] forState:UIControlStateNormal]; 
                        [editButton setBackgroundImage:[UIImage imageNamed:loginOutButtonHighlightedPath] forState:UIControlStateHighlighted]; 
                        [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
                        editButton.titleLabel.font=[UIFont systemFontOfSize:14];
                        [editButton setTitle:@"编  辑" forState:UIControlStateNormal];
                        [editButton addTarget:self action:@selector(editButtonPress) forControlEvents:UIControlEventTouchUpInside];
                        self.editOrSaveButton = editButton;
                        [cell.contentView addSubview:editButton];
                        [editButton release];
                        
                        break;
                    case 1:{
                        UILabel *labelRealName = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 80, 25)];
                        labelRealName.backgroundColor = [UIColor clearColor];
                        labelRealName.textAlignment = UITextAlignmentRight;
                        labelRealName.text = @"真实姓名:";
                        [cell.contentView addSubview:labelRealName];
                        [labelRealName release];
                        
                        UILabel * realNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 200, 25)];
                        realNameLabel.backgroundColor = [UIColor clearColor];
                        realNameLabel.textColor = [UIColor grayColor];
                        realNameLabel.tag = kRealNameLabel;
                        realNameLabelTemp = realNameLabel;
                        [cell.contentView addSubview:realNameLabel];
                        [realNameLabel release];
                        
                        UITextField * realNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, 200, 25)]; 
                        realNameTextField.borderStyle = UITextBorderStyleRoundedRect;
                        realNameTextField.tag =kRealNameTextFieldTag;
                        realNameTextField.delegate = self;
                        realNameTextField.returnKeyType = UIReturnKeyDone;
                        [realNameTextField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        realNameTextFieldTemp = realNameTextField;
                        self.realNameTextField = realNameTextField;
                        [cell.contentView addSubview:realNameTextField];
                        [realNameTextField release];
                    }
                        break;
                    case 2:{
                        UILabel *labelSex = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 80, 25)];
                        labelSex.backgroundColor = [UIColor clearColor];
                        labelSex.textAlignment = UITextAlignmentRight;
                        labelSex.text = @"性别:";
                        [cell.contentView addSubview:labelSex];
                        [labelSex release];
                        
                        UILabel * sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 200, 25)];
                        sexLabel.backgroundColor = [UIColor clearColor];
                        sexLabel.textColor = [UIColor grayColor];
                        sexLabel.tag = kSexLabel;
                        sexLabelTemp = sexLabel;
                        [cell.contentView addSubview:sexLabel];
                        [sexLabel release];
                        
                        UIButton * manCheckbox = [[UIButton alloc] init];
                        [manCheckbox setFrame:CGRectMake(100, 10, 25, 25)];
                        NSString *checkboxButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"checkbox_normal" inDirectory:@"CommonView/CheckBox"];
                        NSString *checkboxButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"checkbox_selected" inDirectory:@"CommonView/CheckBox"];
                        [manCheckbox setImage:[UIImage imageNamed:checkboxButtonNormalPath] forState:UIControlStateNormal];
                        [manCheckbox setImage:[UIImage imageNamed:checkboxButtonSelectedPath] forState:UIControlStateSelected];
                        [manCheckbox addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
                        manCheckbox.tag = kManCheckBoxTag;
                        manCheckboxTemp = manCheckbox;
                        self.manCheckbox = manCheckbox;
                        [cell.contentView addSubview:manCheckbox]; 
                        [manCheckbox release];
                        
                        UIButton *manButton = [[UIButton alloc] initWithFrame:CGRectMake(130, 11, 20, 25)];
                        [manButton setTitle:@"男" forState:UIControlStateNormal];
                        [manButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [manButton addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
                        manButton.tag = kManButtonTag;
                        manButtonTemp = manButton;
                        [cell.contentView addSubview:manButton];
                        [manButton release];
                        
                        UIButton * womanCheckbox = [[UIButton alloc] init];
                        [womanCheckbox setFrame:CGRectMake(210, 10, 25, 25)];
                        [womanCheckbox setImage:[UIImage imageNamed:checkboxButtonNormalPath] forState:UIControlStateNormal];
                        [womanCheckbox setImage:[UIImage imageNamed:checkboxButtonSelectedPath] forState:UIControlStateSelected];
                        [womanCheckbox addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
                        womanCheckbox.tag = kWomanCheckBoxTag;
                        womanCheckboxTemp = womanCheckbox;
                        self.womanCheckbox = womanCheckbox;
                        [cell.contentView addSubview:womanCheckbox]; 
                        [womanCheckbox release];
                        
                        UIButton *womanButton = [[UIButton alloc] initWithFrame:CGRectMake(240, 11, 20, 25)];
                        [womanButton setTitle:@"女" forState:UIControlStateNormal];
                        [womanButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [womanButton addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
                        womanButton.tag = kWomanButtonTag;
                        womanButtonTemp = womanButton;
                        [cell.contentView addSubview:womanButton];
                        [womanButton release];
                    }
                        break;
                    case 3:{
                        UILabel *labelPhone = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 80, 25)];
                        labelPhone.backgroundColor = [UIColor clearColor];
                        labelPhone.textAlignment = UITextAlignmentRight;
                        labelPhone.text = @"手机:";
                        [cell.contentView addSubview:labelPhone];
                        [labelPhone release];
                        
                        UILabel * phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 200, 25)];
                        phoneLabel.backgroundColor = [UIColor clearColor];
                        phoneLabel.textColor = [UIColor grayColor];
                        phoneLabel.tag = kPhoneLabel;
                        phoneLabelTemp = phoneLabel;
                        [cell.contentView addSubview:phoneLabel];
                        [phoneLabel release];
                        
                        UILabel * verifyLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 10, 60, 25)];
                        verifyLabel.backgroundColor = [UIColor clearColor];
                        verifyLabel.textColor = [PiosaColorManager themeColor];
                        verifyLabel.tag = kVerifyLabel;
                        verifyLabelTemp = verifyLabel;
                        [cell.contentView addSubview:verifyLabel];
                        [verifyLabel release];
                        
                        UITextField * phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, 200, 25)]; 
                        phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
                        phoneTextField.keyboardType = UIKeyboardTypePhonePad;
                        phoneTextField.tag =kPhoneTextFieldTag;
                        phoneTextField.delegate = self;
                        phoneTextFieldTemp = phoneTextField;
                        self.phoneTextField = phoneTextField;
                        [cell.contentView addSubview:phoneTextFieldTemp];
                        [phoneTextFieldTemp release];
                    }
                        break;
                    case 4:{
                        UILabel *labelCode = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 80, 25)];
                        labelCode.backgroundColor = [UIColor clearColor];
                        labelCode.textAlignment = UITextAlignmentRight;
                        labelCode.text = @"验证码:";
                        [cell.contentView addSubview:labelCode];
                        [labelCode release];
                        
                        UITextField * verifyCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, 150, 25)]; 
                        verifyCodeTextField.borderStyle = UITextBorderStyleRoundedRect;
                        verifyCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
                        verifyCodeTextField.tag =kVerifyTextFieldTag;
                        verifyCodeTextField.delegate = self;
                        verifyTextFieldTemp = verifyCodeTextField;
                        self.verifyCodeTextField = verifyCodeTextField;
                        [cell.contentView addSubview:verifyCodeTextField];
                        [verifyCodeTextField release];
                        
                        UIButton * sendButton = [[UIButton alloc] init];
                        [sendButton setFrame:CGRectMake(250, 10, 40, 25)];
                        [sendButton setTitle:@"获取" forState:UIControlStateNormal];
                        sendButton.titleLabel.font=[UIFont systemFontOfSize:15];
                        [sendButton setTitleColor:[PiosaColorManager themeColor] forState:UIControlStateNormal];
                        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                        NSString *smallButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"smallButton_normal" inDirectory:@"CommonView/MethodButton"];
                        NSString *smallButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"smallButton_highlighted" inDirectory:@"CommonView/MethodButton"];
                        [sendButton setBackgroundImage:[UIImage imageNamed:smallButtonNormalPath] forState:UIControlStateNormal];
                        [sendButton setBackgroundImage:[UIImage imageNamed:smallButtonHighlightedPath] forState:UIControlStateHighlighted];
                        [sendButton addTarget:self action:@selector(sendVerifyCode) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:sendButton];
                        [sendButton release];
                    }
                        break;
                    case 5:{
                        UILabel *labelEMail = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 80, 25)];
                        labelEMail.backgroundColor = [UIColor clearColor];
                        labelEMail.textAlignment = UITextAlignmentRight;
                        labelEMail.text = @"电子邮箱:";
                        [cell.contentView addSubview:labelEMail];
                        [labelEMail release];
                        
                        UILabel * eMailLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 200, 25)];
                        eMailLabel.backgroundColor = [UIColor clearColor];
                        eMailLabel.textColor = [UIColor grayColor];
                        eMailLabel.tag = kEMailLabel;
                        eMailLabelTemp = eMailLabel;
                        [cell.contentView addSubview:eMailLabel];
                        [eMailLabel release];
                        
                        UITextField * eMailTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, 200, 25)]; 
                        eMailTextField.borderStyle = UITextBorderStyleRoundedRect;
                        eMailTextField.keyboardType = UIKeyboardTypeEmailAddress;
                        eMailTextField.tag =kEMailTextFieldTag;
                        eMailTextField.delegate = self;
                        eMailTextField.returnKeyType = UIReturnKeyDone;
                        [eMailTextField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        eMailTextFieldTemp = eMailTextField;
                        self.eMailTextField = eMailTextField;
                        [cell.contentView addSubview:eMailTextField];
                        [eMailTextField release];
                    }
                        break;
                    case 6:{
                        UILabel *labelConTel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 80, 25)];
                        labelConTel.backgroundColor = [UIColor clearColor];
                        labelConTel.textAlignment = UITextAlignmentRight;
                        labelConTel.text = @"联系电话:";
                        [cell.contentView addSubview:labelConTel];
                        [labelConTel release];
                        
                        UILabel * contactTelLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 200, 25)];
                        contactTelLabel.backgroundColor = [UIColor clearColor];
                        contactTelLabel.textColor = [UIColor grayColor];
                        contactTelLabel.tag = kContactTelLabel;
                        contactTelLabelTemp = contactTelLabel;
                        [cell.contentView addSubview:contactTelLabel];
                        [contactTelLabel release];
                        
                        UITextField * contactTelTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, 200, 25)]; 
                        contactTelTextField.borderStyle = UITextBorderStyleRoundedRect;
                        contactTelTextField.keyboardType = UIKeyboardTypePhonePad;
                        contactTelTextField.tag =kContactTelTextFieldTag;
                        contactTelTextField.delegate = self;
                        contactTelTextFieldTemp = contactTelTextField;
                        self.contactTelTextField = contactTelTextField;
                        [cell.contentView addSubview:contactTelTextField];
                        [contactTelTextField release];
                    }
                        break;
                    case 7:{
                        UILabel *labelIdNumber = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 80, 25)];
                        labelIdNumber.backgroundColor = [UIColor clearColor];
                        labelIdNumber.textAlignment = UITextAlignmentRight;
                        labelIdNumber.text = @"身份证号:";
                        [cell.contentView addSubview:labelIdNumber];
                        [labelIdNumber release];
                        
                        UILabel * idNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 200, 25)];
                        idNumberLabel.backgroundColor = [UIColor clearColor];
                        idNumberLabel.textColor = [UIColor grayColor];
                        idNumberLabel.tag = kIdNumberLabel;
                        idNumberLabelTemp = idNumberLabel;
                        [cell.contentView addSubview:idNumberLabel];
                        [idNumberLabel release];
                        
                        UITextField * idNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 10, 200, 25)]; 
                        idNumberTextField.borderStyle = UITextBorderStyleRoundedRect;
                        idNumberTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                        idNumberTextField.tag =kIdNumberTextFieldTag;
                        idNumberTextField.delegate = self;
                        idNumberTextField.returnKeyType = UIReturnKeyDone;
                        [idNumberTextField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        idNumberTextFieldTemp = idNumberTextField;
                        self.idNumberTextField = idNumberTextField;
                        [cell.contentView addSubview:idNumberTextField];
                        [idNumberTextField release];
                    }
                        break;
                }
                break;
        }
    } else {
        switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 1:
                        registerNameLabelTemp = (UILabel *)[cell.contentView viewWithTag:kRegisterNameLabel];
                        break;
                    case 2:
                        cardNOLabelTemp = (UILabel *)[cell.contentView viewWithTag:kCardNOLabel];
                        break;
                }
            case 1:
                switch (realRow) {
                    case 1:
                        realNameLabelTemp = (UILabel *)[cell.contentView viewWithTag:kRealNameLabel];
                        realNameTextFieldTemp = (UITextField *)[cell.contentView viewWithTag:kRealNameTextFieldTag];
                        break;
                    case 2:
                        sexLabelTemp = (UILabel *)[cell.contentView viewWithTag:kSexLabel];
                        manCheckboxTemp = (UIButton *)[cell.contentView viewWithTag:kManCheckBoxTag];
                        manButtonTemp = (UIButton *)[cell.contentView viewWithTag:kManButtonTag];
                        womanCheckboxTemp = (UIButton *)[cell.contentView viewWithTag:kWomanCheckBoxTag];
                        womanButtonTemp = (UIButton *)[cell.contentView viewWithTag:kWomanButtonTag];
                        break;
                    case 3:
                        phoneLabelTemp = (UILabel *)[cell.contentView viewWithTag:kPhoneLabel];
                        verifyLabelTemp = (UILabel *)[cell.contentView viewWithTag:kVerifyLabel];
                        phoneTextFieldTemp = (UITextField *)[cell.contentView viewWithTag:kPhoneTextFieldTag];
                        break;
                    case 5:
                        eMailLabelTemp = (UILabel *)[cell.contentView viewWithTag:kEMailLabel];
                        eMailTextFieldTemp = (UITextField *)[cell.contentView viewWithTag:kEMailTextFieldTag];
                        break;
                    case 6:
                        contactTelLabelTemp = (UILabel *)[cell.contentView viewWithTag:kContactTelLabel];
                        contactTelTextFieldTemp = (UITextField *)[cell.contentView viewWithTag:kContactTelTextFieldTag];
                        break;
                    case 7:
                        idNumberLabelTemp = (UILabel *)[cell.contentView viewWithTag:kIdNumberLabel];
                        idNumberTextFieldTemp = (UITextField *)[cell.contentView viewWithTag:kIdNumberTextFieldTag];
                        break;
                }
        } 
    }
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 1:
                    registerNameLabelTemp.text = self.memberInfoQueryResponse.registerName;
                    break;
                case 2:
                    cardNOLabelTemp.text = self.memberInfoQueryResponse.cardNO;
                    break;
            }
            break;
        case 1:
            switch (realRow) {
                case 1:
                    if (!isEditing) {
                        realNameLabelTemp.hidden = NO;
                        realNameTextFieldTemp.hidden = YES; 
                    }else{
                        realNameLabelTemp.hidden = YES;
                        realNameTextFieldTemp.hidden = NO;
                    }
                    realNameLabelTemp.text = self.memberInfoQueryResponse.realName;
                    realNameTextFieldTemp.text = self.realNameString == nil ? self.memberInfoQueryResponse.realName:self.realNameString;
                    break;
                case 2:
                    if (!isEditing) {
                        sexLabelTemp.hidden = NO;
                        manCheckboxTemp.hidden = YES;
                        manButtonTemp.hidden = YES;
                        womanCheckboxTemp.hidden = YES;
                        womanButtonTemp.hidden = YES;
                    }else{
                        sexLabelTemp.hidden = YES;
                        manCheckboxTemp.hidden = NO;
                        manButtonTemp.hidden = NO;
                        womanCheckboxTemp.hidden = NO;
                        womanButtonTemp.hidden = NO;
                    }
                    if ([@"F" isEqualToString:self.memberInfoQueryResponse.sex]) {
                        sexLabelTemp.text = @"男";
                    } else if([@"M" isEqualToString:self.memberInfoQueryResponse.sex]) {
                        sexLabelTemp.text = @"女";
                    } else {
                        sexLabelTemp.text = @"";
                    }
                    
                    NSString * sexSign = self.sexString == nil ? self.memberInfoQueryResponse.sex : self.sexString;
                    
                    if ([@"F" isEqualToString:sexSign]) {
                        manCheckboxTemp.selected = YES;
                        womanCheckboxTemp.selected = NO;
                    } else if([@"M" isEqualToString:sexSign]) {
                        manCheckboxTemp.selected = NO;
                        womanCheckboxTemp.selected = YES;
                    } else {
                        manCheckboxTemp.selected = NO;
                        womanCheckboxTemp.selected = NO;
                    }
                    break;
                case 3:
                    if (!isEditing) {
                        phoneLabelTemp.hidden = NO;
                        verifyLabelTemp.hidden = NO;
                        phoneTextFieldTemp.hidden = YES;
                        
                    }else{
                        phoneLabelTemp.hidden = YES;
                        verifyLabelTemp.hidden = YES;
                        phoneTextFieldTemp.hidden = NO;
                    }
                    phoneLabelTemp.text = self.memberInfoQueryResponse.phone;
                    
                    NSString * verifySign = self.memberInfoQueryResponse.phoneVerifyStatus;
                    if ([@"0" isEqualToString:verifySign]) {
                        verifyLabelTemp.text = @"已验证";
                    } else if([@"1" isEqualToString:verifySign]) {
                        verifyLabelTemp.text = @"未验证";
                    } else {
                        verifyLabelTemp.text = @"";
                    }
                    phoneTextFieldTemp.text = self.phoneString == nil ?self.memberInfoQueryResponse.phone : self.phoneString;
                    break;
                case 5:
                    if (!isEditing) {
                        eMailLabelTemp.hidden = NO;
                        eMailTextFieldTemp.hidden = YES;
                    }else{
                        eMailLabelTemp.hidden = YES;
                        eMailTextFieldTemp.hidden = NO;
                    }
                    eMailLabelTemp.text = self.memberInfoQueryResponse.eMail;
                    eMailTextFieldTemp.text = self.eMailString == nil ? self.memberInfoQueryResponse.eMail : self.eMailString;
                    break;
                case 6:
                    if (!isEditing) {
                        contactTelLabelTemp.hidden = NO;
                        contactTelTextFieldTemp.hidden = YES;
                    }else{
                        contactTelLabelTemp.hidden = YES;
                        contactTelTextFieldTemp.hidden = NO;
                    }
                    contactTelLabelTemp.text = self.memberInfoQueryResponse.contactTel;
                    contactTelTextFieldTemp.text = self.contactTelString == nil ? self.memberInfoQueryResponse.contactTel : self.contactTelString;
                    break;
                case 7:
                    if (!isEditing) {
                        idNumberLabelTemp.hidden = NO;
                        idNumberTextFieldTemp.hidden = YES;
                    }else{
                        idNumberLabelTemp.hidden = YES;
                        idNumberTextFieldTemp.hidden = NO;
                    }
                    idNumberLabelTemp.text = self.memberInfoQueryResponse.idNumber;
                    idNumberTextFieldTemp.text = self.idNumberString == nil ? self.memberInfoQueryResponse.idNumber : self.idNumberString;
                    break;
            }
            break;
    }
    
    if (indexPath.row == 0) {
        NSString *tableViewCellGroupTopTitlePath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_group_topTitle" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellGroupTopTitlePath]] autorelease];
    } else if(indexPath.row == [self.memberInfoTableView numberOfRowsInSection:indexPath.section]-1){
        NSString *tableViewCellBottomNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_normal" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomNormalPath]] autorelease];
    } else {
        NSString *tableViewCellCenterNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_normal" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterNormalPath]] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITalbeView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger realRow;
    
    if (self.numberOfRows == 7) {
        realRow = 4;
    } else {
        realRow = 5;
    }
    
    UITableViewCell * cell = [self.memberInfoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:realRow inSection:1]];
    
    UITextField * realNameTextField = (UITextField *)[cell.contentView viewWithTag:kEMailTextFieldTag];
    
    [realNameTextField becomeFirstResponder];
    [realNameTextField resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath row]==0) { //每区的第一行
        return 36;
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[[UIView alloc] init] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[[UIView alloc] init] autorelease];
}

#pragma mark -
#pragma mark ActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([actionSheet cancelButtonIndex] != buttonIndex) {
        //拨打客服电话
        [[UIApplication  sharedApplication] openURL:[NSURL  URLWithString:@"tel://4006840060"]];
    }
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    if (hud.tag == kHUDhiddenAndPopTag) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    [hud release];
	hud = nil;
}

@end

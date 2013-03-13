//
//  AllinTelPayViewController.m
//  UCAI
//
//  Created by  on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"
#import "AllinTelPayViewController.h"

#import "PiosaFileManager.h"
#import "CommonTools.h"
#import "GDataXMLNode.h"
#import "ASIFormDataRequest.h"
#import "StaticConf.h"
#import "ResponseParser.h"
#import "AllinTelPayResponseModel.h"

#import "ALLinTelPayResultViewController.h"

#define kBankCardNOContentFieldTag 101
#define kIdentityNOContentFieldTag 102
#define kPhoneNOContentFieldTag 103

@implementation AllinTelPayViewController

@synthesize payScrollView = _payScrollView;
@synthesize bankCardNOContentField = _bankCardNOContentField;
@synthesize identityNOContentField = _identityNOContentField;
@synthesize phoneNOContentField = _phoneNOContentField;

- (AllinTelPayViewController *)initWithOrderID:(NSString *)orderID andCouponPrice:(NSString *)price andType:(NSString *)type{
    self = [super init];
    _orderID = [orderID copy];
    _orderPrice = [price copy];
    _payType = [type copy];
    return self;
}

-(void)dealloc{
    [_orderID release];
    [_orderPrice release];
    [_payType release];
    
    [_payScrollView release];
    [_bankCardNOContentField release];
    [_identityNOContentField release];
    [_phoneNOContentField release];
    
    [super dealloc];
}


#pragma mark - View lifecycle
- (void)loadView{
    [super loadView];
    
    NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];

	
    self.title = @"电话支付";
    
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
    
    //订单信息
    UIView *orderInfoView = [[UIView alloc] initWithFrame:CGRectMake(5, 10, 310, 90)];
    orderInfoView.backgroundColor = [UIColor whiteColor];
    orderInfoView.layer.cornerRadius = 10;
    
    UILabel * copmanyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 230, 20)];
    copmanyNameLabel.backgroundColor = [UIColor clearColor];
    copmanyNameLabel.font = [UIFont boldSystemFontOfSize:17];
    copmanyNameLabel.text = @"深圳市精度天下科技有限公司";
    [orderInfoView addSubview:copmanyNameLabel];
    [copmanyNameLabel release];
    
    NSString *dottedLinePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"dottedLine" inDirectory:@"CommonView"];
    UIImageView * dottedLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
    dottedLineView.frame = CGRectMake(0, 30, 310, 2);
    [orderInfoView addSubview:dottedLineView];
    [dottedLineView release];
    
    UILabel * orderIDShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 40, 75, 20)];
    orderIDShowLabel.backgroundColor = [UIColor clearColor];
    orderIDShowLabel.font = [UIFont boldSystemFontOfSize:16];
    orderIDShowLabel.text = @"订单编号:";
    [orderInfoView addSubview:orderIDShowLabel];
    [orderIDShowLabel release];
    
    UILabel * orderIDContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 40, 220, 20)];
    orderIDContentLabel.backgroundColor = [UIColor clearColor];
    orderIDContentLabel.textColor = [UIColor grayColor];
    orderIDContentLabel.font = [UIFont boldSystemFontOfSize:15];
    orderIDContentLabel.text = _orderID;
    [orderInfoView addSubview:orderIDContentLabel];
    [orderIDContentLabel release];
    
    UILabel * orderPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 65, 80, 20)];
    orderPriceShowLabel.backgroundColor = [UIColor clearColor];
    orderPriceShowLabel.font = [UIFont boldSystemFontOfSize:16];
    orderPriceShowLabel.text = @"订单金额:";
    [orderInfoView addSubview:orderPriceShowLabel];
    [orderPriceShowLabel release];
    
    UILabel * orderPriceContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 65, 220, 20)];
    orderPriceContentLabel.backgroundColor = [UIColor clearColor];
    orderPriceContentLabel.textColor = [UIColor redColor];
    orderPriceContentLabel.font = [UIFont boldSystemFontOfSize:17];
    orderPriceContentLabel.text = [NSString stringWithFormat:@"¥%@",_orderPrice];
    [orderInfoView addSubview:orderPriceContentLabel];
    [orderPriceContentLabel release];
    
    [self.view addSubview:orderInfoView];
    [orderInfoView release];
    
    //支付滚动信息
    UIScrollView *payScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 110, 310, 270)];
    
    UIView *payView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 320)];
    payView.backgroundColor = [UIColor whiteColor];
    payView.layer.cornerRadius = 10;
    
    UILabel * supportLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 296, 70)];
    supportLabel.backgroundColor = [UIColor clearColor];
    supportLabel.textColor = [UIColor grayColor];
    supportLabel.lineBreakMode = UILineBreakModeWordWrap;
    supportLabel.font = [UIFont systemFontOfSize:13];
    supportLabel.numberOfLines = 0;
    supportLabel.text = @"支持以下银行账号(仅借记卡)：农行、建行、交行、中行、邮储、招行、华夏、光大、中信、浦发、长沙银行。(不需要开通电话银行，不需要开通网银即可支付)";
    [payView addSubview:supportLabel];
    [supportLabel release];
    
    UILabel * bankCardNOShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 80, 20)];
    bankCardNOShowLabel.backgroundColor = [UIColor clearColor];
    bankCardNOShowLabel.font = [UIFont boldSystemFontOfSize:16];
    bankCardNOShowLabel.text = @"银行卡号:";
    [payView addSubview:bankCardNOShowLabel];
    [bankCardNOShowLabel release];
    
    UITextField *bankCardNOContentField = [[UITextField alloc] initWithFrame:CGRectMake(5, 105, 300, 30)];
    bankCardNOContentField.borderStyle = UITextBorderStyleRoundedRect;
    bankCardNOContentField.placeholder = @"必填";
    bankCardNOContentField.clearButtonMode = UITextFieldViewModeWhileEditing;
    bankCardNOContentField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    bankCardNOContentField.returnKeyType = UIReturnKeyDone;
    [bankCardNOContentField addTarget:self action:@selector(textFieldDone) forControlEvents:UIControlEventEditingDidEndOnExit];
    bankCardNOContentField.delegate = self;
    bankCardNOContentField.tag = kBankCardNOContentFieldTag;
    self.bankCardNOContentField = bankCardNOContentField;
    [payView addSubview:bankCardNOContentField];
    [bankCardNOContentField release];
    
    UILabel * identityNOShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 145, 80, 20)];
    identityNOShowLabel.backgroundColor = [UIColor clearColor];
    identityNOShowLabel.font = [UIFont boldSystemFontOfSize:16];
    identityNOShowLabel.text = @"身份证号:";
    [payView addSubview:identityNOShowLabel];
    [identityNOShowLabel release];
    
    UITextField *identityNOContentField = [[UITextField alloc] initWithFrame:CGRectMake(5, 170, 300, 30)];
    identityNOContentField.borderStyle = UITextBorderStyleRoundedRect;
    identityNOContentField.placeholder = @"必填";
    identityNOContentField.clearButtonMode = UITextFieldViewModeWhileEditing;
    identityNOContentField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    identityNOContentField.returnKeyType = UIReturnKeyDone;
    [identityNOContentField addTarget:self action:@selector(textFieldDone) forControlEvents:UIControlEventEditingDidEndOnExit];
    identityNOContentField.delegate = self;
    identityNOContentField.tag = kIdentityNOContentFieldTag;
    if (loginDict) {
        if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
            identityNOContentField.text = [memberDict objectForKey:@"idNumber"];
        }
    }
    self.identityNOContentField = identityNOContentField;
    [payView addSubview:identityNOContentField];
    [identityNOContentField release];
    
    UIImageView * dottedLineTwoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
    dottedLineTwoView.frame = CGRectMake(0, 205, 310, 2);
    [payView addSubview:dottedLineTwoView];
    [dottedLineTwoView release];
    
    UILabel * supportTwoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 215, 296, 30)];
    supportTwoLabel.backgroundColor = [UIColor clearColor];
    supportTwoLabel.textColor = [UIColor grayColor];
    supportTwoLabel.lineBreakMode = UILineBreakModeWordWrap;
    supportTwoLabel.font = [UIFont systemFontOfSize:13];
    supportTwoLabel.numberOfLines = 0;
    supportTwoLabel.text = @"提交信息后系统将为您拨出确认电话到此手机，您可按语音提示进行下一步操作完成付款。";
    [payView addSubview:supportTwoLabel];
    [supportTwoLabel release];
    
    UILabel * phoneNOShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 250, 80, 20)];
    phoneNOShowLabel.backgroundColor = [UIColor clearColor];
    phoneNOShowLabel.font = [UIFont boldSystemFontOfSize:16];
    phoneNOShowLabel.text = @"手机号码:";
    [payView addSubview:phoneNOShowLabel];
    [phoneNOShowLabel release];
    
    UITextField *phoneNOContentField = [[UITextField alloc] initWithFrame:CGRectMake(5, 275, 300, 30)];
    phoneNOContentField.borderStyle = UITextBorderStyleRoundedRect;
    phoneNOContentField.placeholder = @"必填";
    phoneNOContentField.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneNOContentField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    phoneNOContentField.returnKeyType = UIReturnKeyDone;
    [phoneNOContentField addTarget:self action:@selector(textFieldDone) forControlEvents:UIControlEventEditingDidEndOnExit];
    phoneNOContentField.delegate = self;
    phoneNOContentField.tag = kPhoneNOContentFieldTag;
    if (loginDict) {
        if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
            phoneNOContentField.text = [memberDict objectForKey:@"phone"];
        }
    }
    self.phoneNOContentField = phoneNOContentField;
    [payView addSubview:phoneNOContentField];
    [phoneNOContentField release];
    
    UIButton *allinTelPayButton = [[UIButton alloc] init];
	[allinTelPayButton setFrame:CGRectMake(0, 335, 310, 40)];
	[allinTelPayButton setTitle:@"电话支付" forState:UIControlStateNormal];
    [allinTelPayButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
    [allinTelPayButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
	[allinTelPayButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
	[allinTelPayButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
	[allinTelPayButton addTarget:self action:@selector(allinTelPayButtonPress) forControlEvents:UIControlEventTouchUpInside];
	[payScrollView addSubview:allinTelPayButton];
	[allinTelPayButton release];
    
    self.payScrollView = payScrollView;
    [payScrollView addSubview:payView];
    [payView release];
    
    payScrollView.contentSize = CGSizeMake(310, 390);
    [self.view addSubview:payScrollView];
    [payScrollView release];
    
    //底部视图的设置
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

- (void)textFieldDone{
    [self.view becomeFirstResponder];
}

- (void)allinTelPayButtonPress{
    float orderPrice = [_orderPrice floatValue];
     
    if (orderPrice<100||orderPrice>5000) {
        UIAlertView *alertview = [[[UIAlertView alloc] initWithTitle:nil message:@"电话支付单笔金额暂时限额¥100～¥5000之间,请选择其他支付方式" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil]autorelease];
        [alertview show];
    } else {
        int check = [self checkAndSaveIn];
        
        NSString * showMes = nil;
        switch (check) {
            case 1:
                showMes = @"您似乎还没输入银行卡号";
                break;
            case 2:
                showMes = @"您似乎还没输入身份证号";
                break;
            case 3:
                showMes = @"请输入有效的身份证号";
                break;
            case 4:
                showMes = @"您似乎还没输入手机号码";
                break;
            case 5:
                showMes = @"请输入有效的手机号码";
                break;
        }
        
        if (check != 0) {
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
            [hud show:YES];
            [hud hide:YES afterDelay:2];
        }else {
            _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            _hud.bgRGB = [PiosaColorManager progressColor];
            [self.navigationController.view addSubview:_hud];
            _hud.delegate = self;
            _hud.minSize = CGSizeMake(135.f, 135.f);
            _hud.labelText = @"提交中...";
            [_hud show:YES];
            
            NSString *postData = [[NSString alloc] initWithData:[self generateAllinTelPayRequestPostXMLData] encoding:NSUTF8StringEncoding];
            NSLog(@"requestStart\n");
            NSLog(@"%@\n", postData);
            
            ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: ALLIN_TELPAY_ADDRESS]] autorelease];
            [req addRequestHeader:@"API-Version" value:API_VERSION];
            req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
            [req appendPostData:[self generateAllinTelPayRequestPostXMLData]];
            [req setDelegate:self];
            [req startAsynchronous]; // 执行异步post
        }
    }
}

- (int) checkAndSaveIn{
    if (self.bankCardNOContentField.text == nil||[self.bankCardNOContentField.text length]==0) {
		return 1;
	}
    
    if (self.identityNOContentField.text == nil||[self.identityNOContentField.text length]==0) {
		return 2;
	} else {
		if (![CommonTools verifyIDNumberFormat:self.identityNOContentField.text]) {
			return 3;
		}
	}
    
    if (self.phoneNOContentField.text == nil||[self.phoneNOContentField.text length]==0) {
		return 4;
	} else {
		if (![CommonTools verifyPhoneFormat:self.phoneNOContentField.text]) {
			return 5;
		}
	}
    
    return 0;
}

- (NSData*)generateAllinTelPayRequestPostXMLData{
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"memberID"stringValue:@""]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"eCardNO"stringValue:@""]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"orderNo"stringValue:_orderID]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"bankCardNo"stringValue:self.bankCardNOContentField.text]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"phone"stringValue:self.phoneNOContentField.text]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"idNumber"stringValue:self.identityNOContentField.text]];
    
    //[conditionElement addChild:[GDataXMLNode elementWithName:@"money"stringValue:_orderPrice]]; //测试环境
    [conditionElement addChild:[GDataXMLNode elementWithName:@"money"stringValue:[NSString stringWithFormat:@"%d",[_orderPrice intValue]]]]; //正式环境
    [conditionElement addChild:[GDataXMLNode elementWithName:@"payType"stringValue:_payType]];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    return document.XMLData;
}

#pragma mark -
#pragma mark ASIHTTP Delegate Methods

// 响应有响应 : 但可能是错误响应, 如 404，或查询结果为空，则不跳转到下一个机票展示页面
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);
    [_hud hide:YES];
    if ((responseString != nil) && [responseString length] > 0) {
		AllinTelPayResponseModel *allinTelPayResponseModel = [ResponseParser loadAllinTelPayResponse:[request responseData]];
		
		if (allinTelPayResponseModel.resultCode == nil || [allinTelPayResponseModel.resultCode length] == 0 || [allinTelPayResponseModel.resultCode intValue] != 0) {
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
            hud.labelText = allinTelPayResponseModel.resultMessage;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
		} else {
            ALLinTelPayResultViewController *aLLinTelPayResultViewController = [[ALLinTelPayResultViewController alloc] initWithOrderID:_orderID andPrice:_orderPrice andAllinID:allinTelPayResponseModel.allinID andAllinCreatetime:allinTelPayResponseModel.allinCreatetime andPhone:self.phoneNOContentField.text];
            [self.navigationController pushViewController:aLLinTelPayResultViewController animated:YES];
            [aLLinTelPayResultViewController release];
		}
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
    NSLog(@"%f",self.payScrollView.contentOffset.y);
    switch (textField.tag) {
        case kBankCardNOContentFieldTag:
            [self.payScrollView setContentOffset:CGPointMake(0, 82) animated:YES];
            break;
        case kIdentityNOContentFieldTag:
            [self.payScrollView setContentOffset:CGPointMake(0, 145) animated:YES];
            break;
        case kPhoneNOContentFieldTag:
            [self.payScrollView setContentOffset:CGPointMake(0, 250) animated:YES];
            [self.payScrollView setContentInset:UIEdgeInsetsMake(0, 0, 130, 0)];
            break;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"%f",self.payScrollView.contentOffset.y);
    switch (textField.tag) {
        case kBankCardNOContentFieldTag:
            [self.payScrollView setContentOffset:CGPointMake(0, 82) animated:YES];
            break;
        case kIdentityNOContentFieldTag:
            [self.payScrollView setContentOffset:CGPointMake(0, 120) animated:YES];
            break;
        case kPhoneNOContentFieldTag:
            [self.payScrollView setContentInset:UIEdgeInsetsZero];
            break;
    }
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
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    [hud release];
	hud = nil;
}

@end

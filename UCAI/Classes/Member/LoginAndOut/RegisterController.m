//
//  RegisterController.m
//  JingDuTianXia
//
//  Created by admin on 11-9-30.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "RegisterController.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "ResponseParser.h"
#import "CommonTools.h"
#import "MemberRegisterResponse.h"
#import "StaticConf.h"
#import "PiosaFileManager.h"

#define kHUDhiddenTag 101 //只需要消失提交框
#define kHUDhiddenAndPopTag 102 //需要在提交框消失后退出视图

#define kRegisterCellLabelTag 201
#define kRegisterCellTextFieldTag 202


@implementation RegisterController

@synthesize registerTableView;
@synthesize loginName;
@synthesize phone;
@synthesize email;
@synthesize loginCode;
@synthesize secondLoginCode;

- (void)viewDidUnload {
    [super viewDidUnload];
	self.loginName = nil;
	self.phone = nil;
	self.email = nil;
	self.loginCode = nil;
	self.secondLoginCode = nil;
    self.registerTableView = nil;
}


- (void)dealloc {
	[self.loginName release];
	[self.phone release];
	[self.email release];
	[self.loginCode release];
	[self.secondLoginCode release];
	[self.registerTableView release];
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
	[self.registerTableView becomeFirstResponder];
}

//注册按钮的响应函数
- (void)registerButtonPress {
    for (UIView *oneView in self.registerTableView.subviews) {
		if ([oneView isMemberOfClass:[UITableViewCell class]]) {
			UITableViewCell *registerCell = (UITableViewCell *)oneView;
			UITextField *textField = (UITextField *)[registerCell viewWithTag:kRegisterCellTextFieldTag];
			[textField resignFirstResponder];
		}
	}
	
	int check = [self checkAndSaveIn];
	
	NSString * showMes = nil;
    NSString * deShowMes = nil;
	switch (check) {
		case 1:
			showMes = @"您似乎还未输入用户名";
			break;
		case 2:
			showMes = @"用户名不符合规则(长度3-20)";
            deShowMes = @"请重新输入";
			break;
		case 3:
			showMes = @"您似乎还未输入手机号码";
			break;
		case 4:
			showMes = @"请您输入有效的手机号码";
			break;
		case 5:
			showMes = @"您输入的邮箱地址有误";
            deShowMes = @"正确格式:jindu@hotmail.com";
			break;
		case 6:
			showMes = @"您似乎还未输入密码";
			break;
		case 7:
			showMes = @"密码不符合规则(长度6-30)";
            deShowMes = @"请重新输入";
			break;
		case 8:
			showMes = @"您似乎还未输入确认密码";
			break;
		case 9:
			showMes = @"两次密码输入不一致";
            deShowMes = @"请重新输入";
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
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = showMes;
        hud.detailsLabelText = deShowMes;
        hud.tag = kHUDhiddenTag;
        [hud show:YES];
        [hud hide:YES afterDelay:2];
	} else {
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _hud.bgRGB = [PiosaColorManager progressColor];
        [self.navigationController.view addSubview:_hud];
        _hud.delegate = self;
        _hud.minSize = CGSizeMake(135.f, 135.f);
        _hud.labelText = @"注册中...";
        _hud.tag = kHUDhiddenTag;
        [_hud show:YES];
		
		NSString *url = MEMBER_REGISTER_ADDRESS;
		ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: url]] autorelease];
		[req addRequestHeader:@"API-Version" value:API_VERSION];
		req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
		[req appendPostData:[self generateMemberRegisterRequestPostXMLData]];
		[req setDelegate:self];
		[req startAsynchronous]; // 执行异步post
        
        NSLog(@"----phone:%@",self.phone);
         NSLog(@"----email:%@",self.email);
         NSLog(@"----loginName:%@",self.loginName);
		[url release];
	}

}

//检查并保存所输入的注册资料是否合法
//0-合法;
//1-未输入用户名;
//2-用户名不符合规则(长度3-20)
//3-未输入手机号码;
//4-未输入有效的手机号码;
//5-未输入有效的电子邮箱;
//6-未输入密码;
//7-密码不符合规则(长度6-30)
//8-未输入确认密码;
//9-确认密码与登陆密码不一致
- (int) checkAndSaveIn {
	self.loginName = @"";
	self.phone = @"";
	self.email = @"";
	self.loginCode = @"";
	self.secondLoginCode = @"";
	
	UITableViewCell *registerCell = nil;
	for (UIView *oneView in self.registerTableView.subviews) {
		if ([oneView isMemberOfClass:[UITableViewCell class]]) {
			registerCell = (UITableViewCell *)oneView;
			
			NSIndexPath *textFieldIndexPath = [self.registerTableView indexPathForCell:registerCell];
			NSUInteger row = [textFieldIndexPath row];
			
			UITextField *textField = (UITextField *)[registerCell viewWithTag:kRegisterCellTextFieldTag];
			switch (row) {
				case 0:
					self.loginName = textField.text;
					break;
				case 1:
					self.phone = textField.text;
					break;
				case 2:					
					self.email = textField.text;
					break;
				case 3:
					self.loginCode = textField.text;
					break;
				case 4:
					self.secondLoginCode = textField.text;
					break;
			}
		}
	}
	
	
	if (self.loginName == nil || [@"" isEqualToString:self.loginName] == YES) {
		return 1;
	} else {
		if ([self.loginName length]<3||[self.loginName length]>20) {
			return 2;
		}
	}

	
	if (self.phone==nil || [@"" isEqualToString:self.phone] == YES) {
		return 3;
	} else {
		if (![CommonTools verifyPhoneFormat:self.phone]) {
			return 4;
		}
	}

	
	if (self.email!=nil && ![@"" isEqualToString:self.email] == YES) {
        NSLog(@"%@",self.email);
		if (![CommonTools verifyEmailFormat:self.email]) {
			return 5;
		}
	}

	
	if (self.loginCode==nil || [@"" isEqualToString:self.loginCode] == YES) {
		return 6;
	} else if ([self.loginCode length]<6||[self.loginCode length]>30){
		return 7;
	} else if (self.secondLoginCode==nil || [@"" isEqualToString:self.secondLoginCode] == YES) {
		return 8;
	} else if (![self.loginCode isEqualToString:self.secondLoginCode]) {
		return 9;
	}

	return 0;
}

- (NSData*)generateMemberRegisterRequestPostXMLData{
	
	//编辑用户注册请求的xml数据
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"registerName" stringValue:self.loginName]];
	[conditionElement addChild:[GDataXMLNode elementWithName:@"phone" stringValue:self.phone]];
	[conditionElement addChild:[GDataXMLNode elementWithName:@"email" stringValue:self.email]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"password" stringValue:[CommonTools aes:self.loginCode key:@"K14FO23EB32NE41G" iv:@"0A2B4C6D8E1F5793"]]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"IMEI" stringValue:@"1234567890"]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"simID" stringValue:@"9876543210"]];
    [requestElement addChild:conditionElement];
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    
    NSData *xmlData = document.XMLData;
	return xmlData;
}

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应 : 但可能是错误响应, 如 404，或查询结果为空，则不跳转到下一个机票展示页面
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"------------响应内容：%@\n", responseString);
    
    // 关闭加载框
    [_hud hide:YES];
    if ((responseString != nil) && [responseString length] > 0) {
        
		MemberRegisterResponse *memberRegisterResponse = [ResponseParser loadMemberRegisterResponse:[request responseData]];
		
		if (memberRegisterResponse.result_code == nil || [memberRegisterResponse.result_code length] == 0 || [memberRegisterResponse.result_code intValue] != 0) {
			// 注册失败
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
            hud.labelText = memberRegisterResponse.result_message;
            hud.tag = kHUDhiddenTag;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
		}else {
			//注册成功
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
            hud.labelText = @"恭喜您已成功注册,返回登陆!";
            hud.tag = kHUDhiddenAndPopTag;
            [hud show:YES];
            [hud hide:YES afterDelay:4];
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
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"会员注册";
	
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
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 386) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.registerTableView = tableView;
    [self.view addSubview:self.registerTableView];
    [tableView release];
	
	UIButton *registerButton = [[UIButton alloc] init];
	[registerButton setFrame:CGRectMake(10, 250, 300, 40)];
	[registerButton setTitle:@"注    册" forState:UIControlStateNormal];
    [registerButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
    [registerButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
	[registerButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
	[registerButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
	[registerButton addTarget:self action:@selector(registerButtonPress) forControlEvents:UIControlEventTouchUpInside];
	[self.registerTableView addSubview:registerButton];
	[registerButton release];
    
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
#pragma mark Text Field Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	NSLog(@"textFieldDidBeginEditing");
	
	UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
	UITableView *table = (UITableView *)[cell superview];
	NSIndexPath *textFieldIndexPath = [table indexPathForCell:cell];
	NSUInteger row = [textFieldIndexPath row];
	
	switch (row) {
		case 4:
			//当文本输入框为“输入确认密码”，即在表格中的第五行表格时，才需要移动表格视图，以免键盘盖住输入框
			[self.registerTableView setContentOffset:CGPointMake(0, 30) animated:YES];
			break;
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	//文本框输入结束编辑时，表格视图回复原位
	[self.registerTableView setContentOffset:CGPointMake(0, 0) animated:YES];
	[textField resignFirstResponder];
}


#pragma mark -
#pragma mark Table Data Source Methods
//返回分区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UILabel *tempShowLabel;
    UITextField *tempContentTextField;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 78, 22)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentRight;
        label.font = [UIFont boldSystemFontOfSize:16];
        label.tag = kRegisterCellLabelTag;
        tempShowLabel = label;
        [cell.contentView addSubview:label];
        [label release];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(106, 10, 194, 22)];
        textField.font = [UIFont systemFontOfSize:16];
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        [textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
        textField.tag = kRegisterCellTextFieldTag;
        tempContentTextField = textField;
        [cell.contentView addSubview:textField];
        [textField release];
	} else {
        tempShowLabel = (UILabel *)[cell viewWithTag:kRegisterCellLabelTag];
        tempContentTextField = (UITextField *)[cell viewWithTag:kRegisterCellTextFieldTag];
    }
	
	
	NSInteger row = [indexPath row];
	switch (row) {
		case 0:
			tempShowLabel.text = @"用户名:";
			tempContentTextField.placeholder = @"必填";
			break;
		case 1:
			tempShowLabel.text = @"手机号码:";
			tempContentTextField.placeholder = @"必填";
			tempContentTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			break;
		case 2:
			tempShowLabel.text = @"电子邮箱:";
			tempContentTextField.placeholder = @"选填";
			tempContentTextField.keyboardType = UIKeyboardTypeEmailAddress;
			break;
		case 3:
			tempShowLabel.text = @"密码:";
			tempContentTextField.placeholder = @"必填";
			tempContentTextField.secureTextEntry = YES;
			break;
		case 4:
			tempShowLabel.text = @"确认密码:";
			tempContentTextField.placeholder = @"必填";
			tempContentTextField.secureTextEntry = YES;
			break;
	}
	
	//设置表格单元选中的格式为无
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
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

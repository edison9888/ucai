//
//  MemberLoginViewController.m
//  UCAI
//
//  Created by  on 11-12-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PiosaFileManager.h"

#import "MemberLoginViewController.h"
#import "RegisterController.h"
#import "MemberPasswordBackController.h"

#import "OrderSearchMemberViewController.h"

#import "CommonTools.h"
#import "StaticConf.h"
#import "MemberPasswordBackController.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "ResponseParser.h"

#import "MemberLoginResponse.h"

#import "MemberCenterFirstController.h"

#define saveLoginNameCheckboxTag 1
#define saveLoginPasswordCheckboxTag 2
#define autoLoginCheckboxTag 3

@implementation MemberLoginViewController

@synthesize loginScrollView = _loginScrollView;
@synthesize loginTableView = _loginTableView;
@synthesize loginNameTextField = _loginNameTextField;
@synthesize loginCodeTextField = _loginCodeTextField;

@synthesize saveLoginNameCheckbox = _saveLoginNameCheckbox;
@synthesize saveLoginPasswordCheckbox = _saveLoginPasswordCheckbox;
@synthesize autoLoginCheckbox = _autoLoginCheckbox;

- (MemberLoginViewController *)initWithComeFromType:(NSUInteger) loginComeFromType{
    self = [super init];
    _loginComeFromType = loginComeFromType;
    return self;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [_loginScrollView release];
    [_loginTableView release];
	[_loginNameTextField release];
	[_loginCodeTextField release];
    
    [_saveLoginNameCheckbox release];
    [_saveLoginPasswordCheckbox release];
    [_autoLoginCheckbox release];
	
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    self.title = @"会员登陆";
	
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
    
    UIScrollView *loginScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 386)];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 20, 270, 100)];
    NSString *bigLogoPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"bigLogo" inDirectory:@"CommonView"];
    logoImageView.image = [UIImage imageNamed:bigLogoPath];
    [loginScrollView addSubview:logoImageView];
    [logoImageView release];
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 130, 320, 110) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.scrollEnabled = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.loginTableView = tableView;
    [loginScrollView addSubview:self.loginTableView];
    [tableView release];
    
    NSString *checkboxButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"checkbox_normal" inDirectory:@"CommonView/CheckBox"];
    NSString *checkboxButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"checkbox_selected" inDirectory:@"CommonView/CheckBox"];
    
    //保存登陆名选择框
	UIButton *saveLoginNameCheckbox = [[UIButton alloc] initWithFrame:CGRectMake(20,240,20,20)];
    [saveLoginNameCheckbox setImage:[UIImage imageNamed:checkboxButtonNormalPath] forState:UIControlStateNormal];
    [saveLoginNameCheckbox setImage:[UIImage imageNamed:checkboxButtonSelectedPath] forState:UIControlStateSelected];
    [saveLoginNameCheckbox addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
	saveLoginNameCheckbox.selected = YES;
	saveLoginNameCheckbox.tag = saveLoginNameCheckboxTag;
    self.saveLoginNameCheckbox = saveLoginNameCheckbox;
	[loginScrollView addSubview:saveLoginNameCheckbox]; 
    [saveLoginNameCheckbox release];
	
	//保存登陆名按钮
    UIButton *saveLoginNameButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 230, 70, 40)];
    saveLoginNameButton.backgroundColor = [UIColor clearColor];
    saveLoginNameButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    [saveLoginNameButton setTitle:@"保存登陆名  " forState:UIControlStateNormal];
    saveLoginNameButton.tag = saveLoginNameCheckboxTag;
    [saveLoginNameButton addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    [loginScrollView addSubview:saveLoginNameButton];
    [saveLoginNameButton release];
	
	//保存登陆密码选择框
	UIButton *saveLoginPasswordCheckbox = [[UIButton alloc] initWithFrame:CGRectMake(130,240,20,20)];
    [saveLoginPasswordCheckbox setImage:[UIImage imageNamed:checkboxButtonNormalPath] forState:UIControlStateNormal];
    [saveLoginPasswordCheckbox setImage:[UIImage imageNamed:checkboxButtonSelectedPath] forState:UIControlStateSelected];
    [saveLoginPasswordCheckbox addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
	saveLoginPasswordCheckbox.tag = saveLoginPasswordCheckboxTag;
    self.saveLoginPasswordCheckbox = saveLoginPasswordCheckbox;
	[loginScrollView addSubview:saveLoginPasswordCheckbox]; 
    [saveLoginPasswordCheckbox release];
	
    //保存登陆密码按钮
    UIButton *saveLoginPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(150, 230, 60, 40)];
    saveLoginPasswordButton.backgroundColor = [UIColor clearColor];
    saveLoginPasswordButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    [saveLoginPasswordButton setTitle:@"保存密码  " forState:UIControlStateNormal];
    saveLoginPasswordButton.tag = saveLoginPasswordCheckboxTag;
    [saveLoginPasswordButton addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    [loginScrollView addSubview:saveLoginPasswordButton];
    [saveLoginPasswordButton release];
    
	//自动登陆选择框
	UIButton *autoLoginCheckbox = [[UIButton alloc] initWithFrame:CGRectMake(230,240,20,20)];
    [autoLoginCheckbox setImage:[UIImage imageNamed:checkboxButtonNormalPath] forState:UIControlStateNormal];
    [autoLoginCheckbox setImage:[UIImage imageNamed:checkboxButtonSelectedPath] forState:UIControlStateSelected];
    [autoLoginCheckbox addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
	autoLoginCheckbox.tag = autoLoginCheckboxTag;
    self.autoLoginCheckbox = autoLoginCheckbox;
	[loginScrollView addSubview:autoLoginCheckbox]; 
    [autoLoginCheckbox release];
    
    //自动登陆按钮
    UIButton *autoLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(250, 230, 60, 40)];
    autoLoginButton.backgroundColor = [UIColor clearColor];
    autoLoginButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    [autoLoginButton setTitle:@"自动登陆  " forState:UIControlStateNormal];
    autoLoginButton.tag = autoLoginCheckboxTag;
    [autoLoginButton addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    [loginScrollView addSubview:autoLoginButton];
    [autoLoginButton release];
    
    //登陆按钮
    UIButton *loginButton = [[UIButton alloc] init];
	[loginButton setFrame:CGRectMake(10, 290, 300, 40)];
	[loginButton setTitle:@"登    陆" forState:UIControlStateNormal];
    [loginButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
    [loginButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
	[loginButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
	[loginButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
	[loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[loginScrollView addSubview:loginButton];
	[loginButton release];
	
	//注册按钮
	UIButton* registButton= [UIButton buttonWithType:UIButtonTypeCustom];
	[registButton setFrame:CGRectMake(40, 340, 100, 30)];
    registButton.backgroundColor = [UIColor clearColor];
	[registButton setTitle:@"会员注册 >" forState:UIControlStateNormal];
    registButton.titleLabel.font=[UIFont systemFontOfSize:16];
	[registButton addTarget:self action:@selector(registerButtonPress) forControlEvents:UIControlEventTouchUpInside];
	[loginScrollView addSubview:registButton];
	
	//忘记密码按钮
	UIButton* forgetPasswordButton= [UIButton buttonWithType:UIButtonTypeCustom];
	[forgetPasswordButton setFrame:CGRectMake(180, 340, 100, 30)];
	[forgetPasswordButton setTitle:@"忘记密码 >" forState:UIControlStateNormal];
    forgetPasswordButton.titleLabel.font=[UIFont systemFontOfSize:16];
	[forgetPasswordButton addTarget:self action:@selector(forgetPasswordButtonPress) forControlEvents:UIControlEventTouchUpInside];
	[loginScrollView addSubview:forgetPasswordButton];
    
    self.loginScrollView = loginScrollView;
    [self.view addSubview:loginScrollView];
    [loginScrollView release];
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    
    if (loginDict) {
        //如果保存了登陆帐户名，此时设置登陆帐户
        if ([[loginDict objectForKey:@"isSaveLoginName"] boolValue]) {
            self.loginNameTextField.text = [loginDict objectForKey:@"loginName"];
        }
        
        //如果保存了登陆密码，此时设置登陆密码
        if ([[loginDict objectForKey:@"isSaveLoginPassword"] boolValue]) {
            self.loginCodeTextField.text = [loginDict objectForKey:@"loginPassword"];
            self.saveLoginPasswordCheckbox.selected = YES;
        }
    }
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

//响应登陆帐号文本输入框的挑选按钮操作，用于换行
- (IBAction)textFieldNext:(id)sender{
    [self.loginCodeTextField becomeFirstResponder];
}

//响应登陆密码文本输入框的完成按钮操作，用于滑屏
- (IBAction)textFieldDone:(id)sender{
    //[self.view becomeFirstResponder];
    [self.loginScrollView setContentOffset:CGPointZero animated:YES];
}

//响应登陆选项的复选框
-(void)checkboxClick:(UIButton *)btn
{
	switch (btn.tag) {
		case saveLoginNameCheckboxTag:
            self.saveLoginNameCheckbox.selected = !self.saveLoginNameCheckbox.selected;
			if (!self.saveLoginNameCheckbox.selected) {
				self.saveLoginPasswordCheckbox.selected = NO;
				self.autoLoginCheckbox.selected = NO;
			}
			break;
		case saveLoginPasswordCheckboxTag:
            self.saveLoginPasswordCheckbox.selected = !self.saveLoginPasswordCheckbox.selected;
			if (self.saveLoginPasswordCheckbox.selected) {
				self.saveLoginNameCheckbox.selected = YES;
			} else {
				self.autoLoginCheckbox.selected = NO;
			}
			break;
		case autoLoginCheckboxTag:
            self.autoLoginCheckbox.selected = !self.autoLoginCheckbox.selected;
			if (self.autoLoginCheckbox.selected) {
				self.saveLoginNameCheckbox.selected = YES;
				self.saveLoginPasswordCheckbox.selected = YES;
			}
			break;
	}
}

- (IBAction)loginButtonPressed:(id)sender{
    [self.loginNameTextField resignFirstResponder];
    [self.loginCodeTextField resignFirstResponder];
    [self.loginScrollView setContentOffset:CGPointZero animated:YES];
	
	int check = [self checkAndSaveIn];
	
	NSString * showMes = nil;
	switch (check) {
		case 1:
			showMes = @"您似乎还没输入帐号";
			break;
		case 2:
			showMes = @"您似乎还没输入密码";
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
        [hud show:YES];
        [hud hide:YES afterDelay:2];
	}else {
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _hud.bgRGB = [PiosaColorManager progressColor];
        [self.navigationController.view addSubview:_hud];
        _hud.delegate = self;
        _hud.minSize = CGSizeMake(135.f, 135.f);
        _hud.labelText = @"登陆中...";
        [_hud show:YES];
		
		NSString *url = MEMBER_LOGIN_ADDRESS;
		ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: url]] autorelease];
		[req addRequestHeader:@"API-Version" value:API_VERSION];
		req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
		[req appendPostData:[self generateMemberLoginRequestPostXMLData]];
		[req setDelegate:self];
		[req startAsynchronous]; // 执行异步post
		[url release];
	}
}

//检查并保存所输入的登陆帐号与登陆密码是否合法
//0-合法;1-未输入帐号;2-未输入密码
- (int) checkAndSaveIn {
	if (self.loginNameTextField.text == nil || [@"" isEqualToString:self.loginNameTextField.text]) {
		return 1;
	} else if (self.loginCodeTextField.text == nil || [@"" isEqualToString:self.loginCodeTextField.text] == YES) {
		return 2;
	}
	return 0;
}

//注册按钮的响应函数
- (void)registerButtonPress {
	RegisterController *registerController = [[RegisterController alloc] init];
	[self.navigationController pushViewController:registerController animated:YES];
	[registerController release];
}

//找回密码按钮的响应函数
- (void)forgetPasswordButtonPress {
	MemberPasswordBackController *memberPasswordBackController = [[MemberPasswordBackController alloc] initWithStyle:UITableViewStyleGrouped];
	[self.navigationController pushViewController:memberPasswordBackController animated:YES];
	[memberPasswordBackController release];
}

- (NSData*)generateMemberLoginRequestPostXMLData{
	
	//编辑用户登陆请求的xml数据
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"loginName" stringValue:self.loginNameTextField.text]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"password" stringValue:[CommonTools aes:self.loginCodeTextField.text key:@"K14FO23EB32NE41G" iv:@"0A2B4C6D8E1F5793"]]];
	
	[conditionElement addChild:[GDataXMLNode elementWithName:@"IMEI" stringValue:[[UIDevice currentDevice] uniqueIdentifier]]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"simID" stringValue:@""]];
    [requestElement addChild:conditionElement];
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    
    NSData *xmlData = document.XMLData;
	return xmlData;
}

#pragma mark -
#pragma mark ASIHTTP Delegate Methods

// 响应有响应 : 但可能是错误响应, 如 404，或查询结果为空，则不跳转到下一个机票展示页面
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);
    
    // 关闭加载框
    [_hud hide:YES];
    if ((responseString != nil) && [responseString length] > 0) {
        
		MemberLoginResponse *memberLoginResponse = [ResponseParser loadMemberLoginResponse:[request responseData]];//plistXML
		
		if (memberLoginResponse.result_code == nil || [memberLoginResponse.result_code length] == 0 || [memberLoginResponse.result_code intValue] != 0) {
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
            hud.labelText = memberLoginResponse.result_message;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
		} else {            
            NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
            [loginDict setObject:@"1" forKey:@"isLogin"];
            [loginDict setObject:[NSString stringWithFormat:@"%d", self.saveLoginNameCheckbox.selected] forKey:@"isSaveLoginName"];
            [loginDict setObject:[NSString stringWithFormat:@"%d", self.saveLoginPasswordCheckbox.selected] forKey:@"isSaveLoginPassword"];
            [loginDict setObject:[NSString stringWithFormat:@"%d", self.autoLoginCheckbox.selected] forKey:@"isAutoLogin"];
            [loginDict setObject:self.loginNameTextField.text forKey:@"loginName"];
            [loginDict setObject:self.loginCodeTextField.text forKey:@"loginPassword"];
            [PiosaFileManager writeApplicationPlist:loginDict toFile:UCAI_LOGIN_FILE_NAME];
            
            NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
            if (memberDict) {
                [memberDict setObject:memberLoginResponse.memberID forKey:@"memberID"];
                [memberDict setObject:memberLoginResponse.registerName forKey:@"registerName"];
                [memberDict setObject:memberLoginResponse.cardNO forKey:@"cardNO"];
                [memberDict setObject:memberLoginResponse.realName forKey:@"realName"];
                [memberDict setObject:memberLoginResponse.sex forKey:@"sex"];
                [memberDict setObject:memberLoginResponse.phone forKey:@"phone"];
                [memberDict setObject:memberLoginResponse.phoneVerifyStatus forKey:@"phoneVerifyStatus"];
                [memberDict setObject:memberLoginResponse.eMail forKey:@"eMail"];
                [memberDict setObject:memberLoginResponse.contactTel forKey:@"contactTel"];
                [memberDict setObject:memberLoginResponse.contactAddress forKey:@"contactAddress"];
                [memberDict setObject:memberLoginResponse.idNumber forKey:@"idNumber"];
                [memberDict setObject:memberLoginResponse.accPoints forKey:@"accPoints"];
                [memberDict setObject:memberLoginResponse.usablePoints forKey:@"usablePoints"];
                [memberDict setObject:memberLoginResponse.eCardNO forKey:@"eCardNO"];
                [memberDict setObject:memberLoginResponse.eCardUserName forKey:@"eCardUserName"];
                [memberDict setObject:memberLoginResponse.eCardStatus forKey:@"eCardStatus"];
                [PiosaFileManager writeApplicationPlist:memberDict toFile:UCAI_MEMBER_FILE_NAME];
            } else {
                NSMutableDictionary *memberDict = [NSMutableDictionary dictionaryWithCapacity:3];
                [memberDict setObject:memberLoginResponse.memberID forKey:@"memberID"];
                [memberDict setObject:memberLoginResponse.registerName forKey:@"registerName"];
                [memberDict setObject:memberLoginResponse.cardNO forKey:@"cardNO"];
                [memberDict setObject:memberLoginResponse.realName forKey:@"realName"];
                [memberDict setObject:memberLoginResponse.sex forKey:@"sex"];
                [memberDict setObject:memberLoginResponse.phone forKey:@"phone"];
                [memberDict setObject:memberLoginResponse.phoneVerifyStatus forKey:@"phoneVerifyStatus"];
                [memberDict setObject:memberLoginResponse.eMail forKey:@"eMail"];
                [memberDict setObject:memberLoginResponse.contactTel forKey:@"contactTel"];
                [memberDict setObject:memberLoginResponse.contactAddress forKey:@"contactAddress"];
                [memberDict setObject:memberLoginResponse.idNumber forKey:@"idNumber"];
                [memberDict setObject:memberLoginResponse.accPoints forKey:@"accPoints"];
                [memberDict setObject:memberLoginResponse.usablePoints forKey:@"usablePoints"];
                [memberDict setObject:memberLoginResponse.eCardNO forKey:@"eCardNO"];
                [memberDict setObject:memberLoginResponse.eCardUserName forKey:@"eCardUserName"];
                [memberDict setObject:memberLoginResponse.eCardStatus forKey:@"eCardStatus"];
                [PiosaFileManager writeApplicationPlist:memberDict toFile:UCAI_MEMBER_FILE_NAME];
            }
            switch (_loginComeFromType) {
                case 1:
                case 3:
                case 4:
                    [self.navigationController popViewControllerAnimated:YES];
                    break;
                case 2:
                {
                    MemberCenterFirstController *memberCenterfirstController = [[MemberCenterFirstController alloc] init];
                    [self.navigationController pushViewController:memberCenterfirstController animated:YES];
                    [memberCenterfirstController release];
                }
                    break;
            }  
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
	[self.loginScrollView setContentOffset:CGPointMake(0, 130) animated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        switch (indexPath.row) {
            case 0:
            {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
                label.backgroundColor = [UIColor clearColor];
                label.textAlignment = UITextAlignmentCenter;
                label.font = [UIFont boldSystemFontOfSize:16];
                label.text = @"帐号";
                [cell.contentView addSubview:label];
                [label release];
                
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
                textField.font = [UIFont systemFontOfSize:16];
                textField.placeholder = @"用户名/会员卡号/手机号码";
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.clearsOnBeginEditing = NO;
                textField.returnKeyType = UIReturnKeyNext;
                textField.delegate = self;
                [textField addTarget:self action:@selector(textFieldNext:) forControlEvents:UIControlEventEditingDidEndOnExit];
                self.loginNameTextField = textField;
                [cell.contentView addSubview:textField];
                [textField release];
            
            }
                break;
                
            case 1:
            {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
                label.backgroundColor = [UIColor clearColor];
                label.textAlignment = UITextAlignmentCenter;
                label.font = [UIFont boldSystemFontOfSize:16];
                label.text = @"密码";
                [cell.contentView addSubview:label];
                [label release];
                
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
                textField.font = [UIFont systemFontOfSize:16];
                textField.placeholder = @"6-30位数字和字母";
                textField.secureTextEntry = YES;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.clearsOnBeginEditing = NO;
                textField.returnKeyType = UIReturnKeyDone;
                textField.delegate = self;
                [textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                self.loginCodeTextField = textField;
                [cell.contentView addSubview:textField];
                [textField release];
                
            }
                break;
        }
    }
    
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
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    [hud release];
	hud = nil;
}

@end

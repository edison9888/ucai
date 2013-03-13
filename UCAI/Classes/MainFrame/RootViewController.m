//
//  RootViewController.m
//  JingDuTianXialoginAlertView
//
//  Created by Chen Menglin on 4/10/11.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"
#import "RootViewController.h"

#import "PiosaFileManager.h"

#import "MemberLoginViewController.h"
#import "HotelSearchController.h"
#import "FlightClassChoiceViewController.h"
#import "TrainSearchViewController.h"
#import "OrderSearchClassChoiceViewController.h"
#import "MemberCenterFirstController.h"
#import "CouponClassChoiceViewController.h"
#import "PhoneBillRechargeViewController.h"
#import "WeatherSearchViewController.h"
#import "FeedbackEditViewController.h"
#import "SettingChoiceViewController.h"

#import "CommonTools.h"
#import "GTMBase64.h"
#import "StaticConf.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "ResponseParser.h"

#import "MemberLoginResponse.h"

#define kNumberOfPages 2

#define kModuleButtonWidth 90
#define kModuleButtonHeight 105

#define kFirstModuleRow 20
#define kSecondModuleRow 137
#define kThridModuleRow 254

#define kFirstModuleVerticality 15
#define kSecondModuleVerticality 115
#define kThridModuleVerticality 215
#define kFourModuleVerticality 335


//自定义NavigationBar来实现背景图片的替换
@interface MyNavigationBar : UINavigationBar
@end

@implementation MyNavigationBar
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}
@end

@implementation UINavigationBar (LazyNavigationBar)
+ (Class)class {
    return NSClassFromString(@"MyNavigationBar");
}

-(void)drawRect:(CGRect)rect {
    NSString *bgPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"navigationBar" inDirectory:@"CommonView/NavigationItem"];
    UIImage *backImage = [UIImage imageNamed:bgPath];
    [backImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end
//end

@implementation RootViewController

@synthesize bgImageView = _bgImageView;
@synthesize phoneButton = _phoneButton;
@synthesize rootScrollView = _rootScrollView;
@synthesize rootPageControl = _rootPageControl;

- (id)init{
    
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(updateTheme:) 
                                                     name:kThemeDidChangeNotification 
                                                   object:nil];
        
        
        NSMutableDictionary *dict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
        
        if (dict) {
            [dict setObject:@"0" forKey:@"isLogin"];
            [PiosaFileManager writeApplicationPlist:dict toFile:UCAI_LOGIN_FILE_NAME];
        } else {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
            [dict setObject:@"" forKey:@"isSaveLoginName"];
            [dict setObject:@"" forKey:@"isSaveLoginPassword"];
            [dict setObject:@"" forKey:@"isAutoLogin"];
            [dict setObject:@"" forKey:@"loginName"];
            [dict setObject:@"" forKey:@"loginPassword"];
            [dict setObject:@"0" forKey:@"isLogin"];
            [PiosaFileManager writeApplicationPlist:dict toFile:UCAI_LOGIN_FILE_NAME];
        }
    }
    return self;
}

- (void)dealloc {
    [self.bgImageView release];
    [self.phoneButton release];
    [self.rootScrollView release];
    [self.rootPageControl release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
    [super loadView];
    
    //修改导航栏主题的颜色
    self.navigationController.navigationBar.tintColor = [PiosaColorManager barColor];
    
    //修改工具栏主题的颜色
    self.navigationController.toolbar.tintColor = [PiosaColorManager barColor];
    
    //设置标题视图
    NSString *titleLogoImageNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"titleLogo" inDirectory:@"RootView"];
    UIImageView *ucaiTitleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:titleLogoImageNormalPath]];
    ucaiTitleView.frame = CGRectMake(0, 0, 80, 35);
    self.navigationItem.titleView = ucaiTitleView;
    [ucaiTitleView release];
    
    //设置此视图控制器后的视图控制器所属回退按钮
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"悠行宝" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    [backBarButtonItem release];
    
    //首页导航栏左边显示用户信息
    UILabel * memberNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    memberNameLabel.textColor = [UIColor whiteColor];
    memberNameLabel.font=[UIFont systemFontOfSize:16];
    memberNameLabel.textAlignment = UITextAlignmentCenter;
    memberNameLabel.backgroundColor = [UIColor clearColor];
    UIBarButtonItem* someBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:memberNameLabel]; 
    [self.navigationItem setLeftBarButtonItem:someBarButtonItem]; 
    [someBarButtonItem release]; 
    [memberNameLabel release];
    
    //首页导航栏右铵钮的设置
    NSString *loginOutButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"loginOut_normal" inDirectory:@"RootView"];
    NSString *loginOutButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"loginOut_highlighted" inDirectory:@"RootView"];
    UIButton * loginOrOutButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 29)]; 
    [loginOrOutButton setBackgroundImage:[UIImage imageNamed:loginOutButtonNormalPath] forState:UIControlStateNormal]; 
    [loginOrOutButton setBackgroundImage:[UIImage imageNamed:loginOutButtonHighlightedPath] forState:UIControlStateHighlighted]; 
    [loginOrOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
    loginOrOutButton.titleLabel.font=[UIFont systemFontOfSize:14];
    [loginOrOutButton addTarget:self action:@selector(loginOrOut) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * loginOrOutBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:loginOrOutButton]; 
    [self.navigationItem setRightBarButtonItem:loginOrOutBarButtonItem];
    [loginOrOutBarButtonItem release];
	[loginOrOutButton release];
    
    //设置背景图片
    NSString *bgPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"background" inDirectory:@"CommonView"];
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bgPath]];
    bgImageView.frame = CGRectMake(0, 0, 320, 416);
    self.bgImageView = bgImageView;
	[self.view addSubview:bgImageView];
	[bgImageView release];
    
    NSMutableDictionary *dict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    
    if (dict) {
        if ([[dict objectForKey:@"isAutoLogin"] boolValue] && [CommonTools connectedToNetwork]) {
            //需要自动登陆，并且网络畅通时
            
            //编辑用户登陆请求的xml数据
            GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
            GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
            [conditionElement addChild:[GDataXMLNode elementWithName:@"loginName" stringValue:[dict objectForKey:@"loginName"]]];
            [conditionElement addChild:[GDataXMLNode elementWithName:@"password" stringValue:[CommonTools aes:[dict objectForKey:@"loginPassword"] key:@"K14FO23EB32NE41G" iv:@"0A2B4C6D8E1F5793"]]];
            [conditionElement addChild:[GDataXMLNode elementWithName:@"IMEI" stringValue:@"1234567890"]];
            [conditionElement addChild:[GDataXMLNode elementWithName:@"simID" stringValue:@"9876543210"]];
            [requestElement addChild:conditionElement];
            GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
            [document setVersion:@"1.0"]; // 设置xml版本为 1.0
            [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
            NSData *xmlData = document.XMLData;
            
            //显示登陆提示框
            _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            _hud.bgRGB = [PiosaColorManager progressColor];
            [self.navigationController.view addSubview:_hud];
            _hud.delegate = self;
            _hud.minSize = CGSizeMake(135.f, 135.f);
            _hud.labelText = @"为您自动登陆中...";
            [_hud show:YES];
            
            //进行数据请求
            NSString *url = MEMBER_LOGIN_ADDRESS;
            ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: url]] autorelease];
            [req addRequestHeader:@"API-Version" value:API_VERSION];
            req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
            [req appendPostData:xmlData];
            [req setDelegate:self];
            [req startAsynchronous]; // 执行异步post
            [url release];
        } 
    }
    
    UIScrollView *rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 356)];
    rootScrollView.backgroundColor = [UIColor clearColor];
    rootScrollView.pagingEnabled = YES;
    rootScrollView.contentSize = CGSizeMake(rootScrollView.frame.size.width * kNumberOfPages, rootScrollView.frame.size.height);
    rootScrollView.showsHorizontalScrollIndicator = NO;
    rootScrollView.showsVerticalScrollIndicator = NO;
    rootScrollView.scrollsToTop = NO;
    rootScrollView.delegate = self;
    self.rootScrollView = rootScrollView;
    [self.view addSubview:rootScrollView];
    [rootScrollView release];
    
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 356, 320, 30)];
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
    [pageControl setBackgroundColor:[UIColor clearColor]];
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.currentPage = 0;
    self.rootPageControl = pageControl;
    [self.view addSubview:pageControl];
    [pageControl release];
    
    UIButton * firstButton = [[UIButton alloc] initWithFrame:CGRectMake(kFirstModuleVerticality, kFirstModuleRow, kModuleButtonWidth, kModuleButtonHeight)];
    NSString *hotelModuleNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"hotel_normal" inDirectory:@"RootView/ModulePort"];
    NSString *hotelModuleHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"hotel_highlighted" inDirectory:@"RootView/ModulePort"];
    [firstButton setBackgroundImage:[UIImage imageNamed:hotelModuleNormalPath] forState:UIControlStateNormal];
    [firstButton setBackgroundImage:[UIImage imageNamed:hotelModuleHighlightedPath] forState:UIControlStateHighlighted];
    [firstButton addTarget:self action:@selector(hotelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rootScrollView addSubview:firstButton];
    [firstButton release];
    
    UIButton * secondButton = [[UIButton alloc] initWithFrame:CGRectMake(kSecondModuleVerticality, kFirstModuleRow, kModuleButtonWidth, kModuleButtonHeight)];
    NSString *flightModuleNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"flight_normal" inDirectory:@"RootView/ModulePort"];
    NSString *flightModuleHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"flight_highlighted" inDirectory:@"RootView/ModulePort"];
    [secondButton setBackgroundImage:[UIImage imageNamed:flightModuleNormalPath] forState:UIControlStateNormal];
    [secondButton setBackgroundImage:[UIImage imageNamed:flightModuleHighlightedPath] forState:UIControlStateHighlighted];
    [secondButton addTarget:self action:@selector(flightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rootScrollView addSubview:secondButton];
    [secondButton release];
    
    UIButton * thirdButton = [[UIButton alloc] initWithFrame:CGRectMake(kThridModuleVerticality, kFirstModuleRow, kModuleButtonWidth, kModuleButtonHeight)];
    NSString *trainModuleNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"train_normal" inDirectory:@"RootView/ModulePort"];
    NSString *trainModuleHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"train_highlighted" inDirectory:@"RootView/ModulePort"];
    [thirdButton setBackgroundImage:[UIImage imageNamed:trainModuleNormalPath] forState:UIControlStateNormal];
    [thirdButton setBackgroundImage:[UIImage imageNamed:trainModuleHighlightedPath] forState:UIControlStateHighlighted];
    [thirdButton addTarget:self action:@selector(trainButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rootScrollView addSubview:thirdButton];
    [thirdButton release];
    
    UIButton * fourthButton = [[UIButton alloc] initWithFrame:CGRectMake(kFirstModuleVerticality, kSecondModuleRow, kModuleButtonWidth, kModuleButtonHeight)];
    NSString *myOrderModuleNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"myOrder_normal" inDirectory:@"RootView/ModulePort"];
    NSString *myOrderModuleHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"myOrder_highlighted" inDirectory:@"RootView/ModulePort"];
    [fourthButton setBackgroundImage:[UIImage imageNamed:myOrderModuleNormalPath] forState:UIControlStateNormal];
    [fourthButton setBackgroundImage:[UIImage imageNamed:myOrderModuleHighlightedPath] forState:UIControlStateHighlighted];
    [fourthButton addTarget:self action:@selector(myOrderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rootScrollView addSubview:fourthButton];
    [fourthButton release];
    
    UIButton * fifthButton = [[UIButton alloc] initWithFrame:CGRectMake(kSecondModuleVerticality, kSecondModuleRow, kModuleButtonWidth, kModuleButtonHeight)];
    NSString *memberModuleNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"member_normal" inDirectory:@"RootView/ModulePort"];
    NSString *memberModuleHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"member_highlighted" inDirectory:@"RootView/ModulePort"];
    [fifthButton setBackgroundImage:[UIImage imageNamed:memberModuleNormalPath] forState:UIControlStateNormal];
    [fifthButton setBackgroundImage:[UIImage imageNamed:memberModuleHighlightedPath] forState:UIControlStateHighlighted];
    [fifthButton addTarget:self action:@selector(memberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rootScrollView addSubview:fifthButton];
    [fifthButton release];
    
    UIButton * sixthButton = [[UIButton alloc] initWithFrame:CGRectMake(kThridModuleVerticality, kSecondModuleRow, kModuleButtonWidth, kModuleButtonHeight)];
    NSString *couponsModuleNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"coupons_normal" inDirectory:@"RootView/ModulePort"];
    NSString *couponsModuleHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"coupons_highlighted" inDirectory:@"RootView/ModulePort"];
    [sixthButton setBackgroundImage:[UIImage imageNamed:couponsModuleNormalPath] forState:UIControlStateNormal];
    [sixthButton setBackgroundImage:[UIImage imageNamed:couponsModuleHighlightedPath] forState:UIControlStateHighlighted];
    [sixthButton addTarget:self action:@selector(couponsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rootScrollView addSubview:sixthButton];
    [sixthButton release];
    
    UIButton * seventhButton = [[UIButton alloc] initWithFrame:CGRectMake(kFirstModuleVerticality, kThridModuleRow, kModuleButtonWidth, kModuleButtonHeight)];
    NSString *phoneRechargeModuleNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"phoneRecharge_normal" inDirectory:@"RootView/ModulePort"];
    NSString *phoneRechargeModuleHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"phoneRecharge_highlighted" inDirectory:@"RootView/ModulePort"];
    [seventhButton setBackgroundImage:[UIImage imageNamed:phoneRechargeModuleNormalPath] forState:UIControlStateNormal];
    [seventhButton setBackgroundImage:[UIImage imageNamed:phoneRechargeModuleHighlightedPath] forState:UIControlStateHighlighted];
    [seventhButton addTarget:self action:@selector(phoneRechargeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rootScrollView addSubview:seventhButton];
    [seventhButton release];
    
    UIButton * eighthButton = [[UIButton alloc] initWithFrame:CGRectMake(kSecondModuleVerticality, kThridModuleRow, kModuleButtonWidth, kModuleButtonHeight)];
    NSString *weatherRechargeModuleNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"weather_normal" inDirectory:@"RootView/ModulePort"];
    NSString *weatherRechargeModuleHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"weather_highlighted" inDirectory:@"RootView/ModulePort"];
    [eighthButton setBackgroundImage:[UIImage imageNamed:weatherRechargeModuleNormalPath] forState:UIControlStateNormal];
    [eighthButton setBackgroundImage:[UIImage imageNamed:weatherRechargeModuleHighlightedPath] forState:UIControlStateHighlighted];
    [eighthButton addTarget:self action:@selector(weatherButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rootScrollView addSubview:eighthButton];
    [eighthButton release];
    
    UIButton * ninthButton = [[UIButton alloc] initWithFrame:CGRectMake(kThridModuleVerticality, kThridModuleRow, kModuleButtonWidth, kModuleButtonHeight)];
    NSString *questionModuleNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"question_normal" inDirectory:@"RootView/ModulePort"];
    NSString *questionModuleHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"question_highlighted" inDirectory:@"RootView/ModulePort"];
    [ninthButton setBackgroundImage:[UIImage imageNamed:questionModuleNormalPath] forState:UIControlStateNormal];
    [ninthButton setBackgroundImage:[UIImage imageNamed:questionModuleHighlightedPath] forState:UIControlStateHighlighted];
    [ninthButton addTarget:self action:@selector(questionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rootScrollView addSubview:ninthButton];
    [ninthButton release];
    
    UIButton * tenthButton = [[UIButton alloc] initWithFrame:CGRectMake(kFourModuleVerticality, kFirstModuleRow, kModuleButtonWidth, kModuleButtonHeight)];
    NSString *settingModuleNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"setting_normal" inDirectory:@"RootView/ModulePort"];
    NSString *settingModuleHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"setting_highlighted" inDirectory:@"RootView/ModulePort"];
    [tenthButton setBackgroundImage:[UIImage imageNamed:settingModuleNormalPath] forState:UIControlStateNormal];
    [tenthButton setBackgroundImage:[UIImage imageNamed:settingModuleHighlightedPath] forState:UIControlStateHighlighted];
    [tenthButton addTarget:self action:@selector(settingButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [rootScrollView addSubview:tenthButton];
    [tenthButton release];

    //底部视图的设置
    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 386, 320, 30)];
    bottomView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    UIButton * phoneButton = [[UIButton alloc] initWithFrame:CGRectMake(82, 2, 156, 26)];
    NSString *phonecallButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"phonecall_normal" inDirectory:@"CommonView/BottomItem"];
    NSString *phonecallButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"phonecall_highlighted" inDirectory:@"CommonView/BottomItem"];
    [phoneButton setImage:[UIImage imageNamed:phonecallButtonNormalPath] forState:UIControlStateNormal];
    [phoneButton setImage:[UIImage imageNamed:phonecallButtonHighlightedPath] forState:UIControlStateHighlighted];
    [phoneButton addTarget:self action:@selector(phoneCall) forControlEvents:UIControlEventTouchUpInside];
    self.phoneButton = phoneButton;
    [bottomView addSubview:phoneButton];
    [self.view addSubview:bottomView];
    [phoneButton release];
    [bottomView release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self viewUserName];
}

- (void)viewDidUnload {
    self.rootScrollView = nil;
    self.rootPageControl = nil;
    [super viewDidUnload];
}

#pragma mark -
#pragma mark ASIHttp delegate

// 响应有响应 : 但可能是错误响应, 如 404
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
		}else {
            
            NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
            [loginDict setObject:@"1" forKey:@"isLogin"];
            [PiosaFileManager writeApplicationPlist:loginDict toFile:UCAI_LOGIN_FILE_NAME];
            
            NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
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
            
            [self viewUserName];
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

#pragma mark - Custom method

-(void)updateTheme:(NSNotification*)notif
{
    [UIApplication sharedApplication].keyWindow.backgroundColor = [PiosaColorManager fontColor];
    
    //修改导航栏主题的颜色
    self.navigationController.navigationBar.tintColor = [PiosaColorManager barColor];
    
    //修改工具栏主题的颜色
    self.navigationController.toolbar.tintColor = [PiosaColorManager barColor];
    
    //设置背景图片
    NSString *bgPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"background" inDirectory:@"CommonView"];
    self.bgImageView.image = [UIImage imageNamed:bgPath];
    
    //设置导航栏背景图片
    [self.navigationController.navigationBar setNeedsDisplay];
    
    //首页导航栏右铵钮的设置
    NSString *loginOutButtonHighlightedPathButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"loginOut_normal" inDirectory:@"RootView"];
    NSString *loginOutButtonHighlightedPathButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"loginOut_highlighted" inDirectory:@"RootView"];
    UIButton * loginOrOutButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 29)]; 
    [loginOrOutButton setBackgroundImage:[UIImage imageNamed:loginOutButtonHighlightedPathButtonNormalPath] forState:UIControlStateNormal]; 
    [loginOrOutButton setBackgroundImage:[UIImage imageNamed:loginOutButtonHighlightedPathButtonHighlightedPath] forState:UIControlStateHighlighted]; 
    [loginOrOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
    loginOrOutButton.titleLabel.font=[UIFont systemFontOfSize:14];
    [loginOrOutButton addTarget:self action:@selector(loginOrOut) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * loginOrOutBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:loginOrOutButton]; 
    [self.navigationItem setRightBarButtonItem:loginOrOutBarButtonItem];
    [loginOrOutBarButtonItem release];
	[loginOrOutButton release];
    
    //设置电话拨打按钮的图片
    NSString *phonecallButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"phonecall_normal" inDirectory:@"CommonView/BottomItem"];
    NSString *phonecallButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"phonecall_highlighted" inDirectory:@"CommonView/BottomItem"];
    [self.phoneButton setImage:[UIImage imageNamed:phonecallButtonNormalPath] forState:UIControlStateNormal];
    [self.phoneButton setImage:[UIImage imageNamed:phonecallButtonHighlightedPath] forState:UIControlStateHighlighted];
}

- (IBAction)changePage:(UIPageControl *)pageControl{
    int page = pageControl.currentPage;
    
	// update the scroll view to the appropriate page
    CGRect frame = self.rootScrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.rootScrollView scrollRectToVisible:frame animated:YES];
    
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: below.
    _pageControlUsed = YES;
}

- (void)phoneCall{
    if ([[UIApplication  sharedApplication] canOpenURL:[NSURL  URLWithString:@"tel://4006840060"]]) {
        UIActionSheet * phoneActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拨打电话40068 40060" otherButtonTitles:nil, nil];
        phoneActionSheet.delegate = self;
        [phoneActionSheet showInView:[UIApplication sharedApplication].keyWindow];
		[phoneActionSheet release];
    }
}

- (void)viewUserName{
    
    NSString *userTitle;
    NSString *loginTitle;
    
    NSMutableDictionary *dict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    
    if (dict) {
        if ([[dict objectForKey:@"isLogin"] boolValue]) {
            NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
            userTitle = [memberDict objectForKey:@"registerName"];
            loginTitle = @"注销";
        } else {
            userTitle = @"游客";
            loginTitle = @"登陆";
        }
    } else {
        userTitle = @"游客";
        loginTitle = @"登陆";
    }
    
    UILabel * memberNameLabel = (UILabel *)[[self.navigationItem leftBarButtonItem] customView];
    memberNameLabel.text = userTitle;
    
    UIButton * loginOrOutButton = (UIButton *)[[self.navigationItem rightBarButtonItem] customView];
    [loginOrOutButton setTitle:loginTitle forState:UIControlStateNormal];
}

- (void)loginOrOut {
    
    NSMutableDictionary *dict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
    
    if (dict) {
        if ([[dict objectForKey:@"isLogin"] boolValue]) {
            //用户已登陆，进行注销操作
            NSString *logoutMes = [[NSString alloc] initWithFormat:@"是否注销用户:%@",[memberDict objectForKey:@"registerName"]];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:logoutMes delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否",nil];
            [av show];
            [av release];
            [logoutMes release];
        } else {
            //用户未登陆，进行登陆操作
            MemberLoginViewController *loginController = [[MemberLoginViewController alloc] initWithComeFromType:1];
            [self.navigationController pushViewController:loginController animated:YES];
            [loginController release];
        }
    }
}

// 酒店订购
- (void)hotelButtonPressed:(id)sender
{
    HotelSearchController *hotelSearchController = [[HotelSearchController alloc] init];
    [self.navigationController pushViewController:hotelSearchController animated:YES];
    [hotelSearchController release];
}

// 航空秘书
- (void)flightButtonPressed:(id)sender
{
    FlightClassChoiceViewController *flightClassChoiceViewController = [[FlightClassChoiceViewController alloc] init];
    [self.navigationController pushViewController:flightClassChoiceViewController animated:YES];
    [flightClassChoiceViewController release];
}

// 列车时刻
- (void)trainButtonPressed:(id)sender
{
    TrainSearchViewController *trainSearchViewController = [[TrainSearchViewController alloc] init];
    [self.navigationController pushViewController:trainSearchViewController animated:YES];
    [trainSearchViewController release];
}

// 我的订单
- (void)myOrderButtonPressed:(id)sender
{
    OrderSearchClassChoiceViewController *orderSearchClassChoiceViewController = [[OrderSearchClassChoiceViewController alloc] init];
    [self.navigationController pushViewController:orderSearchClassChoiceViewController animated:YES];
    [orderSearchClassChoiceViewController release];
}

// 会员中心
- (void)memberButtonPressed:(id)sender 
{
    NSMutableDictionary *dict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    
    if (dict) {
        if ([[dict objectForKey:@"isLogin"] boolValue]) {
            //会员已登陆
            MemberCenterFirstController *memberCenterfirstController = [[MemberCenterFirstController alloc] init];
            [self.navigationController pushViewController:memberCenterfirstController animated:YES];
            [memberCenterfirstController release];
        } else {
            //会员未登陆
            MemberLoginViewController *loginController = [[MemberLoginViewController alloc] initWithComeFromType:2];
            [self.navigationController pushViewController:loginController animated:YES];
            [loginController release];
        }
    }
}

// 优惠劵
- (void)couponsButtonPressed:(id)sender
{
    CouponClassChoiceViewController *couponClassChoiceViewController = [[CouponClassChoiceViewController alloc] init];
    [self.navigationController pushViewController:couponClassChoiceViewController animated:YES];
    [couponClassChoiceViewController release];
}

// 手机充值
- (void)phoneRechargeButtonPressed:(id)sender
{
    PhoneBillRechargeViewController *phoneBillRechargeViewController = [[PhoneBillRechargeViewController alloc] init];
    [self.navigationController pushViewController:phoneBillRechargeViewController animated:YES];
    [phoneBillRechargeViewController release];
}

// 天气
- (void)weatherButtonPressed:(id)sender
{
    WeatherSearchViewController *weatherSearchViewController = [[WeatherSearchViewController alloc] init];
    [self.navigationController pushViewController:weatherSearchViewController animated:YES];
    [weatherSearchViewController release];
}

// 问题反馈
- (void)questionButtonPressed:(id)sender
{
    FeedbackEditViewController *feedbackEditViewController = [[FeedbackEditViewController alloc] init];
    [self.navigationController pushViewController:feedbackEditViewController animated:YES];
    [feedbackEditViewController release];
}

// 设置
- (void)settingButtonPressed{
    SettingChoiceViewController *settingChoiceViewController = [[SettingChoiceViewController alloc] init];
    [self.navigationController pushViewController:settingChoiceViewController animated:YES];
    [settingChoiceViewController release];
}

// 优付宝
- (IBAction)bestPayCardButtonPressed:(id)sender
{
    NSLog(@"bestPayCardButtonPressed");
}

#pragma mark -
#pragma mark UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (_pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.rootScrollView.frame.size.width;
    int page = floor((self.rootScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.rootPageControl.currentPage = page;
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}

#pragma mark -
#pragma mark AlertView Delegate Methods
- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(int) index {
	if (index == 0) {
        //用户点击确定，注销用户
        NSMutableDictionary *dict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
        if (dict) {
            [dict setObject:@"0" forKey:@"isLogin"];
            
            [PiosaFileManager writeApplicationPlist:dict toFile:UCAI_LOGIN_FILE_NAME];
        }
        [self viewUserName];
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    if (alertView.tag == LOGIN_ALERTVIEW_TAG) {
        alertView.frame = CGRectMake( 20, 200, 280, 100 );
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

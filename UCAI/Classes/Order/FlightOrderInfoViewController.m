//
//  FlightOrderInfoViewController.m
//  UCAI
//
//  Created by  on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FlightOrderInfoViewController.h"

#import "GDataXMLNode.h"
#import "ASIFormDataRequest.h"
#import "StaticConf.h"
#import "ResponseParser.h"
#import "CommonTools.h"
#import "PiosaFileManager.h"

#import "FlightOrderInfoSearchResponseModel.h"
#import "AllinTelPayViewController.h"
#import "FlightOrderCouponChoiceViewController.h"

#define kHUDhiddenTag 101 //只需要消失提交框
#define kHUDhiddenAndPopTag 102 //需要在提交框消失后退出视图

@implementation FlightOrderInfoViewController

@synthesize orderId = _orderId;
@synthesize flightOrderInfoTableView = _flightOrderInfoTableView;

@synthesize orderIDContentLabel = _orderIDContentLabel;
@synthesize orderPriceContentLabel = _orderPriceContentLabel;
@synthesize orderPayStatusContentLabel = _orderPayStatusContentLabel;
@synthesize orderTimeContentLabel = _orderTimeContentLabel;
@synthesize orderTypeContentLabel = _orderTypeContentLabel;

@synthesize linkNameContentLabel = _linkNameContentLabel;
@synthesize linkMobileContentLabel = _linkMobileContentLabel;

@synthesize couponPriceAmount = _couponPriceAmount;
@synthesize couponPriceAmountContentLabel = _couponPriceAmountContentLabel;
@synthesize couponUsedShowLabel = _couponUsedShowLabel;
@synthesize couponUsedContentLabel = _couponUsedContentLabel;
@synthesize couponUsedIDs = _couponUsedIDs;

@synthesize payButton = _payButton;

@synthesize flightOrderInfoSearchResponseModel = _flightOrderInfoSearchResponseModel;

@synthesize modelBGView = _modelBGView;
@synthesize modelButtonView = _modelButtonView;

- (void)dealloc{
    [_flightCompanyDic release];
    
    [self.orderId release];
    [self.flightOrderInfoTableView release];
    
    [self.orderIDContentLabel release];
    [self.orderPriceContentLabel release];
    [self.orderPayStatusContentLabel release];
    [self.orderTimeContentLabel release];
    [self.orderTypeContentLabel release];
    
    [self.linkNameContentLabel release];
    [self.linkMobileContentLabel release];
    
    [self.couponPriceAmount release];
    [self.couponPriceAmountContentLabel release];
    [self.couponUsedShowLabel release];
    [self.couponUsedContentLabel release];
    [self.couponUsedIDs release];
    
    [self.payButton release];
    
    [self.flightOrderInfoSearchResponseModel release];
    [self.modelBGView release];
    [self.modelButtonView release];
    [super dealloc];
}

#pragma mark - Custom method
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

- (NSData*)generateFlightOrderInfoSearchRequestPostXMLData{
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"orderID" stringValue:self.orderId]];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    return document.XMLData;
}

- (void)payButtonPress{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.modelBGView.alpha = 1;
    self.modelButtonView.frame = CGRectMake(0, 316, 320, 100);
    [UIView commitAnimations];
}

- (void)aLiPay{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.modelBGView.alpha = 0;
    self.modelButtonView.frame = CGRectMake(0, 416, 320, 80);
    [UIView commitModalAnimations];
    
    NSLog(@"%@",[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@%@%@",FLIGHT_ORDER_ALIPAY_ADDRESS,self.orderIDContentLabel.text,@"&couponID=",self.couponUsedIDs]]);
    [[UIApplication  sharedApplication] openURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@%@%@",FLIGHT_ORDER_ALIPAY_ADDRESS,self.orderIDContentLabel.text,@"&couponID=",self.couponUsedIDs]]];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)aLlinTelPay{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.modelBGView.alpha = 0;
    self.modelButtonView.frame = CGRectMake(0, 416, 320, 80);
    [UIView commitModalAnimations];
    
    float allinTelPayPrice = [self.flightOrderInfoSearchResponseModel.orderPayPrice floatValue]-[[self.couponPriceAmount substringFromIndex:1] floatValue];
    AllinTelPayViewController *allinTelPayViewController = [[AllinTelPayViewController alloc] initWithOrderID:self.orderIDContentLabel.text andCouponPrice:[NSString stringWithFormat:@"%.2f",allinTelPayPrice] andType:@"1"];
    [self.navigationController pushViewController:allinTelPayViewController animated:YES];
    [allinTelPayViewController release];
}

#pragma mark - View lifecycle


- (void)loadView
{
    [super loadView];
    
    self.title = @"机票订单详情";
    
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
    
    UITableView * tempTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
    tempTableView.dataSource = self;
    tempTableView.delegate = self;
    tempTableView.backgroundColor = [UIColor clearColor];
    self.flightOrderInfoTableView = tempTableView;
    [self.view addSubview:tempTableView];
    [tempTableView release];
    
    ModelBackgroundView *modelBGView = [[ModelBackgroundView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    modelBGView.delegate = self;
    modelBGView.alpha = 0;
    self.modelBGView = modelBGView;
    [self.view addSubview:modelBGView];
    [modelBGView release];
    
    UIView *modelButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 416, 320, 100)];
    
    NSString *modelBottomButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"modelBottomButton_normal" inDirectory:@"CommonView/ModelBottomButton"];
    NSString *modelBottomButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"modelBottomButton_highlighted" inDirectory:@"CommonView/ModelBottomButton"];
    
    UIButton *aliWapPayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [aliWapPayButton setBackgroundImage:[UIImage imageNamed:modelBottomButtonNormalPath] forState:UIControlStateNormal];
    [aliWapPayButton setBackgroundImage:[UIImage imageNamed:modelBottomButtonHighlightedPath] forState:UIControlStateHighlighted];
    [aliWapPayButton addTarget:self action:@selector(aLiPay) forControlEvents:UIControlEventTouchUpInside];
    UILabel *aliWapPayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 40)];
    aliWapPayLabel.backgroundColor = [UIColor clearColor];
    aliWapPayLabel.text = @"支付宝(交易限额¥0.1~¥5000)";
    [aliWapPayButton addSubview:aliWapPayLabel];
    [aliWapPayLabel release];
    [modelButtonView addSubview:aliWapPayButton];
    [aliWapPayButton release];
    
    UIButton *allinTelPayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, 320, 50)];
    [allinTelPayButton setBackgroundImage:[UIImage imageNamed:modelBottomButtonNormalPath] forState:UIControlStateNormal];
    [allinTelPayButton setBackgroundImage:[UIImage imageNamed:modelBottomButtonHighlightedPath] forState:UIControlStateHighlighted];
    [allinTelPayButton addTarget:self action:@selector(aLlinTelPay) forControlEvents:UIControlEventTouchUpInside];
    UILabel *allinTelPayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 40)];
    allinTelPayLabel.backgroundColor = [UIColor clearColor];
    allinTelPayLabel.text = @"电话支付(交易限额¥100~¥5000)";
    [allinTelPayButton addSubview:allinTelPayLabel];
    [allinTelPayLabel release];
    [modelButtonView addSubview:allinTelPayButton];
    [allinTelPayButton release];
    
    self.modelButtonView = modelButtonView;
    [self.view addSubview:modelButtonView];
    [modelButtonView release];
    
    self.couponUsedIDs = @"";
    
    NSArray * flightCompanyCodeArray = [[NSArray alloc] initWithObjects:@"CA",@"CZ",@"MU",@"FM",@"HU",@"SC",@"MF",@"3U",@"ZH",@"JD",@"HO",@"KN",@"8L",@"BK",@"EU",@"8C",@"G5",@"PN",@"OQ",@"NS",@"CN",@"GS",@"JR",nil];
    NSArray * flightCompanyImageArray = [[NSArray alloc] initWithObjects:@"air_line_ca",@"air_line_cz",@"air_line_mu",@"air_line_fm",@"air_line_hu",@"air_line_sc",@"air_line_mf",@"air_line_3u",@"air_line_zh",@"air_line_pn",@"air_line_ho",@"air_line_kn",@"air_line_8l",@"air_line_bk",@"air_line_eu",@"air_line_8c",@"air_line_g5",@"air_line_jd",@"air_line_oq",@"air_line_ns",@"air_line_hu",@"air_line_gs",@"air_line_jr",nil];
    _flightCompanyDic = [NSDictionary dictionaryWithObjects:flightCompanyImageArray forKeys:flightCompanyCodeArray];
    [_flightCompanyDic retain];
    [flightCompanyImageArray release];
    [flightCompanyCodeArray release];
}

- (void) viewDidLoad{
    [super viewDidLoad];
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"查询中...";
    _hud.tag = kHUDhiddenTag;
    [_hud show:YES];
    
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: FLIGHT_ORDERDETAIL_ADDRESS]] autorelease] ;
    request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    
    [request appendPostData:[self generateFlightOrderInfoSearchRequestPostXMLData]];
    
    [request setDelegate:self];
    [request startAsynchronous]; // 执行异步post
}

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应 : 但可能是错误响应, 如 404，或查询结果为空，则不跳转到下一个机票展示页面
- (void)requestFinished:(ASIFormDataRequest *)request
{    
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n",responseString);
    
    // 关闭加载框
    [_hud hide:YES];
    
    if ((responseString != nil) && [responseString length] > 0) {
        // 生成细节数据
        FlightOrderInfoSearchResponseModel *flightOrderInfoSearchResponseModel = [ResponseParser loadFlightOrderInfoSearchResponse:[request responseData]];
        
        if ([flightOrderInfoSearchResponseModel.resultCode intValue] != 0) {
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
            hud.labelText = flightOrderInfoSearchResponseModel.resultMessage;
            hud.tag = kHUDhiddenAndPopTag;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
        } else {
            self.flightOrderInfoSearchResponseModel = flightOrderInfoSearchResponseModel;
            self.couponPriceAmount = @"¥0.0";
            [self.flightOrderInfoTableView reloadData];
            
            for (FlightOrderCustomerInfo * customer in self.flightOrderInfoSearchResponseModel.customers) {
                if ([@"1" isEqualToString:customer.type]) {
                    _adultCount++;
                }
            }
            
            
            if ([@"0" isEqualToString:flightOrderInfoSearchResponseModel.orderPayStatus]) {
                UIButton *payButton = [[UIButton alloc] init];
                [payButton setFrame:CGRectMake(10, self.flightOrderInfoTableView.contentSize.height+10, 300, 40)];
                [payButton setTitle:@"前往支付" forState:UIControlStateNormal];
                [payButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
                [payButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
                NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
                NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
                [payButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
                [payButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
                [payButton addTarget:self action:@selector(payButtonPress) forControlEvents:UIControlEventTouchUpInside];
                self.payButton = payButton;
                [self.flightOrderInfoTableView addSubview:payButton];
                [payButton release];
                
                self.flightOrderInfoTableView.contentSize = CGSizeMake(300, self.flightOrderInfoTableView.contentSize.height+60);
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
    _hud.tag = kHUDhiddenAndPopTag;
    [_hud hide:YES afterDelay:3];
}

#pragma mark -
#pragma mark ModelBackgroundView Delegate Methods

- (void) touchDownForCancel{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.modelBGView.alpha = 0;
    self.modelButtonView.frame = CGRectMake(0, 416, 320, 80);
    [UIView commitAnimations];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
    
    if ([memberDict objectForKey:@"isLogin"] && [@"0" isEqualToString:self.flightOrderInfoSearchResponseModel.orderPayStatus]) {
        return 5;
    } else {
        return 4;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            if (self.flightOrderInfoSearchResponseModel != nil) {
                return [self.flightOrderInfoSearchResponseModel.flights count]+1;
            } else {
                return 2;
            }
            break;
        case 2:
            if (self.flightOrderInfoSearchResponseModel != nil) {
                return [self.flightOrderInfoSearchResponseModel.customers count]+1;
            } else {
                return 2;
            }
            break;
        case 3:
            return 3;
            break;
        case 4:
            return 4;
            break;
        default:
            return 0;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", indexPath.row, indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont systemFontOfSize:18];
                        cell.textLabel.text = @"订单信息";
                        break;
                    case 1:
                    {
                        UILabel * orderIDShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 80, 20)];
                        orderIDShowLabel.backgroundColor = [UIColor clearColor];
                        orderIDShowLabel.font = [UIFont systemFontOfSize:16];
                        orderIDShowLabel.text = @"订单编号:";
                        [cell.contentView addSubview:orderIDShowLabel];
                        [orderIDShowLabel release];
                        
                        UILabel * orderIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 5, 180, 20)];
                        orderIDLabel.backgroundColor = [UIColor clearColor];
                        orderIDLabel.font = [UIFont systemFontOfSize:16];
                        orderIDLabel.textColor = [PiosaColorManager fontColor];
                        self.orderIDContentLabel = orderIDLabel;
                        [cell.contentView addSubview:self.orderIDContentLabel];
                        [orderIDLabel release];
                        
                        UILabel * orderPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 80, 20)];
                        orderPriceShowLabel.backgroundColor = [UIColor clearColor];
                        orderPriceShowLabel.font = [UIFont systemFontOfSize:16];
                        orderPriceShowLabel.text = @"订单金额:";
                        [cell.contentView addSubview:orderPriceShowLabel];
                        [orderPriceShowLabel release];
                        
                        UILabel * orderPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, 180, 20)];
                        orderPriceLabel.backgroundColor = [UIColor clearColor];
                        orderPriceLabel.font = [UIFont systemFontOfSize:16];
                        orderPriceLabel.textColor = [UIColor redColor];
                        self.orderPriceContentLabel = orderPriceLabel;
                        [cell.contentView addSubview:self.orderPriceContentLabel];
                        [orderPriceLabel release];
                        
                        UILabel * orderPayStatusShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 55, 80, 20)];
                        orderPayStatusShowLabel.backgroundColor = [UIColor clearColor];
                        orderPayStatusShowLabel.font = [UIFont systemFontOfSize:16];
                        orderPayStatusShowLabel.text = @"支付状态:";
                        [cell.contentView addSubview:orderPayStatusShowLabel];
                        [orderPayStatusShowLabel release];
                        
                        UILabel * orderPayStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 55, 180, 20)];
                        orderPayStatusLabel.backgroundColor = [UIColor clearColor];
                        orderPayStatusLabel.textColor = [UIColor grayColor];
                        orderPayStatusLabel.font = [UIFont systemFontOfSize:16];
                        self.orderPayStatusContentLabel = orderPayStatusLabel;
                        [cell.contentView addSubview:self.orderPayStatusContentLabel];
                        [orderPayStatusLabel release];
                    }
                        break;
                    case 2:
                    {
                        UILabel * orderTimeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 80, 20)];
                        orderTimeShowLabel.backgroundColor = [UIColor clearColor];
                        orderTimeShowLabel.font = [UIFont systemFontOfSize:16];
                        orderTimeShowLabel.text = @"订购时间:";
                        [cell.contentView addSubview:orderTimeShowLabel];
                        [orderTimeShowLabel release];
                        
                        UILabel * orderTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 5, 180, 20)];
                        orderTimeLabel.backgroundColor = [UIColor clearColor];
                        orderTimeLabel.textColor = [UIColor grayColor];
                        orderTimeLabel.font = [UIFont systemFontOfSize:16];
                        self.orderTimeContentLabel = orderTimeLabel;
                        [cell.contentView addSubview:self.orderTimeContentLabel];
                        [orderTimeLabel release];
                        
                        UILabel * orderTypeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 80, 20)];
                        orderTypeShowLabel.backgroundColor = [UIColor clearColor];
                        orderTypeShowLabel.font = [UIFont systemFontOfSize:16];
                        orderTypeShowLabel.text = @"订单类型:";
                        [cell.contentView addSubview:orderTypeShowLabel];
                        [orderTypeShowLabel release];
                        
                        UILabel * orderTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, 180, 20)];
                        orderTypeLabel.backgroundColor = [UIColor clearColor];
                        orderTypeLabel.textColor = [UIColor grayColor];
                        orderTypeLabel.font = [UIFont systemFontOfSize:16];
                        self.orderTypeContentLabel = orderTypeLabel;
                        [cell.contentView addSubview:self.orderTypeContentLabel];
                        [orderTypeLabel release];
                        
                    }
                        break;
                }
                break;
            case 1:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont systemFontOfSize:18];
                        cell.textLabel.text = @"航程信息";
                        break;
                }
                break;
            case 2:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont systemFontOfSize:18];
                        cell.textLabel.text = @"乘机人信息";
                        break;
                }
                break;
            case 3:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont systemFontOfSize:18];
                        cell.textLabel.text = @"联系信息";
                        break;
                    case 1:
                    {
                        UILabel * linkNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 80, 20)];
                        linkNameShowLabel.backgroundColor = [UIColor clearColor];
                        linkNameShowLabel.font = [UIFont systemFontOfSize:16];
                        linkNameShowLabel.text = @"    联系人:";
                        [cell.contentView addSubview:linkNameShowLabel];
                        [linkNameShowLabel release];
                        
                        UILabel * linkNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 10, 180, 20)];
                        linkNameLabel.backgroundColor = [UIColor clearColor];
                        linkNameLabel.textColor = [UIColor grayColor];
                        linkNameLabel.font = [UIFont systemFontOfSize:16];
                        self.linkNameContentLabel = linkNameLabel;
                        [cell.contentView addSubview:self.linkNameContentLabel];
                        [linkNameLabel release];
                    }
                        break;
                    case 2:
                    {
                        UILabel * linkMobileShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 80, 20)];
                        linkMobileShowLabel.backgroundColor = [UIColor clearColor];
                        linkMobileShowLabel.font = [UIFont systemFontOfSize:16];
                        linkMobileShowLabel.text = @"手机号码:";
                        [cell.contentView addSubview:linkMobileShowLabel];
                        [linkMobileShowLabel release];
                        
                        UILabel * linkMobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 10, 180, 20)];
                        linkMobileLabel.backgroundColor = [UIColor clearColor];
                        linkMobileLabel.textColor = [UIColor grayColor];
                        linkMobileLabel.font = [UIFont systemFontOfSize:16];
                        self.linkMobileContentLabel = linkMobileLabel;
                        [cell.contentView addSubview:self.linkMobileContentLabel];
                        [linkMobileLabel release];
                    }
                        break;
                }
                break;
            case 4:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont systemFontOfSize:18];
                        cell.textLabel.text = @"优惠劵";
                        break;
                    case 1:
                    {
                        UILabel * infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 280, 35)];
                        infoLabel.backgroundColor = [UIColor clearColor];
                        infoLabel.textColor = [UIColor grayColor];
                        infoLabel.font = [UIFont systemFontOfSize:14];
                        infoLabel.lineBreakMode = UILineBreakModeWordWrap;
                        infoLabel.numberOfLines = 0;
                        infoLabel.text = @"如果您有优惠劵，可使用优惠劵享受相应的优惠(每张成人票可使用一张)";
                        [cell.contentView addSubview:infoLabel];
                        [infoLabel release];
                    }
                        break;
                    case 2:
                    {
                        UILabel * couponUsedShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 80, 20)];
                        couponUsedShowLabel.backgroundColor = [UIColor clearColor];
                        couponUsedShowLabel.font = [UIFont systemFontOfSize:16];
                        couponUsedShowLabel.text = @"    已使用:";
                        self.couponUsedShowLabel = couponUsedShowLabel;
                        [cell.contentView addSubview:couponUsedShowLabel];
                        [couponUsedShowLabel release];
                        
                        UILabel * couponUsedContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 10, 180, 20)];
                        couponUsedContentLabel.backgroundColor = [UIColor clearColor];
                        couponUsedContentLabel.textColor = [UIColor grayColor];
                        couponUsedContentLabel.lineBreakMode = UILineBreakModeWordWrap;
                        couponUsedContentLabel.numberOfLines = 0;
                        couponUsedContentLabel.font = [UIFont systemFontOfSize:16];
                        self.couponUsedContentLabel = couponUsedContentLabel;
                        [cell.contentView addSubview:self.couponUsedContentLabel];
                        [couponUsedContentLabel release];
                        
                        NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                        UIImageView * accessoryViewTemp1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                        accessoryViewTemp1.frame = CGRectMake(0, 0, 10, 16);
                        cell.accessoryView = accessoryViewTemp1;
                        [accessoryViewTemp1 release];
                    }
                        break;
                    case 3:
                    {
                        UILabel * couponPriceAmountShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 80, 20)];
                        couponPriceAmountShowLabel.backgroundColor = [UIColor clearColor];
                        couponPriceAmountShowLabel.font = [UIFont systemFontOfSize:16];
                        couponPriceAmountShowLabel.text = @"为您优惠:";
                        [cell.contentView addSubview:couponPriceAmountShowLabel];
                        [couponPriceAmountShowLabel release];
                        
                        UILabel * couponPriceAmountContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 10, 180, 20)];
                        couponPriceAmountContentLabel.backgroundColor = [UIColor clearColor];
                        couponPriceAmountContentLabel.textColor = [UIColor redColor];
                        couponPriceAmountContentLabel.font = [UIFont systemFontOfSize:16];
                        self.couponPriceAmountContentLabel = couponPriceAmountContentLabel;
                        [cell.contentView addSubview:self.couponPriceAmountContentLabel];
                        [couponPriceAmountContentLabel release];
                    }
                        break;
                }
                break;
        }

    }
    
    if (self.flightOrderInfoSearchResponseModel != nil) {
        
        switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 1:
                        
                        self.orderIDContentLabel.text = self.orderId;
                        self.orderPriceContentLabel.text = [NSString stringWithFormat:@"¥%@",self.flightOrderInfoSearchResponseModel.orderPayPrice];
                        
                        NSString * payStatus = nil;
                        if ([self.flightOrderInfoSearchResponseModel.orderPayStatus intValue]==0) {
                            payStatus = @"未支付";
                        } else {
                            payStatus = @"已支付";   
                        }
                        self.orderPayStatusContentLabel.text = payStatus;
                        break;
                    case 2:
                        self.orderTimeContentLabel.text = self.flightOrderInfoSearchResponseModel.orderTime;
                        if ([self.flightOrderInfoSearchResponseModel.flights count] == 1) {
                            self.orderTypeContentLabel.text = @"单程";
                        } else {
                            self.orderTypeContentLabel.text = @"往返";
                        }
                        break;
                }
                break;
            case 1:
            {
                if (indexPath.row != 0) {
                    
                    for (UIView * vi in [cell.contentView  subviews]) {
                        [vi removeFromSuperview];
                    }
                    
                    FlightOrderFlightingInfo * flightOrderFlightingInfo = [self.flightOrderInfoSearchResponseModel.flights objectAtIndex:indexPath.row-1];
                    
                    UIImageView * companyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
                    NSString *flightCompanyPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:[_flightCompanyDic objectForKey:flightOrderFlightingInfo.companyCode] inDirectory:@"Flight/FlightCompany"];
                    companyImageView.image = [UIImage imageNamed:flightCompanyPath];
                    [cell.contentView  addSubview:companyImageView];
                    [companyImageView release];
                    
                    UILabel * companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 80, 20)];
                    companyNameLabel.backgroundColor = [UIColor clearColor];
                    companyNameLabel.text = flightOrderFlightingInfo.companyName;
                    [cell.contentView addSubview:companyNameLabel];
                    [companyNameLabel release];
                    
                    UIView * seperatorView = [[UIView alloc] initWithFrame:CGRectMake(-0.5, 30, 301, 20)];
                    seperatorView.backgroundColor = [UIColor colorWithRed:0.502 green:0.502 blue:0.502 alpha:0.5];
                    [cell.contentView addSubview:seperatorView];
                    [seperatorView release];
                    
                    UILabel * flightStartTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 100, 20)];
                    flightStartTimeLabel.backgroundColor = [UIColor clearColor];
                    flightStartTimeLabel.text = flightOrderFlightingInfo.fromDate;
                    [cell.contentView addSubview:flightStartTimeLabel];
                    [flightStartTimeLabel release];
                    
                    UILabel * flightTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 30, 80, 20)];
                    flightTypeLabel.backgroundColor = [UIColor clearColor];
                    flightTypeLabel.textAlignment = UITextAlignmentRight;
                    flightTypeLabel.text = [NSString stringWithFormat:@"机型%@",flightOrderFlightingInfo.flightType];
                    [cell.contentView addSubview:flightTypeLabel];
                    [flightTypeLabel release];
                    
                    UILabel * fromTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 55, 70, 20)];
                    fromTimeLabel.backgroundColor = [UIColor clearColor];
                    fromTimeLabel.font = [UIFont systemFontOfSize:14];
                    fromTimeLabel.text = [NSString stringWithFormat:@"起飞%@",flightOrderFlightingInfo.fromTime];
                    [cell.contentView addSubview:fromTimeLabel];
                    [fromTimeLabel release];
                    
                    UILabel * dptNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 55, 120, 20)];
                    dptNameLabel.backgroundColor = [UIColor clearColor];
                    dptNameLabel.font = [UIFont systemFontOfSize:14];
                    dptNameLabel.textAlignment = UITextAlignmentCenter;
                    dptNameLabel.text = flightOrderFlightingInfo.dptName;
                    dptNameLabel.textColor = [UIColor grayColor];
                    [cell.contentView addSubview:dptNameLabel];
                    [dptNameLabel release];
                    
                    UILabel * taxLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 55, 80, 20)];
                    taxLabel.backgroundColor = [UIColor clearColor];
                    taxLabel.font = [UIFont systemFontOfSize:14];
                    taxLabel.textAlignment = UITextAlignmentRight;
                    taxLabel.text = [NSString stringWithFormat:@"燃油%@",flightOrderFlightingInfo.tax];
                    taxLabel.textColor = [PiosaColorManager fontColor];
                    [cell.contentView addSubview:taxLabel];
                    [taxLabel release];
                    
                    UILabel * toTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 75, 70, 20)];
                    toTimeLabel.backgroundColor = [UIColor clearColor];
                    toTimeLabel.font = [UIFont systemFontOfSize:14];
                    toTimeLabel.backgroundColor = [UIColor clearColor];
                    toTimeLabel.text = [NSString stringWithFormat:@"到达%@",flightOrderFlightingInfo.toTime];
                    [cell.contentView addSubview:toTimeLabel];
                    [toTimeLabel release];
                    
                    UILabel * arrNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 75, 120, 20)];
                    arrNameLabel.font = [UIFont systemFontOfSize:14];
                    arrNameLabel.textAlignment = UITextAlignmentCenter;
                    arrNameLabel.backgroundColor = [UIColor clearColor];
                    arrNameLabel.text = flightOrderFlightingInfo.arrName;
                    arrNameLabel.textColor = [UIColor grayColor];
                    [cell.contentView addSubview:arrNameLabel];
                    [arrNameLabel release];
                    
                    UILabel * airTaxLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 75, 80, 20)];
                    airTaxLabel.font = [UIFont systemFontOfSize:14];
                    airTaxLabel.textAlignment = UITextAlignmentRight;
                    airTaxLabel.backgroundColor = [UIColor clearColor];
                    airTaxLabel.text = [NSString stringWithFormat:@"基建%@",flightOrderFlightingInfo.airTax];
                    airTaxLabel.textColor = [PiosaColorManager fontColor];
                    [cell.contentView addSubview:airTaxLabel];
                    [airTaxLabel release];
                    
                }
            
            }
                break;
            case 2:
            {
                if (indexPath.row != 0) {
                    
                    for (UIView * vi in [cell.contentView  subviews]) {
                        [vi removeFromSuperview];
                    }
                    
                    FlightOrderCustomerInfo * flightOrderCustomerInfo = [self.flightOrderInfoSearchResponseModel.customers objectAtIndex:indexPath.row-1];
                    
                    UILabel * customerNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 80, 20)];
                    customerNameShowLabel.backgroundColor = [UIColor clearColor];
                    customerNameShowLabel.font = [UIFont systemFontOfSize:16];
                    customerNameShowLabel.text = [NSString stringWithFormat:@"乘  客  (%d):",indexPath.row];
                    [cell.contentView addSubview:customerNameShowLabel];
                    [customerNameShowLabel release];
                    
                    UILabel * customerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 5, 180, 20)];
                    customerNameLabel.backgroundColor = [UIColor clearColor];
                    customerNameLabel.textColor = [UIColor grayColor];
                    customerNameLabel.font = [UIFont systemFontOfSize:16];
                    customerNameLabel.text = flightOrderCustomerInfo.name;
                    [cell.contentView addSubview:customerNameLabel];
                    [customerNameLabel release];
                    
                    UILabel * customerCertificateNoShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 30, 80, 20)];
                    customerCertificateNoShowLabel.backgroundColor = [UIColor clearColor];
                    customerCertificateNoShowLabel.font = [UIFont systemFontOfSize:16];
                    customerCertificateNoShowLabel.text = @"证  件  号:";
                    [cell.contentView addSubview:customerCertificateNoShowLabel];
                    [customerCertificateNoShowLabel release];
                    
                    UILabel * customerCertificateNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, 180, 20)];
                    customerCertificateNoLabel.backgroundColor = [UIColor clearColor];
                    customerCertificateNoLabel.textColor = [UIColor grayColor];
                    customerCertificateNoLabel.font = [UIFont systemFontOfSize:16];
                    customerCertificateNoLabel.text = flightOrderCustomerInfo.certificateNo;
                    [cell.contentView addSubview:customerCertificateNoLabel];
                    [customerCertificateNoLabel release];
                }
            }
                break;
            case 3:
                switch (indexPath.row) {
                    case 1:
                        self.linkNameContentLabel.text = self.flightOrderInfoSearchResponseModel.linkmanName;
                        break;
                    case 2:
                        self.linkMobileContentLabel.text = self.flightOrderInfoSearchResponseModel.linkmanMobile;
                        break;
                }
                break;
            case 4:
                switch (indexPath.row) {
                    case 2:
                    {
                        NSString *tableViewCellCenterHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_highlighted" inDirectory:@"CommonView/TableViewCell"];
                        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterHighlightedPath]] autorelease];
                        cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    }
                        break;
                    case 3:
                    {
                        self.couponPriceAmountContentLabel.text = self.couponPriceAmount;
                    }
                        break;
                }
                break;
        }
    }
    
    if (indexPath.row == 0) {
        NSString *tableViewCellGroupTopTitlePath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_group_topTitle" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellGroupTopTitlePath]] autorelease];
    } else if(indexPath.row == [self.flightOrderInfoTableView numberOfRowsInSection:indexPath.section]-1){
        NSString *tableViewCellBottomNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_normal" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomNormalPath]] autorelease];
    } else {
        NSString *tableViewCellCenterNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_normal" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterNormalPath]] autorelease];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath row]==0) { //每区的第一行
        return 36;
    } else if([indexPath section] == 0 && [indexPath row] == 1){//第一区第二行
        return 80;
    }else if([indexPath section] == 0 && [indexPath row] == 2){//第一区第三行
        return 55;
    }else if([indexPath section] == 1 ){//第二区
        return 100;
    }else if([indexPath section] == 2 ){//第三区
        return 55;
    }else if([indexPath section] == 3 && [indexPath row] == 1){//第四区第二行
        return 40;
    }else if([indexPath section] == 3 && [indexPath row] == 2){//第四区第三行
        return 40;
    }else if([indexPath section] == 4 && [indexPath row] == 1){//第五区第二行
        return 44;
    }else if([indexPath section] == 4 && [indexPath row] == 2){//第五区第三行
        int numberOfLine = [CommonTools calculateRowCountForUTF8:self.couponUsedContentLabel.text bytes:20];
        if (numberOfLine>1) {
            return 22+20*numberOfLine;
        } else {
            return 44;
        }
    }else if([indexPath section] == 4 && [indexPath row] == 3){//第五区第四行
        return 44;
    }else {
        return 0;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 4 && indexPath.row == 2) {
        FlightOrderCouponChoiceViewController *flightOrderCouponChoiceViewController = [[FlightOrderCouponChoiceViewController alloc] initWithMaxUsedCount:_adultCount];
        flightOrderCouponChoiceViewController.flightOrderInfoViewController = self;
        [self.navigationController pushViewController:flightOrderCouponChoiceViewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

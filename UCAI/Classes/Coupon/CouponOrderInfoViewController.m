//
//  CouponOrderInfoViewController.m
//  UCAI
//
//  Created by  on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"
#import "CouponOrderInfoViewController.h"
#import "CouponOrderInfoSearchResponseModel.h"
#import "CouponOrderSendViewController.h"
#import "AllinTelPayViewController.h"

#import "GDataXMLNode.h"
#import "ASIFormDataRequest.h"
#import "StaticConf.h"
#import "ResponseParser.h"
#import "CommonTools.h"
#import "PiosaFileManager.h"

#define kHUDhiddenTag 201 //只需要消失提交框
#define kHUDhiddenAndPopTag 202 //需要在提交框消失后退出视图

@implementation CouponOrderInfoViewController

@synthesize orderId = _orderId;
@synthesize couponOrderInfoTableView = _couponOrderInfoTableView;

@synthesize orderIDContentLabel = _orderIDContentLabel;
@synthesize orderPriceContentLabel = _orderPriceContentLabel;
@synthesize orderPayStatusContentLabel = _orderPayStatusContentLabel;
@synthesize couponNameContentLabel = _couponNameContentLabel;
@synthesize orderTypeContentLabel = _orderTypeContentLabel;
@synthesize expirationTimeContentLabel = _expirationTimeContentLabel;
@synthesize couponPriceContentLabel = _couponPriceContentLabel;
@synthesize businessNameContentLabel = _businessNameContentLabel;
@synthesize businessTelContentLabel = _businessTelContentLabel;
@synthesize businessAddressContentLabel = _businessAddressContentLabel;
@synthesize modelBGView = _modelBGView;
@synthesize modelButtonView = _modelButtonView;

@synthesize couponOrderInfoSearchResponseModel = _couponOrderInfoSearchResponseModel;

- (CouponOrderInfoViewController *)initWithOrderId:(NSString *)orderId{
    self = [super init];
    _orderId = [orderId copy];
    return self;
}

-(void)dealloc{
    [self.orderId release];
    [self.couponOrderInfoTableView release];
    
    [self.orderIDContentLabel release];
    [self.orderPriceContentLabel release];
    [self.orderPayStatusContentLabel release];
    [self.couponNameContentLabel release];
    [self.orderTypeContentLabel release];
    [self.expirationTimeContentLabel release];
    [self.couponPriceContentLabel release];
    [self.businessNameContentLabel release];
    [self.businessTelContentLabel release];
    [self.businessAddressContentLabel release];
    [self.modelBGView release];
    [self.modelButtonView release];
    
    [self.couponOrderInfoSearchResponseModel release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)loadView{
    [super loadView];
	
    self.title = @"优惠劵订单详情";
    
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
    self.couponOrderInfoTableView = tempTableView;
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
    
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: COUPON_ORDERINFO_ADDRESS]] autorelease] ;
    request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    
    [request appendPostData:[self generateCouponOrderInfoSearchRequestPostXMLData]];
    
    [request setDelegate:self];
    [request startAsynchronous]; // 执行异步post
}

#pragma mark -
#pragma mark Custom

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

- (NSData*)generateCouponOrderInfoSearchRequestPostXMLData{
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"orderID" stringValue:self.orderId]];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    return document.XMLData;
}

- (void)sendButtonPress
{
	CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;//间隔时间
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];//动画的开始与结束的快慢
    transition.type = @"moveIn"; // 各种动画效果
    transition.subtype = kCATransitionFromTop;// 动画方向
    transition.delegate = self; 
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
	
	CouponOrderSendViewController * couponOrderSendViewController = [[CouponOrderSendViewController alloc] initWithCouponOrderId:self.orderId];
	[self.navigationController pushViewController:couponOrderSendViewController animated:NO];
	[couponOrderSendViewController release];
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
    
    [[UIApplication  sharedApplication] openURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",COUPON_ALIPAY_ADDRESS,self.orderIDContentLabel.text]]];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)aLlinTelPay{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.modelBGView.alpha = 0;
    self.modelButtonView.frame = CGRectMake(0, 416, 320, 80);
    [UIView commitModalAnimations];
    
    AllinTelPayViewController *allinTelPayViewController = [[AllinTelPayViewController alloc] initWithOrderID:self.orderIDContentLabel.text andCouponPrice:self.couponOrderInfoSearchResponseModel.payPrice  andType:@"3"];
    [self.navigationController pushViewController:allinTelPayViewController animated:YES];
    [allinTelPayViewController release];
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
        CouponOrderInfoSearchResponseModel *couponOrderInfoSearchResponseModel = [ResponseParser loadCouponOrderInfoSearchResponse:[request responseData]];
        
        if ([couponOrderInfoSearchResponseModel.resultCode intValue] != 0) {
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
            hud.labelText = couponOrderInfoSearchResponseModel.resultMessage;
            hud.tag = kHUDhiddenAndPopTag;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
        } else {
            self.couponOrderInfoSearchResponseModel = couponOrderInfoSearchResponseModel;
            
            [self.couponOrderInfoTableView reloadData];
            NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
            NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
            
            if ([@"0" isEqualToString:couponOrderInfoSearchResponseModel.isPay]) {
                
                UIView *payInfoView = [[UIView alloc] initWithFrame:CGRectMake(10, self.couponOrderInfoTableView.contentSize.height+5, 300, 40)];
                payInfoView.backgroundColor = [UIColor whiteColor];
                payInfoView.layer.cornerRadius = 8;
                payInfoView.clipsToBounds = YES;
                UILabel * payInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 40)];
                payInfoLabel.textColor = [UIColor grayColor];
                payInfoLabel.text = @"支付成功后将生成订单中相应数量(张)的可用优惠劵";
                payInfoLabel.font = [UIFont systemFontOfSize:14];
                payInfoLabel.numberOfLines = 2;
                [payInfoView addSubview:payInfoLabel];
                [payInfoLabel release];
                [self.couponOrderInfoTableView addSubview:payInfoView];
                [payInfoView release];
                UIButton *payButton = [[UIButton alloc] init];
                [payButton setFrame:CGRectMake(10, self.couponOrderInfoTableView.contentSize.height+60, 300, 40)];
                [payButton setTitle:@"前往支付" forState:UIControlStateNormal];
                [payButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
                [payButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
                
                [payButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
                [payButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
                [payButton addTarget:self action:@selector(payButtonPress) forControlEvents:UIControlEventTouchUpInside];
                [self.couponOrderInfoTableView addSubview:payButton];
                [payButton release];
                
                self.couponOrderInfoTableView.contentSize = CGSizeMake(300, self.couponOrderInfoTableView.contentSize.height+110);
            } else {
                UIButton *sendToPhoneButton = [[UIButton alloc] init];
                [sendToPhoneButton setFrame:CGRectMake(10, self.couponOrderInfoTableView.contentSize.height+10, 300, 40)];
                [sendToPhoneButton setTitle:@"发送到手机" forState:UIControlStateNormal];
                [sendToPhoneButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
                [sendToPhoneButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
                [sendToPhoneButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
                [sendToPhoneButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
                [sendToPhoneButton addTarget:self action:@selector(sendButtonPress) forControlEvents:UIControlEventTouchUpInside];
                [self.couponOrderInfoTableView addSubview:sendToPhoneButton];
                [sendToPhoneButton release];
                
                self.couponOrderInfoTableView.contentSize = CGSizeMake(300, self.couponOrderInfoTableView.contentSize.height+60);
            }
        }
    }
}


// 网络无响应
- (void)requestFailed:(ASIFormDataRequest *)request
{
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
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            if (self.couponOrderInfoSearchResponseModel != nil) {
                return [self.couponOrderInfoSearchResponseModel.couponArray count]+2;
            } else {
                return 2;
            }
            break;
        case 2:
            return 2;
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
                        UILabel * couponNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 80, 20)];
                        couponNameShowLabel.backgroundColor = [UIColor clearColor];
                        couponNameShowLabel.font = [UIFont systemFontOfSize:16];
                        couponNameShowLabel.text = @"产品名称:";
                        [cell.contentView addSubview:couponNameShowLabel];
                        [couponNameShowLabel release];
                        
                        UILabel * couponNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 5, 180, 20)];
                        couponNameLabel.backgroundColor = [UIColor clearColor];
                        couponNameLabel.textColor = [UIColor grayColor];
                        couponNameLabel.font = [UIFont systemFontOfSize:16];
                        self.couponNameContentLabel = couponNameLabel;
                        [cell.contentView addSubview:self.couponNameContentLabel];
                        [couponNameLabel release];
                        
                        UILabel * orderTypeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 80, 20)];
                        orderTypeShowLabel.backgroundColor = [UIColor clearColor];
                        orderTypeShowLabel.font = [UIFont systemFontOfSize:16];
                        orderTypeShowLabel.text = @"优惠类型:";
                        [cell.contentView addSubview:orderTypeShowLabel];
                        [orderTypeShowLabel release];
                        
                        UILabel * orderTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, 180, 20)];
                        orderTypeLabel.backgroundColor = [UIColor clearColor];
                        orderTypeLabel.textColor = [UIColor grayColor];
                        orderTypeLabel.font = [UIFont systemFontOfSize:16];
                        self.orderTypeContentLabel = orderTypeLabel;
                        [cell.contentView addSubview:self.orderTypeContentLabel];
                        [orderTypeLabel release];
                        
                        UILabel * expirationTimeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 55, 80, 20)];
                        expirationTimeShowLabel.backgroundColor = [UIColor clearColor];
                        expirationTimeShowLabel.font = [UIFont systemFontOfSize:16];
                        expirationTimeShowLabel.text = @"使用截止:";
                        [cell.contentView addSubview:expirationTimeShowLabel];
                        [expirationTimeShowLabel release];
                        
                        UILabel * expirationTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 55, 180, 20)];
                        expirationTimeLabel.backgroundColor = [UIColor clearColor];
                        expirationTimeLabel.textColor = [UIColor grayColor];
                        expirationTimeLabel.font = [UIFont systemFontOfSize:16];
                        self.expirationTimeContentLabel = expirationTimeLabel;
                        [cell.contentView addSubview:self.expirationTimeContentLabel];
                        [expirationTimeLabel release];
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
                        cell.textLabel.text = @"优惠劵信息";
                        break;
                    case 1:{
                        UILabel * couponPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 80, 20)];
                        couponPriceShowLabel.backgroundColor = [UIColor clearColor];
                        couponPriceShowLabel.font = [UIFont systemFontOfSize:16];
                        couponPriceShowLabel.text = @"单张优惠:";
                        [cell.contentView addSubview:couponPriceShowLabel];
                        [couponPriceShowLabel release];
                        
                        UILabel * couponPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 5, 180, 20)];
                        couponPriceLabel.backgroundColor = [UIColor clearColor];
                        couponPriceLabel.font = [UIFont systemFontOfSize:16];
                        couponPriceLabel.textColor = [UIColor redColor];
                        self.couponPriceContentLabel = couponPriceLabel;
                        [cell.contentView addSubview:self.couponPriceContentLabel];
                        [couponPriceLabel release];
                    }
                        break;
                }
                break;
            case 2:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont systemFontOfSize:18];
                        cell.textLabel.text = @"优惠商家信息";
                        break;
                    case 1:{
                        UILabel * businessNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 80, 20)];
                        businessNameShowLabel.backgroundColor = [UIColor clearColor];
                        businessNameShowLabel.font = [UIFont systemFontOfSize:16];
                        businessNameShowLabel.text = @"商家名称:";
                        [cell.contentView addSubview:businessNameShowLabel];
                        [businessNameShowLabel release];
                        
                        UILabel * businessNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 5, 200, 20)];
                        businessNameLabel.backgroundColor = [UIColor clearColor];
                        businessNameLabel.textColor = [UIColor grayColor];
                        businessNameLabel.adjustsFontSizeToFitWidth = YES;
                        businessNameLabel.font = [UIFont systemFontOfSize:16];
                        self.businessNameContentLabel = businessNameLabel;
                        [cell.contentView addSubview:self.businessNameContentLabel];
                        [businessNameLabel release];
                        
                        UILabel * businessTelShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 80, 20)];
                        businessTelShowLabel.backgroundColor = [UIColor clearColor];
                        businessTelShowLabel.font = [UIFont systemFontOfSize:16];
                        businessTelShowLabel.text = @"商家电话:";
                        [cell.contentView addSubview:businessTelShowLabel];
                        [businessTelShowLabel release];
                        
                        UILabel * businessTelLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, 180, 20)];
                        businessTelLabel.backgroundColor = [UIColor clearColor];
                        businessTelLabel.textColor = [UIColor grayColor];
                        businessTelLabel.font = [UIFont systemFontOfSize:16];
                        self.businessTelContentLabel = businessTelLabel;
                        [cell.contentView addSubview:self.businessTelContentLabel];
                        [businessTelLabel release];
                        
                        UILabel * ebusinessAddressShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 55, 80, 20)];
                        ebusinessAddressShowLabel.backgroundColor = [UIColor clearColor];
                        ebusinessAddressShowLabel.font = [UIFont systemFontOfSize:16];
                        ebusinessAddressShowLabel.text = @"商家地址:";
                        [cell.contentView addSubview:ebusinessAddressShowLabel];
                        [ebusinessAddressShowLabel release];
                        
                        UILabel * businessAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 55, 200, 20)];
                        businessAddressLabel.backgroundColor = [UIColor clearColor];
                        businessAddressLabel.textColor = [UIColor grayColor];
                        businessAddressLabel.lineBreakMode = UILineBreakModeWordWrap;
                        businessAddressLabel.numberOfLines = 0;
                        businessAddressLabel.font = [UIFont systemFontOfSize:16];
                        self.businessAddressContentLabel = businessAddressLabel;
                        [cell.contentView addSubview:self.businessAddressContentLabel];
                        [businessAddressLabel release];
                    }
                        break;
                }
                break;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (self.couponOrderInfoSearchResponseModel != nil) {
        
        switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 1:
                        self.orderIDContentLabel.text = self.orderId;
                        self.orderPriceContentLabel.text = [NSString stringWithFormat:@"¥%@",self.couponOrderInfoSearchResponseModel.payPrice];
                        
                        NSString * payStatus = nil;
                        if ([self.couponOrderInfoSearchResponseModel.isPay intValue]==0) {
                            payStatus = @"未支付";
                        } else {
                            payStatus = @"已支付";   
                        }
                        self.orderPayStatusContentLabel.text = payStatus;
                        break;
                    case 2:
                        self.couponNameContentLabel.text = self.couponOrderInfoSearchResponseModel.couponName;
                        self.orderTypeContentLabel.text = self.couponOrderInfoSearchResponseModel.typeName;
                        self.expirationTimeContentLabel.text = self.couponOrderInfoSearchResponseModel.expirationTime;
                        break;
                }
                break;
            case 1:
                if (indexPath.row == 1) {
                    self.couponPriceContentLabel.text = [NSString stringWithFormat:@"¥%@",self.couponOrderInfoSearchResponseModel.couponPrice];
                }
                
                if (indexPath.row != 0 && indexPath.row != 1) {
                    
                    for (UIView * vi in [cell.contentView  subviews]) {
                        [vi removeFromSuperview];
                    }
                    
                    CouponInfo * couponInfo = [self.couponOrderInfoSearchResponseModel.couponArray objectAtIndex:indexPath.row-2];
                    
                    UILabel * sortLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 80, 20)];
                    sortLabel.backgroundColor = [UIColor clearColor];
                    sortLabel.text = [NSString stringWithFormat:@"优惠劵%d",indexPath.row-1];
                    [cell.contentView addSubview:sortLabel];
                    [sortLabel release];
                    
                    UILabel * isUsedLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 5, 80, 20)];
                    isUsedLabel.backgroundColor = [UIColor clearColor];
                    isUsedLabel.textAlignment = UITextAlignmentRight;
                    NSString * usedStatus = nil;
                    if ([couponInfo.status intValue]==1) {
                        usedStatus = @"可用";
                    } else if ([couponInfo.status intValue]==2) {
                        usedStatus = @"占用";   
                    } else if ([couponInfo.status intValue]==3) {
                        usedStatus = @"已使用";   
                    } else if ([couponInfo.status intValue]==4) {
                        usedStatus = @"过期";   
                    }
                    isUsedLabel.text = usedStatus;
                    [cell.contentView addSubview:isUsedLabel];
                    [isUsedLabel release];
                    
                    
                    UILabel * couponCodeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 80, 20)];
                    couponCodeShowLabel.backgroundColor = [UIColor clearColor];
                    couponCodeShowLabel.font = [UIFont systemFontOfSize:16];
                    couponCodeShowLabel.text = @"优惠劵码:";
                    [cell.contentView addSubview:couponCodeShowLabel];
                    [couponCodeShowLabel release];
                    
                    UILabel * couponCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, 180, 20)];
                    couponCodeLabel.backgroundColor = [UIColor clearColor];
                    couponCodeLabel.textColor = [PiosaColorManager fontColor];
                    couponCodeLabel.font = [UIFont systemFontOfSize:16];
                    couponCodeLabel.text = couponInfo.couponNO;
                    [cell.contentView addSubview:couponCodeLabel];
                    [couponCodeLabel release];
                    
                    
                }
                
            case 2:
                switch (indexPath.row) {
                    case 1:
                        self.businessNameContentLabel.text = self.couponOrderInfoSearchResponseModel.businessName;
                        self.businessTelContentLabel.text = self.couponOrderInfoSearchResponseModel.businessTel;
                        int lineNO = [CommonTools calculateRowCountForUTF8:self.couponOrderInfoSearchResponseModel.businessAddress bytes:12*3];
                        self.businessAddressContentLabel.frame = CGRectMake(95, 55, 200, 20*lineNO);
                        self.businessAddressContentLabel.text = self.couponOrderInfoSearchResponseModel.businessAddress;
                        break;
                }
                break;
        }
    }
    
    if (indexPath.row == 0) {
        NSString *tableViewCellGroupTopTitlePath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_group_topTitle" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellGroupTopTitlePath]] autorelease];
    } else if(indexPath.row == [self.couponOrderInfoTableView numberOfRowsInSection:indexPath.section]-1){
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
    } else if([indexPath section] == 0 && [indexPath row] == 2){//第一区第三行
        return 80;
    } else if([indexPath section] == 1 && [indexPath row] == 1){//第二区第二行
        return 30;
    } else if([indexPath section] == 2 && [indexPath row] == 1){//第三区第二行
        if (self.couponOrderInfoSearchResponseModel != nil) {
            return 60+20*[CommonTools calculateRowCountForUTF8:self.couponOrderInfoSearchResponseModel.businessAddress bytes:12*3];
        }else{
            return 80;
        }
    } else {
        return 55;
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

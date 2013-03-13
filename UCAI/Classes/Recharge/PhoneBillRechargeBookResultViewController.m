//
//  PhoneBillRechargeBookResultViewController.m
//  UCAI
//
//  Created by  on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"
#import "PhoneBillRechargeBookResultViewController.h"
#import "PhoneBillRechargeResponseModel.h"
#import "PiosaFileManager.h"
#import "StaticConf.h"
#import "AllinTelPayViewController.h"
@implementation PhoneBillRechargeBookResultViewController
@synthesize modelBGView = _modelBGView;
@synthesize modelButtonView = _modelButtonView; 

- (PhoneBillRechargeBookResultViewController *)initWithResponse:(PhoneBillRechargeResponseModel *)model phone:(NSString *)phone rechargeType:(NSUInteger)type{
    self = [super init];
    _phone = [phone copy];
    _rechargeType = type;
    _phoneBillRechargeResponseModel = model;
    [_phoneBillRechargeResponseModel retain];
    return self;
}

- (void)dealloc{
    [_phone release];
    [_phoneBillRechargeResponseModel release];
    [self.modelBGView release];
    [self.modelButtonView release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)loadView{
    [super loadView];
	
    self.title = @"充值订单";
    
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
    UIView *orderInfoView = [[UIView alloc] initWithFrame:CGRectMake(5, 10, 310, 210)];
    orderInfoView.backgroundColor = [UIColor whiteColor];
    orderInfoView.layer.cornerRadius = 10;
    
    UILabel * orderIDShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 75, 20)];
    orderIDShowLabel.backgroundColor = [UIColor clearColor];
    orderIDShowLabel.font = [UIFont boldSystemFontOfSize:16];
    orderIDShowLabel.text = @"订单号码:";
    [orderInfoView addSubview:orderIDShowLabel];
    [orderIDShowLabel release];
    
    UILabel * orderIDContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 10, 220, 20)];
    orderIDContentLabel.backgroundColor = [UIColor clearColor];
    orderIDContentLabel.textColor = [PiosaColorManager fontColor];
    orderIDContentLabel.font = [UIFont boldSystemFontOfSize:16];
    orderIDContentLabel.text = _phoneBillRechargeResponseModel.orderID;
    [orderInfoView addSubview:orderIDContentLabel];
    [orderIDContentLabel release];
    
    UILabel * orderPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 80, 20)];
    orderPriceShowLabel.backgroundColor = [UIColor clearColor];
    orderPriceShowLabel.font = [UIFont boldSystemFontOfSize:16];
    orderPriceShowLabel.text = @"应付金额:";
    [orderInfoView addSubview:orderPriceShowLabel];
    [orderPriceShowLabel release];
    
    UILabel * orderPriceContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 40, 220, 20)];
    orderPriceContentLabel.backgroundColor = [UIColor clearColor];
    orderPriceContentLabel.textColor = [UIColor redColor];
    orderPriceContentLabel.font = [UIFont boldSystemFontOfSize:16];
    orderPriceContentLabel.text = [NSString stringWithFormat:@"¥%@",_phoneBillRechargeResponseModel.orderCharge];
    [orderInfoView addSubview:orderPriceContentLabel];
    [orderPriceContentLabel release];
    
    UIView *seperatorView1 = [[UIView alloc] initWithFrame:CGRectMake(5, 70, 300, 1)];
    seperatorView1.backgroundColor = [UIColor grayColor];
    [orderInfoView addSubview:seperatorView1];
    [seperatorView1 release];
    
    UILabel * phoneShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, 75, 20)];
    phoneShowLabel.backgroundColor = [UIColor clearColor];
    phoneShowLabel.font = [UIFont boldSystemFontOfSize:16];
    phoneShowLabel.text = @"手机号码:";
    [orderInfoView addSubview:phoneShowLabel];
    [phoneShowLabel release];
    
    UILabel * phoneContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 80, 220, 20)];
    phoneContentLabel.backgroundColor = [UIColor clearColor];
    phoneContentLabel.textColor = [UIColor grayColor];
    phoneContentLabel.font = [UIFont systemFontOfSize:16];
    phoneContentLabel.text = _phone;
    [orderInfoView addSubview:phoneContentLabel];
    [phoneContentLabel release];
    
    UILabel * rechargePriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 110, 80, 20)];
    rechargePriceShowLabel.backgroundColor = [UIColor clearColor];
    rechargePriceShowLabel.font = [UIFont boldSystemFontOfSize:16];
    rechargePriceShowLabel.text = @"充值金额:";
    [orderInfoView addSubview:rechargePriceShowLabel];
    [rechargePriceShowLabel release];
    
    UILabel * rechargePriceContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 110, 220, 20)];
    rechargePriceContentLabel.backgroundColor = [UIColor clearColor];
    rechargePriceContentLabel.textColor = [UIColor grayColor];
    rechargePriceContentLabel.font = [UIFont systemFontOfSize:16];
    NSString *price;
    switch (_rechargeType) {
        case 1:
            price = @"10";
            break;
        case 2:
            price = @"20";
            break;
        case 3:
            price = @"30";
            break;
        case 4:
            price = @"50";
            break;
        case 5:
            price = @"100";
            break;
        case 6:
            price = @"200";
            break;
        case 7:
            price = @"300";
            break;
    }
    rechargePriceContentLabel.text = [NSString stringWithFormat:@"¥%@",price];
    [orderInfoView addSubview:rechargePriceContentLabel];
    [rechargePriceContentLabel release];
    
    UIView *seperatorView2 = [[UIView alloc] initWithFrame:CGRectMake(5, 140, 300, 1)];
    seperatorView2.backgroundColor = [UIColor grayColor];
    [orderInfoView addSubview:seperatorView2];
    [seperatorView2 release];
    
    UILabel * simTypeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 150, 75, 20)];
    simTypeShowLabel.backgroundColor = [UIColor clearColor];
    simTypeShowLabel.font = [UIFont boldSystemFontOfSize:16];
    simTypeShowLabel.text = @"SIM类型:";
    [orderInfoView addSubview:simTypeShowLabel];
    [simTypeShowLabel release];
    
    UILabel * simTypeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 150, 220, 20)];
    simTypeContentLabel.backgroundColor = [UIColor clearColor];
    simTypeContentLabel.textColor = [UIColor grayColor];
    simTypeContentLabel.font = [UIFont systemFontOfSize:16];
    simTypeContentLabel.text = _phoneBillRechargeResponseModel.cardType;
    [orderInfoView addSubview:simTypeContentLabel];
    [simTypeContentLabel release];
    
    UILabel * attributionShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 180, 80, 20)];
    attributionShowLabel.backgroundColor = [UIColor clearColor];
    attributionShowLabel.font = [UIFont boldSystemFontOfSize:16];
    attributionShowLabel.text = @"   归属地:";
    [orderInfoView addSubview:attributionShowLabel];
    [attributionShowLabel release];
    
    UILabel * attributionContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 180, 220, 20)];
    attributionContentLabel.backgroundColor = [UIColor clearColor];
    attributionContentLabel.textColor = [UIColor grayColor];
    attributionContentLabel.font = [UIFont systemFontOfSize:16];
    attributionContentLabel.text = _phoneBillRechargeResponseModel.cardAttribution;
    [orderInfoView addSubview:attributionContentLabel];
    [attributionContentLabel release];
    
    [self.view addSubview:orderInfoView];
    [orderInfoView release];
    
    UIView *payInfoView = [[UIView alloc] initWithFrame:CGRectMake(5, 230, 310, 90)];
    payInfoView.backgroundColor = [UIColor whiteColor];
    payInfoView.layer.cornerRadius = 10;
    
    UILabel *payShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 290, 80)];
    payShowLabel.lineBreakMode = UILineBreakModeWordWrap;
    payShowLabel.numberOfLines = 0;
    payShowLabel.font = [UIFont systemFontOfSize:14];
    payShowLabel.text = @"    选择支付方式后将跳转至相关支付页面,支付成功后,系统将在5分钟内自动充值至手机,月初月底运营商系统繁忙,充值到账时间会稍有延迟.客服服务热线40068-40060.";
    [payInfoView addSubview:payShowLabel];
    [payShowLabel release];
    
    [self.view addSubview:payInfoView];
    [payInfoView release];
    
    UIButton *payButton = [[UIButton alloc] init];
    [payButton setFrame:CGRectMake(5, 330, 310, 40)];
    [payButton setTitle:@"前往支付" forState:UIControlStateNormal];
    [payButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
    [payButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
    [payButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
    [payButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
    [payButton addTarget:self action:@selector(payButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payButton];
    [payButton release];
    
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
    
    [[UIApplication  sharedApplication] openURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@%@%@",PHONE_BILLRECHARGE_ALIPAY_ADDRESS,_phoneBillRechargeResponseModel.orderID,@"&phone=",_phone]]];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)aLlinTelPay{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.modelBGView.alpha = 0;
    self.modelButtonView.frame = CGRectMake(0, 416, 320, 80);
    [UIView commitModalAnimations];

    AllinTelPayViewController *allinTelPayViewController = [[AllinTelPayViewController alloc] initWithOrderID:_phoneBillRechargeResponseModel.orderID andCouponPrice:_phoneBillRechargeResponseModel.orderCharge  andType:@"8"];
    [self.navigationController pushViewController:allinTelPayViewController animated:YES];
    [allinTelPayViewController release];
}
- (void) touchDownForCancel{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.modelBGView.alpha = 0;
    self.modelButtonView.frame = CGRectMake(0, 416, 320, 80);
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark ActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([actionSheet cancelButtonIndex] != buttonIndex) {
        //拨打客服电话
        [[UIApplication  sharedApplication] openURL:[NSURL  URLWithString:@"tel://4006840060"]];
    }
}

@end

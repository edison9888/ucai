//
//  CouponBookResultViewController.m
//  UCAI
//
//  Created by  on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"
#import "CouponBookResultViewController.h"
#import "StaticConf.h"
#import "PiosaFileManager.h"
#import "AllinTelPayViewController.h"

@implementation CouponBookResultViewController

@synthesize modelBGView = _modelBGView;
@synthesize modelButtonView = _modelButtonView;

- (CouponBookResultViewController *)initWithOrderID:(NSString *)orderID andCouponCount:(NSString *)count andCouponPrice:(NSString *)price{
    self = [super init];
    _couponOrderID = [orderID copy];
    _couponCount = [count copy];
    _couponPrice = [price copy];
    return self;
}

-(void)dealloc{
    [_couponOrderID release];
    [_couponCount release];
    [_couponPrice release];

    [_modelBGView release];
    [_modelButtonView release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)loadView{
    [super loadView];
	
    self.title = @"优惠劵";
    
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
    
    //优惠劵简介描述视图
    UIView *couponBookingResultView = [[UIView alloc] initWithFrame:CGRectMake(5, 10, 310, 120)];
    couponBookingResultView.backgroundColor = [UIColor whiteColor];
    couponBookingResultView.layer.cornerRadius = 10;
    
    UIImageView * sucessView = [[UIImageView alloc] initWithFrame:CGRectMake(45, 15, 28, 28)];
    NSString *sucessPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"sucess" inDirectory:@"CommonView"];
    sucessView.image = [UIImage imageNamed:sucessPath];
    [couponBookingResultView addSubview:sucessView];
    [sucessView release];
    
    UILabel * sucessLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 10, 165, 40)];
    sucessLabel.backgroundColor = [UIColor clearColor];
    sucessLabel.font = [UIFont boldSystemFontOfSize:22];
    sucessLabel.textColor = [UIColor redColor];
    sucessLabel.text = @"恭喜您操作成功!";
    [couponBookingResultView addSubview:sucessLabel];
    [sucessLabel release];
    
    UILabel * aramLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 300, 60)];
    aramLabel.backgroundColor = [UIColor clearColor];
    aramLabel.lineBreakMode = UILineBreakModeWordWrap;
    aramLabel.font = [UIFont systemFontOfSize:15];
    aramLabel.numberOfLines = 0;
    aramLabel.text = @"    非免费优惠劵，选择支付方式后将跳转至相关支付页面，支付成功后购买产品可享受优惠";
    [couponBookingResultView addSubview:aramLabel];
    [aramLabel release];
    
    [self.view addSubview:couponBookingResultView];
    [couponBookingResultView release];
    
    UIScrollView *couponInfoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 140, 310, 140)];
    couponInfoScrollView.backgroundColor = [UIColor whiteColor];
    couponInfoScrollView.layer.cornerRadius = 10;
    
    UILabel * copmanyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 230, 20)];
    copmanyNameLabel.backgroundColor = [UIColor clearColor];
    copmanyNameLabel.font = [UIFont boldSystemFontOfSize:17];
    copmanyNameLabel.text = @"深圳市精度天下科技有限公司";
    [couponInfoScrollView addSubview:copmanyNameLabel];
    [copmanyNameLabel release];
    
    UILabel * orderIDShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 90, 20)];
    orderIDShowLabel.backgroundColor = [UIColor clearColor];
    orderIDShowLabel.font = [UIFont boldSystemFontOfSize:16];
    orderIDShowLabel.textAlignment = UITextAlignmentRight;
    orderIDShowLabel.text = @"订单编号:";
    [couponInfoScrollView addSubview:orderIDShowLabel];
    [orderIDShowLabel release];
    
    UILabel * orderIDContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 40, 200, 20)];
    orderIDContentLabel.backgroundColor = [UIColor clearColor];
    orderIDContentLabel.textColor = [UIColor grayColor];
    orderIDContentLabel.font = [UIFont boldSystemFontOfSize:15];
    orderIDContentLabel.text = _couponOrderID;
    [couponInfoScrollView addSubview:orderIDContentLabel];
    [orderIDContentLabel release];
    
    UILabel * orderCountShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 90, 20)];
    orderCountShowLabel.backgroundColor = [UIColor clearColor];
    orderCountShowLabel.font = [UIFont boldSystemFontOfSize:16];
    orderCountShowLabel.textAlignment = UITextAlignmentRight;
    orderCountShowLabel.text = @"优惠劵数量:";
    [couponInfoScrollView addSubview:orderCountShowLabel];
    [orderCountShowLabel release];
    
    UILabel * orderCountContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 70, 200, 20)];
    orderCountContentLabel.backgroundColor = [UIColor clearColor];
    orderCountContentLabel.textColor = [UIColor grayColor];
    orderCountContentLabel.font = [UIFont boldSystemFontOfSize:15];
    orderCountContentLabel.text = _couponCount;
    [couponInfoScrollView addSubview:orderCountContentLabel];
    [orderCountContentLabel release];
    
    NSString *dottedLinePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"dottedLine" inDirectory:@"CommonView"];
    UIImageView * dottedLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
    dottedLineView.frame = CGRectMake(0, 100, 310, 2);
    [couponInfoScrollView addSubview:dottedLineView];
    [dottedLineView release];
    
    UILabel * orderPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, 90, 20)];
    orderPriceShowLabel.backgroundColor = [UIColor clearColor];
    orderPriceShowLabel.font = [UIFont boldSystemFontOfSize:16];
    orderPriceShowLabel.textAlignment = UITextAlignmentRight;
    orderPriceShowLabel.text = @"订单金额:";
    [couponInfoScrollView addSubview:orderPriceShowLabel];
    [orderPriceShowLabel release];
    
    UILabel * orderPriceContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 110, 200, 20)];
    orderPriceContentLabel.backgroundColor = [UIColor clearColor];
    orderPriceContentLabel.textColor = [UIColor redColor];
    orderPriceContentLabel.font = [UIFont boldSystemFontOfSize:17];
    orderPriceContentLabel.text = [NSString stringWithFormat:@"¥%@",_couponPrice];
    [couponInfoScrollView addSubview:orderPriceContentLabel];
    [orderPriceContentLabel release];
    
    [self.view addSubview:couponInfoScrollView];
    [couponInfoScrollView release];
    
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
    
    if ([@"0" isEqualToString:_couponPrice]||[@"0.0" isEqualToString:_couponPrice]) {
        //无需支付时
        UIButton *goButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 295, 310, 40)];
        [goButton setTitle:@"进入我的优惠劵" forState:UIControlStateNormal];
        [goButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
        [goButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
        [goButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
        [goButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
        [goButton addTarget:self action:@selector(cancelButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:goButton];
        [goButton release];
    } else {
        UIButton *payButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 295, 150, 40)];
        [payButton setTitle:@"立即支付" forState:UIControlStateNormal];
        [payButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
        [payButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
        [payButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
        [payButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
        [payButton addTarget:self action:@selector(payButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:payButton];
        [payButton release];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(165, 295, 150, 40)];
        [cancelButton setTitle:@"暂不支付" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
        [cancelButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
        [cancelButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(cancelButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cancelButton];
        [cancelButton release];
    }
    
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

- (void)cancelButtonPress{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)aLiPay{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.modelBGView.alpha = 0;
    self.modelButtonView.frame = CGRectMake(0, 416, 320, 80);
    [UIView commitModalAnimations];
    
    [[UIApplication  sharedApplication] openURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",COUPON_ALIPAY_ADDRESS,_couponOrderID]]];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)aLlinTelPay{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.modelBGView.alpha = 0;
    self.modelButtonView.frame = CGRectMake(0, 416, 320, 80);
    [UIView commitModalAnimations];
    
    AllinTelPayViewController *allinTelPayViewController = [[AllinTelPayViewController alloc] initWithOrderID:_couponOrderID andCouponPrice:_couponPrice  andType:@"3"];
    [self.navigationController pushViewController:allinTelPayViewController animated:YES];
    [allinTelPayViewController release];
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
#pragma mark ModelBackgroundView Delegate Methods

- (void) touchDownForCancel{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.modelBGView.alpha = 0;
    self.modelButtonView.frame = CGRectMake(0, 416, 320, 80);
    [UIView commitAnimations];
}


@end

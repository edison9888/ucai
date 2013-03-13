//
//  ALLinTelPayResultViewController.m
//  UCAI
//
//  Created by  on 11-12-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"
#import "ALLinTelPayResultViewController.h"

#import "PiosaFileManager.h"

@implementation ALLinTelPayResultViewController

- (ALLinTelPayResultViewController *)initWithOrderID:(NSString *)orderID andPrice:(NSString *)orderPrice andAllinID:(NSString *)allinID andAllinCreatetime:(NSString *)allinCreatetime andPhone:(NSString *)phone{
    self = [super init];
    _orderID = [orderID copy];
    _orderPrice = [orderPrice copy];
    _allinID = [allinID copy];
    _allinCreatetime = [allinCreatetime copy];
    _phone = [phone copy];
    return self;
}

#pragma mark - View lifecycle
- (void)loadView{
    [super loadView];
    self.title = @"受理结果";
    
    self.navigationItem.hidesBackButton = YES;
    
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
    
    //描述视图
    UIView *resultView = [[UIView alloc] initWithFrame:CGRectMake(5, 10, 310, 100)];
    resultView.backgroundColor = [UIColor whiteColor];
    resultView.layer.cornerRadius = 10;
    
    UIImageView * sucessView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 17, 25, 25)];
    NSString *sucessPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"sucess" inDirectory:@"CommonView"];
    sucessView.image = [UIImage imageNamed:sucessPath];
    [resultView addSubview:sucessView];
    [sucessView release];
    
    UILabel * sucessLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 240, 40)];
    sucessLabel.backgroundColor = [UIColor clearColor];
    sucessLabel.font = [UIFont boldSystemFontOfSize:17];
    sucessLabel.textColor = [UIColor redColor];
    sucessLabel.text = @"您的付款信息已经成功提交!";
    [resultView addSubview:sucessLabel];
    [sucessLabel release];
    
    UILabel * aramLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 310, 40)];
    aramLabel.backgroundColor = [UIColor clearColor];
    aramLabel.textColor = [UIColor grayColor];
    aramLabel.lineBreakMode = UILineBreakModeWordWrap;
    aramLabel.font = [UIFont systemFontOfSize:15];
    aramLabel.numberOfLines = 0;
    aramLabel.text = @"请留意接听系统为您拨出的确认的电话，您\n可按语音提示进行下一步操作完成付款";
    [resultView addSubview:aramLabel];
    [aramLabel release];
    
    [self.view addSubview:resultView];
    [resultView release];
    
    //支付信息
    UIView *orderInfoView = [[UIView alloc] initWithFrame:CGRectMake(5, 120, 310, 180)];
    orderInfoView.backgroundColor = [UIColor whiteColor];
    orderInfoView.layer.cornerRadius = 10;
    
    UILabel * copmanyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 230, 20)];
    copmanyNameLabel.backgroundColor = [UIColor clearColor];
    copmanyNameLabel.font = [UIFont boldSystemFontOfSize:17];
    copmanyNameLabel.text = @"深圳市精度天下科技有限公司";
    [orderInfoView addSubview:copmanyNameLabel];
    [copmanyNameLabel release];
    
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
    
    NSString *dottedLinePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"dottedLine" inDirectory:@"CommonView"];
    UIImageView * dottedLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
    dottedLineView.frame = CGRectMake(0, 90, 310, 2);
    [orderInfoView addSubview:dottedLineView];
    [dottedLineView release];
    
    UILabel * allinIDShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 100, 70, 20)];
    allinIDShowLabel.backgroundColor = [UIColor clearColor];
    allinIDShowLabel.font = [UIFont boldSystemFontOfSize:16];
    allinIDShowLabel.textAlignment = UITextAlignmentRight;
    allinIDShowLabel.text = @"交易号:";
    [orderInfoView addSubview:allinIDShowLabel];
    [allinIDShowLabel release];
    
    UILabel * allinIDContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 100, 220, 20)];
    allinIDContentLabel.backgroundColor = [UIColor clearColor];
    allinIDContentLabel.textColor = [UIColor grayColor];
    allinIDContentLabel.font = [UIFont boldSystemFontOfSize:17];
    allinIDContentLabel.text = _allinID;
    [orderInfoView addSubview:allinIDContentLabel];
    [allinIDContentLabel release];
    
    UILabel * allinCreatetimeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 125, 80, 20)];
    allinCreatetimeShowLabel.backgroundColor = [UIColor clearColor];
    allinCreatetimeShowLabel.font = [UIFont boldSystemFontOfSize:16];
    allinCreatetimeShowLabel.text = @"交易时间:";
    [orderInfoView addSubview:allinCreatetimeShowLabel];
    [allinCreatetimeShowLabel release];
    
    UILabel * allinCreatetimeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 125, 220, 20)];
    allinCreatetimeContentLabel.backgroundColor = [UIColor clearColor];
    allinCreatetimeContentLabel.textColor = [UIColor grayColor];
    allinCreatetimeContentLabel.font = [UIFont boldSystemFontOfSize:17];
    allinCreatetimeContentLabel.text = _allinCreatetime;
    [orderInfoView addSubview:allinCreatetimeContentLabel];
    [allinCreatetimeContentLabel release];
    
    UILabel * phoneShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 150, 80, 20)];
    phoneShowLabel.backgroundColor = [UIColor clearColor];
    phoneShowLabel.font = [UIFont boldSystemFontOfSize:16];
    phoneShowLabel.text = @"手机号码:";
    [orderInfoView addSubview:phoneShowLabel];
    [phoneShowLabel release];
    
    UILabel * phoneContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 150, 220, 20)];
    phoneContentLabel.backgroundColor = [UIColor clearColor];
    phoneContentLabel.textColor = [UIColor grayColor];
    phoneContentLabel.font = [UIFont boldSystemFontOfSize:17];
    phoneContentLabel.text = _phone;
    [orderInfoView addSubview:phoneContentLabel];
    [phoneContentLabel release];
    
    [self.view addSubview:orderInfoView];
    [orderInfoView release];
    
    UIButton *goButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 320, 310, 40)];
    [goButton setTitle:@"确    定" forState:UIControlStateNormal];
    [goButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
    [goButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
    [goButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
    [goButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
    [goButton addTarget:self action:@selector(cancelButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goButton];
    [goButton release];
    
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

- (void)cancelButtonPress{
    [self.navigationController popToRootViewControllerAnimated:YES];
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

//
//  CouponInfoViewController.m
//  UCAI
//
//  Created by  on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"
#import "CouponInfoViewController.h"
#import "CouponBuyCountChoiceTableViewController.h"
#import "CouponInfoSearchResponseModel.h"
#import "CouponBookingResponseModel.h"
#import "UIHTTPImageView.h"
#import "MemberLoginViewController.h"

#import "CouponBookResultViewController.h"

#import "CommonTools.h"
#import "GDataXMLNode.h"
#import "ASIFormDataRequest.h"
#import "StaticConf.h"
#import "ResponseParser.h"
#import "PiosaFileManager.h"

#define kHUDhiddenTag 101 //只需要消失提交框
#define kHUDhiddenAndPopTag 102 //需要在提交框消失后退出视图

@implementation CouponInfoViewController

@synthesize couponBuyCount = _couponBuyCount;

@synthesize couponImageView = _couponImageView;
@synthesize couponNameLabel = _couponNameLabel;
@synthesize couponPriceLabel = _couponPriceLabel;
@synthesize couponPopularityLabel = _couponPopularityLabel;
@synthesize couponTypeLabel = _couponTypeLabel;
@synthesize couponEndTimeLabel = _couponEndTimeLabel;
@synthesize couponSellPriceLabel = _couponSellPriceLabel;
@synthesize couponBuyCountChoiceButton = _couponBuyCountChoiceButton;
@synthesize couponGetButton = _couponGetButton;

@synthesize requestType = _requestType;

@synthesize couponInfoScrollView = _couponInfoScrollView;

#pragma mark -
#pragma mark Init

- (CouponInfoViewController *)initWithCouponID:(NSString *)couponID couponType:(NSUInteger) couponType{
    self = [super init];
    _couponID = [couponID copy];
    _couponType = couponType;
    _couponBuyCount = 1;
    return self;
}

- (void)dealloc{
    [_couponID release];
    
    [_couponImageView release];
    [_couponNameLabel release];
    [_couponPriceLabel release];
    [_couponPopularityLabel release];
    [_couponTypeLabel release];
    [_couponEndTimeLabel release];
    [_couponSellPriceLabel release];
    [_couponBuyCountChoiceButton release];
    [_couponGetButton release];
    
    [_couponInfoScrollView release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
    self.title = @"优惠劵信息";

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
    UIView *couponSummaryView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 310, 140)];
    couponSummaryView.backgroundColor = [UIColor whiteColor];
    couponSummaryView.layer.cornerRadius = 10;
    
    UIHTTPImageView *uiHTTPImageView = [[UIHTTPImageView alloc] initWithFrame:CGRectMake(10, 5, 100, 74)];
    uiHTTPImageView.backgroundColor = [UIColor clearColor];
    self.couponImageView = uiHTTPImageView;
    [couponSummaryView addSubview:uiHTTPImageView];
    [uiHTTPImageView release];
    
    UILabel *couponNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 5, 170, 15)];
    couponNameLabel.backgroundColor = [UIColor clearColor];
    couponNameLabel.font = [UIFont systemFontOfSize:15];
    couponNameLabel.textColor = [PiosaColorManager fontColor];
    self.couponNameLabel = couponNameLabel;
    [couponSummaryView addSubview:couponNameLabel];
    [couponNameLabel release];
    
    UILabel *couponPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 27, 30, 15)];
    couponPriceShowLabel.backgroundColor = [UIColor clearColor];
    couponPriceShowLabel.font = [UIFont systemFontOfSize:14];
    couponPriceShowLabel.text = @"优惠";
    [couponSummaryView addSubview:couponPriceShowLabel];
    [couponPriceShowLabel release];
    
    UILabel *couponPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 27, 100, 15)];
    couponPriceLabel.backgroundColor = [UIColor clearColor];
    couponPriceLabel.font = [UIFont systemFontOfSize:14];
    couponPriceLabel.textColor = [UIColor redColor];
    self.couponPriceLabel = couponPriceLabel;
    [couponSummaryView addSubview:couponPriceLabel];
    [couponPriceLabel release];
    
    UILabel *couponPopularityShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 45, 30, 15)];
    couponPopularityShowLabel.backgroundColor = [UIColor clearColor];
    couponPopularityShowLabel.font = [UIFont systemFontOfSize:12];
    couponPopularityShowLabel.text = @"人气:";
    [couponSummaryView addSubview:couponPopularityShowLabel];
    [couponPopularityShowLabel release];
    
    UILabel *couponPopularityLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 45, 100, 15)];
    couponPopularityLabel.backgroundColor = [UIColor clearColor];
    couponPopularityLabel.font = [UIFont systemFontOfSize:12];
    couponPopularityLabel.textColor = [UIColor redColor];
    self.couponPopularityLabel = couponPopularityLabel;
    [couponSummaryView addSubview:couponPopularityLabel];
    [couponPopularityLabel release];
    
    UILabel *couponTypeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 63, 30, 15)];
    couponTypeShowLabel.backgroundColor = [UIColor clearColor];
    couponTypeShowLabel.font = [UIFont systemFontOfSize:12];
    couponTypeShowLabel.text = @"类型:";
    [couponSummaryView addSubview:couponTypeShowLabel];
    [couponTypeShowLabel release];
    
    UILabel *couponTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 63, 100, 15)];
    couponTypeLabel.backgroundColor = [UIColor clearColor];
    couponTypeLabel.font = [UIFont systemFontOfSize:12];
    self.couponTypeLabel = couponTypeLabel;
    [couponSummaryView addSubview:couponTypeLabel];
    [couponTypeLabel release];
    
    UILabel *couponEndTimeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 50, 20)];
    couponEndTimeShowLabel.backgroundColor = [UIColor clearColor];
    couponEndTimeShowLabel.font = [UIFont systemFontOfSize:13];
    couponEndTimeShowLabel.text = @"活动至:";
    [couponSummaryView addSubview:couponEndTimeShowLabel];
    [couponEndTimeShowLabel release];
    
    UILabel *couponEndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 80, 140, 20)];
    couponEndTimeLabel.backgroundColor = [UIColor clearColor];
    couponEndTimeLabel.font = [UIFont systemFontOfSize:13];
    couponEndTimeLabel.textColor = [UIColor grayColor];
    self.couponEndTimeLabel = couponEndTimeLabel;
    [couponSummaryView addSubview:couponEndTimeLabel];
    [couponEndTimeLabel release];
    
    UILabel *couponSellPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 80, 40, 20)];
    couponSellPriceShowLabel.backgroundColor = [UIColor clearColor];
    couponSellPriceShowLabel.font = [UIFont systemFontOfSize:13];
    couponSellPriceShowLabel.text = @"购买价";
    [couponSummaryView addSubview:couponSellPriceShowLabel];
    [couponSellPriceShowLabel release];
    
    UILabel *couponSellPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 80 , 50, 20)];
    couponSellPriceLabel.backgroundColor = [UIColor clearColor];
    couponSellPriceLabel.font = [UIFont systemFontOfSize:13];
    couponSellPriceLabel.textColor = [UIColor redColor];
    self.couponSellPriceLabel = couponSellPriceLabel;
    [couponSummaryView addSubview:couponSellPriceLabel];
    [couponSellPriceLabel release];
    
    if (_couponType == 2) {
        UILabel *couponBuyCountShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 110, 70, 20)];
        couponBuyCountShowLabel.backgroundColor = [UIColor clearColor];
        couponBuyCountShowLabel.font = [UIFont systemFontOfSize:15];
        couponBuyCountShowLabel.text = @"购买数量:";
        [couponSummaryView addSubview:couponBuyCountShowLabel];
        [couponBuyCountShowLabel release];
        
        UIButton *couponBuyCountButton = [[UIButton alloc] initWithFrame:CGRectMake(80, 105, 90, 30)];
        NSString *textFieldNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"textField_normal" inDirectory:@"CommonView/TextField"];
        NSString *textFieldHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"textField_highlighted" inDirectory:@"CommonView/TextField"];
        [couponBuyCountButton setBackgroundImage:[UIImage imageNamed:textFieldNormalPath] forState:UIControlStateNormal];
        [couponBuyCountButton setBackgroundImage:[UIImage imageNamed:textFieldHighlightedPath] forState:UIControlStateHighlighted];
        [couponBuyCountButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [couponBuyCountButton setTitle:[NSString stringWithFormat:@"%d",self.couponBuyCount] forState:UIControlStateNormal];
        [couponBuyCountButton addTarget:self action:@selector(couponBuyCountChoice) forControlEvents:UIControlEventTouchUpInside];
        self.couponBuyCountChoiceButton = couponBuyCountButton;
        [couponSummaryView addSubview:couponBuyCountButton];
        [couponBuyCountButton release];
    }
    
    UIButton *getButton = [[UIButton alloc] initWithFrame:CGRectMake(220, 105, 80, 30)];
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"doneButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"doneButton_highlighted" inDirectory:@"CommonView/MethodButton"];
    [getButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
	[getButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
    switch (_couponType) {
        case 1:
            [getButton setTitle:@"领  取" forState:UIControlStateNormal];
            break;
        case 2:
            [getButton setTitle:@"购  买" forState:UIControlStateNormal];
            break;
    }
    [getButton addTarget:self action:@selector(couponGetPress) forControlEvents:UIControlEventTouchUpInside];
    self.couponGetButton = getButton;
    [couponSummaryView addSubview:getButton];
    [getButton release];
    
    [self.view addSubview:couponSummaryView];
    [couponSummaryView release];
    
    UIScrollView *couponInfoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 150, 310, 260)];
    couponInfoScrollView.backgroundColor = [UIColor whiteColor];
    couponInfoScrollView.layer.cornerRadius = 10;
    self.couponInfoScrollView = couponInfoScrollView;
    [self.view addSubview:couponInfoScrollView];
    [couponInfoScrollView release];
}

- (void)viewDidLoad{
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"查询中...";
    _hud.tag = kHUDhiddenTag;
    [_hud show:YES];
    
    self.requestType = 1;
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: COUPON_INFO_ADDRESS]] ;
    request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    
    NSString *postData = [[NSString alloc] initWithData:[self generateCouponInfoSearchRequestPostXMLData] encoding:NSUTF8StringEncoding];
    NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    [postData release];
    
    [request appendPostData:[self generateCouponInfoSearchRequestPostXMLData]];
    
    [request setDelegate:self];
    [request startAsynchronous]; // 执行异步post
    [request release];
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

- (NSData*)generateCouponInfoSearchRequestPostXMLData{
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"couponID"stringValue:_couponID]];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    return document.XMLData;
}

- (NSData*)generateCouponBookingSearchRequestPostXMLData{
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
    
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"source"stringValue:[NSString stringWithFormat:@"%d",_couponType]]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"couponID"stringValue:_couponID]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"memberID"stringValue:[memberDict objectForKey:@"memberID"]]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"amount"stringValue:[NSString stringWithFormat:@"%d",self.couponBuyCount]]];
    
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    return document.XMLData;
}

- (void)couponBuyCountChoice{
    CATransition * animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.4;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"moveIn";
    animation.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:animation forKey:nil];
    
    CouponBuyCountChoiceTableViewController *couponBuyCountChoiceTableViewController = [[CouponBuyCountChoiceTableViewController alloc] initWithSelectRow:self.couponBuyCount-1];
    couponBuyCountChoiceTableViewController.couponInfoViewController = self;
    [self.navigationController pushViewController:couponBuyCountChoiceTableViewController animated:NO];
    [CouponBuyCountChoiceTableViewController release];
}

- (void)couponGetPress{
    
    NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _hud.bgRGB = [PiosaColorManager progressColor];
        [self.navigationController.view addSubview:_hud];
        _hud.delegate = self;
        _hud.minSize = CGSizeMake(135.f, 135.f);
        _hud.labelText = @"请稍候...";
        _hud.tag = kHUDhiddenTag;
        [_hud show:YES];
        
        self.requestType = 2;
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: COUPON_BOOK_ADDRESS]] ;
        request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
        
        NSString *postData = [[NSString alloc] initWithData:[self generateCouponBookingSearchRequestPostXMLData] encoding:NSUTF8StringEncoding];
        NSLog(@"requestStart\n");
        NSLog(@"%@\n", postData);
        [postData release];
        
        [request appendPostData:[self generateCouponBookingSearchRequestPostXMLData]];
        
        [request setDelegate:self];
        [request startAsynchronous]; // 执行异步post
        [request release];
    } else {
        //会员未登陆
        MemberLoginViewController *loginController = [[MemberLoginViewController alloc] initWithComeFromType:4];
        [self.navigationController pushViewController:loginController animated:YES];
        [loginController release];
    }
}

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应 : 但可能是错误响应, 如 404，或查询结果为空，则不跳转到下一个机票展示页面
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);
    //关闭提示框
    [_hud hide:YES];
    if ((responseString != nil) && [responseString length] > 0) {
        
        switch (self.requestType) {
            case 1:{
                CouponInfoSearchResponseModel *couponInfoSearchResponseModel = [ResponseParser loadCouponInfoSearchResponse:[request responseData]];
                
                if (couponInfoSearchResponseModel.resultCode == nil || [couponInfoSearchResponseModel.resultCode length] == 0 || [couponInfoSearchResponseModel.resultCode intValue] != 0) {
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
                    hud.labelText = couponInfoSearchResponseModel.resultMessage;
                    hud.tag = kHUDhiddenAndPopTag;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    NSString *imageLoadingPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"image_loading" inDirectory:@"Hotel"];
                    [self.couponImageView setImageWithURL:[NSURL URLWithString:couponInfoSearchResponseModel.couponImage] placeholderImage:[UIImage imageNamed:imageLoadingPath]];
                    self.couponNameLabel.text = couponInfoSearchResponseModel.couponName;
                    self.couponPriceLabel.text = [NSString stringWithFormat:@"¥%@",couponInfoSearchResponseModel.couponPrice];
                    self.couponPopularityLabel.text = couponInfoSearchResponseModel.couponPopularity;
                    self.couponTypeLabel.text = couponInfoSearchResponseModel.couponType;
                    self.couponEndTimeLabel.text = couponInfoSearchResponseModel.couponEndTime;
                    if ([@"0.0" isEqualToString:couponInfoSearchResponseModel.couponSellPrice]) {
                        self.couponSellPriceLabel.text = @"免费";
                    } else {
                        self.couponSellPriceLabel.text = [NSString stringWithFormat:@"¥%@",couponInfoSearchResponseModel.couponSellPrice];
                    }
                    
                    UILabel * couponPeriodShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 100, 15)];
                    couponPeriodShowLabel.backgroundColor = [UIColor clearColor];
                    couponPeriodShowLabel.font = [UIFont systemFontOfSize:15];
                    couponPeriodShowLabel.text = @"使用有效期:";
                    [self.couponInfoScrollView addSubview:couponPeriodShowLabel];
                    [couponPeriodShowLabel release];
                    
                    UILabel * couponPeriodContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 200, 15)];
                    couponPeriodContentLabel.backgroundColor = [UIColor clearColor];
                    couponPeriodContentLabel.font = [UIFont systemFontOfSize:15];
                    couponPeriodContentLabel.textColor = [UIColor grayColor];
                    couponPeriodContentLabel.text = [NSString stringWithFormat:@"%@个月(从领取/购买之日计算)",couponInfoSearchResponseModel.couponPeriod];
                    [self.couponInfoScrollView addSubview:couponPeriodContentLabel];
                    [couponPeriodContentLabel release];
                    
                    UILabel * couponConditionShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 55, 100, 15)];
                    couponConditionShowLabel.backgroundColor = [UIColor clearColor];
                    couponConditionShowLabel.font = [UIFont systemFontOfSize:15];
                    couponConditionShowLabel.text = @"使用条件:";
                    [self.couponInfoScrollView addSubview:couponConditionShowLabel];
                    [couponConditionShowLabel release];
                    
                    int conditionRowNum = [CommonTools calculateRowCountForUTF8:couponInfoSearchResponseModel.couponCondition bytes:3*19];
                    
                    UILabel * couponConditionContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 75, 290, 17*conditionRowNum)];
                    couponConditionContentLabel.backgroundColor = [UIColor clearColor];
                    couponConditionContentLabel.textColor = [UIColor grayColor];
                    couponConditionContentLabel.font = [UIFont systemFontOfSize:15];
                    couponConditionContentLabel.lineBreakMode = UILineBreakModeWordWrap;
                    couponConditionContentLabel.numberOfLines = 0;
                    couponConditionContentLabel.text = couponInfoSearchResponseModel.couponCondition;
                    [self.couponInfoScrollView addSubview:couponConditionContentLabel];
                    [couponConditionContentLabel release];
                    
                    UILabel * couponDetailShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 85+17*conditionRowNum, 100, 15)];
                    couponDetailShowLabel.backgroundColor = [UIColor clearColor];
                    couponDetailShowLabel.font = [UIFont systemFontOfSize:15];
                    couponDetailShowLabel.text = @"详细说明:";
                    [self.couponInfoScrollView addSubview:couponDetailShowLabel];
                    [couponDetailShowLabel release];
                    
                    int detailRowNum = [CommonTools calculateRowCountForUTF8:couponInfoSearchResponseModel.couponDetail bytes:3*19];
                    
                    UILabel * couponDetailContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 105+17*conditionRowNum, 290, 17*detailRowNum)];
                    couponDetailContentLabel.backgroundColor = [UIColor clearColor];
                    couponDetailContentLabel.textColor = [UIColor grayColor];
                    couponDetailContentLabel.font = [UIFont systemFontOfSize:15];
                    couponDetailContentLabel.lineBreakMode = UILineBreakModeWordWrap;
                    couponDetailContentLabel.numberOfLines = 0;
                    couponDetailContentLabel.text = couponInfoSearchResponseModel.couponDetail;
                    [self.couponInfoScrollView addSubview:couponDetailContentLabel];
                    [couponDetailContentLabel release];
                    
                    UILabel * couponMethodShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 105+17*conditionRowNum+17*detailRowNum+10, 100, 15)];
                    couponMethodShowLabel.backgroundColor = [UIColor clearColor];
                    couponMethodShowLabel.font = [UIFont systemFontOfSize:15];
                    couponMethodShowLabel.text = @"使用方法:";
                    [self.couponInfoScrollView addSubview:couponMethodShowLabel];
                    [couponMethodShowLabel release];
                    
                    int methodRowNum = [CommonTools calculateRowCountForUTF8:couponInfoSearchResponseModel.couponMethod bytes:3*19];
                    
                    UILabel * couponMethodContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 105+17*conditionRowNum+17*detailRowNum+10+20, 290, 17*methodRowNum)];
                    couponMethodContentLabel.backgroundColor = [UIColor clearColor];
                    couponMethodContentLabel.textColor = [UIColor grayColor];
                    couponMethodContentLabel.font = [UIFont systemFontOfSize:15];
                    couponMethodContentLabel.lineBreakMode = UILineBreakModeWordWrap;
                    couponMethodContentLabel.numberOfLines = 0;
                    couponMethodContentLabel.text = couponInfoSearchResponseModel.couponMethod;
                    [self.couponInfoScrollView addSubview:couponMethodContentLabel];
                    [couponMethodContentLabel release];
                    
                    //商家分隔线
                    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(5, 105+17*conditionRowNum+17*detailRowNum+10+20+17*methodRowNum+10, 300, 1)];
                    separatorView.backgroundColor = [UIColor grayColor];
                    [self.couponInfoScrollView addSubview:separatorView];
                    [separatorView release];
                    
                    UILabel * businessNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 105+17*conditionRowNum+17*detailRowNum+10+20+17*methodRowNum+20, 70, 15)];
                    businessNameShowLabel.backgroundColor = [UIColor clearColor];
                    businessNameShowLabel.font = [UIFont systemFontOfSize:15];
                    businessNameShowLabel.text = @"商家名称:";
                    [self.couponInfoScrollView addSubview:businessNameShowLabel];
                    [businessNameShowLabel release];
                    
                    UILabel * businessNameContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 105+17*conditionRowNum+17*detailRowNum+10+20+17*methodRowNum+20, 230, 15)];
                    businessNameContentLabel.backgroundColor = [UIColor clearColor];
                    businessNameContentLabel.textColor = [UIColor grayColor];
                    businessNameContentLabel.font = [UIFont systemFontOfSize:15];
                    businessNameContentLabel.text = couponInfoSearchResponseModel.businessName;
                    [self.couponInfoScrollView addSubview:businessNameContentLabel];
                    [businessNameContentLabel release];
                    
                    UILabel * cityNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 105+17*conditionRowNum+17*detailRowNum+10+20+17*methodRowNum+20+25, 70, 15)];
                    cityNameShowLabel.backgroundColor = [UIColor clearColor];
                    cityNameShowLabel.font = [UIFont systemFontOfSize:15];
                    cityNameShowLabel.text = @"所在城市:";
                    [self.couponInfoScrollView addSubview:cityNameShowLabel];
                    [cityNameShowLabel release];
                    
                    UILabel * cityNameContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 105+17*conditionRowNum+17*detailRowNum+10+20+17*methodRowNum+20+25, 230, 15)];
                    cityNameContentLabel.backgroundColor = [UIColor clearColor];
                    cityNameContentLabel.textColor = [UIColor grayColor];
                    cityNameContentLabel.font = [UIFont systemFontOfSize:15];
                    cityNameContentLabel.text = couponInfoSearchResponseModel.cityName;
                    [self.couponInfoScrollView addSubview:cityNameContentLabel];
                    [cityNameContentLabel release];
                    
                    UILabel * businessWebsiteShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 105+17*conditionRowNum+17*detailRowNum+10+20+17*methodRowNum+20+25+25, 70, 15)];
                    businessWebsiteShowLabel.backgroundColor = [UIColor clearColor];
                    businessWebsiteShowLabel.font = [UIFont systemFontOfSize:15];
                    businessWebsiteShowLabel.text = @"商家网站:";
                    [self.couponInfoScrollView addSubview:businessWebsiteShowLabel];
                    [businessWebsiteShowLabel release];
                    
                    UILabel * businessWebsiteContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 105+17*conditionRowNum+17*detailRowNum+10+20+17*methodRowNum+20+25+25, 230, 15)];
                    businessWebsiteContentLabel.backgroundColor = [UIColor clearColor];
                    businessWebsiteContentLabel.textColor = [UIColor grayColor];
                    businessWebsiteContentLabel.font = [UIFont systemFontOfSize:15];
                    businessWebsiteContentLabel.text = couponInfoSearchResponseModel.businessWebsite;
                    [self.couponInfoScrollView addSubview:businessWebsiteContentLabel];
                    [businessWebsiteContentLabel release];
                    
                    UILabel * businessTelShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 105+17*conditionRowNum+17*detailRowNum+10+20+17*methodRowNum+20+25+25+25, 70, 15)];
                    businessTelShowLabel.backgroundColor = [UIColor clearColor];
                    businessTelShowLabel.font = [UIFont systemFontOfSize:15];
                    businessTelShowLabel.text = @"商家电话:";
                    [self.couponInfoScrollView addSubview:businessTelShowLabel];
                    [businessTelShowLabel release];
                    
                    UILabel * businessTelContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 105+17*conditionRowNum+17*detailRowNum+10+20+17*methodRowNum+20+25+25+25, 230, 15)];
                    businessTelContentLabel.backgroundColor = [UIColor clearColor];
                    businessTelContentLabel.textColor = [UIColor grayColor];
                    businessTelContentLabel.font = [UIFont systemFontOfSize:15];
                    businessTelContentLabel.text = couponInfoSearchResponseModel.businessTel;
                    [self.couponInfoScrollView addSubview:businessTelContentLabel];
                    [businessTelContentLabel release];
                    
                    UILabel * businessAddressShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 105+17*conditionRowNum+17*detailRowNum+10+20+17*methodRowNum+20+25+25+25+25, 70, 15)];
                    businessAddressShowLabel.backgroundColor = [UIColor clearColor];
                    businessAddressShowLabel.font = [UIFont systemFontOfSize:15];
                    businessAddressShowLabel.text = @"商家地址:";
                    [self.couponInfoScrollView addSubview:businessAddressShowLabel];
                    [businessAddressShowLabel release];
                    
                    int businessAddressRowNum = [CommonTools calculateRowCountForUTF8:couponInfoSearchResponseModel.businessAddress bytes:3*15];
                    
                    UILabel * businessAddressContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 105+17*conditionRowNum+17*detailRowNum+10+20+17*methodRowNum+20+25+25+25+25, 230, 17*businessAddressRowNum)];
                    businessAddressContentLabel.backgroundColor = [UIColor clearColor];
                    businessAddressContentLabel.textColor = [UIColor grayColor];
                    businessAddressContentLabel.font = [UIFont systemFontOfSize:15];
                    businessAddressContentLabel.lineBreakMode = UILineBreakModeWordWrap;
                    businessAddressContentLabel.numberOfLines = 0;
                    businessAddressContentLabel.text = couponInfoSearchResponseModel.businessAddress;
                    [self.couponInfoScrollView addSubview:businessAddressContentLabel];
                    [businessAddressContentLabel release];
                    
                    UILabel * businessContactShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 105+17*conditionRowNum+17*detailRowNum+10+20+17*methodRowNum+20+25+25+25+25+17*businessAddressRowNum+10, 80, 15)];
                    businessContactShowLabel.backgroundColor = [UIColor clearColor];
                    businessContactShowLabel.font = [UIFont systemFontOfSize:15];
                    businessContactShowLabel.text = @"商家联系人:";
                    [self.couponInfoScrollView addSubview:businessContactShowLabel];
                    [businessContactShowLabel release];
                    
                    UILabel * businessContactContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 105+17*conditionRowNum+17*detailRowNum+10+20+17*methodRowNum+20+25+25+25+25+17*businessAddressRowNum+10, 220, 15)];
                    businessContactContentLabel.backgroundColor = [UIColor clearColor];
                    businessContactContentLabel.textColor = [UIColor grayColor];
                    businessContactContentLabel.font = [UIFont systemFontOfSize:15];
                    businessContactContentLabel.text = couponInfoSearchResponseModel.businessContact;
                    [self.couponInfoScrollView addSubview:businessContactContentLabel];
                    [businessContactContentLabel release];
                    
                    self.couponInfoScrollView.contentSize = CGSizeMake(310, 105+17*conditionRowNum+17*detailRowNum+10+20+17*methodRowNum+20+25+25+25+25+17*businessAddressRowNum+10+25);
                }
            }
                break;
            case 2:{
                CouponBookingResponseModel *couponBookingResponseModel = [ResponseParser loadCouponBookingResponse:[request responseData]];
                
                if (couponBookingResponseModel.resultCode == nil || [couponBookingResponseModel.resultCode length] == 0 || [couponBookingResponseModel.resultCode intValue] != 0) {
                    // 下单失败
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
                    hud.labelText = couponBookingResponseModel.resultMessage;
                    hud.tag = kHUDhiddenTag;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    CouponBookResultViewController *couponBookResultViewController = [[CouponBookResultViewController alloc] initWithOrderID:couponBookingResponseModel.orderID andCouponCount:[NSString stringWithFormat:@"%d",self.couponBuyCount] andCouponPrice:couponBookingResponseModel.payPrice];
                    [self.navigationController pushViewController:couponBookResultViewController animated:YES];
                    [couponBookResultViewController release];
                }
            }
                break;
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
    if (self.requestType == 1) {
        _hud.tag = kHUDhiddenAndPopTag;
    } else {
        _hud.tag = kHUDhiddenTag;
    }
    [_hud hide:YES afterDelay:3];
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

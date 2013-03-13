//
//  FlightBookViewController.m
//  UCAI
//
//  Created by  on 12-1-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "FlightBookViewController.h"
#import "FlightCustomer.h"

#import "FlightCustomerAddController.h"
#import "FlightBookResponseModel.h"
#import "FlightBookSucceedViewController.h"
#import "FlightHistoryCustomerChoiceViewController.h"

#import "PiosaFileManager.h"
#import "ResponseParser.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "StaticConf.h"
#import "CommonTools.h"

@implementation FlightBookViewController

@synthesize bookTableView = _bookTableView;
@synthesize customers = _customers;

@synthesize contactNameLabel = _contactNameLabel;
@synthesize contactPhoneLabel = _contactPhoneLabel;

@synthesize bookButton = _bookButton;

@synthesize confirmView = _confirmView;

- (void)dealloc {
    [_flightCompanyDic release];
	
    [_bookTableView release];
    [_customers release];
    
    [_contactNameLabel release];
	[_contactPhoneLabel release];
    
	[_bookButton release];
    
	[_confirmView release];
	
    [super dealloc];
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

- (void)phoneCall{
    if ([[UIApplication  sharedApplication] canOpenURL:[NSURL  URLWithString:@"tel://4006840060"]]) {
        UIActionSheet * phoneActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拨打电话40068 40060" otherButtonTitles:nil, nil];
        phoneActionSheet.delegate = self;
        [phoneActionSheet showInView:[UIApplication sharedApplication].keyWindow];
		[phoneActionSheet release];
    }
}

//根据表格列表的内容来重新设置订购按钮的位置
- (void)resetBookButton{
	int add = ([self.customers count]>1?[self.customers count]-1:0)*44;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    switch ([userDefaults integerForKey:@"flightSearchLineType"]) {
        case UCAIFlightLineStyleSingle:
            [self.bookButton setFrame:CGRectMake(10, 465+add, 300, 40)];
            break;
        case UCAIFlightLineStyleDouble:
            [self.bookButton setFrame:CGRectMake(10, 642+add, 300, 40)];
            break;
    }
}

//新增旅客按钮响应方法
- (void)addGuest:(id)sender
{
    if ([self.customers count]<9) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5f;//间隔时间
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];//动画的开始与结束的快慢
        transition.type = @"moveIn"; // 各种动画效果
        transition.subtype = kCATransitionFromTop;// 动画方向
        transition.delegate = self; 
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        
        FlightCustomerAddController * flightCustomerAddController = [[FlightCustomerAddController alloc] init];
        flightCustomerAddController.flightBookViewController = self;
        [self.navigationController pushViewController:flightCustomerAddController animated:NO];
        [flightCustomerAddController release];
    }
}

- (void)historyCustomerFind{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;//间隔时间
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];//动画的开始与结束的快慢
    transition.type = @"moveIn"; // 各种动画效果
    transition.subtype = kCATransitionFromTop;// 动画方向
    transition.delegate = self; 
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    FlightHistoryCustomerChoiceViewController *flightHistoryCustomerChoiceViewController = [[FlightHistoryCustomerChoiceViewController alloc] initWithMaxChoiceCount:9-[self.customers count]];
    flightHistoryCustomerChoiceViewController.flightBookViewController = self;
    [self.navigationController pushViewController:flightHistoryCustomerChoiceViewController animated:NO];
    [flightHistoryCustomerChoiceViewController release];
}

//响应文本输入框的完成按钮操作，用于收回键盘
- (IBAction)textFieldDone:(id)sender{
	[self.bookTableView becomeFirstResponder];
    self.bookTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 80.0f, 0.0f);//设置列表的位置
}

//表格表单进入编辑的按钮响应方法
- (IBAction) toggleEdit:(id)sender{
	UIButton * button = (UIButton *)sender;
	[self.bookTableView setEditing:!self.bookTableView.editing animated:YES];
	if (self.bookTableView.editing) {
		[button setTitle:@"完成" forState:UIControlStateNormal];
        NSString *doneButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"doneButton_normal" inDirectory:@"CommonView/MethodButton"];
        NSString *doneButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"doneButton_highlighted" inDirectory:@"CommonView/MethodButton"];
        [button setBackgroundImage:[UIImage imageNamed:doneButtonNormalPath] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:doneButtonHighlightedPath] forState:UIControlStateHighlighted];
		self.bookButton.enabled = FALSE;
	} else {
		[button setTitle:@"编辑" forState:UIControlStateNormal];
        NSString *addAndEditButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"addAndEditButton_normal.png" inDirectory:@"CommonView/MethodButton"];
        NSString *addAndEditButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"addAndEditButton_highlighted.png" inDirectory:@"CommonView/MethodButton"];
        [button setBackgroundImage:[UIImage imageNamed:addAndEditButtonNormalPath] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:addAndEditButtonHighlightedPath] forState:UIControlStateHighlighted];
		self.bookButton.enabled = TRUE;
	}
}

//确认视图中返回按钮的响应
- (void) backFromConfirm{
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
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:0.3];
	
	self.confirmView.alpha = 0.0f;										//设置确认视图的透明度
	self.confirmView.transform = CGAffineTransformMakeScale(0.25f, 0.25f);//设置确认视图的缩放大小
	
	[UIView commitAnimations];
	
	self.title = @"填写订单";
}

//订购按钮响应方法
- (void)bookButtonPress:(id)sender{
	int check = [self checkAndSaveIn];
	
	NSString * showMes = nil;
	switch (check) {
		case 1:
			showMes = @"您似乎还未填写乘机人信息";
			break;
        case 2:
			showMes = @"儿童或婴儿不可单独订票";
			break;
		case 3:
			showMes = @"儿童婴儿总人数不可超过成人人数";
			break;
		case 4:
			showMes = @"您似乎还未输入联系人姓名";
			break;
		case 5:
			showMes = @"您似乎还未输入联系手机号";
			break;
		case 6:
			showMes = @"请输入有效的手机号码";
			break;
	}
	
	if (check!=0) {
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
	} else {
        self.title = @"核对订单";
        
        //返回按钮
        NSString *backButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"backButton_normal" inDirectory:@"CommonView/NavigationItem"];
        NSString *backButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"backButton_highlighted" inDirectory:@"CommonView/NavigationItem"];
        UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
        [backButton setBackgroundImage:[UIImage imageNamed:backButtonNormalPath] forState:UIControlStateNormal];
        [backButton setBackgroundImage:[UIImage imageNamed:backButtonHighlightedPath] forState:UIControlStateHighlighted];
        [backButton addTarget:self action:@selector(backFromConfirm) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
        [backBarButtonItem release];
        [backButton release];
        
        //删除确认视图中的所有子视图
		for (UIView *v in [self.confirmView subviews]) {
			[v removeFromSuperview];
		}
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        //设置确认视图中的滚动视图
        UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 376)];
        scrollView.backgroundColor = [UIColor whiteColor];
        [self.confirmView addSubview:scrollView];
        
        UIView * goFlightInfoTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        goFlightInfoTitleView.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.2 alpha:1.0]; 
        
        UILabel * separatedFirstLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, 310, 25)];
		separatedFirstLabel.backgroundColor = [UIColor clearColor]; 
        separatedFirstLabel.textColor = [UIColor whiteColor];
        separatedFirstLabel.text = @"去程信息";
		[goFlightInfoTitleView addSubview:separatedFirstLabel];
		[separatedFirstLabel release];
        
        NSMutableDictionary * flightBookingLineSingle = [userDefaults objectForKey:@"flightBookingLineSingle"];
        
        UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 5, 140, 25)];
        cityLabel.backgroundColor = [UIColor clearColor];
        cityLabel.textColor = [UIColor whiteColor];
        cityLabel.font = [UIFont systemFontOfSize:15];
        cityLabel.text = [NSString stringWithFormat:@"%@ ⇀ %@",[flightBookingLineSingle valueForKey:@"startedCityName"],[flightBookingLineSingle valueForKey:@"arrivedCityName"]];
        [goFlightInfoTitleView addSubview:cityLabel];
        [cityLabel release];
        
        UILabel *startedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 5, 80, 25)];
        startedDateLabel.backgroundColor = [UIColor clearColor];
        startedDateLabel.textColor = [UIColor whiteColor];
        startedDateLabel.font = [UIFont systemFontOfSize:15];
        startedDateLabel.text = [flightBookingLineSingle valueForKey:@"goDate"];
        [goFlightInfoTitleView addSubview:startedDateLabel];
        [startedDateLabel release];
        
        [scrollView addSubview:goFlightInfoTitleView];
        [goFlightInfoTitleView release];
        
        UILabel * flightNOShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 37, 60, 15)];
        flightNOShowLabel.backgroundColor = [UIColor clearColor];
        flightNOShowLabel.font = [UIFont boldSystemFontOfSize:15];
        flightNOShowLabel.text = @"航班号:";
        [scrollView  addSubview:flightNOShowLabel];
        [flightNOShowLabel release];
        
        UIImageView * companyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 34, 20, 20)];
        NSString *flightCompanyPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:[_flightCompanyDic objectForKey:[flightBookingLineSingle valueForKey:@"carrier"]] inDirectory:@"Flight/FlightCompany"];
        companyImageView.image = [UIImage imageNamed:flightCompanyPath];
        [scrollView  addSubview:companyImageView];
        [companyImageView release];
        
        UILabel * companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 37, 70, 15)];
        companyNameLabel.backgroundColor = [UIColor clearColor];
        companyNameLabel.font = [UIFont systemFontOfSize:15];
        companyNameLabel.text = [flightBookingLineSingle valueForKey:@"carrierName"];
        [scrollView  addSubview:companyNameLabel];
        [companyNameLabel release];
        
        UILabel * flightCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(155, 37, 70, 15)];
        flightCodeLabel.backgroundColor = [UIColor clearColor];
        flightCodeLabel.textColor = [UIColor redColor];
        flightCodeLabel.font = [UIFont systemFontOfSize:15];
        flightCodeLabel.text = [flightBookingLineSingle valueForKey:@"flightNo"];
        [scrollView addSubview:flightCodeLabel];
        [flightCodeLabel release];
        
        NSString *dottedLinePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"dottedLine" inDirectory:@"CommonView"];
        UIImageView * dottedLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
        dottedLineView.frame = CGRectMake(0, 60, 320, 2);
        [scrollView addSubview:dottedLineView];
        [dottedLineView release];
        
        UILabel * flightTypeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 68, 60, 15)];
        flightTypeShowLabel.backgroundColor = [UIColor clearColor];
        flightTypeShowLabel.font = [UIFont boldSystemFontOfSize:15];
        flightTypeShowLabel.text = @"机    型:";
        [scrollView  addSubview:flightTypeShowLabel];
        [flightTypeShowLabel release];
        
        UILabel * plantypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 68, 70, 15)];
        plantypeLabel.backgroundColor = [UIColor clearColor];
        plantypeLabel.font = [UIFont systemFontOfSize:15];
        plantypeLabel.text = [flightBookingLineSingle valueForKey:@"flightType"];
        [scrollView  addSubview:plantypeLabel];
        [plantypeLabel release];
        
        UIImageView * dottedLineView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
        dottedLineView2.frame = CGRectMake(0, 91, 320, 2);
        [scrollView addSubview:dottedLineView2];
        [dottedLineView2 release];
        
        UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 99, 60, 15)];
        fromLabel.backgroundColor = [UIColor clearColor];
        fromLabel.font = [UIFont boldSystemFontOfSize:15];
        fromLabel.text = @"起    飞:";
        [scrollView  addSubview:fromLabel];
        [fromLabel release];
        
        UILabel * fromTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 99, 57, 15)];
        fromTimeLabel.backgroundColor = [UIColor clearColor];
        fromTimeLabel.font = [UIFont systemFontOfSize:15];
        fromTimeLabel.text = [flightBookingLineSingle valueForKey:@"fromTime"];
        [scrollView  addSubview:fromTimeLabel];
        [fromTimeLabel release];
        
        UILabel * fromAirportNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 99, 100, 15)];
        fromAirportNameLabel.backgroundColor = [UIColor clearColor];
        fromAirportNameLabel.textColor = [UIColor grayColor];
        fromAirportNameLabel.font = [UIFont systemFontOfSize:15];
        fromAirportNameLabel.text = [flightBookingLineSingle valueForKey:@"fromAirportName"];
        [scrollView  addSubview:fromAirportNameLabel];
        [fromAirportNameLabel release];
        
        UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 121, 60, 15)];
        toLabel.backgroundColor = [UIColor clearColor];
        toLabel.font = [UIFont boldSystemFontOfSize:15];
        toLabel.text = @"到    达:";
        [scrollView  addSubview:toLabel];
        [toLabel release];
        
        UILabel * toTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 121, 57, 15)];
        toTimeLabel.backgroundColor = [UIColor clearColor];
        toTimeLabel.font = [UIFont systemFontOfSize:15];
        toTimeLabel.text = [flightBookingLineSingle valueForKey:@"toTime"];
        [scrollView  addSubview:toTimeLabel];
        [toTimeLabel release];
        
        UILabel * toAirportNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 121, 100, 15)];
        toAirportNameLabel.backgroundColor = [UIColor clearColor];
        toAirportNameLabel.textColor = [UIColor grayColor];
        toAirportNameLabel.font = [UIFont systemFontOfSize:15];
        toAirportNameLabel.text = [flightBookingLineSingle valueForKey:@"toAirportName"];
        [scrollView  addSubview:toAirportNameLabel];
        [toAirportNameLabel release];
        
        UIImageView * dottedLineView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
        dottedLineView3.frame = CGRectMake(0, 144, 320, 2);
        [scrollView addSubview:dottedLineView3];
        [dottedLineView3 release];
        
        UILabel *priceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 152, 70, 15)];
        priceShowLabel.backgroundColor = [UIColor clearColor];
        priceShowLabel.font = [UIFont boldSystemFontOfSize:15];
        priceShowLabel.text = @"机票 价格:";
        [scrollView  addSubview:priceShowLabel];
        [priceShowLabel release];
        
        UILabel * prePriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 152, 140, 15)];
        prePriceLabel.backgroundColor = [UIColor clearColor];
        prePriceLabel.textColor = [UIColor grayColor];
        prePriceLabel.font = [UIFont systemFontOfSize:15];
        prePriceLabel.text = [NSString stringWithFormat:@"原价:¥%@ /油菜价",[flightBookingLineSingle valueForKey:@"prePrice"]];
        [scrollView  addSubview:prePriceLabel];
        [prePriceLabel release];
        
        UILabel * ucaiPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 152, 90, 15)];
        ucaiPriceLabel.backgroundColor = [UIColor clearColor];
        ucaiPriceLabel.textColor = [UIColor redColor];
        ucaiPriceLabel.font = [UIFont boldSystemFontOfSize:15];
        ucaiPriceLabel.text = [NSString stringWithFormat:@"¥%@",[flightBookingLineSingle valueForKey:@"ucaiPrice"]];
        [scrollView  addSubview:ucaiPriceLabel];
        [ucaiPriceLabel release];
        
        UILabel *taxShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 174, 70, 15)];
        taxShowLabel.backgroundColor = [UIColor clearColor];
        taxShowLabel.font = [UIFont boldSystemFontOfSize:15];
        taxShowLabel.text = @"机建/燃油:";
        [scrollView  addSubview:taxShowLabel];
        [taxShowLabel release];
        
        UILabel * taxLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 174, 140, 15)];
        taxLabel.backgroundColor = [UIColor clearColor];
        taxLabel.font = [UIFont systemFontOfSize:15];
        taxLabel.text = [NSString stringWithFormat:@"¥%@ /¥%@",[flightBookingLineSingle valueForKey:@"airTax"],[flightBookingLineSingle valueForKey:@"tax"]];
        [scrollView  addSubview:taxLabel];
        [taxLabel release];
        
        NSInteger distance = 198;
        if ([userDefaults integerForKey:@"flightSearchLineType"] == UCAIFlightLineStyleDouble) {
            
            UIView * backFlightInfoTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, distance+0, 320, 30)];
            backFlightInfoTitleView.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.2 alpha:1.0];
            
            UILabel * separatedFirstLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, 310, 25)];
            separatedFirstLabel.backgroundColor = [UIColor clearColor]; 
            separatedFirstLabel.textColor = [UIColor whiteColor];
            separatedFirstLabel.text = @"回程信息";
            [backFlightInfoTitleView addSubview:separatedFirstLabel];
            [separatedFirstLabel release];
            
            NSMutableDictionary * flightBookingLineDouble = [userDefaults objectForKey:@"flightBookingLineDouble"];
            
            UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 5, 140, 25)];
            cityLabel.backgroundColor = [UIColor clearColor];
            cityLabel.textColor = [UIColor whiteColor];
            cityLabel.font = [UIFont systemFontOfSize:15];
            cityLabel.text = [NSString stringWithFormat:@"%@ ⇀ %@",[flightBookingLineDouble valueForKey:@"startedCityName"],[flightBookingLineDouble valueForKey:@"arrivedCityName"]];
            [backFlightInfoTitleView addSubview:cityLabel];
            [cityLabel release];
            
            UILabel *startedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 5, 80, 25)];
            startedDateLabel.backgroundColor = [UIColor clearColor];
            startedDateLabel.textColor = [UIColor whiteColor];
            startedDateLabel.font = [UIFont systemFontOfSize:15];
            startedDateLabel.text = [flightBookingLineDouble valueForKey:@"goDate"];
            [backFlightInfoTitleView addSubview:startedDateLabel];
            [startedDateLabel release];
            
            [scrollView addSubview:backFlightInfoTitleView];
            [backFlightInfoTitleView release];
            
            UILabel * flightNOShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, distance+37, 60, 15)];
            flightNOShowLabel.backgroundColor = [UIColor clearColor];
            flightNOShowLabel.font = [UIFont boldSystemFontOfSize:15];
            flightNOShowLabel.text = @"航班号:";
            [scrollView  addSubview:flightNOShowLabel];
            [flightNOShowLabel release];
            
            UIImageView * companyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, distance+34, 20, 20)];
            NSString *flightCompanyPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:[_flightCompanyDic objectForKey:[flightBookingLineDouble valueForKey:@"carrier"]] inDirectory:@"Flight/FlightCompany"];
            companyImageView.image = [UIImage imageNamed:flightCompanyPath];
            [scrollView  addSubview:companyImageView];
            [companyImageView release];
            
            UILabel * companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, distance+37, 70, 15)];
            companyNameLabel.backgroundColor = [UIColor clearColor];
            companyNameLabel.font = [UIFont systemFontOfSize:15];
            companyNameLabel.text = [flightBookingLineDouble valueForKey:@"carrierName"];
            [scrollView  addSubview:companyNameLabel];
            [companyNameLabel release];
            
            UILabel * flightCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(155, distance+37, 70, 15)];
            flightCodeLabel.backgroundColor = [UIColor clearColor];
            flightCodeLabel.textColor = [UIColor redColor];
            flightCodeLabel.font = [UIFont systemFontOfSize:15];
            flightCodeLabel.text = [flightBookingLineDouble valueForKey:@"flightNo"];
            [scrollView addSubview:flightCodeLabel];
            [flightCodeLabel release];
            
            UIImageView * dottedLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
            dottedLineView.frame = CGRectMake(0, distance+60, 320, 2);
            [scrollView addSubview:dottedLineView];
            [dottedLineView release];
            
            UILabel * flightTypeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, distance+68, 60, 15)];
            flightTypeShowLabel.backgroundColor = [UIColor clearColor];
            flightTypeShowLabel.font = [UIFont boldSystemFontOfSize:15];
            flightTypeShowLabel.text = @"机    型:";
            [scrollView  addSubview:flightTypeShowLabel];
            [flightTypeShowLabel release];
            
            UILabel * plantypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, distance+68, 70, 15)];
            plantypeLabel.backgroundColor = [UIColor clearColor];
            plantypeLabel.font = [UIFont systemFontOfSize:15];
            plantypeLabel.text = [flightBookingLineDouble valueForKey:@"flightType"];
            [scrollView  addSubview:plantypeLabel];
            [plantypeLabel release];
            
            UIImageView * dottedLineView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
            dottedLineView2.frame = CGRectMake(0, distance+91, 320, 2);
            [scrollView addSubview:dottedLineView2];
            [dottedLineView2 release];
            
            UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, distance+99, 60, 15)];
            fromLabel.backgroundColor = [UIColor clearColor];
            fromLabel.font = [UIFont boldSystemFontOfSize:15];
            fromLabel.text = @"起    飞:";
            [scrollView  addSubview:fromLabel];
            [fromLabel release];
            
            UILabel * fromTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, distance+99, 57, 15)];
            fromTimeLabel.backgroundColor = [UIColor clearColor];
            fromTimeLabel.font = [UIFont systemFontOfSize:15];
            fromTimeLabel.text = [flightBookingLineDouble valueForKey:@"fromTime"];
            [scrollView  addSubview:fromTimeLabel];
            [fromTimeLabel release];
            
            UILabel * fromAirportNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, distance+99, 100, 15)];
            fromAirportNameLabel.backgroundColor = [UIColor clearColor];
            fromAirportNameLabel.textColor = [UIColor grayColor];
            fromAirportNameLabel.font = [UIFont systemFontOfSize:15];
            fromAirportNameLabel.text = [flightBookingLineDouble valueForKey:@"fromAirportName"];
            [scrollView  addSubview:fromAirportNameLabel];
            [fromAirportNameLabel release];
            
            UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, distance+121, 60, 15)];
            toLabel.backgroundColor = [UIColor clearColor];
            toLabel.font = [UIFont boldSystemFontOfSize:15];
            toLabel.text = @"到    达:";
            [scrollView  addSubview:toLabel];
            [toLabel release];
            
            UILabel * toTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, distance+121, 57, 15)];
            toTimeLabel.backgroundColor = [UIColor clearColor];
            toTimeLabel.font = [UIFont systemFontOfSize:15];
            toTimeLabel.text = [flightBookingLineDouble valueForKey:@"toTime"];
            [scrollView  addSubview:toTimeLabel];
            [toTimeLabel release];
            
            UILabel * toAirportNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, distance+121, 100, 15)];
            toAirportNameLabel.backgroundColor = [UIColor clearColor];
            toAirportNameLabel.textColor = [UIColor grayColor];
            toAirportNameLabel.font = [UIFont systemFontOfSize:15];
            toAirportNameLabel.text = [flightBookingLineDouble valueForKey:@"toAirportName"];
            [scrollView  addSubview:toAirportNameLabel];
            [toAirportNameLabel release];
            
            UIImageView * dottedLineView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
            dottedLineView3.frame = CGRectMake(0, distance+144, 320, 2);
            [scrollView addSubview:dottedLineView3];
            [dottedLineView3 release];
            
            UILabel *priceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, distance+152, 70, 15)];
            priceShowLabel.backgroundColor = [UIColor clearColor];
            priceShowLabel.font = [UIFont boldSystemFontOfSize:15];
            priceShowLabel.text = @"机票 价格:";
            [scrollView  addSubview:priceShowLabel];
            [priceShowLabel release];
            
            UILabel * prePriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, distance+152, 140, 15)];
            prePriceLabel.backgroundColor = [UIColor clearColor];
            prePriceLabel.textColor = [UIColor grayColor];
            prePriceLabel.font = [UIFont systemFontOfSize:15];
            prePriceLabel.text = [NSString stringWithFormat:@"原价:¥%@ /油菜价",[flightBookingLineDouble valueForKey:@"prePrice"]];
            [scrollView  addSubview:prePriceLabel];
            [prePriceLabel release];
            
            UILabel * ucaiPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, distance+152, 90, 15)];
            ucaiPriceLabel.backgroundColor = [UIColor clearColor];
            ucaiPriceLabel.textColor = [UIColor redColor];
            ucaiPriceLabel.font = [UIFont boldSystemFontOfSize:15];
            ucaiPriceLabel.text = [NSString stringWithFormat:@"¥%@",[flightBookingLineDouble valueForKey:@"ucaiPrice"]];
            [scrollView  addSubview:ucaiPriceLabel];
            [ucaiPriceLabel release];
            
            UILabel *taxShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, distance+174, 70, 15)];
            taxShowLabel.backgroundColor = [UIColor clearColor];
            taxShowLabel.font = [UIFont boldSystemFontOfSize:15];
            taxShowLabel.text = @"机建/燃油:";
            [scrollView  addSubview:taxShowLabel];
            [taxShowLabel release];
            
            UILabel * taxLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, distance+174, 140, 15)];
            taxLabel.backgroundColor = [UIColor clearColor];
            taxLabel.font = [UIFont systemFontOfSize:15];
            taxLabel.text = [NSString stringWithFormat:@"¥%@ /¥%@",[flightBookingLineDouble valueForKey:@"airTax"],[flightBookingLineDouble valueForKey:@"tax"]];
            [scrollView  addSubview:taxLabel];
            [taxLabel release];
            
            distance *= 2;
        }
        
        UIView * guestInfoTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, distance + 0, 320, 30)];
        guestInfoTitleView.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.2 alpha:1.0]; 
        UILabel * guestInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, 310, 25)];
		guestInfoLabel.backgroundColor = [UIColor clearColor]; 
        guestInfoLabel.textColor = [UIColor whiteColor];
        guestInfoLabel.text = [NSString stringWithFormat: @"乘机人信息(%d位)",[self.customers count]];
		[guestInfoTitleView addSubview:guestInfoLabel];
		[guestInfoLabel release];
        [scrollView addSubview:guestInfoTitleView];
        [guestInfoTitleView release];
        
        NSInteger secureNum = 0;
        
        for (NSInteger customerNO = 0;customerNO < [self.customers count];customerNO++) {
            FlightCustomer* customer = (FlightCustomer *)[self.customers objectAtIndex:customerNO];
            
            UILabel * guestNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, distance + 30 + 2, 160, 20)];
            guestNameLabel.backgroundColor = [UIColor clearColor];
            guestNameLabel.font = [UIFont systemFontOfSize:15];
            if ([@"1" isEqualToString:customer.customerType]) {
                guestNameLabel.text = [NSString stringWithFormat:@"%@:(成人)",customer.customerName];
            } else if ([@"2" isEqualToString:customer.customerType]) {
                guestNameLabel.text = [NSString stringWithFormat:@"%@:(儿童)",customer.customerName];
            } else if ([@"3" isEqualToString:customer.customerType]) {
                guestNameLabel.text = [NSString stringWithFormat:@"%@:(婴儿)",customer.customerName];
            }
            [scrollView addSubview:guestNameLabel];
            [guestNameLabel release];
            
            UILabel * secureNumShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(253, distance + 30 + 2, 40, 20)];
            secureNumShowLabel.backgroundColor = [UIColor clearColor];
            secureNumShowLabel.font = [UIFont systemFontOfSize:15];
            secureNumShowLabel.text = @"保险:";
            [scrollView addSubview:secureNumShowLabel];
            [secureNumShowLabel release];
            
            UILabel * secureNumContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(288, distance + 30 + 2, 40, 20)];
            secureNumContentLabel.backgroundColor = [UIColor clearColor];
            secureNumContentLabel.textColor = [UIColor grayColor];
            secureNumContentLabel.font = [UIFont systemFontOfSize:15];
            secureNumContentLabel.text = [NSString stringWithFormat:@"%@份",customer.secureNum];
            [scrollView addSubview:secureNumContentLabel];
            [secureNumContentLabel release];
            
            secureNum += [customer.secureNum intValue];
            
            UILabel * certificateNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, distance + 30 + 24, 270, 20)];
            certificateNoLabel.backgroundColor = [UIColor clearColor];
            certificateNoLabel.textColor = [UIColor grayColor];
            certificateNoLabel.font = [UIFont systemFontOfSize:15];
            
            if ([@"1" isEqualToString:customer.customerType]) {
                if ([@"1" isEqualToString:customer.certificateType]) {
                    certificateNoLabel.text = [NSString stringWithFormat:@"身份证:%@",customer.certificateNo];
                } else if ([@"2" isEqualToString:customer.certificateType]) {
                    certificateNoLabel.text = [NSString stringWithFormat:@"军官证:%@",customer.certificateNo];
                } else if ([@"3" isEqualToString:customer.certificateType]) {
                    certificateNoLabel.text = [NSString stringWithFormat:@"港澳通行证:%@",customer.certificateNo];
                } else if ([@"4" isEqualToString:customer.certificateType]) {
                    certificateNoLabel.text = [NSString stringWithFormat:@"护照:%@",customer.certificateNo];
                } else if ([@"5" isEqualToString:customer.certificateType]) {
                    certificateNoLabel.text = [NSString stringWithFormat:@"台胞证:%@",customer.certificateNo];
                } else if ([@"6" isEqualToString:customer.certificateType]) {
                    certificateNoLabel.text = [NSString stringWithFormat:@"士兵证:%@",customer.certificateNo];
                } else if ([@"7" isEqualToString:customer.certificateType]) {
                    certificateNoLabel.text = [NSString stringWithFormat:@"回乡证:%@",customer.certificateNo];
                } else if ([@"8" isEqualToString:customer.certificateType]) {
                    certificateNoLabel.text = [NSString stringWithFormat:@"其他:%@",customer.certificateNo];
                } 
            } else {
                certificateNoLabel.text = [NSString stringWithFormat:@"出生日期:%@",customer.certificateNo];
            }
            
            [scrollView addSubview:certificateNoLabel];
            [certificateNoLabel release];
            
            UIImageView * dottedLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
            dottedLineView.frame = CGRectMake(0, distance + 30 + 46, 320, 2);
            [scrollView addSubview:dottedLineView];
            [dottedLineView release];
            
            distance += 48;
        }
        
        if ([userDefaults integerForKey:@"flightSearchLineType"] == UCAIFlightLineStyleDouble) {
            secureNum *= 2;
        }
        
        UIView * contractInfoTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, distance + 30 - 2, 320, 30)];
        contractInfoTitleView.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.2 alpha:1.0]; 
        UILabel * contractInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, 310, 25)];
		contractInfoLabel.backgroundColor = [UIColor clearColor]; 
        contractInfoLabel.textColor = [UIColor whiteColor];
        contractInfoLabel.text = @"联系信息";
		[contractInfoTitleView addSubview:contractInfoLabel];
		[contractInfoLabel release];
        [scrollView addSubview:contractInfoTitleView];
        [contractInfoTitleView release];
        
		UILabel * confirmNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, distance + 30 - 2 + 35, 70, 20)];
		confirmNameShowLabel.backgroundColor = [UIColor clearColor];
		confirmNameShowLabel.font = [UIFont boldSystemFontOfSize:15];
		confirmNameShowLabel.text = @"联 系 人:";
		[scrollView addSubview:confirmNameShowLabel];
		[confirmNameShowLabel release];
		
        UILabel * confirmNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, distance + 30 - 2 + 35, 290, 20)];
		confirmNameLabel.backgroundColor = [UIColor clearColor];
        confirmNameLabel.textColor = [UIColor grayColor];
		confirmNameLabel.font = [UIFont systemFontOfSize:15];
		confirmNameLabel.text = self.contactNameLabel.text;
		[scrollView addSubview:confirmNameLabel];
		[confirmNameLabel release];
        
        UIImageView * dottedLineView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
        dottedLineView1.frame = CGRectMake(0, distance + 30 - 2 + 35 + 25, 320, 2);
        [scrollView addSubview:dottedLineView1];
        [dottedLineView1 release];
        
		UILabel * confirmPhoneShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, distance + 30 - 2 + 35 + 25 +7, 70, 20)];
		confirmPhoneShowLabel.backgroundColor = [UIColor clearColor];
		confirmPhoneShowLabel.font = [UIFont boldSystemFontOfSize:15];
		confirmPhoneShowLabel.text = @"手机号码:";
		[scrollView addSubview:confirmPhoneShowLabel];
		[confirmPhoneShowLabel release];
        
        UILabel * confirmPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, distance + 30 - 2 + 35 + 25 +7, 290, 20)];
		confirmPhoneLabel.backgroundColor = [UIColor clearColor];
        confirmPhoneLabel.textColor = [UIColor grayColor];
		confirmPhoneLabel.font = [UIFont systemFontOfSize:15];
		confirmPhoneLabel.text = self.contactPhoneLabel.text;
		[scrollView addSubview:confirmPhoneLabel];
		[confirmPhoneLabel release];
        
        scrollView.contentSize = CGSizeMake(312, distance + 30 - 2 + 35 + 25 + 7 + 27);
		[self.confirmView addSubview:scrollView];
		[scrollView release];
        
        UIImageView * totalPriceView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 376, 258, 40)];
        NSString *checkBarBGPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"checkBarBG" inDirectory:@"CommonView/CheckBar"];
        totalPriceView.image = [UIImage imageNamed:checkBarBGPath];
        
        UILabel * confirmTotalPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, 70, 20)];
		confirmTotalPriceShowLabel.backgroundColor = [UIColor clearColor];
        confirmTotalPriceShowLabel.font = [UIFont systemFontOfSize:15];
		confirmTotalPriceShowLabel.text = @"订单总额:";
		[totalPriceView addSubview:confirmTotalPriceShowLabel];
		[confirmTotalPriceShowLabel release];
		
		UILabel * confirmTotalPriceContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 5, 110, 16)];
		confirmTotalPriceContentLabel.backgroundColor = [UIColor clearColor];
        confirmTotalPriceContentLabel.font = [UIFont boldSystemFontOfSize:15];
		confirmTotalPriceContentLabel.textColor = [UIColor redColor];
		confirmTotalPriceContentLabel.text = [NSString stringWithFormat:@"¥%.1f",[self calculateOrderTotalPrice]];
		[totalPriceView addSubview:confirmTotalPriceContentLabel];
		[confirmTotalPriceContentLabel release];
        
        UILabel * customerNumAndsecureNumContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 20, 140, 15)];
		customerNumAndsecureNumContentLabel.backgroundColor = [UIColor clearColor];
        customerNumAndsecureNumContentLabel.font = [UIFont systemFontOfSize:11];
		customerNumAndsecureNumContentLabel.textColor = [UIColor grayColor];
		customerNumAndsecureNumContentLabel.text = [NSString stringWithFormat:@"(含人数%d人,保险%d份/20元)",[self.customers count],secureNum];
		[totalPriceView addSubview:customerNumAndsecureNumContentLabel];
		[customerNumAndsecureNumContentLabel release];
        
        [self.confirmView addSubview:totalPriceView];
        [totalPriceView release];
        
        UIImageView * separatorLineView2 = [[UIImageView alloc] initWithFrame:CGRectMake(258, 376, 2, 40)];
        NSString *checkBarSeparatorLinePath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"checkBarSeparatorLine" inDirectory:@"CommonView/CheckBar"];
        separatorLineView2.image = [UIImage imageNamed:checkBarSeparatorLinePath];
        [self.confirmView addSubview:separatorLineView2];
        [separatorLineView2 release];
        
		//设置确认视图中的提交订单按钮
		UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 376, 60, 40)];
        confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
		[confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[confirmButton setTitleColor:[PiosaColorManager themeColor] forState:UIControlStateHighlighted];
		[confirmButton setTitle:@"提交订单" forState:UIControlStateNormal];
		[confirmButton setBackgroundImage:[UIImage imageNamed:checkBarBGPath] forState:UIControlStateNormal];
        NSString *checkBarButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"checkBarButton_highlighted" inDirectory:@"CommonView/CheckBar"];
		[confirmButton setBackgroundImage:[UIImage imageNamed:checkBarButtonHighlightedPath] forState:UIControlStateHighlighted];
		[confirmButton addTarget:self action:@selector(confirmBookButtonPress) forControlEvents:UIControlEventTouchUpInside];
		[self.confirmView addSubview:confirmButton];
		[confirmButton release];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:nil context:context];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.3];
		
		self.confirmView.alpha = 1.0f;
		self.confirmView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
		[UIView commitAnimations];
    }
}

//检查并保存所输入的登陆帐号与登陆密码是否合法
//0-合法;
//1-未输入旅客信息
//2-儿童或婴儿不可单独订票
//3-儿童加婴儿的总人数不可超过成人的人数
//4-未输入联系人姓名
//5-未输入联系手机号
//6-未输入有效的手机号码;
//
- (int) checkAndSaveIn {
	if ([self.customers count]==0) {
		return 1;
	} else {
        NSInteger adultCount = 0;
        NSInteger childCount = 0;
        
        for (FlightCustomer * flightCustomer in self.customers) {
            if ([@"1" isEqualToString:flightCustomer.customerType]) {
                adultCount ++;
            } else {
                childCount ++;
            }
        }
        
        if (adultCount == 0) {
            return 2;
        } else if (adultCount<childCount){
            return 3;
        }
    }
        
    if (self.contactNameLabel.text == nil || [@"" isEqualToString:[self.contactNameLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
		return 4;
	} else if (self.contactPhoneLabel.text == nil || [@"" isEqualToString:[self.contactPhoneLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
		return 5;
	} else if (![CommonTools verifyPhoneFormat:self.contactPhoneLabel.text]) {
		return 6;
	} else{
		return 0;
	}
}

//计算订单总价
- (CGFloat) calculateOrderTotalPrice{
    CGFloat returnValue;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * flightBookingLineSingle = [userDefaults objectForKey:@"flightBookingLineSingle"];
    
    for (FlightCustomer * flightCustomer in self.customers) {
        if ([@"1" isEqualToString:flightCustomer.customerType]) {
            returnValue += [[flightBookingLineSingle valueForKey:@"ucaiPrice"] floatValue];
            returnValue += [[flightBookingLineSingle valueForKey:@"tax"] floatValue];
            returnValue += [[flightBookingLineSingle valueForKey:@"airTax"] floatValue];
        } else if ([@"2" isEqualToString:flightCustomer.customerType]) {
            returnValue += ([[flightBookingLineSingle valueForKey:@"yPrice"] floatValue] * 0.5);
            returnValue += ([[flightBookingLineSingle valueForKey:@"tax"] floatValue] * 0.5);
        } else if ([@"3" isEqualToString:flightCustomer.customerType]) {
            returnValue += ([[flightBookingLineSingle valueForKey:@"yPrice"] floatValue] * 0.1);
        }
        
        returnValue += (20 * [flightCustomer.secureNum intValue]);
    }
    
    if ([userDefaults integerForKey:@"flightSearchLineType"] == UCAIFlightLineStyleDouble) {
        NSMutableDictionary * flightBookingLineDouble = [userDefaults objectForKey:@"flightBookingLineDouble"];
        
        for (FlightCustomer * flightCustomer in self.customers) {
            if ([@"1" isEqualToString:flightCustomer.customerType]) {
                returnValue += [[flightBookingLineDouble valueForKey:@"ucaiPrice"] floatValue];
                returnValue += [[flightBookingLineDouble valueForKey:@"tax"] floatValue];
                returnValue += [[flightBookingLineDouble valueForKey:@"airTax"] floatValue];
            } else if ([@"2" isEqualToString:flightCustomer.customerType]) {
                returnValue += ([[flightBookingLineDouble valueForKey:@"yPrice"] floatValue] * 0.5);
                returnValue += ([[flightBookingLineDouble valueForKey:@"tax"] floatValue] * 0.5);
            } else if ([@"3" isEqualToString:flightCustomer.customerType]) {
                returnValue += ([[flightBookingLineDouble valueForKey:@"yPrice"] floatValue] * 0.1);
            }
            
            returnValue += (20 * [flightCustomer.secureNum intValue]);
        }
    }
    
    return returnValue;
}

//确认订购按钮响应方法
- (void) confirmBookButtonPress{
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"提交订单中...";
    [_hud show:YES];
	
	NSMutableString *postData = [[NSMutableString alloc] initWithData:[self generateFlightBookRequestPostXMLData] encoding:NSUTF8StringEncoding];
	NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
	
    ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: FLIGHT_BOOKING_ADDRESS]] autorelease];
    [req addRequestHeader:@"API-Version" value:API_VERSION];
	req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    [req appendPostData:[self generateFlightBookRequestPostXMLData]];
	[req setDelegate:self];
	[req startAsynchronous]; // 执行异步post
	[postData release];
}

// 机票下单POST数据拼装函数
- (NSData*)generateFlightBookRequestPostXMLData{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * flightBookingLineSingle = [userDefaults objectForKey:@"flightBookingLineSingle"];
    NSMutableDictionary * flightBookingLineDouble = [userDefaults objectForKey:@"flightBookingLineDouble"];
    
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    GDataXMLElement *order = [GDataXMLElement elementWithName:@"order"]; 
    [order addChild:[GDataXMLNode elementWithName:@"fromDate" stringValue:[flightBookingLineSingle valueForKey:@"goDate"]]];
    if ([userDefaults integerForKey:@"flightSearchLineType"] == UCAIFlightLineStyleDouble) {
        [order addChild:[GDataXMLNode elementWithName:@"bakDate" stringValue:[flightBookingLineDouble valueForKey:@"goDate"]]];
        [order addChild:[GDataXMLNode elementWithName:@"tripType" stringValue:@"2"]];
    }else{
        [order addChild:[GDataXMLNode elementWithName:@"bakDate" stringValue:@""]];
        [order addChild:[GDataXMLNode elementWithName:@"tripType" stringValue:@"1"]];
    }
    [order addChild:[GDataXMLNode elementWithName:@"issue" stringValue:@"1"]];
    [order addChild:[GDataXMLNode elementWithName:@"tkDate" stringValue:@""]];
    [order addChild:[GDataXMLNode elementWithName:@"tkTime" stringValue:@""]];
    [order addChild:[GDataXMLNode elementWithName:@"deliveryType" stringValue:@"1"]];
    [order addChild:[GDataXMLNode elementWithName:@"route" stringValue:@"0"]];
    
    NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
    if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
        [order addChild:[GDataXMLNode elementWithName:@"memberId" stringValue:[memberDict objectForKey:@"memberID"]]];
    } else {
        [order addChild:[GDataXMLNode elementWithName:@"memberId" stringValue:@""]];
    }
    [order addChild:[GDataXMLNode elementWithName:@"memberkh" stringValue:@""]];
    
    //航程
    GDataXMLElement *flights = [GDataXMLElement elementWithName:@"flights"]; 
    GDataXMLElement *goflight = [GDataXMLElement elementWithName:@"flight"];
    [goflight addChild:[GDataXMLNode elementWithName:@"dpt" stringValue:[flightBookingLineSingle valueForKey:@"dpt"]]];
    [goflight addChild:[GDataXMLNode elementWithName:@"arr" stringValue:[flightBookingLineSingle valueForKey:@"arr"]]];
    [goflight addChild:[GDataXMLNode elementWithName:@"fromTime" stringValue:[flightBookingLineSingle valueForKey:@"fromTime"]]];
    [goflight addChild:[GDataXMLNode elementWithName:@"toTime" stringValue:[flightBookingLineSingle valueForKey:@"toTime"]]];
    [goflight addChild:[GDataXMLNode elementWithName:@"flightNo" stringValue:[flightBookingLineSingle valueForKey:@"flightNo"]]];
    [goflight addChild:[GDataXMLNode elementWithName:@"carrier" stringValue:[flightBookingLineSingle valueForKey:@"carrier"]]];
    [goflight addChild:[GDataXMLNode elementWithName:@"discount" stringValue:[flightBookingLineSingle valueForKey:@"discount"]]];
    [goflight addChild:[GDataXMLNode elementWithName:@"classCode" stringValue:[flightBookingLineSingle valueForKey:@"classCode"]]];
    [goflight addChild:[GDataXMLNode elementWithName:@"flightType" stringValue:[flightBookingLineSingle valueForKey:@"flightType"]]];
    [goflight addChild:[GDataXMLNode elementWithName:@"yPrice" stringValue:[flightBookingLineSingle valueForKey:@"yPrice"]]];
    [flights addChild:goflight];
    if ([userDefaults integerForKey:@"flightSearchLineType"] == UCAIFlightLineStyleDouble) {
        GDataXMLElement *backflight = [GDataXMLElement elementWithName:@"flight"];
        [backflight addChild:[GDataXMLNode elementWithName:@"dpt" stringValue:[flightBookingLineDouble valueForKey:@"dpt"]]];
        [backflight addChild:[GDataXMLNode elementWithName:@"arr" stringValue:[flightBookingLineDouble valueForKey:@"arr"]]];
        [backflight addChild:[GDataXMLNode elementWithName:@"fromTime" stringValue:[flightBookingLineDouble valueForKey:@"fromTime"]]];
        [backflight addChild:[GDataXMLNode elementWithName:@"toTime" stringValue:[flightBookingLineDouble valueForKey:@"toTime"]]];
        [backflight addChild:[GDataXMLNode elementWithName:@"flightNo" stringValue:[flightBookingLineDouble valueForKey:@"flightNo"]]];
        [backflight addChild:[GDataXMLNode elementWithName:@"carrier" stringValue:[flightBookingLineDouble valueForKey:@"carrier"]]];
        [backflight addChild:[GDataXMLNode elementWithName:@"discount" stringValue:[flightBookingLineDouble valueForKey:@"discount"]]];
        [backflight addChild:[GDataXMLNode elementWithName:@"classCode" stringValue:[flightBookingLineDouble valueForKey:@"classCode"]]];
        [backflight addChild:[GDataXMLNode elementWithName:@"flightType" stringValue:[flightBookingLineDouble valueForKey:@"flightType"]]];
        [backflight addChild:[GDataXMLNode elementWithName:@"yPrice" stringValue:[flightBookingLineDouble valueForKey:@"yPrice"]]];
        [flights addChild:backflight];
    }
    [order addChild:flights];
    
    //乘客
    GDataXMLElement *customers = [GDataXMLElement elementWithName:@"customers"]; 
    for (FlightCustomer * flightCustomer in self.customers) {
        GDataXMLElement *customer = [GDataXMLElement elementWithName:@"customer"]; 
        [customer addChild:[GDataXMLNode elementWithName:@"name" stringValue:flightCustomer.customerName]];
        [customer addChild:[GDataXMLNode elementWithName:@"type" stringValue:flightCustomer.customerType]];
        [customer addChild:[GDataXMLNode elementWithName:@"certificateType" stringValue:flightCustomer.certificateType]];
        [customer addChild:[GDataXMLNode elementWithName:@"certificateNo" stringValue:flightCustomer.certificateNo]];
        [customer addChild:[GDataXMLNode elementWithName:@"secureNum" stringValue:flightCustomer.secureNum]];
        if ([@"1" isEqualToString:flightCustomer.customerType]) {
            [customer addChild:[GDataXMLNode elementWithName:@"price" stringValue:[flightBookingLineSingle valueForKey:@"ucaiPrice"]]];
            [customer addChild:[GDataXMLNode elementWithName:@"machine" stringValue:[flightBookingLineSingle valueForKey:@"airTax"]]];
            [customer addChild:[GDataXMLNode elementWithName:@"tax" stringValue:[flightBookingLineSingle valueForKey:@"tax"]]];
        } else if ([@"2" isEqualToString:flightCustomer.customerType]) {
            [customer addChild:[GDataXMLNode elementWithName:@"price" stringValue:[NSString stringWithFormat:@"%.0f",([[flightBookingLineSingle valueForKey:@"yPrice"] floatValue] * 0.5)]]];
            [customer addChild:[GDataXMLNode elementWithName:@"machine" stringValue:[NSString stringWithFormat:@"%.0f",([[flightBookingLineSingle valueForKey:@"tax"] floatValue] * 0.5)]]];
            [customer addChild:[GDataXMLNode elementWithName:@"tax" stringValue:@"0"]];
        } else if ([@"3" isEqualToString:flightCustomer.customerType]) {
            [customer addChild:[GDataXMLNode elementWithName:@"price" stringValue:[NSString stringWithFormat:@"%.0f",([[flightBookingLineSingle valueForKey:@"yPrice"] floatValue] * 0.1)]]];
            [customer addChild:[GDataXMLNode elementWithName:@"machine" stringValue:@"0"]];
            [customer addChild:[GDataXMLNode elementWithName:@"tax" stringValue:@"0"]];
        }
        
        if ([userDefaults integerForKey:@"flightSearchLineType"] == UCAIFlightLineStyleDouble) {
            if ([@"1" isEqualToString:flightCustomer.customerType]) {
                [customer addChild:[GDataXMLNode elementWithName:@"priceBack" stringValue:[flightBookingLineDouble valueForKey:@"ucaiPrice"]]];
                [customer addChild:[GDataXMLNode elementWithName:@"machineBack" stringValue:[flightBookingLineDouble valueForKey:@"airTax"]]];
                [customer addChild:[GDataXMLNode elementWithName:@"taxBack" stringValue:[flightBookingLineDouble valueForKey:@"tax"]]];
            } else if ([@"2" isEqualToString:flightCustomer.customerType]) {
                [customer addChild:[GDataXMLNode elementWithName:@"priceBack" stringValue:[NSString stringWithFormat:@"%.0f",([[flightBookingLineDouble valueForKey:@"yPrice"] floatValue] * 0.5)]]];
                [customer addChild:[GDataXMLNode elementWithName:@"machineBack" stringValue:[NSString stringWithFormat:@"%.0f",([[flightBookingLineDouble valueForKey:@"tax"] floatValue] * 0.5)]]];
                [customer addChild:[GDataXMLNode elementWithName:@"taxBack" stringValue:@"0"]];
            } else if ([@"3" isEqualToString:flightCustomer.customerType]) {
                [customer addChild:[GDataXMLNode elementWithName:@"priceBack" stringValue:[NSString stringWithFormat:@"%.0f",([[flightBookingLineDouble valueForKey:@"yPrice"] floatValue] * 0.1)]]];
                [customer addChild:[GDataXMLNode elementWithName:@"machineBack" stringValue:@"0"]];
                [customer addChild:[GDataXMLNode elementWithName:@"taxBack" stringValue:@"0"]];
            }
        } else {
            [customer addChild:[GDataXMLNode elementWithName:@"price" stringValue:@""]];
            [customer addChild:[GDataXMLNode elementWithName:@"machine" stringValue:@""]];
            [customer addChild:[GDataXMLNode elementWithName:@"tax" stringValue:@""]];
        }
        
        [customers addChild:customer];
    }
    [order addChild:customers];
    
    //收件人
    GDataXMLElement *recman = [GDataXMLElement elementWithName:@"recman"]; 
    [recman addChild:[GDataXMLNode elementWithName:@"name" stringValue:@""]];
    [recman addChild:[GDataXMLNode elementWithName:@"post" stringValue:@""]];
    [recman addChild:[GDataXMLNode elementWithName:@"reptAddress" stringValue:@""]];
    [order addChild:recman];
    
    //联系人
    GDataXMLElement *linkman = [GDataXMLElement elementWithName:@"linkman"]; 
    [linkman addChild:[GDataXMLNode elementWithName:@"name" stringValue:self.contactNameLabel.text]];
    [linkman addChild:[GDataXMLNode elementWithName:@"mobile" stringValue:self.contactPhoneLabel.text]];
    [order addChild:linkman];
    
    [conditionElement addChild:order];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    
    return document.XMLData;
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
	[super loadView];
	
	//设置导航栏标题
	self.title = @"填写订单";
	
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
	
	
	//设置酒店预订信息填写表格
	UITableView * tempBookTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 386) style:UITableViewStyleGrouped];
	tempBookTableView.backgroundColor = [UIColor clearColor];
	tempBookTableView.dataSource = self;
	tempBookTableView.delegate = self;
    
	NSMutableArray * tempCustomers = [[NSMutableArray alloc] init];
	NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
	if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
		FlightCustomer * flightCustomer = [[FlightCustomer alloc] init];
		flightCustomer.customerName = [memberDict objectForKey:@"realName"];
        flightCustomer.customerType = @"1";
        flightCustomer.certificateType = @"1";
        flightCustomer.certificateNo = [memberDict objectForKey:@"idNumber"];
        flightCustomer.secureNum = @"1";
		[tempCustomers addObject:flightCustomer];
		[flightCustomer release];
	}
	self.customers = tempCustomers;
	[tempCustomers release];
	
	UIButton *tempBookButton = [[UIButton alloc] init];
	[tempBookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[tempBookButton setTitle:@"订    购" forState:UIControlStateNormal];
    [tempBookButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
    [tempBookButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
	[tempBookButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
	[tempBookButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
	[tempBookButton addTarget:self action:@selector(bookButtonPress:) forControlEvents:UIControlEventTouchUpInside];
	self.bookButton = tempBookButton;
	[tempBookTableView addSubview:tempBookButton];
	[tempBookButton release];
	
	//设置tableView与滚动视图的上下边距，以显示出订购按钮
	tempBookTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 80.0f, 0.0f);//设置列表的位置
	tempBookTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.bookTableView = tempBookTableView;
	[self.view addSubview:self.bookTableView];
	[tempBookTableView release];
    
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
	
	UIView * tempConfirmView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
	tempConfirmView.alpha = 0.0f;										//设置确认视图的透明度
	tempConfirmView.transform = CGAffineTransformMakeScale(0.25f, 0.25f);//设置确认视图的缩放大小
    tempConfirmView.backgroundColor = [UIColor whiteColor];
	self.confirmView = tempConfirmView;
	[self.view addSubview:self.confirmView];
	[tempConfirmView release];
    
    NSArray * flightCompanyCodeArray = [[NSArray alloc] initWithObjects:@"CA",@"CZ",@"MU",@"FM",@"HU",@"SC",@"MF",@"3U",@"ZH",@"JD",@"HO",@"KN",@"8L",@"BK",@"EU",@"8C",@"G5",@"PN",@"OQ",@"NS",@"CN",@"GS",@"JR",nil];
    NSArray * flightCompanyImageArray = [[NSArray alloc] initWithObjects:@"air_line_ca",@"air_line_cz",@"air_line_mu",@"air_line_fm",@"air_line_hu",@"air_line_sc",@"air_line_mf",@"air_line_3u",@"air_line_zh",@"air_line_pn",@"air_line_ho",@"air_line_kn",@"air_line_8l",@"air_line_bk",@"air_line_eu",@"air_line_8c",@"air_line_g5",@"air_line_jd",@"air_line_oq",@"air_line_ns",@"air_line_hu",@"air_line_gs",@"air_line_jr",nil];
    _flightCompanyDic = [NSDictionary dictionaryWithObjects:flightCompanyImageArray forKeys:flightCompanyCodeArray];
    [_flightCompanyDic retain];
    [flightCompanyImageArray release];
    [flightCompanyCodeArray release];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	
	[self.bookTableView reloadData];
	[self resetBookButton];
}

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应 : 但可能是错误响应, 如 404
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);
    
    [_hud hide:YES];
    if ((responseString != nil) && [responseString length] > 0) {
        
		FlightBookResponseModel *flightBookResponseModel = [ResponseParser loadFlightBookResponse:[request responseData]];
		
		if (flightBookResponseModel.resultCode == nil || [flightBookResponseModel.resultCode length] == 0 || [flightBookResponseModel.resultCode intValue] != 0) {
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
            hud.labelText = flightBookResponseModel.resultMessage;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
		}else {
            FlightBookSucceedViewController *flightBookSucceedViewController = [[FlightBookSucceedViewController alloc] init];
            flightBookSucceedViewController.customers = self.customers;
            flightBookSucceedViewController.flightOrderPrice = flightBookResponseModel.orderPrice;
            flightBookSucceedViewController.flightOrderID = flightBookResponseModel.orderNo;
            [self.navigationController pushViewController:flightBookSucceedViewController animated:YES];
            [flightBookSucceedViewController release];
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
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    switch ([userDefaults integerForKey:@"flightSearchLineType"]) {
        case UCAIFlightLineStyleSingle:
            return 3;
            break;
        case UCAIFlightLineStyleDouble:
            return 4;
            break;
        default:
            return 0;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger realSection = section;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults integerForKey:@"flightSearchLineType"] == UCAIFlightLineStyleSingle) {
        if (realSection != 0) {
                realSection++;
        }
    }
    
	switch (realSection) {
        case 0:
			return 3;
			break;
        case 1:  
            return 3;
            break;
		case 2:
			switch ([self.customers count]) {
				case 0:
					return 3;
					break;
				default:
					return [self.customers count]+2;
					break;
			}
			return 3;
			break;
		case 3:
			return 3;
			break;
		default:
			return 0;
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger realSection = indexPath.section;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults integerForKey:@"flightSearchLineType"] == UCAIFlightLineStyleSingle) {
        if (realSection != 0) {
            realSection++;
        }
    }
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %d %d",realSection,indexPath.row];
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        switch (realSection) {
            case 0:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
                        cell.textLabel.text = @"去程";
                        break;
                    case 1:{
                        NSMutableDictionary * flightBookingLineSingle = [userDefaults objectForKey:@"flightBookingLineSingle"];
                        
                        UIImageView * companyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 2, 20, 20)];
                        NSString *flightCompanyPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:[_flightCompanyDic objectForKey:[flightBookingLineSingle valueForKey:@"carrier"]] inDirectory:@"Flight/FlightCompany"];
                        companyImageView.image = [UIImage imageNamed:flightCompanyPath];
                        [cell.contentView  addSubview:companyImageView];
                        [companyImageView release];
                        
                        UILabel * companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 70, 15)];
                        companyNameLabel.backgroundColor = [UIColor clearColor];
                        companyNameLabel.font = [UIFont systemFontOfSize:15];
                        companyNameLabel.text = [flightBookingLineSingle valueForKey:@"carrierName"];
                        [cell.contentView  addSubview:companyNameLabel];
                        [companyNameLabel release];
                        
                        UILabel * flightCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 5, 70, 15)];
                        flightCodeLabel.backgroundColor = [UIColor clearColor];
                        flightCodeLabel.textColor = [UIColor redColor];
                        flightCodeLabel.font = [UIFont systemFontOfSize:15];
                        flightCodeLabel.text = [flightBookingLineSingle valueForKey:@"flightNo"];
                        [cell.contentView addSubview:flightCodeLabel];
                        [flightCodeLabel release];
                        
                        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 25, 300, 22)];
                        titleView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
                        
                        UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 120, 23)];
                        cityLabel.backgroundColor = [UIColor clearColor];
                        cityLabel.font = [UIFont systemFontOfSize:15];
                        cityLabel.text = [NSString stringWithFormat:@"%@ ⇀ %@",[flightBookingLineSingle valueForKey:@"startedCityName"],[flightBookingLineSingle valueForKey:@"arrivedCityName"]];
                        [titleView addSubview:cityLabel];
                        [cityLabel release];
                        
                        UILabel *startedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 80, 23)];
                        startedDateLabel.backgroundColor = [UIColor clearColor];
                        startedDateLabel.font = [UIFont systemFontOfSize:15];
                        startedDateLabel.text = [flightBookingLineSingle valueForKey:@"goDate"];
                        [titleView addSubview:startedDateLabel];
                        [startedDateLabel release];
                        
                        UILabel * plantypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(226, 0, 70, 23)];
                        plantypeLabel.backgroundColor = [UIColor clearColor];
                        plantypeLabel.font = [UIFont systemFontOfSize:15];
                        plantypeLabel.textAlignment = UITextAlignmentRight;
                        plantypeLabel.text = [NSString stringWithFormat:@"机型%@",[flightBookingLineSingle valueForKey:@"flightType"]];
                        [titleView  addSubview:plantypeLabel];
                        [plantypeLabel release];
                        
                        [cell.contentView addSubview:titleView];
                        [titleView release];
                         
                        UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 52, 32, 15)];
                        fromLabel.backgroundColor = [UIColor clearColor];
                        fromLabel.textColor = [UIColor grayColor];
                        fromLabel.font = [UIFont systemFontOfSize:15];
                        fromLabel.text = @"起飞";
                        [cell.contentView  addSubview:fromLabel];
                        [fromLabel release];
                        
                        UILabel * fromTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 52, 57, 15)];
                        fromTimeLabel.backgroundColor = [UIColor clearColor];
                        fromTimeLabel.font = [UIFont systemFontOfSize:15];
                        fromTimeLabel.text = [flightBookingLineSingle valueForKey:@"fromTime"];
                        [cell.contentView  addSubview:fromTimeLabel];
                        [fromTimeLabel release];
                        
                        UILabel * fromAirportNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 52, 100, 15)];
                        fromAirportNameLabel.backgroundColor = [UIColor clearColor];
                        fromAirportNameLabel.textColor = [PiosaColorManager fontColor];
                        fromAirportNameLabel.font = [UIFont systemFontOfSize:15];
                        fromAirportNameLabel.text = [flightBookingLineSingle valueForKey:@"fromAirportName"];
                        [cell.contentView  addSubview:fromAirportNameLabel];
                        [fromAirportNameLabel release];
                        
                        UILabel * taxLabel = [[UILabel alloc] initWithFrame:CGRectMake(217, 52, 80, 15)];
                        taxLabel.backgroundColor = [UIColor clearColor];
                        taxLabel.textColor = [PiosaColorManager fontColor];
                        taxLabel.font = [UIFont systemFontOfSize:15];
                        taxLabel.textAlignment = UITextAlignmentRight;
                        taxLabel.text = [NSString stringWithFormat:@"燃油¥%@",[flightBookingLineSingle valueForKey:@"tax"]];
                        [cell.contentView  addSubview:taxLabel];
                        [taxLabel release];
                        
                        UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 74, 32, 15)];
                        toLabel.backgroundColor = [UIColor clearColor];
                        toLabel.textColor = [UIColor grayColor];
                        toLabel.font = [UIFont systemFontOfSize:15];
                        toLabel.text = @"到达";
                        [cell.contentView  addSubview:toLabel];
                        [toLabel release];
                        
                        UILabel * toTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 74, 57, 15)];
                        toTimeLabel.backgroundColor = [UIColor clearColor];
                        toTimeLabel.font = [UIFont systemFontOfSize:15];
                        toTimeLabel.text = [flightBookingLineSingle valueForKey:@"toTime"];
                        [cell.contentView  addSubview:toTimeLabel];
                        [toTimeLabel release];
                        
                        UILabel * toAirportNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 74, 100, 15)];
                        toAirportNameLabel.backgroundColor = [UIColor clearColor];
                        toAirportNameLabel.textColor = [UIColor grayColor];
                        toAirportNameLabel.font = [UIFont systemFontOfSize:15];
                        toAirportNameLabel.text = [flightBookingLineSingle valueForKey:@"toAirportName"];
                        [cell.contentView  addSubview:toAirportNameLabel];
                        [toAirportNameLabel release];
                        
                        UILabel * airTaxLabel = [[UILabel alloc] initWithFrame:CGRectMake(217, 74, 80, 15)];
                        airTaxLabel.backgroundColor = [UIColor clearColor];
                        airTaxLabel.textColor = [PiosaColorManager fontColor];
                        airTaxLabel.font = [UIFont systemFontOfSize:15];
                        airTaxLabel.textAlignment = UITextAlignmentRight;
                        airTaxLabel.text = [NSString stringWithFormat:@"机建¥%@",[flightBookingLineSingle valueForKey:@"airTax"]];
                        [cell.contentView  addSubview:airTaxLabel];
                        [airTaxLabel release];
                    }
                        break;
                    case 2:{
                        NSMutableDictionary * flightBookingLineSingle = [userDefaults objectForKey:@"flightBookingLineSingle"];
                        
                        UILabel *ucaiPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 0, 50, 36)];
                        ucaiPriceShowLabel.backgroundColor = [UIColor clearColor];
                        ucaiPriceShowLabel.font = [UIFont boldSystemFontOfSize:16];
                        ucaiPriceShowLabel.text = @"油菜价";
                        [cell.contentView  addSubview:ucaiPriceShowLabel];
                        [ucaiPriceShowLabel release];
                        
                        UILabel *ucaiPriceContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(235, 0, 60, 36)];
                        ucaiPriceContentLabel.backgroundColor = [UIColor clearColor];
                        ucaiPriceContentLabel.textColor = [UIColor redColor];
                        ucaiPriceContentLabel.font = [UIFont boldSystemFontOfSize:16];
                        ucaiPriceContentLabel.textAlignment = UITextAlignmentRight;
                        ucaiPriceContentLabel.text = [NSString stringWithFormat:@"¥%@",[flightBookingLineSingle valueForKey:@"ucaiPrice"]];
                        [cell.contentView  addSubview:ucaiPriceContentLabel];
                        [ucaiPriceContentLabel release];

                    }
                        break;
                }
                break;
            case 1:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
                        cell.textLabel.text = @"返程";
                        break;
                    case 1:{
                        NSMutableDictionary * flightBookingLineDouble = [userDefaults objectForKey:@"flightBookingLineDouble"];
                        
                        UIImageView * companyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 2, 20, 20)];
                        NSString *flightCompanyPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:[_flightCompanyDic objectForKey:[flightBookingLineDouble valueForKey:@"carrier"]] inDirectory:@"Flight/FlightCompany"];
                        companyImageView.image = [UIImage imageNamed:flightCompanyPath];
                        [cell.contentView  addSubview:companyImageView];
                        [companyImageView release];
                        
                        UILabel * companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 70, 15)];
                        companyNameLabel.backgroundColor = [UIColor clearColor];
                        companyNameLabel.font = [UIFont systemFontOfSize:15];
                        companyNameLabel.text = [flightBookingLineDouble valueForKey:@"carrierName"];
                        [cell.contentView  addSubview:companyNameLabel];
                        [companyNameLabel release];
                        
                        UILabel * flightCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 5, 70, 15)];
                        flightCodeLabel.backgroundColor = [UIColor clearColor];
                        flightCodeLabel.textColor = [UIColor redColor];
                        flightCodeLabel.font = [UIFont systemFontOfSize:15];
                        flightCodeLabel.text = [flightBookingLineDouble valueForKey:@"flightNo"];
                        [cell.contentView addSubview:flightCodeLabel];
                        [flightCodeLabel release];
                        
                        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 25, 300, 22)];
                        titleView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
                        
                        UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 120, 23)];
                        cityLabel.backgroundColor = [UIColor clearColor];
                        cityLabel.font = [UIFont systemFontOfSize:15];
                        cityLabel.text = [NSString stringWithFormat:@"%@ ⇀ %@",[flightBookingLineDouble valueForKey:@"startedCityName"],[flightBookingLineDouble valueForKey:@"arrivedCityName"]];
                        [titleView addSubview:cityLabel];
                        [cityLabel release];
                        
                        UILabel *startedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 80, 23)];
                        startedDateLabel.backgroundColor = [UIColor clearColor];
                        startedDateLabel.font = [UIFont systemFontOfSize:15];
                        startedDateLabel.text = [flightBookingLineDouble valueForKey:@"goDate"];
                        [titleView addSubview:startedDateLabel];
                        [startedDateLabel release];
                        
                        UILabel * plantypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(226, 0, 70, 23)];
                        plantypeLabel.backgroundColor = [UIColor clearColor];
                        plantypeLabel.font = [UIFont systemFontOfSize:15];
                        plantypeLabel.textAlignment = UITextAlignmentRight;
                        plantypeLabel.text = [NSString stringWithFormat:@"机型%@",[flightBookingLineDouble valueForKey:@"flightType"]];
                        [titleView  addSubview:plantypeLabel];
                        [plantypeLabel release];
                        
                        [cell.contentView addSubview:titleView];
                        [titleView release];
                        
                        UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 52, 32, 15)];
                        fromLabel.backgroundColor = [UIColor clearColor];
                        fromLabel.textColor = [UIColor grayColor];
                        fromLabel.font = [UIFont systemFontOfSize:15];
                        fromLabel.text = @"起飞";
                        [cell.contentView  addSubview:fromLabel];
                        [fromLabel release];
                        
                        UILabel * fromTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 52, 57, 15)];
                        fromTimeLabel.backgroundColor = [UIColor clearColor];
                        fromTimeLabel.font = [UIFont systemFontOfSize:15];
                        fromTimeLabel.text = [flightBookingLineDouble valueForKey:@"fromTime"];
                        [cell.contentView  addSubview:fromTimeLabel];
                        [fromTimeLabel release];
                        
                        UILabel * fromAirportNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 52, 100, 15)];
                        fromAirportNameLabel.backgroundColor = [UIColor clearColor];
                        fromAirportNameLabel.textColor = [PiosaColorManager fontColor];
                        fromAirportNameLabel.font = [UIFont systemFontOfSize:15];
                        fromAirportNameLabel.text = [flightBookingLineDouble valueForKey:@"fromAirportName"];
                        [cell.contentView  addSubview:fromAirportNameLabel];
                        [fromAirportNameLabel release];
                        
                        UILabel * taxLabel = [[UILabel alloc] initWithFrame:CGRectMake(217, 52, 80, 15)];
                        taxLabel.backgroundColor = [UIColor clearColor];
                        taxLabel.textColor = [PiosaColorManager fontColor];
                        taxLabel.font = [UIFont systemFontOfSize:15];
                        taxLabel.textAlignment = UITextAlignmentRight;
                        taxLabel.text = [NSString stringWithFormat:@"燃油¥%@",[flightBookingLineDouble valueForKey:@"tax"]];
                        [cell.contentView  addSubview:taxLabel];
                        [taxLabel release];
                        
                        UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 74, 32, 15)];
                        toLabel.backgroundColor = [UIColor clearColor];
                        toLabel.textColor = [UIColor grayColor];
                        toLabel.font = [UIFont systemFontOfSize:15];
                        toLabel.text = @"到达";
                        [cell.contentView  addSubview:toLabel];
                        [toLabel release];
                        
                        UILabel * toTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 74, 57, 15)];
                        toTimeLabel.backgroundColor = [UIColor clearColor];
                        toTimeLabel.font = [UIFont systemFontOfSize:15];
                        toTimeLabel.text = [flightBookingLineDouble valueForKey:@"toTime"];
                        [cell.contentView  addSubview:toTimeLabel];
                        [toTimeLabel release];
                        
                        UILabel * toAirportNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 74, 100, 15)];
                        toAirportNameLabel.backgroundColor = [UIColor clearColor];
                        toAirportNameLabel.textColor = [UIColor grayColor];
                        toAirportNameLabel.font = [UIFont systemFontOfSize:15];
                        toAirportNameLabel.text = [flightBookingLineDouble valueForKey:@"toAirportName"];
                        [cell.contentView  addSubview:toAirportNameLabel];
                        [toAirportNameLabel release];
                        
                        UILabel * airTaxLabel = [[UILabel alloc] initWithFrame:CGRectMake(217, 74, 80, 15)];
                        airTaxLabel.backgroundColor = [UIColor clearColor];
                        airTaxLabel.textColor = [PiosaColorManager fontColor];
                        airTaxLabel.font = [UIFont systemFontOfSize:15];
                        airTaxLabel.textAlignment = UITextAlignmentRight;
                        airTaxLabel.text = [NSString stringWithFormat:@"机建¥%@",[flightBookingLineDouble valueForKey:@"airTax"]];
                        [cell.contentView  addSubview:airTaxLabel];
                        [airTaxLabel release];
                    }
                        break;
                    case 2:{
                        NSMutableDictionary * flightBookingLineDouble = [userDefaults objectForKey:@"flightBookingLineDouble"];
                        
                        UILabel *ucaiPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 0, 50, 36)];
                        ucaiPriceShowLabel.backgroundColor = [UIColor clearColor];
                        ucaiPriceShowLabel.font = [UIFont boldSystemFontOfSize:16];
                        ucaiPriceShowLabel.text = @"油菜价";
                        [cell.contentView  addSubview:ucaiPriceShowLabel];
                        [ucaiPriceShowLabel release];
                        
                        UILabel *ucaiPriceContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(235, 0, 60, 36)];
                        ucaiPriceContentLabel.backgroundColor = [UIColor clearColor];
                        ucaiPriceContentLabel.textColor = [UIColor redColor];
                        ucaiPriceContentLabel.font = [UIFont boldSystemFontOfSize:16];
                        ucaiPriceContentLabel.textAlignment = UITextAlignmentRight;
                        ucaiPriceContentLabel.text = [NSString stringWithFormat:@"¥%@",[flightBookingLineDouble valueForKey:@"ucaiPrice"]];
                        [cell.contentView  addSubview:ucaiPriceContentLabel];
                        [ucaiPriceContentLabel release];
                        
                    }
                        break;
                }
                break;
            case 2:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
                        cell.textLabel.text = @"乘机人信息";
                        break;
                }
                break;
            case 3:{
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
                        cell.textLabel.text = @"联系信息";
                        break;
                    case 1:{
						UILabel * contractShowLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 80, 30)];
                        contractShowLabel1.backgroundColor = [UIColor clearColor];
                        contractShowLabel1.font = [UIFont systemFontOfSize:16];
						contractShowLabel1.text = @"联系人:";
						[cell.contentView addSubview:contractShowLabel1];
						[contractShowLabel1 release];
						
						UITextField * contractInputTextField1 = [[UITextField alloc] initWithFrame:CGRectMake(100, 7, 180, 30)];
                        NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
                        NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
						if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
							contractInputTextField1.text = [memberDict objectForKey:@"realName"];
						}
						contractInputTextField1.borderStyle = UITextBorderStyleRoundedRect;
						contractInputTextField1.returnKeyType = UIReturnKeyDone;
						[contractInputTextField1 addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
						contractInputTextField1.delegate = self;
						self.contactNameLabel = contractInputTextField1;
						[cell.contentView addSubview:self.contactNameLabel];
						[contractInputTextField1 release];
                        
                        NSString *tableViewCellCenterNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_normal" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterNormalPath]] autorelease];
					}
						break;
					case 2:{
						UILabel * contractShowLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 80, 30)];
                        contractShowLabel2.backgroundColor = [UIColor clearColor];
                        contractShowLabel2.font = [UIFont systemFontOfSize:16];
						contractShowLabel2.text = @"手机号:";
						[cell.contentView addSubview:contractShowLabel2];
						[contractShowLabel2 release];
						
						UITextField * contractInputTextField2 = [[UITextField alloc] initWithFrame:CGRectMake(100, 7, 180, 30)];
                        NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
                        NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
						if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
							contractInputTextField2.text = [memberDict objectForKey:@"phone"];
						}
						contractInputTextField2.borderStyle = UITextBorderStyleRoundedRect;
						contractInputTextField2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
						contractInputTextField2.returnKeyType = UIReturnKeyDone;
						[contractInputTextField2 addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
						contractInputTextField2.delegate = self;
						self.contactPhoneLabel = contractInputTextField2;
						[cell.contentView addSubview:self.contactPhoneLabel];
						[contractInputTextField2 release];
                        
                        NSString *tableViewCellBottomNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_normal" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomNormalPath]] autorelease];
					}
						break;
                }
            }
                break;
        }
    }
    
    if (realSection == 2 && indexPath.row != 0) {
        
        for (UIView * v in [cell.contentView subviews]) {
            [v removeFromSuperview];
        }
        
        switch (indexPath.row) {
            case 1:{
                
                UIButton * newButton = [UIButton buttonWithType:UIButtonTypeCustom];
                NSString *addAndEditButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"addAndEditButton_normal.png" inDirectory:@"CommonView/MethodButton"];
                NSString *addAndEditButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"addAndEditButton_highlighted.png" inDirectory:@"CommonView/MethodButton"];
                [newButton setBackgroundImage:[UIImage imageNamed:addAndEditButtonNormalPath] forState:UIControlStateNormal];
                [newButton setBackgroundImage:[UIImage imageNamed:addAndEditButtonHighlightedPath] forState:UIControlStateHighlighted];
                [newButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [newButton setTitleColor:[PiosaColorManager themeColor] forState:UIControlStateHighlighted];
                [newButton setTitle:@"新增" forState:UIControlStateNormal];
                newButton.titleLabel.font = [UIFont systemFontOfSize:15];
                [newButton addTarget:self action:@selector(addGuest:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:newButton];
                
                UIButton * editButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [editButton setBackgroundImage:[UIImage imageNamed:addAndEditButtonNormalPath] forState:UIControlStateNormal];
                [editButton setBackgroundImage:[UIImage imageNamed:addAndEditButtonHighlightedPath] forState:UIControlStateHighlighted];
                [editButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
                [editButton setTitleColor:[PiosaColorManager themeColor] forState:UIControlStateHighlighted];
                [editButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                editButton.titleLabel.font = [UIFont systemFontOfSize:15];
                if (self.bookTableView.editing) {
                    [editButton setTitle:@"完成" forState:UIControlStateNormal];
                    [editButton setBackgroundImage:[UIImage imageNamed:@"doneButton_normal.png"] forState:UIControlStateNormal];
                    [editButton setBackgroundImage:[UIImage imageNamed:@"doneButton_highlighted.png"] forState:UIControlStateHighlighted];
                    
                } else {
                    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
                    [editButton setBackgroundImage:[UIImage imageNamed:addAndEditButtonNormalPath] forState:UIControlStateNormal];
                    [editButton setBackgroundImage:[UIImage imageNamed:addAndEditButtonHighlightedPath] forState:UIControlStateHighlighted];
                }
                
                [editButton addTarget:self action:@selector(toggleEdit:) forControlEvents:UIControlEventTouchUpInside];
                if ([self.customers count] == 0) {
                    editButton.enabled = FALSE;
                } else {
                    editButton.enabled = TRUE;
                }
                [cell.contentView addSubview:editButton];
                
                NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
                if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
                    newButton.frame = CGRectMake(12, 5, 60, 30);
                    editButton.frame = CGRectMake(92, 5, 60, 30);
                    UIButton * findButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    findButton.frame = CGRectMake(200, 5, 90, 30);
                    [findButton setBackgroundImage:[UIImage imageNamed:addAndEditButtonNormalPath] forState:UIControlStateNormal];
                    [findButton setBackgroundImage:[UIImage imageNamed:addAndEditButtonHighlightedPath] forState:UIControlStateHighlighted];
                    [findButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [findButton setTitleColor:[PiosaColorManager themeColor] forState:UIControlStateHighlighted];
                    [findButton setTitle:@"选择乘机人" forState:UIControlStateNormal];
                    findButton.titleLabel.font = [UIFont systemFontOfSize:15];
                    [findButton addTarget:self action:@selector(historyCustomerFind) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:findButton];
                }else{
                    newButton.frame = CGRectMake(20, 5, 60, 30);
                    editButton.frame = CGRectMake(220, 5, 60, 30);
                }
            }
                break;
                
            default:{
                if ([self.customers count] == 0 ) {
                    UILabel * alertShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 260, 30)];
                    alertShowLabel.textAlignment = UITextAlignmentCenter;
                    alertShowLabel.textColor = [UIColor grayColor];
                    alertShowLabel.text = @"您还没填写旅客信息";
                    alertShowLabel.backgroundColor = [UIColor clearColor];
                    [cell.contentView addSubview:alertShowLabel];
                    [alertShowLabel release];
                } else {
                    FlightCustomer* customer = (FlightCustomer *)[self.customers objectAtIndex:indexPath.row-2];
                    
                    UILabel * guestNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, 160, 20)];
                    guestNameLabel.backgroundColor = [UIColor clearColor];
                    guestNameLabel.font = [UIFont systemFontOfSize:14];
                    if ([@"1" isEqualToString:customer.customerType]) {
                        guestNameLabel.text = [NSString stringWithFormat:@"%@:(成人)",customer.customerName];
                    } else if ([@"2" isEqualToString:customer.customerType]) {
                        guestNameLabel.text = [NSString stringWithFormat:@"%@:(儿童)",customer.customerName];
                    } else if ([@"3" isEqualToString:customer.customerType]) {
                        guestNameLabel.text = [NSString stringWithFormat:@"%@:(婴儿)",customer.customerName];
                    }
                    [cell.contentView addSubview:guestNameLabel];
                    [guestNameLabel release];
                    
                    UILabel * secureNumShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(213, 2, 40, 20)];
                    secureNumShowLabel.backgroundColor = [UIColor clearColor];
                    secureNumShowLabel.font = [UIFont systemFontOfSize:14];
                    secureNumShowLabel.text = @"保险:";
                    [cell.contentView addSubview:secureNumShowLabel];
                    [secureNumShowLabel release];
                    
                    UILabel * secureNumContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(248, 2, 40, 20)];
                    secureNumContentLabel.backgroundColor = [UIColor clearColor];
                    secureNumContentLabel.textColor = [UIColor grayColor];
                    secureNumContentLabel.font = [UIFont systemFontOfSize:14];
                    secureNumContentLabel.text = [NSString stringWithFormat:@"%@份",customer.secureNum];
                    [cell.contentView addSubview:secureNumContentLabel];
                    [secureNumContentLabel release];
                    
                    UILabel * certificateNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 270, 20)];
                    certificateNoLabel.backgroundColor = [UIColor clearColor];
                    certificateNoLabel.textColor = [UIColor grayColor];
                    certificateNoLabel.font = [UIFont systemFontOfSize:13];
                    
                    if ([@"1" isEqualToString:customer.customerType]) {
                        if ([@"1" isEqualToString:customer.certificateType]) {
                            certificateNoLabel.text = [NSString stringWithFormat:@"身份证:%@",customer.certificateNo];
                        } else if ([@"2" isEqualToString:customer.certificateType]) {
                            certificateNoLabel.text = [NSString stringWithFormat:@"军官证:%@",customer.certificateNo];
                        } else if ([@"3" isEqualToString:customer.certificateType]) {
                            certificateNoLabel.text = [NSString stringWithFormat:@"港澳通行证:%@",customer.certificateNo];
                        } else if ([@"4" isEqualToString:customer.certificateType]) {
                            certificateNoLabel.text = [NSString stringWithFormat:@"护照:%@",customer.certificateNo];
                        } else if ([@"5" isEqualToString:customer.certificateType]) {
                            certificateNoLabel.text = [NSString stringWithFormat:@"台胞证:%@",customer.certificateNo];
                        } else if ([@"6" isEqualToString:customer.certificateType]) {
                            certificateNoLabel.text = [NSString stringWithFormat:@"士兵证:%@",customer.certificateNo];
                        } else if ([@"7" isEqualToString:customer.certificateType]) {
                            certificateNoLabel.text = [NSString stringWithFormat:@"回乡证:%@",customer.certificateNo];
                        } else if ([@"8" isEqualToString:customer.certificateType]) {
                            certificateNoLabel.text = [NSString stringWithFormat:@"其他:%@",customer.certificateNo];
                        } 
                    } else {
                        certificateNoLabel.text = [NSString stringWithFormat:@"出生日期:%@",customer.certificateNo];
                    }
                    
                    [cell.contentView addSubview:certificateNoLabel];
                    [certificateNoLabel release];
                }
            }
                break;
        }
    }
    
    if (indexPath.row == 0) {
        NSString *tableViewCellGroupTopTitlePath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_group_topTitle" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellGroupTopTitlePath]] autorelease];
    } else if(indexPath.row == [self.bookTableView numberOfRowsInSection:indexPath.section]-1){
        NSString *tableViewCellBottomNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_normal" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomNormalPath]] autorelease];
    } else {
        NSString *tableViewCellCenterNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_normal" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterNormalPath]] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

//设置单元格是否可以进行编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger realSection = indexPath.section;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults integerForKey:@"flightSearchLineType"] == UCAIFlightLineStyleSingle) {
        if (realSection != 0) {
            realSection++;
        }
    }
    
	if (realSection == 2) {
		switch (indexPath.row) {
			case 0:
            case 1:
				return FALSE;
				break;
			default:
				if ([self.customers count] == 0) {
					return FALSE;
				} else {
					return TRUE;
				}
				break;
		}
	} else {
		return FALSE;
	}
}

//单元格编辑提交
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)edittingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	NSUInteger row = [indexPath row];
	[self.customers removeObjectAtIndex:row-2];
	
	if ([self.customers count] == 0) {
		[self.bookTableView reloadData];
		[self.bookTableView setEditing:FALSE animated:YES];
		[self.bookButton setEnabled:YES];
	} else {
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
	
	[self resetBookButton];
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger realSection = indexPath.section;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults integerForKey:@"flightSearchLineType"] == UCAIFlightLineStyleSingle) {
        if (realSection != 0) {
            realSection++;
        }
    }
    
    if ([indexPath row]==0) {
        return 36;
    } else if(realSection == 0 || realSection == 1){
        if ([indexPath row] == 1) {
            return 94;
        } else {
            return 36;
        }
    } else {
        return 44;
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

//设置表格列表在进入编辑模式后，单元格的编辑控件风格
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return UITableViewCellEditingStyleDelete;
}

//设置单元格删除确认按钮的显示文本
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
	return @"删除";
}

//设置编辑模式下的单元格是不进行缩近
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
	return NO;
}

#pragma mark -
#pragma mark Text Field Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	int add = ([self.customers count]>1?[self.customers count]-1:0)*44;
	
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    switch ([userDefaults integerForKey:@"flightSearchLineType"]) {
        case UCAIFlightLineStyleSingle:
            [self.bookTableView setContentOffset:CGPointMake(0, add+350) animated:YES];
            break;
        case UCAIFlightLineStyleDouble:
            [self.bookTableView setContentOffset:CGPointMake(0, add+523) animated:YES];
            break;
    }
    
    self.bookTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 293.0f, 0.0f);//设置列表的位置
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

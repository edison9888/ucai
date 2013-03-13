//
//  HotelBookController.m
//  JingDuTianXia
//
//  Created by Piosa on 11-11-10.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HotelBookController.h"
#import "PiosaFileManager.h"
#import "HotelRoomArrivalLastTimeChoiceController.h"
#import "HotelRoomCountChoiceController.h"
#import "HotelGuestAddController.h"
#import "HotelGuest.h"
#import "CommonTools.h"

#import "ASIFormDataRequest.h"
#import "StaticConf.h"
#import "GDataXMLNode.h"

#import "HotelBookResponse.h"
#import "ResponseParser.h"

#import "HotelBookSucceedViewController.h"

@implementation HotelBookController

@synthesize cityCode = _cityCode;
@synthesize hotelName = _hotelName;
@synthesize hotelCode = _hotelCode;
@synthesize roomName = _roomName;
@synthesize roomCode = _roomCode;
@synthesize inDate = _inDate;
@synthesize outDate = _outDate;
@synthesize paymentType = _paymentType;
@synthesize ratePlanCode = _ratePlanCode;
@synthesize vendorCode = _vendorCode;
@synthesize totalAmount = _totalAmount;

@synthesize bookTableView = _bookTableView;
@synthesize guests = _guests;

@synthesize contactNameLabel = _contactNameLabel;
@synthesize contactPhoneLabel = _contactPhoneLabel;

@synthesize hotelLastTimeLabel = _hotelLastTimeLabel;
@synthesize hotelRoomCounterLabel = _hotelRoomCounterLabel;

@synthesize bookButton = _bookButton;
@synthesize confirmView = _confirmView;

- (void)dealloc {
	[_cityCode release];
	[_hotelName release];
	[_hotelCode release];
	[_roomName release];
	[_roomCode release];
	[_inDate release];
	[_outDate release];
	[_paymentType release];
	[_ratePlanCode release];
	[_vendorCode release];
	[_totalAmount release];
	
	[_bookTableView release];
	[_guests release];
	
	[_contactNameLabel release];
	[_contactPhoneLabel release];
	
	[_hotelLastTimeLabel release];
	[_hotelRoomCounterLabel release];
	
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
	int add = ([self.guests count]>1?[self.guests count]-1:0)*44;
	[self.bookButton setFrame:CGRectMake(10, 610+add, 300, 40)];
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

//新增旅客按钮响应方法
- (void)addGuest:(id)sender
{
	CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;//间隔时间
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];//动画的开始与结束的快慢
    transition.type = @"moveIn"; // 各种动画效果
    transition.subtype = kCATransitionFromTop;// 动画方向
    transition.delegate = self; 
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    //另外加一句,transition在申请时用的是+方法,所以不需要自己进行release ,在层上添加后不要认为retainCount已经+1,就还要release
    //实际上CATransition类中还有一个属性是removedOnCompletion,是此动画执行完后会自动remove,默认值为true
	
	HotelGuestAddController * hotelGuestAddController = [[HotelGuestAddController alloc] initWithStyle:UITableViewStyleGrouped];
	hotelGuestAddController.hotelBookController = self;
	[self.navigationController pushViewController:hotelGuestAddController animated:NO];
	[hotelGuestAddController release];
}

//响应文本输入框的完成按钮操作，用于收回键盘
- (IBAction)textFieldDone:(id)sender{
	[self.bookTableView becomeFirstResponder];
    self.bookTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 80.0f, 0.0f);//设置列表的位置
}

//订购按钮响应方法
- (void)bookButtonPress:(id)sender{
	int check = [self checkAndSaveIn];
	
	NSString * showMes = nil;
	switch (check) {
		case 1:
			showMes = @"您似乎还未填写旅客信息";
			break;
		case 2:
			showMes = @"您似乎还未输入联系人姓名";
			break;
		case 3:
			showMes = @"您似乎还未输入联系手机号";
			break;
		case 4:
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
		
        //设置确认视图中的滚动视图
        UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 376)];
        scrollView.backgroundColor = [UIColor whiteColor];
        [self.confirmView addSubview:scrollView];
        
		//计算入住天数
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd"];
		NSDate * inDate = [dateFormatter dateFromString:self.inDate];
		NSDate * outDate = [dateFormatter dateFromString:self.outDate];
		int dayCount = [outDate timeIntervalSinceDate:inDate]/(24*60*60);
		[dateFormatter release];
		//计算入住天数
		
		//订单总金额
		float orderTotalPrice = dayCount * [self.totalAmount floatValue] * [self.hotelRoomCounterLabel.text intValue];
		
        UIView * hotelInfoTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        hotelInfoTitleView.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.2 alpha:1.0]; 
        UILabel * separatedFirstLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, 310, 25)];
		separatedFirstLabel.backgroundColor = [UIColor clearColor]; 
        separatedFirstLabel.textColor = [UIColor whiteColor];
        separatedFirstLabel.text = @"酒店信息";
		[hotelInfoTitleView addSubview:separatedFirstLabel];
		[separatedFirstLabel release];
        [scrollView addSubview:hotelInfoTitleView];
        [hotelInfoTitleView release];
        
        UILabel * confirmHotelNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 70, 20)];
		confirmHotelNameShowLabel.backgroundColor = [UIColor clearColor];
		confirmHotelNameShowLabel.font = [UIFont systemFontOfSize:16];
		confirmHotelNameShowLabel.text = @"酒店名称:";
		[scrollView addSubview:confirmHotelNameShowLabel];
		[confirmHotelNameShowLabel release];
		
		UILabel * confirmHotelNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, 35, 230, 20)];
		confirmHotelNameLabel.backgroundColor = [UIColor clearColor];
        confirmHotelNameLabel.textColor = [UIColor grayColor];
		confirmHotelNameLabel.adjustsFontSizeToFitWidth = YES;
		confirmHotelNameLabel.font = [UIFont systemFontOfSize:16];
		confirmHotelNameLabel.text = self.hotelName;
		[scrollView addSubview:confirmHotelNameLabel];
		[confirmHotelNameLabel release];
		
		UILabel * confirmRoomNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 70, 20)];
		confirmRoomNameShowLabel.backgroundColor = [UIColor clearColor];
		confirmRoomNameShowLabel.font = [UIFont systemFontOfSize:16];
		confirmRoomNameShowLabel.text = @"房       型:";
		[scrollView addSubview:confirmRoomNameShowLabel];
		[confirmRoomNameShowLabel release];
        
        UILabel * confirmRoomNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, 60, 230, 20)];
		confirmRoomNameLabel.backgroundColor = [UIColor clearColor];
        confirmRoomNameLabel.textColor = [UIColor grayColor];
		confirmRoomNameLabel.font = [UIFont systemFontOfSize:16];
		confirmRoomNameLabel.text = self.roomName;
		[scrollView addSubview:confirmRoomNameLabel];
		[confirmRoomNameLabel release];
        
        UILabel * roomCountShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 85, 70, 20)];
		roomCountShowLabel.backgroundColor = [UIColor clearColor];
		roomCountShowLabel.font = [UIFont systemFontOfSize:16];
		roomCountShowLabel.text = @"房间数量:";
		[scrollView addSubview:roomCountShowLabel];
		[roomCountShowLabel release];
        
        UILabel * roomCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, 85, 230, 20)];
		roomCountLabel.backgroundColor = [UIColor clearColor];
        roomCountLabel.textColor = [UIColor grayColor];
		roomCountLabel.font = [UIFont systemFontOfSize:16];
		roomCountLabel.text = [NSString stringWithFormat:@"%@间",self.hotelRoomCounterLabel.text];
		[scrollView addSubview:roomCountLabel];
		[roomCountLabel release];
        
        NSString *dottedLinePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"dottedLine" inDirectory:@"CommonView"];
        UIImageView * dottedLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
        dottedLineView.frame = CGRectMake(0, 110, 320, 2);
        [scrollView addSubview:dottedLineView];
        [dottedLineView release];
        
        UILabel * stayDateShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 117, 70, 20)];
		stayDateShowLabel.backgroundColor = [UIColor clearColor];
		stayDateShowLabel.font = [UIFont systemFontOfSize:16];
		stayDateShowLabel.text = @"住店时间:";
		[scrollView addSubview:stayDateShowLabel];
		[stayDateShowLabel release];
        
        UILabel * stayDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, 117, 230, 20)];
		stayDateLabel.backgroundColor = [UIColor clearColor];
        stayDateLabel.textColor = [UIColor grayColor];
		stayDateLabel.font = [UIFont systemFontOfSize:16];
		stayDateLabel.text = [NSString stringWithFormat:@"%@至%@",self.inDate,self.outDate];
		[scrollView addSubview:stayDateLabel];
		[stayDateLabel release];
        
        UILabel * confirmPaymentTypeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 142, 70, 20)];
		confirmPaymentTypeShowLabel.backgroundColor = [UIColor clearColor];
		confirmPaymentTypeShowLabel.font = [UIFont systemFontOfSize:16];
		confirmPaymentTypeShowLabel.text = @"支付方式";
		[scrollView addSubview:confirmPaymentTypeShowLabel];
		[confirmPaymentTypeShowLabel release];
        
        NSString * payment;
		if ([@"T" isEqualToString:self.paymentType]) {
			payment = @"前台支付";
		} else  if ([@"S" isEqualToString:self.paymentType]) {
			payment = @"代收现付";
		} else  if ([@"Y" isEqualToString:self.paymentType]) {
			payment = @"预付";
		}
        
        UILabel * confirmPaymentTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, 142, 230, 20)];
		confirmPaymentTypeLabel.backgroundColor = [UIColor clearColor];
        confirmPaymentTypeLabel.textColor = [UIColor grayColor];
		confirmPaymentTypeLabel.font = [UIFont systemFontOfSize:16];
		confirmPaymentTypeLabel.text = payment;
		[scrollView addSubview:confirmPaymentTypeLabel];
		[confirmPaymentTypeLabel release];

        
        UIView * guestInfoTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 167, 320, 30)];
        guestInfoTitleView.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.2 alpha:1.0]; 
        UILabel * guestInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, 310, 25)];
		guestInfoLabel.backgroundColor = [UIColor clearColor]; 
        guestInfoLabel.textColor = [UIColor whiteColor];
        guestInfoLabel.text = [NSString stringWithFormat:@"旅客信息(%d位)",[self.guests count]];
		[guestInfoTitleView addSubview:guestInfoLabel];
		[guestInfoLabel release];
        [scrollView addSubview:guestInfoTitleView];
        [guestInfoTitleView release];
		
		int i = 0;
		for (HotelGuest * guest in self.guests) {
			UILabel * guestNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 202+i*55, 70, 20)];
			guestNameShowLabel.backgroundColor = [UIColor clearColor];
			guestNameShowLabel.font = [UIFont systemFontOfSize:16];
			guestNameShowLabel.text = @"旅       客:";
			[scrollView addSubview:guestNameShowLabel];
			[guestNameShowLabel release];
            
            UILabel * guestNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, 202+i*55, 230, 20)];
			guestNameLabel.backgroundColor = [UIColor clearColor];
            guestNameLabel.textColor = [UIColor grayColor];
			guestNameLabel.font = [UIFont systemFontOfSize:16];
			guestNameLabel.text = guest.guestName;
			[scrollView addSubview:guestNameLabel];
			[guestNameLabel release];
			
			UILabel * guestPhoneShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 227+i*55, 70, 20)];
			guestPhoneShowLabel.backgroundColor = [UIColor clearColor];
			guestPhoneShowLabel.font = [UIFont systemFontOfSize:16];
			guestPhoneShowLabel.text = @"手       机:";
			[scrollView addSubview:guestPhoneShowLabel];
			[guestPhoneShowLabel release];
            
            UILabel * guestPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, 227+i*55, 230, 20)];
			guestPhoneLabel.backgroundColor = [UIColor clearColor];
            guestPhoneLabel.textColor = [UIColor grayColor];
			guestPhoneLabel.font = [UIFont systemFontOfSize:16];
			guestPhoneLabel.text = guest.guestPhone;
			[scrollView addSubview:guestPhoneLabel];
			[guestPhoneLabel release];
            
            UIImageView * dottedLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
            dottedLineView.frame = CGRectMake(0, 252+i*55, 320, 2);
            [scrollView addSubview:dottedLineView];
            [dottedLineView release];
			
			i++;
		}
        
        
        UIView * contractInfoTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 252+(i-1)*55, 320, 30)];
        contractInfoTitleView.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.2 alpha:1.0]; 
        UILabel * contractInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, 310, 25)];
		contractInfoLabel.backgroundColor = [UIColor clearColor]; 
        contractInfoLabel.textColor = [UIColor whiteColor];
        contractInfoLabel.text = @"联系信息";
		[contractInfoTitleView addSubview:contractInfoLabel];
		[contractInfoLabel release];
        [scrollView addSubview:contractInfoTitleView];
        [contractInfoTitleView release];

		UILabel * confirmNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 287+(i-1)*55, 70, 20)];
		confirmNameShowLabel.backgroundColor = [UIColor clearColor];
		confirmNameShowLabel.font = [UIFont systemFontOfSize:16];
		confirmNameShowLabel.text = @"联 系 人:";
		[scrollView addSubview:confirmNameShowLabel];
		[confirmNameShowLabel release];
		
        UILabel * confirmNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, 287+(i-1)*55, 290, 20)];
		confirmNameLabel.backgroundColor = [UIColor clearColor];
        confirmNameLabel.textColor = [UIColor grayColor];
		confirmNameLabel.font = [UIFont systemFontOfSize:16];
		confirmNameLabel.text = self.contactNameLabel.text;
		[scrollView addSubview:confirmNameLabel];
		[confirmNameLabel release];
        
        UIImageView * dottedLineView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
        dottedLineView1.frame = CGRectMake(0, 312+(i-1)*55, 320, 2);
        [scrollView addSubview:dottedLineView1];
        [dottedLineView1 release];
        
		UILabel * confirmPhoneShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 319+(i-1)*55, 70, 20)];
		confirmPhoneShowLabel.backgroundColor = [UIColor clearColor];
		confirmPhoneShowLabel.font = [UIFont systemFontOfSize:16];
		confirmPhoneShowLabel.text = @"手机号码:";
		[scrollView addSubview:confirmPhoneShowLabel];
		[confirmPhoneShowLabel release];
        
        UILabel * confirmPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, 319+(i-1)*55, 290, 20)];
		confirmPhoneLabel.backgroundColor = [UIColor clearColor];
        confirmPhoneLabel.textColor = [UIColor grayColor];
		confirmPhoneLabel.font = [UIFont systemFontOfSize:16];
		confirmPhoneLabel.text = self.contactPhoneLabel.text;
		[scrollView addSubview:confirmPhoneLabel];
		[confirmPhoneLabel release];
        
        UIImageView * dottedLineView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
        dottedLineView2.frame = CGRectMake(0, 344+(i-1)*55, 320, 2);
        [scrollView addSubview:dottedLineView2];
        [dottedLineView2 release];
        
        UILabel * confirmLastTimeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 351+(i-1)*55, 70, 20)];
        confirmLastTimeShowLabel.backgroundColor = [UIColor clearColor];
        confirmLastTimeShowLabel.font = [UIFont systemFontOfSize:16];
        confirmLastTimeShowLabel.text = @"最晚到店:";
        [scrollView addSubview:confirmLastTimeShowLabel];
        [confirmLastTimeShowLabel release];
        
        UILabel * confirmLastTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, 351+(i-1)*55, 290, 20)];
        confirmLastTimeLabel.backgroundColor = [UIColor clearColor];
        confirmLastTimeLabel.textColor = [UIColor grayColor];
        confirmLastTimeLabel.font = [UIFont systemFontOfSize:16];
        confirmLastTimeLabel.text = self.hotelLastTimeLabel.text;
        [scrollView addSubview:confirmLastTimeLabel];
        [confirmLastTimeLabel release];

		scrollView.contentSize = CGSizeMake(312, 378+(i-1)*55);
        
		scrollView.tag = kConfirmScrollViewTag;
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
		
		UILabel * confirmTotalPriceContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 110, 20)];
		confirmTotalPriceContentLabel.backgroundColor = [UIColor clearColor];
        confirmTotalPriceContentLabel.font = [UIFont systemFontOfSize:15];
		confirmTotalPriceContentLabel.textColor = [UIColor redColor];
		confirmTotalPriceContentLabel.text = [NSString stringWithFormat:@"¥%.1f",orderTotalPrice];
		[totalPriceView addSubview:confirmTotalPriceContentLabel];
		[confirmTotalPriceContentLabel release];
        
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
		confirmButton.tag = kConfirmCommitButtonTag;
		[self.confirmView addSubview:confirmButton];
		[confirmButton release];
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:nil context:context];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.3];
		
		self.confirmView.alpha = 1.0f;
		self.confirmView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
		[UIView commitAnimations];
		
		self.title = @"核对订单";
	}
}

//检查并保存所输入的登陆帐号与登陆密码是否合法
//0-合法;
//1-未输入旅客信息
//2-未输入联系人姓名
//3-未输入联系手机号
//4-未输入有效的手机号码;
//
- (int) checkAndSaveIn {
	if ([self.guests count]==0) {
		return 1;
	} else if (self.contactNameLabel.text == nil || [@"" isEqualToString:[self.contactNameLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
		return 2;
	} else if (self.contactPhoneLabel.text == nil || [@"" isEqualToString:[self.contactPhoneLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
		return 3;
	} else if (![CommonTools verifyPhoneFormat:self.contactPhoneLabel.text]) {
		return 4;
	} else{
		return 0;
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

//确认订购按钮响应方法
- (void) confirmBookButtonPress{
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"提交订单中...";
    [_hud show:YES];
	
	ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: HOTEL_BOOK_ADDRESS]] autorelease];
	req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
	
	NSMutableString *postData = [[NSMutableString alloc] initWithData:[self generateHotelBookRequestPostXMLData] encoding:NSUTF8StringEncoding];
	[postData deleteCharactersInRange:NSMakeRange(0,39)];//删除xml中的“<?xml version="1.0" encoding="UTF-8"?>”	
	NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    [req setPostValue:postData forKey:@"requestXml"];
	
	[req setDelegate:self];
	[req startAsynchronous]; // 执行异步post
	[postData release];
}


// 酒店下单POST数据拼装函数
- (NSData*)generateHotelBookRequestPostXMLData {
	NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
	
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
	[requestElement addChild:[GDataXMLNode elementWithName:@"source" stringValue:@"M"]];
	if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
		[requestElement addChild:[GDataXMLNode elementWithName:@"userID" stringValue:[memberDict objectForKey:@"memberID"]]];
	} else {
		[requestElement addChild:[GDataXMLNode elementWithName:@"userID" stringValue:@""]];
	}
	[requestElement addChild:[GDataXMLNode elementWithName:@"city" stringValue:self.cityCode]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"hotelCode" stringValue:self.hotelCode]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"hotelName" stringValue:self.hotelName]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"roomCode" stringValue:self.roomCode]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"roomName" stringValue:self.roomName]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"inDate" stringValue:self.inDate]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"outDate" stringValue:self.outDate]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"earlyTime" stringValue:@"1200"]];
	NSMutableString * tempLastTimeString = [[NSMutableString alloc] initWithString:self.hotelLastTimeLabel.text] ;
	[tempLastTimeString deleteCharactersInRange:NSMakeRange(2, 1)];
	[requestElement addChild:[GDataXMLNode elementWithName:@"lateTime" stringValue:tempLastTimeString]];
	[tempLastTimeString release];
	[requestElement addChild:[GDataXMLNode elementWithName:@"roomNum" stringValue:self.hotelRoomCounterLabel.text]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"paymentType" stringValue:self.paymentType]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"ratePlanCode" stringValue:self.ratePlanCode]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"vendorCode" stringValue:self.vendorCode]];
	
	//计算入住天数
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSDate * inDate = [dateFormatter dateFromString:self.inDate];
	NSDate * outDate = [dateFormatter dateFromString:self.outDate];
	int dayCount = [outDate timeIntervalSinceDate:inDate]/(24*60*60);
	[dateFormatter release];
	//计算入住天数
	float orderTotalPrice = dayCount * [self.totalAmount floatValue] * [self.hotelRoomCounterLabel.text intValue];//订单总金额
	[requestElement addChild:[GDataXMLNode elementWithName:@"totalAmount" stringValue:[NSString stringWithFormat:@"%.1f",orderTotalPrice]]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"specialRequest" stringValue:@""]];
	
	NSMutableString * tempGuestsString = [[NSMutableString alloc] init];
	for (HotelGuest * guest in self.guests) {
		[tempGuestsString appendString:[guest toCommitString]];
		[tempGuestsString appendString:@"|"];
	}
	[requestElement addChild:[GDataXMLNode elementWithName:@"guests" stringValue:tempGuestsString]];//无
	[tempGuestsString release];
	[requestElement addChild:[GDataXMLNode elementWithName:@"guestCount" stringValue:[NSString stringWithFormat:@"%d",[self.guests count]]]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"linkName" stringValue:self.contactNameLabel.text]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"linkTel" stringValue:@""]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"linkMobile" stringValue:self.contactPhoneLabel.text]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"linkEmail" stringValue:@""]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"sj" stringValue:[UIDevice currentDevice].uniqueIdentifier]];//测试数据
	[requestElement addChild:[GDataXMLNode elementWithName:@"payment" stringValue:@"0"]];
	GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
	[document setVersion:@"1.0"]; // 设置xml版本为 1.0
	[document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
	
	NSData *xmlData = document.XMLData;
	return xmlData;
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
        
		HotelBookResponse *hotelBookResponse = [ResponseParser loadHotelBookResponse:[request responseData]];
		
		if (hotelBookResponse.result_code == nil || [hotelBookResponse.result_code length] == 0 || [hotelBookResponse.result_code intValue] != 1) {
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
            hud.labelText = hotelBookResponse.result_message;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
		}else {
            HotelBookSucceedViewController * hotelBookSucceedViewController = [[HotelBookSucceedViewController alloc] init];
            hotelBookSucceedViewController.hotelOrderID = hotelBookResponse.orderNo;
            hotelBookSucceedViewController.hotelOrderPrice = hotelBookResponse.amount;
            [self.navigationController pushViewController:hotelBookSucceedViewController animated:YES];
            [hotelBookSucceedViewController release];
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
    
	NSMutableArray * tempGuests = [[NSMutableArray alloc] init];
	NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
	if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
		HotelGuest * hotelGuest = [[HotelGuest alloc] init];
		hotelGuest.guestName = [memberDict objectForKey:@"realName"];
		hotelGuest.guestPhone = [memberDict objectForKey:@"phone"];
		[tempGuests addObject:hotelGuest];
		[hotelGuest release];
	}
	self.guests = tempGuests;
	[tempGuests release];
	
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
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	
	[self.bookTableView reloadData];
	[self resetBookButton];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
        case 0:
			return 4;
			break;
		case 1:
			switch ([self.guests count]) {
				case 0:
					return 3;
					break;
				default:
					return [self.guests count]+2;
					break;
			}
			return 3;
			break;
		case 2:
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
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %d %d",indexPath.section,indexPath.row];
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	
		switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 0:{
                        NSString *tableViewCellGroupTopTitlePath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_group_topTitle" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellGroupTopTitlePath]] autorelease];
                        
                        UILabel * inLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 12, 120, 14)];
                        inLabel.font = [UIFont systemFontOfSize:15];
                        inLabel.backgroundColor = [UIColor clearColor];
                        inLabel.textColor = [UIColor whiteColor];
                        inLabel.text = [NSString stringWithFormat:@"入:%@",self.inDate];
                        [cell.contentView addSubview:inLabel];
                        [inLabel release];
                        
                        UILabel * outLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 12, 120, 14)];
                        outLabel.font = [UIFont systemFontOfSize:15];
                        outLabel.backgroundColor = [UIColor clearColor];
                        outLabel.textColor = [UIColor whiteColor];
                        outLabel.text = [NSString stringWithFormat:@"离:%@",self.outDate];
                        [cell.contentView addSubview:outLabel];
                        [outLabel release];
                        
                        //计算入住天数
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        NSDate * inDate = [dateFormatter dateFromString:self.inDate];
                        NSDate * outDate = [dateFormatter dateFromString:self.outDate];
                        int dayCount = [outDate timeIntervalSinceDate:inDate]/(24*60*60);
                        [dateFormatter release];
                        //计算入住天数
                        
                        UILabel * dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 12, 50, 14)];
                        dayLabel.font = [UIFont systemFontOfSize:15];
                        dayLabel.backgroundColor = [UIColor clearColor];
                        dayLabel.textColor = [UIColor whiteColor];
                        dayLabel.text = [NSString stringWithFormat:@"共%d天",dayCount];
                        dayLabel.textAlignment = UITextAlignmentRight;
                        [cell.contentView addSubview:dayLabel];
                        [dayLabel release];
                    }
                        break;
                    case 1:{
                        NSString *tableViewCellCenterNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_normal" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterNormalPath]] autorelease];
                        
                        UILabel * hotelNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 7, 80, 40)];
                        hotelNameLabel.backgroundColor = [UIColor clearColor];
                        hotelNameLabel.font = [UIFont systemFontOfSize:16];
                        hotelNameLabel.text = @"酒店名称:";
                        [cell.contentView addSubview:hotelNameLabel];
                        [hotelNameLabel release];
                        
                        UILabel * hotelNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 7, 220, 40)];
                        hotelNameShowLabel.lineBreakMode = UILineBreakModeWordWrap;
                        hotelNameShowLabel.numberOfLines = 0;
                        hotelNameShowLabel.backgroundColor = [UIColor clearColor];
                        hotelNameShowLabel.textColor = [UIColor grayColor];
                        hotelNameShowLabel.font = [UIFont systemFontOfSize:16];
                        hotelNameShowLabel.text = self.hotelName;
                        [cell.contentView addSubview:hotelNameShowLabel];
                        [hotelNameShowLabel release];
                    }
                        break;
                    case 2:{
                        NSString *tableViewCellCenterNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_normal" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterNormalPath]] autorelease];
                        
                        UILabel * roomTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 12, 80, 20)];
                        roomTypeLabel.backgroundColor = [UIColor clearColor];
                        roomTypeLabel.font = [UIFont systemFontOfSize:16];
                        roomTypeLabel.text = @"房\t\t\t\t\t\t\t型:";
                        [cell.contentView addSubview:roomTypeLabel];
                        [roomTypeLabel release];
                        
                        UILabel * roomTypeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 12, 220, 20)];
                        roomTypeShowLabel.backgroundColor = [UIColor clearColor];
                        roomTypeShowLabel.textColor = [UIColor grayColor];
                        roomTypeShowLabel.font = [UIFont systemFontOfSize:16];
                        roomTypeShowLabel.text = self.roomName;
                        [cell.contentView addSubview:roomTypeShowLabel];
                        [roomTypeShowLabel release];
                    }
                        break;
                    case 3:{
                        NSString *tableViewCellBottomNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_normal" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomNormalPath]] autorelease];
                        
                        UILabel * totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 12, 80, 20)];
                        totalPriceLabel.backgroundColor = [UIColor clearColor];
                        totalPriceLabel.font = [UIFont systemFontOfSize:16];
                        totalPriceLabel.text = @"总价(1间):";
                        [cell.contentView addSubview:totalPriceLabel];
                        [totalPriceLabel release];
                        
                        //计算入住天数
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        NSDate * inDate = [dateFormatter dateFromString:self.inDate];
                        NSDate * outDate = [dateFormatter dateFromString:self.outDate];
                        int dayCount = [outDate timeIntervalSinceDate:inDate]/(24*60*60);
                        [dateFormatter release];
                        //计算入住天数
                        
                        //计算单间多天入住价格
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init]; 
                        float totalPricePer = [[numberFormatter numberFromString:self.totalAmount] floatValue] * dayCount;
                        [numberFormatter release];
                        //计算单间多天入住价格
                        
                        UILabel * totalPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 12, 100, 20)];
                        totalPriceShowLabel.backgroundColor = [UIColor clearColor];
                        NSMutableString * tempTotalPricePer = [[NSMutableString alloc] initWithFormat:@"¥%.1f",totalPricePer];
                        totalPriceShowLabel.textColor = [UIColor redColor];
                        totalPriceShowLabel.font = [UIFont systemFontOfSize:16];
                        totalPriceShowLabel.text = tempTotalPricePer;
                        [tempTotalPricePer release];
                        [cell.contentView addSubview:totalPriceShowLabel];
                        [totalPriceShowLabel release];
                        
                        UILabel * payMentLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 12, 60, 20)];
                        payMentLabel.backgroundColor = [UIColor clearColor];
                        payMentLabel.font = [UIFont systemFontOfSize:14];
                        payMentLabel.text = @"支付方式:";
                        [cell.contentView addSubview:payMentLabel];
                        [payMentLabel release];
                        
                        NSString * payment;
                        if ([@"T" isEqualToString:self.paymentType]) {
                            payment = @"前台支付";
                        } else  if ([@"S" isEqualToString:self.paymentType]) {
                            payment = @"代收现付";
                        } else  if ([@"Y" isEqualToString:self.paymentType]) {
                            payment = @"预付";
                        }
                        
                        UILabel * payMentShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 12, 60, 20)];
                        payMentShowLabel.font = [UIFont systemFontOfSize:14];
                        payMentShowLabel.backgroundColor = [UIColor clearColor];
                        payMentShowLabel.textColor = [UIColor grayColor];
                        payMentShowLabel.text = payment;
                        [cell.contentView addSubview:payMentShowLabel];
                        [payMentShowLabel release];
                    
                    }
                        break;
                }
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				break;
                
			case 1:
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
				break;
			case 2:{
				
				switch (indexPath.row) {
                    case 0:{
                        NSString *tableViewCellGroupTopTitlePath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_group_topTitle" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellGroupTopTitlePath]] autorelease];
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont systemFontOfSize:15];
                        cell.textLabel.text = @"联系信息";
                    }
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
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
				break;
			case 3:{
				switch (indexPath.row) {
                    case 0:{
                        NSString *tableViewCellGroupTopTitlePath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_group_topTitle" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellGroupTopTitlePath]] autorelease];
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont systemFontOfSize:15];
                        cell.textLabel.text = @"房间要求";
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                        break;
					case 1:{
						UILabel * roomShowLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 80, 30)];
                        roomShowLabel1.font = [UIFont systemFontOfSize:16];
						roomShowLabel1.text = @"最晚到店:";
                        roomShowLabel1.backgroundColor = [UIColor clearColor];
						[cell.contentView addSubview:roomShowLabel1];
						[roomShowLabel1 release];
						UILabel * roomContentLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 6, 140, 30)];
						roomContentLabel1.textAlignment = UITextAlignmentCenter;
                        roomContentLabel1.backgroundColor = [UIColor clearColor];
                        roomContentLabel1.font = [UIFont systemFontOfSize:16];
						roomContentLabel1.text = @"23:00";
						self.hotelLastTimeLabel = roomContentLabel1;
						[cell.contentView addSubview:self.hotelLastTimeLabel];
						[roomContentLabel1 release];
                        
                        NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                        UIImageView * accessoryViewTemp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                        accessoryViewTemp.frame = CGRectMake(0, 0, 10, 16);
                        cell.accessoryView = accessoryViewTemp;
                        [accessoryViewTemp release];
                        
                        NSString *tableViewCellCenterNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_normal" inDirectory:@"CommonView/TableViewCell"];
                        NSString *tableViewCellCenterHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_highlighted" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterNormalPath]] autorelease];
                        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterHighlightedPath]] autorelease];
					}
						break;
					case 2:{
						UILabel * roomShowLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 80, 30)];
                        roomShowLabel2.font = [UIFont systemFontOfSize:16];
						roomShowLabel2.text = @"房间数量:";
                        roomShowLabel2.backgroundColor = [UIColor clearColor];
						[cell.contentView addSubview:roomShowLabel2];
						[roomShowLabel2 release];
						
						UILabel * roomContentLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(100, 6, 140, 30)];
						roomContentLabel2.textAlignment = UITextAlignmentCenter;
                        roomContentLabel2.backgroundColor = [UIColor clearColor];
                        roomContentLabel2.font = [UIFont systemFontOfSize:16];
						roomContentLabel2.text = @"1";
						self.hotelRoomCounterLabel = roomContentLabel2;
						[cell.contentView addSubview:self.hotelRoomCounterLabel];
						[roomContentLabel2 release];
                        
                        NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                        UIImageView * accessoryViewTemp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                        accessoryViewTemp.frame = CGRectMake(0, 0, 10, 16);
                        cell.accessoryView = accessoryViewTemp;
                        [accessoryViewTemp release];
                        
                        NSString *tableViewCellBottomNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_normal" inDirectory:@"CommonView/TableViewCell"];
                        NSString *tableViewCellBottomHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_highlighted" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomNormalPath]] autorelease];
                        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomHighlightedPath]] autorelease];
					}
						break;
				}
                
			}
				break;
		}
	}
	
	if (indexPath.section == 1) {
        
        for (UIView * v in [cell.contentView subviews]) {
            [v removeFromSuperview];
        }
        
        switch (indexPath.row) {
            case 0:{
                NSString *tableViewCellGroupTopTitlePath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_group_topTitle" inDirectory:@"CommonView/TableViewCell"];
                cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellGroupTopTitlePath]] autorelease];
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.backgroundColor = [UIColor clearColor];
                cell.textLabel.font = [UIFont systemFontOfSize:15];
                cell.textLabel.text = @"旅客信息";
            }
                break;
            case 1:{
                UIButton * newButton = [UIButton buttonWithType:UIButtonTypeCustom];
                newButton.frame = CGRectMake(20, 5, 80, 30);
                NSString *addAndEditButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"addAndEditButton_normal.png" inDirectory:@"CommonView/MethodButton"];
                NSString *addAndEditButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"addAndEditButton_highlighted.png" inDirectory:@"CommonView/MethodButton"];
                [newButton setBackgroundImage:[UIImage imageNamed:addAndEditButtonNormalPath] forState:UIControlStateNormal];
                [newButton setBackgroundImage:[UIImage imageNamed:addAndEditButtonHighlightedPath] forState:UIControlStateHighlighted];
                [newButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [newButton setTitleColor:[PiosaColorManager themeColor] forState:UIControlStateHighlighted];
                [newButton setTitle:@"新增" forState:UIControlStateNormal];
                [newButton addTarget:self action:@selector(addGuest:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:newButton];
                
                UIButton * editButton = [UIButton buttonWithType:UIButtonTypeCustom];
                editButton.frame = CGRectMake(200, 5, 80, 30);
                [editButton setBackgroundImage:[UIImage imageNamed:addAndEditButtonNormalPath] forState:UIControlStateNormal];
                [editButton setBackgroundImage:[UIImage imageNamed:addAndEditButtonHighlightedPath] forState:UIControlStateHighlighted];
                [editButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
                [editButton setTitleColor:[PiosaColorManager themeColor] forState:UIControlStateHighlighted];
                [editButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
                if ([self.guests count] == 0) {
                    editButton.enabled = FALSE;
                } else {
                    editButton.enabled = TRUE;
                }
                [cell.contentView addSubview:editButton];
            }
                break;
                
            default:{
                if ([self.guests count] == 0 ) {
                    UILabel * alertShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 260, 30)];
                    alertShowLabel.textAlignment = UITextAlignmentCenter;
                    alertShowLabel.textColor = [UIColor grayColor];
                    alertShowLabel.text = @"您还没填写旅客信息";
                    alertShowLabel.backgroundColor = [UIColor clearColor];
                    [cell.contentView addSubview:alertShowLabel];
                    [alertShowLabel release];
                } else {
                    HotelGuest* guest = (HotelGuest*)[self.guests objectAtIndex:indexPath.row-2];
                    
                    UILabel * guestNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, 130, 20)];
                    guestNameLabel.font = [UIFont systemFontOfSize:14];
                    guestNameLabel.text = [NSString stringWithFormat:@"旅客:%@",guest.guestName];
                    guestNameLabel.backgroundColor = [UIColor clearColor];
                    [cell.contentView addSubview:guestNameLabel];
                    [guestNameLabel release];
                    
                    UILabel * guestPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 150, 20)];
                    guestPhoneLabel.font = [UIFont systemFontOfSize:14];
                    guestPhoneLabel.text = [NSString stringWithFormat:@"手机:%@",guest.guestPhone];
                    guestPhoneLabel.backgroundColor = [UIColor clearColor];
                    [cell.contentView addSubview:guestPhoneLabel];
                    [guestPhoneLabel release];
                }
            }
                break;
        }
        
        
        if (indexPath.row != 0) {
            if(indexPath.row == [self.bookTableView numberOfRowsInSection:indexPath.section]-1){
                NSString *tableViewCellBottomNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_normal" inDirectory:@"CommonView/TableViewCell"];
                cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomNormalPath]] autorelease];
            } else {
                NSString *tableViewCellCenterNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_normal" inDirectory:@"CommonView/TableViewCell"];
                cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterNormalPath]] autorelease];
            }
        }
			
    }
	
	return cell;

}

//设置单元格是否可以进行编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.section == 1) {
		switch (indexPath.row) {
			case 0:
            case 1:
				return FALSE;
				break;
			default:
				if ([self.guests count] == 0) {
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
	[self.guests removeObjectAtIndex:row-2];
	
	if ([self.guests count] == 0) {
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
    if ([indexPath row]==0) {
        return 36;
    } else if([indexPath section] == 0 && [indexPath row] == 1){
        return 55;
    }else {
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



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 3) {
		switch (indexPath.row) {
			case 1:{
				HotelRoomArrivalLastTimeChoiceController * hotelRoomArrivalLastTimeChoiceController = [[HotelRoomArrivalLastTimeChoiceController alloc] initWithStyle:UITableViewStyleGrouped];
				hotelRoomArrivalLastTimeChoiceController.hotelBookController = self;
				[self.navigationController pushViewController:hotelRoomArrivalLastTimeChoiceController animated:YES];
				[hotelRoomArrivalLastTimeChoiceController release];
			}
				break;
			case 2:{
				HotelRoomCountChoiceController * hotelRoomCountChoiceController = [[HotelRoomCountChoiceController alloc] initWithStyle:UITableViewStyleGrouped];
				hotelRoomCountChoiceController.hotelBookController = self;
				[self.navigationController pushViewController:hotelRoomCountChoiceController animated:YES];
				[hotelRoomCountChoiceController release];
			}
		}
		[self.bookTableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:YES];
	}
	
	
}

#pragma mark -
#pragma mark Text Field Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	int add = ([self.guests count]>1?[self.guests count]-1:0)*44;
	[self.bookTableView setContentOffset:CGPointMake(0, add+325) animated:YES];
    self.bookTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 120.0f, 0.0f);//设置列表的位置
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

//
//  CouponOrderSendViewController.m
//  UCAI
//
//  Created by  on 11-12-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CouponOrderSendViewController.h"
#import "CouponSendResponseModel.h"

#import "GDataXMLNode.h"
#import "ASIFormDataRequest.h"
#import "StaticConf.h"
#import "ResponseParser.h"
#import "CommonTools.h"

#import "PiosaFileManager.h"

@implementation CouponOrderSendViewController

@synthesize phoneField = _phoneField;

- (CouponOrderSendViewController *)initWithCouponOrderId:(NSString *)orderId{
    self = [super init];
    _couponOrderId = [orderId copy];
    return self;
}

- (void)dealloc{
    [_couponOrderId release];
    [self.phoneField release];
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    
    self.title = @"发送到手机";

	UIBarButtonItem *saveGuestButton = [[UIBarButtonItem alloc]
                                        initWithTitle:@"发送" 
                                        style:UIBarButtonItemStyleDone
                                        target:self 
                                        action:@selector(sendButtonPress)];
	self.navigationItem.rightBarButtonItem = saveGuestButton;
	[saveGuestButton release];
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"返回" 
                                   style:UIBarButtonItemStylePlain
                                   target:self 
                                   action:@selector(back)];
	[self.navigationItem setLeftBarButtonItem:backButton];
	[backButton release];
    
    //设置背景图片
    NSString *bgPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"background" inDirectory:@"CommonView"];
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bgPath]];
    bgImageView.frame = CGRectMake(0, 0, 320, 416);
	[self.view addSubview:bgImageView];
	[bgImageView release];
    
    UITableView *sendTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 400) style:UITableViewStyleGrouped];
    sendTableView.backgroundColor = [UIColor clearColor];
    sendTableView.dataSource = self;
    sendTableView.delegate = self;
    sendTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:sendTableView];
    [sendTableView release];
	
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	//在视图消失前，隐藏起键盘
	[self.phoneField resignFirstResponder];
}

#pragma mark -
#pragma mark custom

//返回按钮的响应方法
- (void) back{
	CATransition *transition = [CATransition animation];
	transition.delegate = self; 
	transition.duration = 0.5f;//间隔时间
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];//动画的开始与结束的快慢
	transition.type = kCATransitionReveal; // 各种动画效果
	transition.subtype = kCATransitionFromBottom;// 动画方向
	[self.navigationController.view.layer addAnimation:transition forKey:nil];
	
	[self.navigationController popViewControllerAnimated:NO];
}

//保存按钮的响应方法
- (void) sendButtonPress{
	[self.phoneField resignFirstResponder];
    
	int check = [self checkAndSaveIn];
	
	NSString * showMes = nil;
	switch (check) {
		case 1:
			showMes = @"您似乎还未输入手机号";
			break;
		case 2:
			showMes = @"请您输入有效的手机号码";
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
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = showMes;
        [hud show:YES];
        [hud hide:YES afterDelay:2];
	} else {
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _hud.bgRGB = [PiosaColorManager progressColor];
        [self.navigationController.view addSubview:_hud];
        _hud.delegate = self;
        _hud.minSize = CGSizeMake(135.f, 135.f);
        _hud.labelText = @"发送中...";
        [_hud show:YES];
        
        ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: COUPON_SEND_ADDRESS]] autorelease] ;
        request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
        
        [request appendPostData:[self generateCouponOrderSendRequestPostXMLData]];
        
        [request setDelegate:self];
        [request startAsynchronous]; // 执行异步post
	}
}

- (int) checkAndSaveIn {
	if (self.phoneField.text == nil || [@"" isEqualToString:[self.phoneField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
		return 1;
	} else if (![CommonTools verifyPhoneFormat:self.phoneField.text]) {
		return 2;
	} else {
        return 0;
    }
}

- (NSData*)generateCouponOrderSendRequestPostXMLData{
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"couponOrderID" stringValue:_couponOrderId]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"phone" stringValue:self.phoneField.text]];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    return document.XMLData;
}

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应 : 但可能是错误响应, 如 404，或查询结果为空，则不跳转到下一个机票展示页面
- (void)requestFinished:(ASIFormDataRequest *)request
{    
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n",responseString);
    
    if ((responseString != nil) && [responseString length] > 0) {
        // 生成细节数据
        CouponSendResponseModel *couponSendResponseModel = [ResponseParser loadCouponSendResponse :[request responseData]];
        
        if ([couponSendResponseModel.resultCode intValue] != 0) {
            NSString *exclamationImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"exclamation" inDirectory:@"CommonView/ProgressView"];
            UIImageView *exclamationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:exclamationImagePath]];
            exclamationImageView.frame = CGRectMake(0, 0, 37, 37);
            _hud.customView = exclamationImageView;
            [exclamationImageView release];
            _hud.opacity = 1.0;
            _hud.mode = MBProgressHUDModeCustomView;
            _hud.labelText = couponSendResponseModel.resultMessage;
            [_hud hide:YES afterDelay:2];
        } else {
            NSString *tickImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"tick" inDirectory:@"CommonView/ProgressView"];
            UIImageView *tickImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:tickImagePath]];
            tickImageView.frame = CGRectMake(0, 0, 37, 37);
            _hud.customView = tickImageView;
            [tickImageView release];
            _hud.opacity = 1.0;
            _hud.mode = MBProgressHUDModeCustomView;
            _hud.labelText = @"发送成功";
            _hud.detailsLabelText = [NSString stringWithFormat:@"此优惠劵订单剩余发送次数为%@次",couponSendResponseModel.remainingCount];
            [_hud hide:YES afterDelay:4];
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %d %d",indexPath.section,indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		switch (indexPath.row) {
			case 0:{
				UILabel * showLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 260, 40)];
                showLabel.backgroundColor = [UIColor clearColor];
                showLabel.textColor = [UIColor grayColor];
                showLabel.lineBreakMode = UILineBreakModeWordWrap;
                showLabel.numberOfLines = 0;
                showLabel.font = [UIFont systemFontOfSize:14];
				showLabel.text = @"我们将通过短信方式将此优惠劵信息发送至您手机中，一张优惠劵最多可发送5次";
				[cell.contentView addSubview:showLabel];
				[showLabel release];
			}
				break;
			case 1:{
				UILabel * phoneShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 80, 30)];
                phoneShowLabel.backgroundColor = [UIColor clearColor];
				phoneShowLabel.text = @"手机号码:";
				[cell.contentView addSubview:phoneShowLabel];
				[phoneShowLabel release];
				
				UITextField * phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 40, 260, 30)];
				phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
				phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
				phoneTextField.keyboardType = UIKeyboardTypePhonePad;
                [phoneTextField becomeFirstResponder];
				self.phoneField = phoneTextField;
				[cell.contentView addSubview:self.phoneField];
				[phoneTextField release];
			}
				break;
		}
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return 50;
            break;
        case 1:
            return 80;
            break;
        default:
            return 0;
            break;
    }
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    [hud release];
	hud = nil;
    
    [self.phoneField becomeFirstResponder];
}

@end

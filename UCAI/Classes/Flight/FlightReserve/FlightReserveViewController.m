//
//  FlightBookingViewController.m
//  UCAI
//
//  Created by  on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import "UIView-ModalAnimationHelper.h"

#import "FlightReserveViewController.h"
#import "FlightReserveWeekChoiceTableViewController.h"
#import "FlightReserveDiscountChoiceTableViewController.h"
#import "FlightReserveResponseModel.h"
#import "FlightReserveCityChoiceTableViewController.h"

#import "PiosaFileManager.h"
#import "ResponseParser.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "StaticConf.h"
#import "CommonTools.h"

#define kSingleLeftSegmentControlButtonTag 101
#define kDoubleRightSegmentControlButtonTag 102

#define kMaxPriceTextFieldTag 201
#define kLinkManNameTextFieldTag 202
#define kLinkManIDnumberTextFieldTag 203
#define kLinkManPhoneTextFieldTag 204
#define kLinkManTelTextFieldTag 205
#define kLinkManEmailTextFieldTag 206

@implementation FlightReserveViewController

@synthesize bigLeftSegmentControlButton = _bigLeftSegmentControlButton;
@synthesize bigRightSegmentControlButton = _bigRightSegmentControlButton;
@synthesize startedCityShowlabel = _startedCityShowlabel;
@synthesize arrivedCityShowlabel = _arrivedCityShowlabel;
@synthesize startCityCode = _startCityCode;
@synthesize arrivedCityCode = _arrivedCityCode;
@synthesize goStartedDateShowlabel = _goStartedDateShowlabel;
@synthesize goEndDateShowlabel = _goEndDateShowlabel;
@synthesize backStartedDateShowlabel = _backStartedDateShowlabel;
@synthesize backEndDateShowlabel = _backEndDateShowlabel;
@synthesize dayOfWeekShowlabel = _dayOfWeekShowlabel;
@synthesize week = _week;
@synthesize discountChoiceShowlabel = _discountChoiceShowlabel;
@synthesize discount = _discount;
@synthesize priceCheckBoxButton = _priceCheckBoxButton;
@synthesize discountCheckBoxButton = _discountCheckBoxButton;
@synthesize maxPriceTextField = _maxPriceTextField;
@synthesize linkManNameTextField = _linkManNameTextField;
@synthesize linkManIDnumberTextField = _linkManIDnumberTextField;
@synthesize linkManPhoneTextField = _linkManPhoneTextField;
@synthesize linkManTelTextField = _linkManTelTextField;
@synthesize linkManEmailTextField = _linkManEmailTextField;
@synthesize reserveTableView = _reserveTableView;
@synthesize commitButton = _commitButton;
@synthesize dateBar = _dateBar;
@synthesize datePicker = _datePicker;

- (void)dealloc{
    [self.bigLeftSegmentControlButton release];
    [self.bigRightSegmentControlButton release];
    [self.startedCityShowlabel release];
    [self.arrivedCityShowlabel release];
    [self.startCityCode release];
    [self.arrivedCityCode release];
    [self.goStartedDateShowlabel release];
    [self.goEndDateShowlabel release];
    [self.backStartedDateShowlabel release];
    [self.backEndDateShowlabel release];
    [self.dayOfWeekShowlabel release];
    [self.discountChoiceShowlabel release];
    [self.priceCheckBoxButton release];
    [self.discountCheckBoxButton release];
    [self.maxPriceTextField release];
    [self.linkManNameTextField release];
    [self.linkManIDnumberTextField release];
    [self.linkManPhoneTextField release];
    [self.linkManTelTextField release];
    [self.linkManEmailTextField release];
    [self.reserveTableView release];
    [self.commitButton release];
    [self.dateBar release];
	[self.datePicker release];
    [super dealloc];
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

- (void)typeSegmentControlAction:(UIButton *)segmentControlButton
{
    switch (segmentControlButton.tag) {
        case kSingleLeftSegmentControlButtonTag:
            //设置单程按钮为选中
            [self.bigLeftSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.bigLeftSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            NSString *titleLeftSegmentControlButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleLeftSegmentControlButton_selected" inDirectory:@"CommonView/TitleSegmentedControl"];
            [self.bigLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonSelectedPath] forState:UIControlStateNormal];
            [self.bigLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonSelectedPath] forState:UIControlStateHighlighted];
            //设置往返按钮为非选中
            [self.bigRightSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateNormal];
            [self.bigRightSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateHighlighted];
            NSString *titleRightSegmentControlButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleRightSegmentControlButton_normal" inDirectory:@"CommonView/TitleSegmentedControl"];
            [self.bigRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonNormalPath] forState:UIControlStateNormal];
            [self.bigRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonNormalPath] forState:UIControlStateHighlighted];
            
            if (_flightLineType != UCAIFlightLineStyleSingle) {
                _flightLineType = UCAIFlightLineStyleSingle;
                [self.reserveTableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation: UITableViewRowAnimationFade];
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                [UIView setAnimationDelegate:self];
                self.commitButton.frame = CGRectMake(10, 620, 300, 40);
                [UIView commitAnimations];
                
            }
            break;
        case kDoubleRightSegmentControlButtonTag:
            //设置单程按钮为非选中
            [self.bigLeftSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateNormal];
            [self.bigLeftSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateHighlighted];
            NSString *titleLeftSegmentControlButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleLeftSegmentControlButton_normal" inDirectory:@"CommonView/TitleSegmentedControl"];
            [self.bigLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonNormalPath] forState:UIControlStateNormal];
            [self.bigLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonNormalPath] forState:UIControlStateHighlighted];
            //设置往返按钮为选中
            [self.bigRightSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.bigRightSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            NSString *titleRightSegmentControlButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleRightSegmentControlButton_selected" inDirectory:@"CommonView/TitleSegmentedControl"];
            [self.bigRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonSelectedPath] forState:UIControlStateNormal];
            [self.bigRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonSelectedPath] forState:UIControlStateHighlighted];
            
            if (_flightLineType != UCAIFlightLineStyleDouble) {
                _flightLineType = UCAIFlightLineStyleDouble;
                [self.reserveTableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation: UITableViewRowAnimationFade];
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                [UIView setAnimationDelegate:self];
                self.commitButton.frame = CGRectMake(10, 729, 300, 40);
                [UIView commitAnimations];
            }
            break;
    }
}

- (void)dateCancel{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	self.dateBar.frame = CGRectMake(0, 416, 320, 40);
	self.datePicker.frame = CGRectMake(0, 446, 320, 216);
	[UIView commitModalAnimations];
    self.dateBar.hidden = YES;
    self.datePicker.hidden = YES;
    [self.reserveTableView setScrollEnabled:YES];
    
    [self.reserveTableView reloadData];
}

- (void)dateDone{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	self.dateBar.frame = CGRectMake(0, 416, 320, 40);
	self.datePicker.frame = CGRectMake(0, 446, 320, 216);
	[UIView commitModalAnimations];
    self.dateBar.hidden = YES;
    self.datePicker.hidden = YES;
	[self.reserveTableView setScrollEnabled:YES];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"yyyy-MM-dd";
    
    switch (_flightReserveDateType) {
        case UCAIFlightReserveDateTypeGoStarted:
            self.goStartedDateShowlabel.text = [formatter stringFromDate:[self.datePicker date]];
            // 判断去程开始日期是否晚于去程结束日期，若是，则要设置去程结束日期为去程开始日期的后一天
            if ([[formatter dateFromString:self.goEndDateShowlabel.text] compare:[self.datePicker date]] != NSOrderedDescending) {
                //去程开始日期晚于去程结束日期
                self.goEndDateShowlabel.text = [formatter stringFromDate:[[self.datePicker date] dateByAddingTimeInterval:86400]];
            }
            // 判断去程开始日期是否晚于回程开始日期，若是，则要设置回程开始日期为去程开始日期
            if ([[formatter dateFromString:self.backStartedDateShowlabel.text] compare:[self.datePicker date]] == NSOrderedAscending) {
                //去程开始日期晚于回程开始日期
                self.backStartedDateShowlabel.text = [formatter stringFromDate:[self.datePicker date]];
            }
            // 判断回程开始日期是否晚于回程结束日期，若是，则要设置回程结束日期为回程开始日期的后一天
            if ([[formatter dateFromString:self.backEndDateShowlabel.text] compare:[formatter dateFromString:self.backStartedDateShowlabel.text]] != NSOrderedDescending) {
                //回程开始日期晚于回程结束日期
                self.backEndDateShowlabel.text = [formatter stringFromDate:[[formatter dateFromString:self.backStartedDateShowlabel.text] dateByAddingTimeInterval:86400]];
            }
            break;
        case UCAIFlightReserveDateTypeGoEnd:
            self.goEndDateShowlabel.text = [formatter stringFromDate:[self.datePicker date]];
            // 判断去程结束日期是否晚于回程结束日期，若是，则要设置回程结束日期为去程开始日期
            if ([[formatter dateFromString:self.backEndDateShowlabel.text] compare:[formatter dateFromString:self.goEndDateShowlabel.text]] == NSOrderedAscending) {
                //去程结束日期晚于回程结束日期
                self.backEndDateShowlabel.text = [formatter stringFromDate:[formatter dateFromString:self.goEndDateShowlabel.text]];
            }
            break;
        case UCAIFlightReserveDateTypeBackStarted:
            self.backStartedDateShowlabel.text = [formatter stringFromDate:[self.datePicker date]];
            // 判断回程开始日期是否晚于回程结束日期，若是，则要设置回程结束日期为回程开始日期的后一天
            if ([[formatter dateFromString:self.backEndDateShowlabel.text] compare:[self.datePicker date]] != NSOrderedDescending) {
                //回程开始日期晚于回程结束日期
                self.backEndDateShowlabel.text = [formatter stringFromDate:[[self.datePicker date] dateByAddingTimeInterval:86400]];
            }
            break;
        case UCAIFlightReserveDateTypeBackEnd:
            self.backEndDateShowlabel.text = [formatter stringFromDate:[self.datePicker date]];
            break;
    }
    [formatter release];
    
    [self.reserveTableView reloadData];
}

//响应性别选项的复选框
-(void)checkboxClick:(UIButton *)btn
{
	self.priceCheckBoxButton.selected = !self.priceCheckBoxButton.selected;
	self.discountCheckBoxButton.selected = !self.discountCheckBoxButton.selected;
    
    switch (_flightLineType) {
        case UCAIFlightLineStyleSingle:
            [self.reserveTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:2],nil] withRowAnimation:UITableViewRowAnimationMiddle];
            break;
        case UCAIFlightLineStyleDouble:
            [self.reserveTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:3],nil] withRowAnimation:UITableViewRowAnimationMiddle];
            break;
    }
}

//响应文本输入框的完成按钮操作，用于收回键盘
- (IBAction)textFieldDone:(id)sender{
    [self.reserveTableView setContentInset:UIEdgeInsetsMake(0, 0, 60, 0)];
}

- (void)commitButtonPress{
    [self.reserveTableView setContentInset:UIEdgeInsetsMake(0, 0, 60, 0)];
    [self.maxPriceTextField resignFirstResponder];
    [self.linkManNameTextField resignFirstResponder];
    [self.linkManIDnumberTextField resignFirstResponder];
    [self.linkManPhoneTextField resignFirstResponder];
    [self.linkManTelTextField resignFirstResponder];
    [self.linkManEmailTextField resignFirstResponder];
    
    
    int check = [self checkAndSaveIn];
	
	NSString * showMes = nil;
    NSString * deShowMes = nil;
	switch (check) {
		case 1:
			showMes = @"您似乎还未输入期望最高价格";
			break;
		case 2:
			showMes = @"您似乎还未输入联系姓名";
			break;
		case 3:
			showMes = @"请输入有效的身份证号";
			break;
		case 4:
			showMes = @"您似乎还未输入手机号码";
			break;
		case 5:
            showMes = @"请输入有效的手机号码";
			break;
		case 6:
			showMes = @"您输入的邮箱地址有误";
            deShowMes = @"正确格式:jindu@hotmail.com";
			break;
	}
	
	if (check != 0) {
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
        hud.detailsLabelText = deShowMes;
        [hud show:YES];
        [hud hide:YES afterDelay:2];
	}else{
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _hud.bgRGB = [PiosaColorManager progressColor];
        [self.navigationController.view addSubview:_hud];
        _hud.delegate = self;
        _hud.minSize = CGSizeMake(135.f, 135.f);
        _hud.labelText = @"提交中...";
        [_hud show:YES];
        
        NSString *postData = [[NSString alloc] initWithData:[self generateFlightBookingRequestPostXMLData] encoding:NSUTF8StringEncoding];
        NSLog(@"requestStart\n");
        NSLog(@"%@\n", postData);
        [postData release];
		
		ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: FLIGHT_RESERVE_ADDRESS]] autorelease];
		[req addRequestHeader:@"API-Version" value:API_VERSION];
		req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
		[req appendPostData:[self generateFlightBookingRequestPostXMLData]];
		[req setDelegate:self];
		[req startAsynchronous]; // 执行异步post
    }
}

//检查并保存所输入信息是否合法
//0-合法;
//1-未输入期望最高价格;
//2-未输入联系姓名;
//3-所输入身份证格式错误;
//4-未输入手机号码;
//5-未输入有效手机号码;
//6-所输入电子邮箱格式错误;
- (int)checkAndSaveIn{
    
    if (self.priceCheckBoxButton.selected && (self.maxPriceTextField.text == nil || [self.maxPriceTextField.text length]==0)) {
		return 1;
	}
    
    if (self.linkManNameTextField.text == nil || [self.linkManNameTextField.text length]==0) {
		return 2;
	}

    if (self.linkManIDnumberTextField.text!=nil && [self.linkManIDnumberTextField.text length]!=0) {
		if (![CommonTools verifyIDNumberFormat:self.linkManIDnumberTextField.text]){
			return 3;
		}
	}
    
    if (self.linkManPhoneTextField.text == nil || [self.linkManPhoneTextField.text length]==0) {
		return 4;
	} else {
		if (![CommonTools verifyPhoneFormat:self.linkManPhoneTextField.text]) {
			return 5;
		}
	}
    
    if (self.linkManEmailTextField.text!=nil && [self.linkManEmailTextField.text length]!=0) {
		if (![CommonTools verifyEmailFormat:self.linkManEmailTextField.text]){
			return 6;
		}
	}
    
    return 0;
    
}

- (NSData*)generateFlightBookingRequestPostXMLData{
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    if (_flightLineType == UCAIFlightLineStyleSingle) {
        [conditionElement addChild:[GDataXMLNode elementWithName:@"ticketType" stringValue:@"1"]];
    } else {
        [conditionElement addChild:[GDataXMLNode elementWithName:@"ticketType" stringValue:@"2"]];
    }
    
    [conditionElement addChild:[GDataXMLNode elementWithName:@"startCityCode" stringValue:self.startCityCode]];
	[conditionElement addChild:[GDataXMLNode elementWithName:@"endCityCode" stringValue:self.arrivedCityCode]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"startDate" stringValue:self.goStartedDateShowlabel.text]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"endDate" stringValue:self.goEndDateShowlabel.text]];
    if (_flightLineType == UCAIFlightLineStyleDouble) {
        [conditionElement addChild:[GDataXMLNode elementWithName:@"hstartDate" stringValue:self.backStartedDateShowlabel.text]];
        [conditionElement addChild:[GDataXMLNode elementWithName:@"hendDate" stringValue:self.backEndDateShowlabel.text]];
    } else {
        [conditionElement addChild:[GDataXMLNode elementWithName:@"hstartDate" stringValue:@""]];
        [conditionElement addChild:[GDataXMLNode elementWithName:@"hendDate" stringValue:@""]];
    }
    
    [conditionElement addChild:[GDataXMLNode elementWithName:@"week" stringValue:[NSString stringWithFormat:@"%d",self.week]]];
    if (self.priceCheckBoxButton.selected) {
        [conditionElement addChild:[GDataXMLNode elementWithName:@"priceType" stringValue:@"1"]];
        [conditionElement addChild:[GDataXMLNode elementWithName:@"price" stringValue:self.maxPriceTextField.text]];
    } else {
        [conditionElement addChild:[GDataXMLNode elementWithName:@"priceType" stringValue:@"2"]];
        [conditionElement addChild:[GDataXMLNode elementWithName:@"price" stringValue:[NSString stringWithFormat:@"%d",self.discount]]];
    }
    GDataXMLElement *linkManElement = [GDataXMLElement elementWithName:@"linkMan"];
    [linkManElement addChild:[GDataXMLNode elementWithName:@"name" stringValue:self.linkManNameTextField.text]];
    [linkManElement addChild:[GDataXMLNode elementWithName:@"IDnumber" stringValue:self.linkManIDnumberTextField.text]];
    [linkManElement addChild:[GDataXMLNode elementWithName:@"phone" stringValue:self.linkManPhoneTextField.text]];
    [linkManElement addChild:[GDataXMLNode elementWithName:@"tel" stringValue:self.linkManTelTextField.text]];
    [linkManElement addChild:[GDataXMLNode elementWithName:@"email" stringValue:self.linkManEmailTextField.text]];
    [conditionElement addChild:linkManElement];
    [requestElement addChild:conditionElement];
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    
    NSData *xmlData = document.XMLData;
	return xmlData;

}

#pragma mark -
#pragma mark View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	self.title = @"机票预约";
	
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
    
    //单程左按钮
    UIButton * tempLeftSegmentedButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 150, 34)];
    tempLeftSegmentedButton.tag = kSingleLeftSegmentControlButtonTag;
    [tempLeftSegmentedButton setTitle:@"单程" forState:UIControlStateNormal];
    [tempLeftSegmentedButton setTitle:@"单程" forState:UIControlStateSelected];
    tempLeftSegmentedButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [tempLeftSegmentedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tempLeftSegmentedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    NSString *titleLeftSegmentControlButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleLeftSegmentControlButton_selected" inDirectory:@"CommonView/TitleSegmentedControl"];
    [tempLeftSegmentedButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonSelectedPath] forState:UIControlStateNormal];
    [tempLeftSegmentedButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonSelectedPath] forState:UIControlStateHighlighted];
    [tempLeftSegmentedButton addTarget:self action:@selector(typeSegmentControlAction:) forControlEvents:UIControlEventTouchDown];
    self.bigLeftSegmentControlButton = tempLeftSegmentedButton;
    [self.view addSubview:self.bigLeftSegmentControlButton];
    [tempLeftSegmentedButton release];
    
    //往返右按钮
    UIButton * tempRightSegmentedButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 10, 150, 34)];
    tempRightSegmentedButton.tag =kDoubleRightSegmentControlButtonTag;
    [tempRightSegmentedButton setTitle:@"往返" forState:UIControlStateNormal];
    [tempRightSegmentedButton setTitle:@"往返" forState:UIControlStateSelected];
    tempRightSegmentedButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [tempRightSegmentedButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateNormal];
    [tempRightSegmentedButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateHighlighted];
    NSString *titleRightSegmentControlButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleRightSegmentControlButton_normal" inDirectory:@"CommonView/TitleSegmentedControl"];
    [tempRightSegmentedButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonNormalPath] forState:UIControlStateNormal];
    [tempRightSegmentedButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonNormalPath] forState:UIControlStateHighlighted];
    [tempRightSegmentedButton addTarget:self action:@selector(typeSegmentControlAction:) forControlEvents:UIControlEventTouchDown];
    self.bigRightSegmentControlButton = tempRightSegmentedButton;
    [self.view addSubview:self.bigRightSegmentControlButton];
    [tempRightSegmentedButton release];
    
    UITableView * uiTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 54, 320, 332) style:UITableViewStyleGrouped];
    uiTableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    uiTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	uiTableView.backgroundColor = [UIColor clearColor];
	uiTableView.dataSource = self;
	uiTableView.delegate = self;
    self.reserveTableView = uiTableView;
	[self.view addSubview:uiTableView];
	[uiTableView release];
    
    UIButton *commitButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 620, 300, 40)];
	[commitButton setTitle:@"提交预约" forState:UIControlStateNormal];
    [commitButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
    [commitButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
	[commitButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
	[commitButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
	[commitButton addTarget:self action:@selector(commitButtonPress) forControlEvents:UIControlEventTouchUpInside];
    self.commitButton = commitButton;
	[self.reserveTableView addSubview:commitButton];
	[commitButton release];
    
    _flightLineType = UCAIFlightLineStyleSingle;
    
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
    
    //初始化dataPicker
	UIDatePicker * tempDatePicker = [[UIDatePicker alloc] init];
	[tempDatePicker setFrame:CGRectMake(0, 446, 320, 100)];//大小固定为320＊216
    tempDatePicker.hidden = YES;
	tempDatePicker.datePickerMode = UIDatePickerModeDate;//时间选择只有日期
    self.datePicker = tempDatePicker;
	[self.view addSubview:self.datePicker];
    [tempDatePicker release];
	
	//初始化dataBar
	NSMutableArray *buttons = [[NSMutableArray alloc] init]; 
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: @"取消" style:UIBarButtonItemStyleBordered target: self action: @selector(dateCancel)]; 
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"确定" style:UIBarButtonItemStyleBordered target: self action: @selector(dateDone)]; 
	[buttons addObject:cancelButton];
    [buttons addObject:flexibleSpace]; 
    [buttons addObject:doneButton]; 
	[cancelButton release];
	[flexibleSpace release]; 
	[doneButton release];
    
	UIToolbar * dataToolBar = [[UIToolbar alloc] init];
	dataToolBar.tintColor = [PiosaColorManager tableViewPlainHeaderColor];
	[dataToolBar setFrame:CGRectMake(0, 416, 320, 40)];
    dataToolBar.hidden = YES;
	[dataToolBar setItems:buttons animated:TRUE]; 
    self.dateBar = dataToolBar;
	[self.view addSubview:self.dateBar];
    [dataToolBar release];
	[buttons release];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.reserveTableView reloadData];
}

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);
    // 关闭加载框
    [_hud hide:YES];
    if ((responseString != nil) && [responseString length] > 0) {
        
		FlightReserveResponseModel *flightReserveResponseModel = [ResponseParser loadFlightReserveResponseModelResponse:[request responseData]];
		
		if (flightReserveResponseModel.resultCode == nil || [flightReserveResponseModel.resultCode length] == 0 || [flightReserveResponseModel.resultCode intValue] != 0) {
			// 修改失败
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
            hud.labelText = flightReserveResponseModel.resultMessage;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
		}else {
			//修改成功
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            hud.bgRGB = [PiosaColorManager progressColor];
            [self.navigationController.view addSubview:hud];
            hud.delegate = self;
            hud.minSize = CGSizeMake(135.f, 135.f);
            NSString *tickImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"tick" inDirectory:@"CommonView/ProgressView"];
            UIImageView *tickImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:tickImagePath]];
            tickImageView.frame = CGRectMake(0, 0, 37, 37);
            hud.customView = tickImageView;
            [tickImageView release];
            hud.opacity = 1.0;
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"机票预约成功!";
            hud.detailsLabelText = @"我们将尽快处理您的预约信息";
            [hud show:YES];
            [hud hide:YES afterDelay:4];
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
    switch (_flightLineType) {
        case UCAIFlightLineStyleSingle:
            return 4;
            break;
        case UCAIFlightLineStyleDouble:
            return 5;
            break;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger realSection = section;
    
    if (_flightLineType == UCAIFlightLineStyleSingle) {
        if (section != 0 && section != 1) {
            realSection ++;
        }
    }
    
    switch (realSection) {
        case 0:
            return 2;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 2;
            break;
        case 3:
            return 3;
            break;
        case 4:
            return 5;
            break;
        default:
            return 0;
            break;
    }
}


//设置表格单元的展现
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger realSection = indexPath.section;
    if (_flightLineType == UCAIFlightLineStyleSingle) {
        if (indexPath.section != 0 && indexPath.section != 1) {
            realSection ++;
        }
    }
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell%d%d",realSection,indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        switch (realSection) {
            case 0:
                switch (indexPath.row) {
                    case 0:{
                        UILabel *startedCityTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        startedCityTitlelabel.backgroundColor = [UIColor clearColor];
                        startedCityTitlelabel.textAlignment = UITextAlignmentRight;
                        startedCityTitlelabel.text = @"出发城市:";
                        [cell.contentView addSubview:startedCityTitlelabel];
                        [startedCityTitlelabel release];
                        
                        UILabel *startedCityShowlabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        startedCityShowlabel.backgroundColor = [UIColor clearColor];
                        startedCityShowlabel.textColor = [UIColor grayColor];
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        NSString * flightDefaultStartedCityName = [userDefaults stringForKey:@"flightDefaultStartedCityName"];
                        startedCityShowlabel.text = flightDefaultStartedCityName == nil ?@"深圳":flightDefaultStartedCityName;
                        self.startedCityShowlabel = startedCityShowlabel;
                        [cell.contentView addSubview:startedCityShowlabel];
                        [startedCityShowlabel release];
                        
                        NSString * flightDefaultStartedCityCode = [userDefaults stringForKey:@"flightDefaultStartedCityCode"];
                        self.startCityCode = flightDefaultStartedCityCode == nil ?@"SZX":flightDefaultStartedCityCode;
                    }
                        break;
                    case 1:{
                        UILabel *arrivedCityTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        arrivedCityTitlelabel.backgroundColor = [UIColor clearColor];
                        arrivedCityTitlelabel.textAlignment = UITextAlignmentRight;
                        arrivedCityTitlelabel.text = @"目的城市:";
                        [cell.contentView addSubview:arrivedCityTitlelabel];
                        [arrivedCityTitlelabel release];
                        
                        UILabel *arrivedCityShowlabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        arrivedCityShowlabel.backgroundColor = [UIColor clearColor];
                        arrivedCityShowlabel.textColor = [UIColor grayColor];
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        NSString * flightDefaultArrivedCityName = [userDefaults stringForKey:@"flightDefaultArrivedCityName"];
                        arrivedCityShowlabel.text = flightDefaultArrivedCityName == nil ?@"北京":flightDefaultArrivedCityName;
                        self.arrivedCityShowlabel = arrivedCityShowlabel;
                        [cell.contentView addSubview:arrivedCityShowlabel];
                        [arrivedCityShowlabel release];
                        
                        NSString * flightDefaultArrivedCityCode = [userDefaults stringForKey:@"flightDefaultArrivedCityCode"];
                        self.arrivedCityCode = flightDefaultArrivedCityCode == nil ?@"PEK":flightDefaultArrivedCityCode;
                    }
                        break;
                }
                NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                UIImageView * accessoryViewTemp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                accessoryViewTemp.frame = CGRectMake(0, 0, 10, 16);
                cell.accessoryView = accessoryViewTemp;
                [accessoryViewTemp release];
                break;
            case 1:{
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				formatter.dateFormat = @"yyyy-MM-dd";
                switch (indexPath.row) {
                    case 0:{
                        UILabel *goStartedDateTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        goStartedDateTitlelabel.backgroundColor = [UIColor clearColor];
                        goStartedDateTitlelabel.textAlignment = UITextAlignmentRight;
                        goStartedDateTitlelabel.text = @"去程开始:";
                        [cell.contentView addSubview:goStartedDateTitlelabel];
                        [goStartedDateTitlelabel release];
                        
                        UILabel *goStartedDateShowlabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        goStartedDateShowlabel.backgroundColor = [UIColor clearColor];
                        goStartedDateShowlabel.textColor = [UIColor grayColor];
                        goStartedDateShowlabel.text = [formatter stringFromDate:[NSDate date]];
                        self.goStartedDateShowlabel = goStartedDateShowlabel;
                        [cell.contentView addSubview:goStartedDateShowlabel];
                        [goStartedDateShowlabel release];
                    }
                        break;
                    case 1:{
                        UILabel *goEndDateTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        goEndDateTitlelabel.backgroundColor = [UIColor clearColor];
                        goEndDateTitlelabel.textAlignment = UITextAlignmentRight;
                        goEndDateTitlelabel.text = @"去程结束:";
                        [cell.contentView addSubview:goEndDateTitlelabel];
                        [goEndDateTitlelabel release];
                        
                        UILabel *goEndDateShowlabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        goEndDateShowlabel.backgroundColor = [UIColor clearColor];
                        goEndDateShowlabel.textColor = [UIColor grayColor];
                        goEndDateShowlabel.text = [formatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:86400]];
                        self.goEndDateShowlabel = goEndDateShowlabel;
                        [cell.contentView addSubview:goEndDateShowlabel];
                        [goEndDateShowlabel release];  
                    }
                        break;
                }
                [formatter release];
                NSString *accessoryTimeIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryTimeIndicator" inDirectory:@"CommonView/TableViewCell"];
                UIImageView * accessoryViewTemp1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryTimeIndicatorPath]];
                accessoryViewTemp1.frame = CGRectMake(0, 0, 20, 20);
                cell.accessoryView = accessoryViewTemp1;
                [accessoryViewTemp1 release];
            } 
                break;
            case 2:{
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				formatter.dateFormat = @"yyyy-MM-dd";
                switch (indexPath.row) {
                    case 0:{
                        UILabel *bacgStartedDateTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        bacgStartedDateTitlelabel.backgroundColor = [UIColor clearColor];
                        bacgStartedDateTitlelabel.textAlignment = UITextAlignmentRight;
                        bacgStartedDateTitlelabel.text = @"回程开始:";
                        [cell.contentView addSubview:bacgStartedDateTitlelabel];
                        [bacgStartedDateTitlelabel release];
                        
                        UILabel *backStartedDateShowlabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        backStartedDateShowlabel.backgroundColor = [UIColor clearColor];
                        backStartedDateShowlabel.textColor = [UIColor grayColor];
                        backStartedDateShowlabel.text = [formatter stringFromDate:[NSDate date]];
                        self.backStartedDateShowlabel = backStartedDateShowlabel;
                        [cell.contentView addSubview:backStartedDateShowlabel];
                        [backStartedDateShowlabel release];
                    }
                        break;
                    case 1:{
                        UILabel *backEndDateTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        backEndDateTitlelabel.backgroundColor = [UIColor clearColor];
                        backEndDateTitlelabel.textAlignment = UITextAlignmentRight;
                        backEndDateTitlelabel.text = @"回程结束:";
                        [cell.contentView addSubview:backEndDateTitlelabel];
                        [backEndDateTitlelabel release];
                        
                        UILabel *backEndDateShowlabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        backEndDateShowlabel.backgroundColor = [UIColor clearColor];
                        backEndDateShowlabel.textColor = [UIColor grayColor];
                        backEndDateShowlabel.text = [formatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:86400]];
                        self.backEndDateShowlabel = backEndDateShowlabel;
                        [cell.contentView addSubview:backEndDateShowlabel];
                        [backEndDateShowlabel release];  
                    }
                        break;
                }
                [formatter release];
            } 
                NSString *accessoryTimeIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryTimeIndicator" inDirectory:@"CommonView/TableViewCell"];
                UIImageView * accessoryViewTemp2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryTimeIndicatorPath]];
                accessoryViewTemp2.frame = CGRectMake(0, 0, 20, 20);
                cell.accessoryView = accessoryViewTemp2;
                [accessoryViewTemp2 release];
                break;
            case 3:
                switch (indexPath.row) {
                    case 0:{
                        UILabel *dayOfWeekTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        dayOfWeekTitlelabel.backgroundColor = [UIColor clearColor];
                        dayOfWeekTitlelabel.textAlignment = UITextAlignmentRight;
                        dayOfWeekTitlelabel.text = @"周几出发:";
                        [cell.contentView addSubview:dayOfWeekTitlelabel];
                        [dayOfWeekTitlelabel release];
                        
                        UILabel *dayOfWeekShowlabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        dayOfWeekShowlabel.backgroundColor = [UIColor clearColor];
                        dayOfWeekShowlabel.textColor = [UIColor grayColor];
                        dayOfWeekShowlabel.text = @"星期一";
                        self.dayOfWeekShowlabel = dayOfWeekShowlabel;
                        [cell.contentView addSubview:dayOfWeekShowlabel];
                        [dayOfWeekShowlabel release];
                        
                        self.week = 1;
                        
                        NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                        UIImageView * accessoryViewTemp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                        accessoryViewTemp.frame = CGRectMake(0, 0, 10, 16);
                        cell.accessoryView = accessoryViewTemp;
                        [accessoryViewTemp release];
                    }
                        break;
                    case 1:{
                        UILabel *expectedChoiceTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        expectedChoiceTitlelabel.backgroundColor = [UIColor clearColor];
                        expectedChoiceTitlelabel.textAlignment = UITextAlignmentRight;
                        expectedChoiceTitlelabel.text = @"期望选择:";
                        [cell.contentView addSubview:expectedChoiceTitlelabel];
                        [expectedChoiceTitlelabel release];
                        
                        
                        UIButton *priceCheckboxButton = [[UIButton alloc] initWithFrame:CGRectMake(110, 10, 25, 25)];
                        priceCheckboxButton.backgroundColor = [UIColor clearColor];
                        NSString *checkboxButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"checkbox_normal" inDirectory:@"CommonView/CheckBox"];
                        NSString *checkboxButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"checkbox_selected" inDirectory:@"CommonView/CheckBox"];
                        [priceCheckboxButton setImage:[UIImage imageNamed:checkboxButtonNormalPath] forState:UIControlStateNormal];
                        [priceCheckboxButton setImage:[UIImage imageNamed:checkboxButtonSelectedPath] forState:UIControlStateSelected];
                        [priceCheckboxButton addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
                        self.priceCheckBoxButton = priceCheckboxButton;
                        priceCheckboxButton.selected = YES;
                        [cell.contentView addSubview:priceCheckboxButton]; 
                        [priceCheckboxButton release];
                        
                        UIButton *priceCheckboxTitleButton = [[UIButton alloc] initWithFrame:CGRectMake(135, 5, 60, 35)];
                        priceCheckboxTitleButton.backgroundColor = [UIColor clearColor];
                        priceCheckboxTitleButton.titleLabel.font = [UIFont systemFontOfSize:15];
                        [priceCheckboxTitleButton setTitle:@"价格    " forState:UIControlStateNormal];
                        [priceCheckboxTitleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [priceCheckboxTitleButton addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:priceCheckboxTitleButton];
                        [priceCheckboxTitleButton release];
                        
                        UIButton *discountCheckboxButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 10, 25, 25)];
                        discountCheckboxButton.backgroundColor = [UIColor clearColor];
                        [discountCheckboxButton setImage:[UIImage imageNamed:checkboxButtonNormalPath] forState:UIControlStateNormal];
                        [discountCheckboxButton setImage:[UIImage imageNamed:checkboxButtonSelectedPath] forState:UIControlStateSelected];
                        [discountCheckboxButton addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
                        self.discountCheckBoxButton = discountCheckboxButton;
                        [cell.contentView addSubview:discountCheckboxButton]; 
                        [discountCheckboxButton release];
                        
                        UIButton *discountCheckboxTitleButton = [[UIButton alloc] initWithFrame:CGRectMake(225, 5, 60, 35)];
                        discountCheckboxTitleButton.backgroundColor = [UIColor clearColor];
                        discountCheckboxTitleButton.titleLabel.font = [UIFont systemFontOfSize:15];
                        [discountCheckboxTitleButton setTitle:@"折扣    " forState:UIControlStateNormal];
                        [discountCheckboxTitleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [discountCheckboxTitleButton addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:discountCheckboxTitleButton];
                        [discountCheckboxTitleButton release];
                        
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                        break;
                    case 2:{
                        if (self.priceCheckBoxButton.selected) {
                            UILabel *maxPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                            maxPriceShowLabel.backgroundColor = [UIColor clearColor];
                            maxPriceShowLabel.textAlignment = UITextAlignmentRight;
                            maxPriceShowLabel.text = @"最高价格:";
                            [cell.contentView addSubview:maxPriceShowLabel];
                            [maxPriceShowLabel release];
                            
                            
                            UITextField *maxPriceTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 190, 25)];
                            maxPriceTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                            maxPriceTextField.borderStyle = UITextBorderStyleRoundedRect;
                            maxPriceTextField.keyboardType = UIKeyboardTypeDecimalPad;
                            maxPriceTextField.returnKeyType = UIReturnKeyDone;
                            maxPriceTextField.placeholder = @"必填";
                            maxPriceTextField.text = @"";
                            maxPriceTextField.delegate = self;
                            [maxPriceTextField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                            maxPriceTextField.tag = kMaxPriceTextFieldTag;
                            self.maxPriceTextField = maxPriceTextField;
                            [cell.contentView addSubview:maxPriceTextField];
                            [maxPriceTextField release];
                            
                            cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        } else {
                            UILabel *discountChoiceTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                            discountChoiceTitlelabel.backgroundColor = [UIColor clearColor];
                            discountChoiceTitlelabel.textAlignment = UITextAlignmentRight;
                            discountChoiceTitlelabel.text = @"期望折扣:";
                            [cell.contentView addSubview:discountChoiceTitlelabel];
                            [discountChoiceTitlelabel release];
                            
                            UILabel *discountChoiceShowlabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                            discountChoiceShowlabel.backgroundColor = [UIColor clearColor];
                            discountChoiceShowlabel.textColor = [UIColor grayColor];
                            discountChoiceShowlabel.text = @"6折及以下";
                            self.discountChoiceShowlabel = discountChoiceShowlabel;
                            [cell.contentView addSubview:discountChoiceShowlabel];
                            [discountChoiceShowlabel release];
                            
                            self.discount = 60;
                            
                            NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                            UIImageView * accessoryViewTemp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                            accessoryViewTemp.frame = CGRectMake(0, 0, 10, 16);
                            cell.accessoryView = accessoryViewTemp;
                            [accessoryViewTemp release];
                        }
                    }
                        break;
                }
                break;
            case 4:{
                NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
                NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
                switch (indexPath.row) {
                    case 0:{
                        UILabel *linkManNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        linkManNameShowLabel.backgroundColor = [UIColor clearColor];
                        linkManNameShowLabel.textAlignment = UITextAlignmentRight;
                        linkManNameShowLabel.text = @"姓名:";
                        [cell.contentView addSubview:linkManNameShowLabel];
                        [linkManNameShowLabel release];
                        
                        
                        UITextField *linkManNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 190, 25)];
                        linkManNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                        linkManNameTextField.borderStyle = UITextBorderStyleRoundedRect;
                        linkManNameTextField.keyboardType = UIKeyboardTypeNamePhonePad;
                        linkManNameTextField.returnKeyType = UIReturnKeyDone;
                        linkManNameTextField.placeholder = @"必填";
                        if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
                            linkManNameTextField.text = [memberDict objectForKey:@"realName"];
                        } else {
                            linkManNameTextField.text = @"";
                        }
                        linkManNameTextField.delegate = self;
                        [linkManNameTextField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        linkManNameTextField.tag = kLinkManNameTextFieldTag;
                        self.linkManNameTextField = linkManNameTextField;
                        [cell.contentView addSubview:linkManNameTextField];
                        [linkManNameTextField release];
                    }
                        break;
                    case 1:{
                        UILabel *linkManIDnumberShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        linkManIDnumberShowLabel.backgroundColor = [UIColor clearColor];
                        linkManIDnumberShowLabel.textAlignment = UITextAlignmentRight;
                        linkManIDnumberShowLabel.text = @"身份证:";
                        [cell.contentView addSubview:linkManIDnumberShowLabel];
                        [linkManIDnumberShowLabel release];
                        
                        
                        UITextField *linkManIDnumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 190, 25)];
                        linkManIDnumberTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                        linkManIDnumberTextField.borderStyle = UITextBorderStyleRoundedRect;
                        linkManIDnumberTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                        linkManIDnumberTextField.returnKeyType = UIReturnKeyDone;
                        linkManIDnumberTextField.placeholder = @"选填";
                        if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
                            linkManIDnumberTextField.text = [memberDict objectForKey:@"idNumber"];
                        } else {
                            linkManIDnumberTextField.text = @"";
                        }
                        linkManIDnumberTextField.delegate = self;
                        [linkManIDnumberTextField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        linkManIDnumberTextField.tag = kLinkManIDnumberTextFieldTag;
                        self.linkManIDnumberTextField = linkManIDnumberTextField;
                        [cell.contentView addSubview:linkManIDnumberTextField];
                        [linkManIDnumberTextField release];
                    }
                        break;
                    case 2:{
                        UILabel *linkManPhoneShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        linkManPhoneShowLabel.backgroundColor = [UIColor clearColor];
                        linkManPhoneShowLabel.textAlignment = UITextAlignmentRight;
                        linkManPhoneShowLabel.text = @"手机号码:";
                        [cell.contentView addSubview:linkManPhoneShowLabel];
                        [linkManPhoneShowLabel release];
                        
                        
                        UITextField *linkManPhoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 190, 25)];
                        linkManPhoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                        linkManPhoneTextField.borderStyle = UITextBorderStyleRoundedRect;
                        linkManPhoneTextField.keyboardType = UIKeyboardTypePhonePad;
                        linkManPhoneTextField.returnKeyType = UIReturnKeyDone;
                        linkManPhoneTextField.placeholder = @"必填";
                        if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
                            linkManPhoneTextField.text = [memberDict objectForKey:@"phone"];
                        } else {
                            linkManPhoneTextField.text = @"";
                        }
                        linkManPhoneTextField.delegate = self;
                        [linkManPhoneTextField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        linkManPhoneTextField.tag = kLinkManPhoneTextFieldTag;
                        self.linkManPhoneTextField = linkManPhoneTextField;
                        [cell.contentView addSubview:linkManPhoneTextField];
                        [linkManPhoneTextField release];
                    }
                        break;
                    case 3:{
                        UILabel *linkManTelShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        linkManTelShowLabel.backgroundColor = [UIColor clearColor];
                        linkManTelShowLabel.textAlignment = UITextAlignmentRight;
                        linkManTelShowLabel.text = @"固定电话:";
                        [cell.contentView addSubview:linkManTelShowLabel];
                        [linkManTelShowLabel release];
                        
                        
                        UITextField *linkManTelTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 190, 25)];
                        linkManTelTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                        linkManTelTextField.borderStyle = UITextBorderStyleRoundedRect;
                        linkManTelTextField.keyboardType = UIKeyboardTypePhonePad;
                        linkManTelTextField.returnKeyType = UIReturnKeyDone;
                        linkManTelTextField.placeholder = @"选填";
                        if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
                            linkManTelTextField.text = [memberDict objectForKey:@"contactTel"];
                        } else {
                            linkManTelTextField.text = @"";
                        }
                        linkManTelTextField.delegate = self;
                        [linkManTelTextField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        linkManTelTextField.tag = kLinkManTelTextFieldTag;
                        self.linkManTelTextField = linkManTelTextField;
                        [cell.contentView addSubview:linkManTelTextField];
                        [linkManTelTextField release];
                    }
                        break;
                    case 4:{
                        UILabel *linkManEmailShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        linkManEmailShowLabel.backgroundColor = [UIColor clearColor];
                        linkManEmailShowLabel.textAlignment = UITextAlignmentRight;
                        linkManEmailShowLabel.text = @"电子邮箱:";
                        [cell.contentView addSubview:linkManEmailShowLabel];
                        [linkManEmailShowLabel release];
                        
                        
                        UITextField *linkManEmailTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 190, 25)];
                        linkManEmailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                        linkManEmailTextField.borderStyle = UITextBorderStyleRoundedRect;
                        linkManEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
                        linkManEmailTextField.returnKeyType = UIReturnKeyDone;
                        linkManEmailTextField.placeholder = @"选填";
                        if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
                            linkManEmailTextField.text = [memberDict objectForKey:@"eMail"];
                        } else {
                            linkManEmailTextField.text = @"";
                        }
                        linkManEmailTextField.delegate = self;
                        [linkManEmailTextField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        linkManEmailTextField.tag = kLinkManEmailTextFieldTag;
                        self.linkManEmailTextField = linkManEmailTextField;
                        [cell.contentView addSubview:linkManEmailTextField];
                        [linkManEmailTextField release];
                    }
                        break;
                }
            }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
        }
	}
    
    if ([self.reserveTableView numberOfRowsInSection:indexPath.section] == 1) {
        NSString *tableViewCellSingleNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_single_normal" inDirectory:@"CommonView/TableViewCell"];
        NSString *tableViewCellSingleHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_single_highlighted" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellSingleNormalPath]] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellSingleHighlightedPath]] autorelease];
    } else {
        if (indexPath.row == 0) {
            NSString *tableViewCellTopNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_top_normal" inDirectory:@"CommonView/TableViewCell"];
            NSString *tableViewCellTopHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_top_highlighted" inDirectory:@"CommonView/TableViewCell"];
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellTopNormalPath]] autorelease];
            cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellTopHighlightedPath]] autorelease];
        } else if(indexPath.row == [self.reserveTableView numberOfRowsInSection:indexPath.section]-1){
            NSString *tableViewCellBottomNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_normal" inDirectory:@"CommonView/TableViewCell"];
            NSString *tableViewCellBottomHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_highlighted" inDirectory:@"CommonView/TableViewCell"];
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomNormalPath]] autorelease];
            cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomHighlightedPath]] autorelease];
        } else {
            NSString *tableViewCellCenterNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_normal" inDirectory:@"CommonView/TableViewCell"];
            NSString *tableViewCellCenterHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_highlighted" inDirectory:@"CommonView/TableViewCell"];
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterNormalPath]] autorelease];
            cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterHighlightedPath]] autorelease];
        }
    }

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.maxPriceTextField resignFirstResponder];
    [self.linkManNameTextField resignFirstResponder];
    [self.linkManIDnumberTextField resignFirstResponder];
    [self.linkManPhoneTextField resignFirstResponder];
    [self.linkManTelTextField resignFirstResponder];
    [self.linkManEmailTextField resignFirstResponder];
    [self.reserveTableView setContentInset:UIEdgeInsetsMake(0, 0, 60, 0)];
    
    NSInteger realSection = indexPath.section;
    if (_flightLineType == UCAIFlightLineStyleSingle) {
        if (indexPath.section != 0 && indexPath.section != 1) {
            realSection ++;
        }
    }
    
    switch (realSection) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    FlightReserveCityChoiceTableViewController *flightReserveCityChoiceTableViewController = [[FlightReserveCityChoiceTableViewController alloc] initWithCityType:1];
                    flightReserveCityChoiceTableViewController.flightReserveViewController = self;
                    [self.navigationController pushViewController:flightReserveCityChoiceTableViewController animated:YES];
                    [flightReserveCityChoiceTableViewController release];
                }
                    break;
                case 1:
                {
                    FlightReserveCityChoiceTableViewController *flightReserveCityChoiceTableViewController = [[FlightReserveCityChoiceTableViewController alloc] initWithCityType:2];
                    flightReserveCityChoiceTableViewController.flightReserveViewController = self;
                    [self.navigationController pushViewController:flightReserveCityChoiceTableViewController animated:YES];
                    [flightReserveCityChoiceTableViewController release];
                }
                    break;
            }
            break;
        case 1:{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			formatter.dateFormat = @"yyyy-MM-dd";
            switch (indexPath.row) {
				case 0:{
					[self.datePicker setDate:[formatter dateFromString:self.goStartedDateShowlabel.text]];//设置日期滚轮的当前显示
					self.datePicker.minimumDate = [NSDate date];//最小选择日期，当日
                    _flightReserveDateType = UCAIFlightReserveDateTypeGoStarted;
				}
					break;
				case 1:{
					[self.datePicker setDate:[formatter dateFromString:self.goEndDateShowlabel.text]];//设置日期滚轮的当前显示
					self.datePicker.minimumDate = [[formatter dateFromString:self.goStartedDateShowlabel.text] dateByAddingTimeInterval:86400];//最小选择日期，去程开始的后一天
                    _flightReserveDateType = UCAIFlightReserveDateTypeGoEnd;
				}
					break;
			}
            [formatter release];
        } 
            self.dateBar.hidden = NO;
            self.datePicker.hidden = NO;
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationDelegate:self];
			self.dateBar.frame = CGRectMake(0, 180, 320, 40);
			self.datePicker.frame = CGRectMake(0, 210, 320, 216);
			[UIView commitAnimations];
			[self.reserveTableView setScrollEnabled:NO];
            break;
        case 2:{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			formatter.dateFormat = @"yyyy-MM-dd";
            switch (indexPath.row) {
				case 0:{
					[self.datePicker setDate:[formatter dateFromString:self.backStartedDateShowlabel.text]];//设置日期滚轮的当前显示
					self.datePicker.minimumDate = [formatter dateFromString:self.goStartedDateShowlabel.text];//最小选择日期,去程开始当天
                    _flightReserveDateType = UCAIFlightReserveDateTypeBackStarted;
				}
					break;
				case 1:{
					[self.datePicker setDate:[formatter dateFromString:self.backEndDateShowlabel.text]];//设置日期滚轮的当前显示
					self.datePicker.minimumDate = [[formatter dateFromString:self.backStartedDateShowlabel.text] dateByAddingTimeInterval:86400];//最小选择日期，回程开始的后一天
                    _flightReserveDateType = UCAIFlightReserveDateTypeBackEnd;
				}
					break;
			}
            [formatter release];
        } 
            self.dateBar.hidden = NO;
            self.datePicker.hidden = NO;
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationDelegate:self];
			self.dateBar.frame = CGRectMake(0, 180, 320, 40);
			self.datePicker.frame = CGRectMake(0, 210, 320, 216);
			[UIView commitAnimations];
			[self.reserveTableView setScrollEnabled:NO];
            break;
        case 3:
            switch (indexPath.row) {
                case 0:{
                    FlightReserveWeekChoiceTableViewController *flightReserveWeekChoiceTableViewController = [[FlightReserveWeekChoiceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    flightReserveWeekChoiceTableViewController.flightReserveViewController = self;
                    [self.navigationController pushViewController:flightReserveWeekChoiceTableViewController animated:YES];
                    [flightReserveWeekChoiceTableViewController release];
                }
                    break;
                case 2:{
                    if (self.discountCheckBoxButton.selected) {
                        FlightReserveDiscountChoiceTableViewController *flightReserveDiscountChoiceTableViewController = [[FlightReserveDiscountChoiceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                        flightReserveDiscountChoiceTableViewController.flightReserveViewController = self;
                        [self.navigationController pushViewController:flightReserveDiscountChoiceTableViewController animated:YES];
                        [flightReserveDiscountChoiceTableViewController release];
                    }
                }
                    break;
            }
            break;
    }
}

#pragma mark -
#pragma mark Text Field Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    switch (_flightLineType) {
        case UCAIFlightLineStyleSingle:
            switch (textField.tag) {
                case kMaxPriceTextFieldTag:
                    [self.reserveTableView setContentOffset:CGPointMake(0, 273) animated:YES];
                    break;
                case kLinkManNameTextFieldTag:
                    [self.reserveTableView setContentOffset:CGPointMake(0, 340) animated:YES];
                    break;
                case kLinkManIDnumberTextFieldTag:
                    [self.reserveTableView setContentOffset:CGPointMake(0, 384) animated:YES];
                    break;
                case kLinkManPhoneTextFieldTag:
                    [self.reserveTableView setContentOffset:CGPointMake(0, 428) animated:YES];
                    break;
                case kLinkManTelTextFieldTag:
                    [self.reserveTableView setContentOffset:CGPointMake(0, 472) animated:YES];
                    break;
                case kLinkManEmailTextFieldTag:
                    [self.reserveTableView setContentOffset:CGPointMake(0, 516) animated:YES];
                    break;
            }
            
            break;
        case UCAIFlightLineStyleDouble:
            switch (textField.tag) {
                case kMaxPriceTextFieldTag:
                    [self.reserveTableView setContentOffset:CGPointMake(0, 382) animated:YES];
                    break;
                case kLinkManNameTextFieldTag:
                    [self.reserveTableView setContentOffset:CGPointMake(0, 449) animated:YES];
                    break;
                case kLinkManIDnumberTextFieldTag:
                    [self.reserveTableView setContentOffset:CGPointMake(0, 493) animated:YES];
                    break;
                case kLinkManPhoneTextFieldTag:
                    [self.reserveTableView setContentOffset:CGPointMake(0, 537) animated:YES];
                    break;
                case kLinkManTelTextFieldTag:
                    [self.reserveTableView setContentOffset:CGPointMake(0, 581) animated:YES];
                    break;
                case kLinkManEmailTextFieldTag:
                    [self.reserveTableView setContentOffset:CGPointMake(0, 625) animated:YES];
                    break;
            }
            break;
    }
    [self.reserveTableView setContentInset:UIEdgeInsetsMake(0, 0, 236, 0)];
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

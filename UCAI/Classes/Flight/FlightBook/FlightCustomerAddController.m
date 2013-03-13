//
//  FlightCustomerAddController.m
//  UCAI
//
//  Created by  on 12-2-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIView-ModalAnimationHelper.h"

#import <QuartzCore/QuartzCore.h>
#import "FlightCustomerAddController.h"
#import "FlightBookViewController.h"
#import "FlightCustomer.h"

#import "FlightCustomerTypeTableViewController.h"
#import "FlightCertificateTypeTableViewController.h"
#import "FlightSecureNumTableViewController.h"

@implementation FlightCustomerAddController

@synthesize isAdult = _isAdult;

@synthesize flightBookViewController = _flightBookViewController;

@synthesize addTableView = _addTableView;

@synthesize customerNameTextField= _customerNameTextField;
@synthesize customerTypeShowLabel= _customerTypeShowLabel;
@synthesize customerType= _customerType;
@synthesize certificateTypeShowLabel= _certificateTypeShowLabel;
@synthesize certificateType= _certificateType;
@synthesize certificateNoTextField = _certificateNoTextField;
@synthesize customerBirthdayLabel = _customerBirthdayLabel;
@synthesize secureNumShowLabel= _secureNumShowLabel;
@synthesize secureNum= _secureNum;

@synthesize dateBar = _dateBar;
@synthesize datePicker = _datePicker;

- (void)dealloc{
    
    [self.flightBookViewController release];
    
    [self.addTableView release];
    
    [self.customerNameTextField release];
    [self.customerTypeShowLabel release];
    [self.customerType release];
    [self.certificateTypeShowLabel release];
    [self.certificateType release];
    [self.certificateNoTextField release];
    [self.customerBirthdayLabel release];
    [self.secureNumShowLabel release];
    [self.secureNum release];
    
    [self.dateBar release];
	[self.datePicker release];
    
    [super dealloc];
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
- (void) saveCustomer{
	
	int check = [self checkAndSaveIn];
	
	NSString * showMes = nil;
	switch (check) {
		case 1:
			showMes = @"您似乎还未输入乘机人姓名";
			break;
		case 2:
			showMes = @"您似乎还未输入证件号码";
			break;
		case 3:
			showMes = @"请您选择出生日期";
			break;
	}
	
	if (check!=0) {
		UIAlertView *showAlert = [[[UIAlertView alloc] initWithTitle:nil message:showMes 
															delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
		[showAlert show];
	} else {
		FlightCustomer * flightCustomer = [[FlightCustomer alloc] init];
		flightCustomer.customerName = self.customerNameTextField.text;
		flightCustomer.customerType = self.customerType;
        flightCustomer.certificateType = self.certificateType;
        if (self.isAdult) {
            flightCustomer.certificateNo = self.certificateNoTextField.text;
        } else {
            flightCustomer.certificateNo = self.customerBirthdayLabel.text;
        }
        flightCustomer.secureNum = self.secureNum;
		[self.flightBookViewController.customers addObject:flightCustomer];
		[flightCustomer release];
		
		CATransition *transition = [CATransition animation];
		transition.delegate = self; 
		transition.duration = 0.5f;//间隔时间
		transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];//动画的开始与结束的快慢
		transition.type = kCATransitionReveal; // 各种动画效果
		transition.subtype = kCATransitionFromBottom;// 动画方向
		[self.navigationController.view.layer addAnimation:transition forKey:nil];
		
		[self.navigationController popViewControllerAnimated:NO];
	}
}

//检查并保存所输入的登陆帐号与登陆密码是否合法
//0-合法;
//1-未输入姓名;
//2-未输入证件号码;
//3-未输入出生日期;
- (int) checkAndSaveIn {
	if (self.customerNameTextField.text == nil || [@"" isEqualToString:[self.customerNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
		return 1;
	}
	
    if (self.isAdult) {
        if (self.certificateNoTextField.text == nil || [@"" isEqualToString:[self.certificateNoTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
            return 2;
        }
    }else{
        if (self.customerBirthdayLabel.text == nil || [@"请选择出生日期" isEqualToString:self.customerBirthdayLabel.text]) {
            return 3;
        }
    }
    
    return 0;
}

- (void) textfieldDone{
    [self.customerNameTextField resignFirstResponder];
    [self.certificateNoTextField resignFirstResponder];
    [self.addTableView setContentOffset:CGPointZero animated:YES];
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
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"yyyy-MM-dd";
	
	self.customerBirthdayLabel.text = [formatter stringFromDate:[self.datePicker date]];
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
	[super loadView];
    
    self.title = @"新增乘机人";
	
	//保存旅客铵钮的设置
	UIBarButtonItem *saveGuestButton = [[UIBarButtonItem alloc]
                                        initWithTitle:@"保存" 
                                        style:UIBarButtonItemStyleDone
                                        target:self 
                                        action:@selector(saveCustomer)];
	self.navigationItem.rightBarButtonItem = saveGuestButton;
	[saveGuestButton release];
	
	//保存旅客铵钮的设置
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
    
    UIView * tipsView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 50)];
    tipsView.backgroundColor = [UIColor whiteColor];
    tipsView.layer.cornerRadius = 10;
    
    UILabel * tipsShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 60, 17)];
    tipsShowLabel.backgroundColor = [UIColor clearColor];
    tipsShowLabel.textColor = [UIColor redColor];
    tipsShowLabel.font = [UIFont systemFontOfSize:14];
    tipsShowLabel.text = @"温馨提示:";
    [tipsView addSubview:tipsShowLabel];
    [tipsShowLabel release];
    
    UILabel * tipsContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 280, 34)];
    tipsContentLabel.backgroundColor = [UIColor clearColor];
    tipsContentLabel.textColor = [UIColor grayColor];
    tipsContentLabel.font = [UIFont systemFontOfSize:14];
    tipsContentLabel.text = @"                 乘机人姓名中包含生僻字或者繁体字请用拼音代替填写,否则可能造成下单失败";
    tipsContentLabel.lineBreakMode = UILineBreakModeWordWrap;
    tipsContentLabel.numberOfLines = 2;
    [tipsView addSubview:tipsContentLabel];
    [tipsContentLabel release];
    
    [self.view addSubview:tipsView];
    [tipsView release];
    
    UITableView * uiTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, 320, 356) style:UITableViewStyleGrouped];
    uiTableView.backgroundColor = [UIColor clearColor];
    uiTableView.dataSource = self;
    uiTableView.delegate = self;
    uiTableView.scrollEnabled = NO;
    uiTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.addTableView = uiTableView;
    [self.view addSubview:uiTableView];
    [uiTableView release];
    
    self.isAdult = YES;
    
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isAdult) {
        return 5;
    } else {
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger realRow = indexPath.row;
    
    if (!self.isAdult && realRow>=2) {
        realRow++;
    }
    
    NSString * cellIdentifier = [NSString stringWithFormat:@"%d",realRow];
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        
        switch (realRow) {
            case 0:{
                UILabel *customerNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 70, 30)];
                customerNameShowLabel.backgroundColor = [UIColor clearColor];
                customerNameShowLabel.font = [UIFont systemFontOfSize:15];
                customerNameShowLabel.text = @"乘机人:";
                customerNameShowLabel.textAlignment = UITextAlignmentRight;
                [cell.contentView addSubview:customerNameShowLabel];
                [customerNameShowLabel release];
                
                UITextField * uiTextField = [[UITextField alloc] initWithFrame:CGRectMake(82, 6, 200, 30)];
                uiTextField.borderStyle = UITextBorderStyleRoundedRect;
                uiTextField.returnKeyType = UIReturnKeyDone;
                uiTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [uiTextField addTarget:self action:@selector(textfieldDone) forControlEvents:UIControlEventEditingDidEndOnExit];
                self.customerNameTextField = uiTextField;
                [cell.contentView addSubview:uiTextField];
                [uiTextField release];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
                break;
            case 1:{
                UILabel *customerTypeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 70, 30)];
                customerTypeShowLabel.backgroundColor = [UIColor clearColor];
                customerTypeShowLabel.font = [UIFont systemFontOfSize:15];
                customerTypeShowLabel.text = @"乘客类型:";
                customerTypeShowLabel.textAlignment = UITextAlignmentRight;
                [cell.contentView addSubview:customerTypeShowLabel];
                [customerTypeShowLabel release];
                
                UILabel * customerTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 5, 190, 30)];
                customerTypeLabel.backgroundColor = [UIColor clearColor];
                customerTypeLabel.font = [UIFont systemFontOfSize:15];
                customerTypeLabel.text = @"成人";
                self.customerTypeShowLabel = customerTypeLabel;
                [cell.contentView addSubview:customerTypeLabel];
                [customerTypeLabel release];
                
                self.customerType = @"1";
                
                NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                UIImageView * accessoryViewTemp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                accessoryViewTemp.frame = CGRectMake(0, 0, 10, 16);
                cell.accessoryView = accessoryViewTemp;
                [accessoryViewTemp release];
            }
                break;
            case 2:{
                UILabel *certificateTypeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 70, 30)];
                certificateTypeShowLabel.backgroundColor = [UIColor clearColor];
                certificateTypeShowLabel.font = [UIFont systemFontOfSize:15];
                certificateTypeShowLabel.text = @"证件类型:";
                certificateTypeShowLabel.textAlignment = UITextAlignmentRight;
                [cell.contentView addSubview:certificateTypeShowLabel];
                [certificateTypeShowLabel release];
                
                UILabel * certificateTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 5, 190, 30)];
                certificateTypeLabel.backgroundColor = [UIColor clearColor];
                certificateTypeLabel.font = [UIFont systemFontOfSize:15];
                certificateTypeLabel.text = @"身份证";
                self.certificateTypeShowLabel = certificateTypeLabel;
                [cell.contentView addSubview:certificateTypeLabel];
                [certificateTypeLabel release];
                
                self.certificateType = @"1";
                
                NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                UIImageView * accessoryViewTemp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                accessoryViewTemp.frame = CGRectMake(0, 0, 10, 16);
                cell.accessoryView = accessoryViewTemp;
                [accessoryViewTemp release];
            }
                break;
            case 3:{
                if ([@"1" isEqualToString:self.customerType]) {
                    UILabel *certificateNOShowLabelShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 70, 30)];
                    certificateNOShowLabelShowLabel.backgroundColor = [UIColor clearColor];
                    certificateNOShowLabelShowLabel.font = [UIFont systemFontOfSize:15];
                    certificateNOShowLabelShowLabel.text = @"证件号码:";
                    certificateNOShowLabelShowLabel.textAlignment = UITextAlignmentRight;
                    [cell.contentView addSubview:certificateNOShowLabelShowLabel];
                    [certificateNOShowLabelShowLabel release];
                    
                    UITextField * uiTextField = [[UITextField alloc] initWithFrame:CGRectMake(82, 6, 200, 30)];
                    uiTextField.borderStyle = UITextBorderStyleRoundedRect;
                    uiTextField.returnKeyType = UIReturnKeyDone;
                    uiTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                    uiTextField.delegate = self;
                    [uiTextField addTarget:self action:@selector(textfieldDone) forControlEvents:UIControlEventEditingDidEndOnExit];
                    self.certificateNoTextField = uiTextField;
                    [cell.contentView addSubview:uiTextField];
                    [uiTextField release];
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                } else {
                    UILabel *customerBirthdayShowLabelShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 70, 30)];
                    customerBirthdayShowLabelShowLabel.backgroundColor = [UIColor clearColor];
                    customerBirthdayShowLabelShowLabel.font = [UIFont systemFontOfSize:15];
                    customerBirthdayShowLabelShowLabel.text = @"出生日期:";
                    customerBirthdayShowLabelShowLabel.textAlignment = UITextAlignmentRight;
                    [cell.contentView addSubview:customerBirthdayShowLabelShowLabel];
                    [customerBirthdayShowLabelShowLabel release];
                    
                    UILabel * customerBirthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 5, 190, 30)];
                    customerBirthdayLabel.backgroundColor = [UIColor clearColor];
                    customerBirthdayLabel.font = [UIFont systemFontOfSize:15];
                    customerBirthdayLabel.text = @"请选择出生日期";
                    self.customerBirthdayLabel = customerBirthdayLabel;
                    [cell.contentView addSubview:customerBirthdayLabel];
                    [customerBirthdayLabel release];
                    
                    NSString *accessoryTimeIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryTimeIndicator" inDirectory:@"CommonView/TableViewCell"];
                    UIImageView * accessoryViewTemp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryTimeIndicatorPath]];
                    accessoryViewTemp.frame = CGRectMake(0, 0, 20, 20);
                    cell.accessoryView = accessoryViewTemp;
                    [accessoryViewTemp release];
                }
            }
                break;
            case 4:{
                UILabel *secureNumShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 70, 30)];
                secureNumShowLabel.backgroundColor = [UIColor clearColor];
                secureNumShowLabel.font = [UIFont systemFontOfSize:15];
                secureNumShowLabel.text = @"保险:";
                secureNumShowLabel.textAlignment = UITextAlignmentRight;
                [cell.contentView addSubview:secureNumShowLabel];
                [secureNumShowLabel release];
                
                UILabel * secureNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 5, 190, 30)];
                secureNumLabel.backgroundColor = [UIColor clearColor];
                secureNumLabel.font = [UIFont systemFontOfSize:15];
                secureNumLabel.text = @"1份(20元/份)";
                self.secureNumShowLabel = secureNumLabel;
                [cell.contentView addSubview:secureNumLabel];
                [secureNumLabel release];
                
                self.secureNum = @"1";
                
                NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                UIImageView * accessoryViewTemp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                accessoryViewTemp.frame = CGRectMake(0, 0, 10, 16);
                cell.accessoryView = accessoryViewTemp;
                [accessoryViewTemp release];
            }
                break;
        }
    }
    
    if (indexPath.row == 0) {
        NSString *tableViewCellTopNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_top_normal" inDirectory:@"CommonView/TableViewCell"];
        NSString *tableViewCellTopHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_top_highlighted" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellTopNormalPath]] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellTopHighlightedPath]] autorelease];
    } else if(indexPath.row == [self.addTableView numberOfRowsInSection:indexPath.section]-1){
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
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.customerNameTextField resignFirstResponder];
    [self.certificateNoTextField resignFirstResponder];
    [self.addTableView setContentOffset:CGPointZero animated:YES];
    
    NSUInteger realRow = indexPath.row;
    
    if (!self.isAdult && realRow>=2) {
        realRow++;
    }
    
    switch (realRow) {
        case 1:{
            FlightCustomerTypeTableViewController *flightCustomerTypeTableViewController = [[FlightCustomerTypeTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            flightCustomerTypeTableViewController.flightCustomerAddController = self;
            [self.navigationController pushViewController:flightCustomerTypeTableViewController animated:YES];
            [flightCustomerTypeTableViewController release];
        }
            break;
        case 2:{
            FlightCertificateTypeTableViewController *flightCertificateTypeTableViewController = [[FlightCertificateTypeTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            flightCertificateTypeTableViewController.flightCustomerAddController = self;
            [self.navigationController pushViewController:flightCertificateTypeTableViewController animated:YES];
            [flightCertificateTypeTableViewController release];
        }
            break;
        case 3:{
            if (!self.isAdult) {
                NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
                formatter.dateFormat = @"yyyy-MM-dd";
                if ([self.customerBirthdayLabel.text isEqualToString:@"请选择出生日期"]) {
                    [self.datePicker setDate:[NSDate date]];//设置日期滚轮的当前显示
                } else {
                    [self.datePicker setDate:[formatter dateFromString:self.customerBirthdayLabel.text]];//设置日期滚轮的当前显示
                }
                
                self.dateBar.hidden = NO;
                self.datePicker.hidden = NO;
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                [UIView setAnimationDelegate:self];
                self.dateBar.frame = CGRectMake(0, 180, 320, 40);
                self.datePicker.frame = CGRectMake(0, 210, 320, 216);
                [UIView commitAnimations];
            }
        }
            break;
        case 4:{
            FlightSecureNumTableViewController *flightSecureNumTableViewController = [[FlightSecureNumTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            flightSecureNumTableViewController.flightCustomerAddController = self;
            [self.navigationController pushViewController:flightSecureNumTableViewController animated:YES];
            [flightSecureNumTableViewController release];
        }
            
            break;
    }
    
    [self.addTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark TextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.addTableView setContentOffset:CGPointMake(0, 142) animated:YES];
}

@end

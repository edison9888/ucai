//
//  PhoneBillRechargeViewController.m
//  UCAI
//
//  Created by  on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PhoneBillRechargeViewController.h"
#import "PhoneBillRechargePriceChoiceTableViewController.h"
#import "PhoneBillRechargeResponseModel.h"
#import "PhoneBillRechargeBookResultViewController.h"

#import "PiosaFileManager.h"
#import "CommonTools.h"
#import "GDataXMLNode.h"
#import "ASIFormDataRequest.h"
#import "StaticConf.h"
#import "ResponseParser.h"

@implementation PhoneBillRechargeViewController

@synthesize rechargeTableView = _rechargeTableView;
@synthesize phoneTextField = _phoneTextField;

- (void)dealloc {
    [self.phoneTextField release];
    [self.rechargeTableView release];
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

- (int) checkAndSaveIn{
    
    if (self.phoneTextField.text == nil||[self.phoneTextField.text length]==0) {
		return 1;
	} else {
		if (![CommonTools verifyPhoneFormat:self.phoneTextField.text]) {
			return 2;
		}
	}
    
    return 0;
}

- (NSData*)generatePhoneBillRechargeRequestPostXMLData:(NSUInteger) rechargeType{
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"rechargeType"stringValue:[NSString stringWithFormat:@"%d",rechargeType]]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"phone"stringValue:self.phoneTextField.text]];
    
    NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
    if (memberDict) {
        if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
            [conditionElement addChild:[GDataXMLNode elementWithName:@"memberID"stringValue:[memberDict objectForKey:@"memberID"]]];
        } else {
            [conditionElement addChild:[GDataXMLNode elementWithName:@"memberID"stringValue:@""]];
        }
    } else {
        [conditionElement addChild:[GDataXMLNode elementWithName:@"memberID"stringValue:@""]];
    }
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    return document.XMLData;
}

- (void)addressBookButtonPressed{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"联系" message:@"为了便捷输入您的朋友手机号码，悠行宝需要您的联系人的访问权" delegate:self cancelButtonTitle:@"不允许" otherButtonTitles:@"好的", nil];
    [alertView show];
    [alertView release];
}

#pragma mark -
#pragma mark View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	self.title = @"手机充值";
	
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
	
	UITableView * uiTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 386) style:UITableViewStyleGrouped];
	uiTableView.backgroundColor = [UIColor clearColor];
	uiTableView.dataSource = self;
	uiTableView.delegate = self;
    self.rechargeTableView = uiTableView;
	[self.view addSubview:uiTableView];
	[uiTableView release];
    
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

- (void)viewWillAppear:(BOOL)animated{
    self.rechargeTableView.contentInset = UIEdgeInsetsZero;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}


//设置表格单元的展现
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        switch (indexPath.section) {
            case 0:
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UILabel *phoneShowlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 25)];
                phoneShowlabel.backgroundColor = [UIColor clearColor];
                phoneShowlabel.text = @"手机号码:";
                [cell.contentView addSubview:phoneShowlabel];
                [phoneShowlabel release];
                
                UITextField *phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 165, 25)];
                phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                phoneTextField.borderStyle = UITextBorderStyleNone;
                phoneTextField.keyboardType = UIKeyboardTypePhonePad;
                phoneTextField.returnKeyType = UIReturnKeyDone;
                phoneTextField.placeholder = @"必填";
                NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
                NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
                if (memberDict) {
                    if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
                        phoneTextField.text = [memberDict objectForKey:@"phone"];
                    } else {
                        phoneTextField.text = @"";
                    }
                } else {
                    phoneTextField.text = @"";
                }
                phoneTextField.delegate = self;
                self.phoneTextField = phoneTextField;
                [cell.contentView addSubview:phoneTextField];
                [phoneTextField release];
                
                
                UIButton * addressBookButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 30)];
                NSString * accessoryAddressBookDisclosureButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryAddressBookDisclosureButton_normal" inDirectory:@"CommonView/TableViewCell"];
                NSString * accessoryAddressBookDisclosureButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryAddressBookDisclosureButton_highlighted" inDirectory:@"CommonView/TableViewCell"];
                [addressBookButton setBackgroundImage:[UIImage imageNamed:accessoryAddressBookDisclosureButtonNormalPath] forState:UIControlStateNormal];
                [addressBookButton setBackgroundImage:[UIImage imageNamed:accessoryAddressBookDisclosureButtonHighlightedPath] forState:UIControlStateHighlighted];
                [addressBookButton addTarget:self action:@selector(addressBookButtonPressed) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = addressBookButton;
                [addressBookButton release];
                break;
            case 1:{
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.text = @"50元";
                        break;
                    case 1:
                        cell.textLabel.text = @"100元";
                        break;
                }
                NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                UIImageView * accessoryViewTemp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                accessoryViewTemp.frame = CGRectMake(0, 0, 10, 16);
                cell.accessoryView = accessoryViewTemp;
                [accessoryViewTemp release];
            }
                break;
            case 2:{
                cell.textLabel.text = @"更多面值";
                NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                UIImageView * accessoryViewTemp2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                accessoryViewTemp2.frame = CGRectMake(0, 0, 10, 16);
                cell.accessoryView = accessoryViewTemp2;
                [accessoryViewTemp2 release];
            }
                break;
        }
	}
    
    cell.textLabel.highlightedTextColor = [PiosaColorManager themeColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    
    if ([self.rechargeTableView numberOfRowsInSection:indexPath.section] == 1) {
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
        } else if(indexPath.row == [self.rechargeTableView numberOfRowsInSection:indexPath.section]-1){
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
    switch (indexPath.section) {
        case 1:
        {   
            int check = [self checkAndSaveIn];
            
            NSString * showMes = nil;
            switch (check) {
                case 1:
                    showMes = @"您似乎还未输入手机号码";
                    break;
                case 2:
                    showMes = @"请输入有效的手机号码";
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
                [hud show:YES];
                [hud hide:YES afterDelay:2];
            }else{
                _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                _hud.bgRGB = [PiosaColorManager progressColor];
                [self.navigationController.view addSubview:_hud];
                _hud.delegate = self;
                _hud.minSize = CGSizeMake(135.f, 135.f);
                _hud.labelText = @"请稍候...";
                [_hud show:YES];
                
                switch (indexPath.row) {
                    case 0:
                        _rechargeType = 4;
                        break;
                    case 1:
                        _rechargeType = 5;
                        break;
                }
                
                
                NSString *postData = [[NSString alloc] initWithData:[self generatePhoneBillRechargeRequestPostXMLData:_rechargeType] encoding:NSUTF8StringEncoding];
                NSLog(@"requestStart\n");
                NSLog(@"%@\n", postData);
                
                ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: PHONE_BILLRECHARGE_ADDRESS]] autorelease];
                [req addRequestHeader:@"API-Version" value:API_VERSION];
                req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
                [req appendPostData:[self generatePhoneBillRechargeRequestPostXMLData:_rechargeType]];
                [req setDelegate:self];
                [req startAsynchronous]; // 执行异步post
            }
        }
            break;
            
        case 2:
        {   
            PhoneBillRechargePriceChoiceTableViewController *phoneBillRechargePriceChoiceTableViewController = [[PhoneBillRechargePriceChoiceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            phoneBillRechargePriceChoiceTableViewController.phoneBillRechargeViewController = self;
            [self.navigationController pushViewController:phoneBillRechargePriceChoiceTableViewController animated:YES];
            [phoneBillRechargePriceChoiceTableViewController release];
        }
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应 : 但可能是错误响应, 如 404，或查询结果为空，则不跳转到下一个机票展示页面
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);
    // 关闭加载框
    [_hud hide:YES];
    if ((responseString != nil) && [responseString length] > 0) {
        
		PhoneBillRechargeResponseModel *phoneBillRechargeResponseModel = [ResponseParser loadPhoneBillRechargeResponse:[request responseData]];
		
		if (phoneBillRechargeResponseModel.resultCode == nil || [phoneBillRechargeResponseModel.resultCode length] == 0 || [phoneBillRechargeResponseModel.resultCode intValue] != 0) {
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
            hud.labelText = phoneBillRechargeResponseModel.resultMessage;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
		}else {
			//修改成功
			PhoneBillRechargeBookResultViewController *phoneBillRechargeBookResultViewController = [[PhoneBillRechargeBookResultViewController alloc] initWithResponse:phoneBillRechargeResponseModel phone:self.phoneTextField.text rechargeType:_rechargeType];
            [self.navigationController pushViewController:phoneBillRechargeBookResultViewController animated:YES];
            [phoneBillRechargeBookResultViewController release];
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
#pragma mark Text Field Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.rechargeTableView setContentInset:UIEdgeInsetsMake(0, 0, 200, 0)];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate methods
// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	return YES;
}


// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    ABMultiValueRef phones = (ABMultiValueRef) ABRecordCopyValue(person, property);
    NSString *phoneNO = (NSString *)ABMultiValueCopyValueAtIndex(phones, identifier);  // 这个就是电话号码
    NSString *phone =[phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    self.phoneTextField.text = phone;
    [self dismissModalViewControllerAnimated:YES];
	return NO;
}


// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark AlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%d",buttonIndex);
    if (buttonIndex != 0) {
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = self;
        picker.navigationBar.tintColor = [PiosaColorManager barColor];
        // Display only a person's phone
        NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty], nil];
        picker.displayedProperties = displayedItems;
        // Show the picker 
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
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

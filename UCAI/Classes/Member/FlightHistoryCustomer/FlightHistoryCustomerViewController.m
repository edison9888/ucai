//
//  FlightHistoryCustomerViewController.m
//  UCAI
//
//  Created by  on 12-2-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FlightHistoryCustomerViewController.h"
#import "MemberFlightHistoryCustomerQueryResponse.h"
#import "MemberFlightHistoryCustomerDeleteResponse.h"

#import "PiosaFileManager.h"
#import "ResponseParser.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "StaticConf.h"
#import "CommonTools.h"

#define kHUDhiddenTag 101 //只需要消失提交框
#define kHUDhiddenAndPopTag 102 //需要在提交框消失后退出视图

#define numberLabelTag 201
#define guestNameLabelTag 202
#define secureNumContentLabelTag 203
#define certificateNoLabelTag 204

@implementation FlightHistoryCustomerViewController

@synthesize countLabel = _countLabel;
@synthesize customerTableView = _customerTableView;
@synthesize memberFlightHistoryCustomerQueryResponse = _memberFlightHistoryCustomerQueryResponse;
@synthesize requestType = _requestType;
@synthesize deletingRow = _deletingRow;

-(void)dealloc{
    [self.countLabel release];
    [self.customerTableView release];
    [self.memberFlightHistoryCustomerQueryResponse release];
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

- (void)editOrComplete{
    if (self.customerTableView.editing) {
        [self.customerTableView setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem.title = @"编辑";
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;
    } else {
        [self.customerTableView setEditing:YES animated:YES];
        self.navigationItem.rightBarButtonItem.title = @"完成";
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
    }
}

- (void)queryHistoryCustomers{
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"加载中...";
    _hud.tag = kHUDhiddenAndPopTag;
    [_hud show:YES];
    
    self.requestType = 1;
	
	ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: MEMBER_HISTORY_CUSTOMER_QUERY_ADDRESS]] autorelease];
	[req addRequestHeader:@"API-Version" value:API_VERSION];
	req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
	[req appendPostData:[self generateMemberFlightHistoryCustomerQueryRequestPostXMLData]];
	[req setDelegate:self];
	[req startAsynchronous]; // 执行异步post
}

- (NSData*)generateMemberFlightHistoryCustomerQueryRequestPostXMLData{
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
	
	//编辑会员资料查询请求的xml数据
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"userID" stringValue:[memberDict objectForKey:@"memberID"]]];
    [requestElement addChild:conditionElement];
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    
    NSData *xmlData = document.XMLData;
	return xmlData;
}

- (NSData*)generateMemberFlightHistoryCustomerDeleteRequestPostXMLData:(NSString *)customerId{
	//编辑会员资料查询请求的xml数据
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"passagerID" stringValue:customerId]];
    [requestElement addChild:conditionElement];
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    
    NSData *xmlData = document.XMLData;
	return xmlData;
}

#pragma mark -
#pragma mark View lifecycle


- (void)loadView {
    [super loadView];
    
	self.title = @"常用乘机人";
    
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
    
	//设置背景图片
    NSString *bgPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"background" inDirectory:@"CommonView"];
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bgPath]];
    bgImageView.frame = CGRectMake(0, 0, 320, 416);
	[self.view addSubview:bgImageView];
	[bgImageView release];
    
    //编辑按钮
    UIBarButtonItem *homeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleBordered target:self action:@selector(editOrComplete)];
    self.navigationItem.rightBarButtonItem = homeBarButtonItem;
    [homeBarButtonItem release];
    
    UILabel * countLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 100, 20)];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.font = [UIFont systemFontOfSize:15];
    self.countLabel = countLabel;
    [self.view addSubview:countLabel];
    [countLabel release];
    
    UITableView *customerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, 320, 396) style:UITableViewStylePlain];
    customerTableView.dataSource = self;
    customerTableView.delegate = self;
    self.customerTableView = customerTableView;
    [self.view addSubview:customerTableView];
    [customerTableView release];
    
    [self queryHistoryCustomers];
}

#pragma mark - UITableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.memberFlightHistoryCustomerQueryResponse.historyCustomers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentifier = @"cell";
    
    FlightHistoryCustomer* customer = (FlightHistoryCustomer *)[self.memberFlightHistoryCustomerQueryResponse.historyCustomers objectAtIndex:indexPath.row];
    
    UILabel * tempNumberLabel;
    UILabel * tempGuestNameLabel;
    UILabel * tempSecureNumContentLabel;
    UILabel * tempCertificateNoLabel;
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        NSString *numberBGPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"number_bg" inDirectory:@"CommonView"];
        UIImageView * numberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:numberBGPath]];
        numberImageView.frame = CGRectMake(5, 13, 22, 22);
        [cell.contentView addSubview:numberImageView];
        [numberImageView release];
        
        UILabel * numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 13, 20, 20)];
        numberLabel.backgroundColor = [UIColor clearColor];
        numberLabel.font = [UIFont systemFontOfSize:13];
        numberLabel.textAlignment = UITextAlignmentCenter;
        numberLabel.tag = numberLabelTag;
        tempNumberLabel = numberLabel;
        [cell.contentView addSubview:numberLabel];
        [numberLabel release];
        
        UILabel * guestNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 3, 160, 20)];
        guestNameLabel.backgroundColor = [UIColor clearColor];
        guestNameLabel.font = [UIFont systemFontOfSize:14];
        guestNameLabel.tag = guestNameLabelTag;
        tempGuestNameLabel = guestNameLabel;
        [cell.contentView addSubview:guestNameLabel];
        [guestNameLabel release];
        
        UILabel * secureNumContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 3, 80, 20)];
        secureNumContentLabel.backgroundColor = [UIColor clearColor];
        secureNumContentLabel.font = [UIFont systemFontOfSize:14];
        secureNumContentLabel.tag = secureNumContentLabelTag;
        tempSecureNumContentLabel = secureNumContentLabel;
        [cell.contentView addSubview:secureNumContentLabel];
        [secureNumContentLabel release];
        
        UILabel * certificateNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 23, 270, 20)];
        certificateNoLabel.backgroundColor = [UIColor clearColor];
        certificateNoLabel.textColor = [UIColor grayColor];
        certificateNoLabel.font = [UIFont systemFontOfSize:13];
        certificateNoLabel.tag = certificateNoLabelTag;
        tempCertificateNoLabel = certificateNoLabel;
        [cell.contentView addSubview:certificateNoLabel];
        [certificateNoLabel release];
    }else{
        tempNumberLabel = (UILabel *)[cell.contentView viewWithTag:numberLabelTag];
        tempGuestNameLabel = (UILabel *)[cell.contentView viewWithTag:guestNameLabelTag];
        tempSecureNumContentLabel = (UILabel *)[cell.contentView viewWithTag:secureNumContentLabelTag];
        tempCertificateNoLabel = (UILabel *)[cell.contentView viewWithTag:certificateNoLabelTag];
    }
    
    tempNumberLabel.text = [NSString stringWithFormat:@"%d",indexPath.row+1];
    
    if ([@"1" isEqualToString:customer.customerType]) {
        tempGuestNameLabel.text = [NSString stringWithFormat:@"%@:(成人)",customer.customerName];
    } else if ([@"2" isEqualToString:customer.customerType]) {
        tempGuestNameLabel.text = [NSString stringWithFormat:@"%@:(儿童)",customer.customerName];
    } else if ([@"3" isEqualToString:customer.customerType]) {
        tempGuestNameLabel.text = [NSString stringWithFormat:@"%@:(婴儿)",customer.customerName];
    }
    
    tempSecureNumContentLabel.text = [NSString stringWithFormat:@"保险:%@份",customer.secureNum];
    
    if ([@"1" isEqualToString:customer.customerType]) {
        if ([@"1" isEqualToString:customer.certificateType]) {
            tempCertificateNoLabel.text = [NSString stringWithFormat:@"身份证:%@",customer.certificateNo];
        } else if ([@"2" isEqualToString:customer.certificateType]) {
            tempCertificateNoLabel.text = [NSString stringWithFormat:@"军官证:%@",customer.certificateNo];
        } else if ([@"3" isEqualToString:customer.certificateType]) {
            tempCertificateNoLabel.text = [NSString stringWithFormat:@"港澳通行证:%@",customer.certificateNo];
        } else if ([@"4" isEqualToString:customer.certificateType]) {
            tempCertificateNoLabel.text = [NSString stringWithFormat:@"护照:%@",customer.certificateNo];
        } else if ([@"5" isEqualToString:customer.certificateType]) {
            tempCertificateNoLabel.text = [NSString stringWithFormat:@"台胞证:%@",customer.certificateNo];
        } else if ([@"6" isEqualToString:customer.certificateType]) {
            tempCertificateNoLabel.text = [NSString stringWithFormat:@"士兵证:%@",customer.certificateNo];
        } else if ([@"7" isEqualToString:customer.certificateType]) {
            tempCertificateNoLabel.text = [NSString stringWithFormat:@"回乡证:%@",customer.certificateNo];
        } else if ([@"8" isEqualToString:customer.certificateType]) {
            tempCertificateNoLabel.text = [NSString stringWithFormat:@"其他:%@",customer.certificateNo];
        } 
    } else {
        tempCertificateNoLabel.text = [NSString stringWithFormat:@"出生日期:%@",customer.certificateNo];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"删除中...";
    _hud.tag = kHUDhiddenTag;
    [_hud show:YES];
    
    self.requestType = 2;
    
    FlightHistoryCustomer* customer = (FlightHistoryCustomer *)[self.memberFlightHistoryCustomerQueryResponse.historyCustomers objectAtIndex:indexPath.row];
	
	ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: MEMBER_HISTORY_CUSTOMER_DELETE_ADDRESS]] autorelease];
	[req addRequestHeader:@"API-Version" value:API_VERSION];
	req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
	[req appendPostData:[self generateMemberFlightHistoryCustomerDeleteRequestPostXMLData:customer.customerID]];
	[req setDelegate:self];
	[req startAsynchronous]; // 执行异步post
    
    self.deletingRow = indexPath.row;
}

#pragma mark - UITableView Delegate

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"完成");
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark -
#pragma mark ASIHTTP Response

- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);
	
    // 关闭加载框
    [_hud hide:YES];
	switch (self.requestType) {
		case 1:{
			//查询历史乘机人
			if ((responseString != nil) && [responseString length] > 0) {
				MemberFlightHistoryCustomerQueryResponse *memberFlightHistoryCustomerQueryResponse = [ResponseParser loadMemberFlightHistoryCustomerQueryResponse:[request responseData]];
				
				if (memberFlightHistoryCustomerQueryResponse.resultCode == nil || [memberFlightHistoryCustomerQueryResponse.resultCode length] == 0 || [memberFlightHistoryCustomerQueryResponse.resultCode intValue] != 0) {
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
                    hud.labelText = memberFlightHistoryCustomerQueryResponse.resultMessage;
                    hud.tag = kHUDhiddenAndPopTag;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
				} else {
					//查询成功
                    _hud.tag = kHUDhiddenTag;
                    
                    self.countLabel.text = [NSString stringWithFormat:@"%d条纪录",[memberFlightHistoryCustomerQueryResponse.historyCustomers count]];
					self.memberFlightHistoryCustomerQueryResponse = memberFlightHistoryCustomerQueryResponse;
                    [self.customerTableView reloadData];
				}
			}
		}
			break;
		case 2:{
			//删除历史乘机人
            if ((responseString != nil) && [responseString length] > 0) {
				MemberFlightHistoryCustomerDeleteResponse *memberFlightHistoryCustomerDeleteResponse = [ResponseParser loadMemberFlightHistoryCustomerDeleteResponse:[request responseData]];
				
				if (memberFlightHistoryCustomerDeleteResponse.resultCode == nil || [memberFlightHistoryCustomerDeleteResponse.resultCode length] == 0 || [memberFlightHistoryCustomerDeleteResponse.resultCode intValue] != 0) {
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
                    hud.labelText = memberFlightHistoryCustomerDeleteResponse.resultMessage;
                    hud.tag = kHUDhiddenTag;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
				} else {
					//查询成功
                    _hud.tag = kHUDhiddenTag;
                    
                    [self.memberFlightHistoryCustomerQueryResponse.historyCustomers removeObjectAtIndex:self.deletingRow];
                    self.countLabel.text = [NSString stringWithFormat:@"%d条纪录",[self.memberFlightHistoryCustomerQueryResponse.historyCustomers count]];
                    [self.customerTableView reloadData];
				}
			}
		}
			break;
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

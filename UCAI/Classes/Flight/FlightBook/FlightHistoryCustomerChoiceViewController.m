//
//  FlightHistoryCustomerChoiceViewController.m
//  UCAI
//
//  Created by  on 12-2-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "FlightHistoryCustomerChoiceViewController.h"

#import "FlightBookViewController.h"
#import "MemberFlightHistoryCustomerQueryResponse.h"
#import "MemberFlightHistoryCustomerDeleteResponse.h"
#import "FlightCustomer.h"

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

@implementation FlightHistoryCustomerChoiceViewController

@synthesize countLabel = _countLabel;
@synthesize customerTableView = _customerTableView;
@synthesize memberFlightHistoryCustomerQueryResponse = _memberFlightHistoryCustomerQueryResponse;
@synthesize flightBookViewController = _flightBookViewController;

- (FlightHistoryCustomerChoiceViewController *)initWithMaxChoiceCount:(NSUInteger)maxCount{
    self = [super init];
    _maxCount = maxCount;
    return self;
}

-(void)dealloc{
    [_selectedRowArray release];
    [self.countLabel release];
    [self.customerTableView release];
    [self.memberFlightHistoryCustomerQueryResponse release];
    [self.flightBookViewController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom

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
    
    for (NSNumber * row in _selectedRowArray) {
        FlightHistoryCustomer* customer = (FlightHistoryCustomer *)[self.memberFlightHistoryCustomerQueryResponse.historyCustomers objectAtIndex:[row intValue]];
        
        FlightCustomer * flightCustomer = [[FlightCustomer alloc] init];
		flightCustomer.customerName = customer.customerName;
		flightCustomer.customerType = customer.customerType;
        flightCustomer.certificateType = customer.certificateType;
        flightCustomer.certificateNo = customer.certificateNo;
        flightCustomer.secureNum = customer.secureNum;
		[self.flightBookViewController.customers addObject:flightCustomer];
		[flightCustomer release];
    }
    
    CATransition *transition = [CATransition animation];
    transition.delegate = self; 
    transition.duration = 0.5f;//间隔时间
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];//动画的开始与结束的快慢
    transition.type = kCATransitionReveal; // 各种动画效果
    transition.subtype = kCATransitionFromBottom;// 动画方向
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
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

#pragma mark -
#pragma mark View lifecycle


- (void)loadView {
    [super loadView];
    
	self.title = @"选择乘机人";
    
	//保存旅客铵钮的设置
	UIBarButtonItem *saveGuestButton = [[UIBarButtonItem alloc]
                                        initWithTitle:@"确定" 
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
    
    NSMutableArray *selectedRowArray = [[NSMutableArray alloc] init];
    _selectedRowArray = selectedRowArray;
    [_selectedRowArray retain];
    [selectedRowArray release];
    
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
    
    NSString *tableViewCellPlainHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_plain_highlighted" inDirectory:@"CommonView/TableViewCell"];
    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellPlainHighlightedPath]] autorelease];
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell * selectedCell = [self.customerTableView cellForRowAtIndexPath:indexPath];
    
    if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        selectedCell.accessoryType = UITableViewCellAccessoryNone;
        [_selectedRowArray removeObject:[NSNumber numberWithInt:indexPath.row]];
    } else {
        if ([_selectedRowArray count] < _maxCount) {
            selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
            [_selectedRowArray addObject:[NSNumber numberWithInt:indexPath.row]];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        CATransition *transition = [CATransition animation];
        transition.delegate = self; 
        transition.duration = 0.5f;//间隔时间
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];//动画的开始与结束的快慢
        transition.type = kCATransitionReveal; // 各种动画效果
        transition.subtype = kCATransitionFromBottom;// 动画方向
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    [hud release];
	hud = nil;
}

@end


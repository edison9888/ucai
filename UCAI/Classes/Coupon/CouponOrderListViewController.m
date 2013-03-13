//
//  CouponOrderListViewController.m
//  UCAI
//
//  Created by  on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CouponOrderListViewController.h"
#import "CommonTools.h"
#import "GDataXMLNode.h"
#import "ASIFormDataRequest.h"
#import "StaticConf.h"
#import "ResponseParser.h"
#import "EGORefreshTableHeaderView.h"
#import "CouponOrderInfoViewController.h"

#import "PiosaFileManager.h"

#define kHeightForTableCell 83

#define kCouponNameLabelTag 101
#define kCouponOrderIDLabelTag 102
#define kCouponAmountLabelTag 103
#define kIsPayLabelTag 104
#define kPayPriceShowLabelTag 105
#define kPayPriceLabelTag 106

#define kHUDhiddenTag 201 //只需要消失提交框
#define kHUDhiddenAndPopTag 202 //需要在提交框消失后退出视图

@implementation CouponOrderListViewController

@synthesize couponOrderListCountLabel = _couponOrderListCountLabel;
@synthesize couponOrderListTableView = _couponOrderListTableView;
@synthesize req = _req;
@synthesize couponOrderListSearchResponseModel = _couponOrderListSearchResponseModel;

@synthesize requestType = _requestType;

- (void)dealloc{
    [_couponOrderListCountLabel release];
    [_couponOrderListTableView release];
    
    _refreshHeaderView=nil;
    if (![self.req isFinished]) {//异步请求未完成时
		[self.req clearDelegatesAndCancel];
		//ASIHTTPRequest在1.8版本前没有以上的clearDelegatesAndCancel方法，可使用以下的语句替换
		//self.req.delegate = nil;
		//[self.req cancel];
	}
    [self.req release];
    
    [_couponOrderListSearchResponseModel release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)loadView{
    [super loadView];
	
    self.title = @"我的优惠劵";
    
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
    
    UIView * secondTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    secondTitleView.backgroundColor = [PiosaColorManager secondTitleColor];
    UILabel * couponOrderListCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(200 , 0, 120 ,24)];
    couponOrderListCountLabel.backgroundColor = [UIColor clearColor];
    couponOrderListCountLabel.textAlignment = UITextAlignmentRight;
    couponOrderListCountLabel.textColor = [UIColor whiteColor];
    couponOrderListCountLabel.font = [UIFont systemFontOfSize:15];
    self.couponOrderListCountLabel = couponOrderListCountLabel;
    [secondTitleView addSubview:couponOrderListCountLabel];
    [couponOrderListCountLabel release];
    [self.view addSubview:secondTitleView];
    [secondTitleView release];
    
    UITableView * uiTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 24, 320, 392) style:UITableViewStylePlain];
    uiTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	uiTableView.dataSource = self;
	uiTableView.delegate = self;
    self.couponOrderListTableView = uiTableView;
	[self.view addSubview:uiTableView];
    [uiTableView release];
    
    //拉动刷新框
	if (_refreshHeaderView == nil) { 
        EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, kHeightForTableCell*5, 320, 70)]; //拉动刷新框的初始化位置y坐标是在默认查出的6条数据列表下
		view1.delegate = self; 
        [self.couponOrderListTableView addSubview:view1]; 
		//则隐藏拉动刷新框
		[view1 setHidden:YES];
        _refreshHeaderView = view1; 
        [view1 release]; 
    } 
    [_refreshHeaderView refreshLastUpdatedDate];

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
    
    if (![self.req isFinished]) {
        NSLog(@"self.req is Finished");
        [self.req clearDelegatesAndCancel]; //取消可能存在的请求
    } else {
        NSLog(@"self.req is not Finished");
    }
    
    self.requestType = 1;
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: COUPON_ORDERLIST_ADDRESS]] ;
    request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    
    [request appendPostData:[self generateCouponOrderListSearchRequestPostXMLData:@"1"]];
    NSString *postData = [[NSString alloc] initWithData:[self generateCouponOrderListSearchRequestPostXMLData:@"1"] encoding:NSUTF8StringEncoding];
    NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    
    [request setDelegate:self];
    [request startAsynchronous]; // 执行异步post
    self.req = request;
    [request release];
    [postData release];
    
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

- (NSData*)generateCouponOrderListSearchRequestPostXMLData:(NSString *) pageIndex{
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
    
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *pageInfoElement = [GDataXMLElement elementWithName:@"pageInfo"];
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"currentPage" stringValue:pageIndex]];
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"pageSize" stringValue:@"10"]];
    [requestElement addChild:pageInfoElement];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"memberID"stringValue:[memberDict objectForKey:@"memberID"]]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"type"stringValue:@"0"]];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    return document.XMLData;
}

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应 : 但可能是错误响应, 如 404，或查询结果为空
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);

    if ((responseString != nil) && [responseString length] > 0) {
        switch (_requestType) {
            case 1:{//刷新列表
                [_hud hide:YES];
                CouponOrderListSearchResponseModel *couponOrderListSearchResponseModel = [ResponseParser loadCouponOrderListSearchResponse:[request responseData] oldCouponList:nil];
                
                if (couponOrderListSearchResponseModel.resultCode == nil || [couponOrderListSearchResponseModel.resultCode length] == 0 || [couponOrderListSearchResponseModel.resultCode intValue] != 0) {
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
                    hud.labelText = couponOrderListSearchResponseModel.resultMessage;
                    hud.tag = kHUDhiddenAndPopTag;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    self.couponOrderListSearchResponseModel = couponOrderListSearchResponseModel;
                    self.couponOrderListCountLabel.text = [NSString stringWithFormat:@"%@个结果",couponOrderListSearchResponseModel.count];
                    [self.couponOrderListTableView reloadData];
                    
                    self.couponOrderListTableView.contentOffset = CGPointMake(0, 0);//列表回顶部
                    
                    //设置拉动刷新框
                    int numberOfRowForList = self.couponOrderListSearchResponseModel.couponOrderArray == nil ? 0 : [self.couponOrderListSearchResponseModel.couponOrderArray count];
                    [_refreshHeaderView setFrame:CGRectMake(0, kHeightForTableCell*numberOfRowForList, 320, 70)];//重设拉动刷新框的位置
                    
                    if ([self.couponOrderListSearchResponseModel.pageSize intValue]*[self.couponOrderListSearchResponseModel.currentPage intValue]>=[self.couponOrderListSearchResponseModel.count intValue]) {
                        //如果当前页为最后一页，则隐藏拉动刷新框
                        [_refreshHeaderView setHidden:YES];
                    } else {
                        //如果当前页不为最后一页，则显示拉动刷新框
                        [_refreshHeaderView setHidden:NO];
                    }
                }
            }
                break;
            case 2:{//加载列表
                CouponOrderListSearchResponseModel *couponOrderListSearchResponseModel = [ResponseParser loadCouponOrderListSearchResponse:[request responseData] oldCouponList:self.couponOrderListSearchResponseModel];
                
                if (couponOrderListSearchResponseModel.resultCode == nil || [couponOrderListSearchResponseModel.resultCode length] == 0 || [couponOrderListSearchResponseModel.resultCode intValue] != 0) {
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
                    hud.labelText = couponOrderListSearchResponseModel.resultMessage;
                    hud.tag = kHUDhiddenTag;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    self.couponOrderListSearchResponseModel = couponOrderListSearchResponseModel;
                    [_refreshHeaderView setHidden:TRUE];//隐藏拉动刷新框，因为当加载速度很快时，拉动刷新框在doneLoadingTableViewData里调整位置前，已经显示出了hotelListTableView的新数据
                    [self.couponOrderListTableView reloadData];  
                }
                [self doneLoadingTableViewData]; //加载完成数据，修改拉动刷新框的位置与其它参数
                
            }
                break;
        }
    }
}

// 网络无响应
- (void)requestFailed:(ASIFormDataRequest *)request
{
	// 提示用户打开网络联接
    if (_requestType == 2) {
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _hud.bgRGB = [PiosaColorManager progressColor];
        [self.navigationController.view addSubview:_hud];
        _hud.delegate = self;
        _hud.minSize = CGSizeMake(135.f, 135.f);
        NSString *badFaceImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"badFace" inDirectory:@"CommonView/ProgressView"];
        UIImageView *badFaceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:badFaceImagePath]];
        badFaceImageView.frame = CGRectMake(0, 0, 37, 37);
        _hud.customView = badFaceImageView;
        [badFaceImageView release];
        _hud.mode = MBProgressHUDModeCustomView;
        _hud.labelText = @"网络连接失败啦";
        _hud.tag = kHUDhiddenTag;
        [_hud show:YES];
        [_hud hide:YES afterDelay:3];
    } else {
        NSString *badFaceImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"badFace" inDirectory:@"CommonView/ProgressView"];
        UIImageView *badFaceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:badFaceImagePath]];
        badFaceImageView.frame = CGRectMake(0, 0, 37, 37);
        _hud.customView = badFaceImageView;
        [badFaceImageView release];
        _hud.mode = MBProgressHUDModeCustomView;
        _hud.labelText = @"网络连接失败啦";
        _hud.tag = kHUDhiddenAndPopTag;
        [_hud hide:YES afterDelay:3];
    }
    
    [self doneLoadingTableViewData]; //加载完成数据，修改拉动刷新框的位置与其它参数
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.couponOrderListSearchResponseModel == nil) {
        return 0;
    }else{
        return [self.couponOrderListSearchResponseModel.couponOrderArray count];
    }
}

//设置表格单元的展现
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell"];
    
    CouponOrderListInfoModel * couponOrderListInfoModel = [self.couponOrderListSearchResponseModel.couponOrderArray objectAtIndex:indexPath.row];
    
    UILabel *tempCouponNameLabel;
    UILabel *tempCouponOrderIDLabel;
    UILabel *tempCouponAmountLabel;
    UILabel *tempIsPayLabel;
    UILabel *tempPayPriceShowLabel;
    UILabel *tempPayPriceLabel;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        UILabel *couponNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 170, 15)];
        couponNameLabel.backgroundColor = [UIColor clearColor];
        couponNameLabel.tag = kCouponNameLabelTag;
        couponNameLabel.font = [UIFont systemFontOfSize:15];
        tempCouponNameLabel = couponNameLabel;
        [cell.contentView addSubview:couponNameLabel];
        [couponNameLabel release];
        
        UILabel *couponOrderIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 170, 15)];
        couponOrderIDLabel.backgroundColor = [UIColor clearColor];
        couponOrderIDLabel.tag = kCouponOrderIDLabelTag;
        couponOrderIDLabel.font = [UIFont systemFontOfSize:14];
        couponOrderIDLabel.textColor = [PiosaColorManager fontColor];
        tempCouponOrderIDLabel = couponOrderIDLabel;
        [cell.contentView addSubview:couponOrderIDLabel];
        [couponOrderIDLabel release];
        
        UILabel *couponAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, 170, 15)];
        couponAmountLabel.backgroundColor = [UIColor clearColor];
        couponAmountLabel.tag = kCouponAmountLabelTag;
        couponAmountLabel.font = [UIFont systemFontOfSize:14];
        couponAmountLabel.textColor = [UIColor grayColor];
        tempCouponAmountLabel = couponAmountLabel;
        [cell.contentView addSubview:couponAmountLabel];
        [couponAmountLabel release];
        
        UILabel *isPayLabel = [[UILabel alloc] initWithFrame:CGRectMake(255, 45, 45, 15)];
        isPayLabel.backgroundColor = [UIColor clearColor];
        isPayLabel.tag = kIsPayLabelTag;
        isPayLabel.font = [UIFont systemFontOfSize:14];
        isPayLabel.textColor = [UIColor grayColor];
        tempIsPayLabel = isPayLabel;
        [cell.contentView addSubview:isPayLabel];
        [isPayLabel release];
        
        UILabel *payPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 65, 90, 15)];
        payPriceShowLabel.backgroundColor = [UIColor clearColor];
        payPriceShowLabel.tag = kPayPriceShowLabelTag;
        payPriceShowLabel.font = [UIFont systemFontOfSize:14];
        payPriceShowLabel.textColor = [UIColor grayColor];
        payPriceShowLabel.text = @"支付总额";
        tempPayPriceShowLabel = payPriceShowLabel;
        [cell.contentView addSubview:payPriceShowLabel];
        [payPriceShowLabel release];
        
        UILabel *payPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 65, 90, 15)];
        payPriceLabel.backgroundColor = [UIColor clearColor];
        payPriceLabel.tag = kPayPriceLabelTag;
        payPriceLabel.font = [UIFont systemFontOfSize:14];
        payPriceLabel.textColor = [UIColor redColor];
        payPriceLabel.textAlignment = UITextAlignmentRight;
        tempPayPriceLabel = payPriceLabel;
        [cell.contentView addSubview:payPriceLabel];
        [payPriceLabel release];
        
	} else {
        tempCouponNameLabel = (UILabel *)[cell.contentView viewWithTag:kCouponNameLabelTag];
        tempCouponOrderIDLabel = (UILabel *)[cell.contentView viewWithTag:kCouponOrderIDLabelTag];
        tempCouponAmountLabel = (UILabel *)[cell.contentView viewWithTag:kCouponAmountLabelTag];
        tempIsPayLabel = (UILabel *)[cell.contentView viewWithTag:kIsPayLabelTag];
        tempPayPriceShowLabel = (UILabel *)[cell.contentView viewWithTag:kPayPriceShowLabelTag];
        tempPayPriceLabel = (UILabel *)[cell.contentView viewWithTag:kPayPriceLabelTag];
    }
    
    tempCouponNameLabel.text = couponOrderListInfoModel.couponName;
    tempCouponOrderIDLabel.text = couponOrderListInfoModel.orderID;
    tempCouponAmountLabel.text = [NSString stringWithFormat:@"优惠劵数量%@张",couponOrderListInfoModel.couponAmount];
    
    if ([@"0" isEqualToString:couponOrderListInfoModel.payPrice]||[@"0.0" isEqualToString:couponOrderListInfoModel.payPrice]||[@"0.00" isEqualToString:couponOrderListInfoModel.payPrice]) {
        tempIsPayLabel.text = @"";
        tempPayPriceShowLabel.hidden = YES;
        tempPayPriceLabel.text = @"免费";
    } else {
        if ([@"0" isEqualToString:couponOrderListInfoModel.isPay]) {
            tempIsPayLabel.text = @"未支付";
        } else if ([@"1" isEqualToString:couponOrderListInfoModel.isPay]){
            tempIsPayLabel.text = @"已支付";
        }
        tempPayPriceShowLabel.hidden = NO;
        tempPayPriceLabel.text = [NSString stringWithFormat:@"¥%@",couponOrderListInfoModel.payPrice];
    }
    
    NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
    UIImageView * accessoryViewTemp1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
    accessoryViewTemp1.frame = CGRectMake(0, 0, 10, 16);
    cell.accessoryView = accessoryViewTemp1;
    [accessoryViewTemp1 release];
    
    if ((indexPath.row+1)%2 == 0) {
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [PiosaColorManager tableViewPlainSepColor];
        cell.backgroundView = bgView;
        [bgView release];
    }  else  {
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = bgView;
        [bgView release];
    } 
    
    NSString *tableViewCellPlainHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_plain_highlighted" inDirectory:@"CommonView/TableViewCell"];
    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellPlainHighlightedPath]] autorelease];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return kHeightForTableCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.couponOrderListSearchResponseModel != nil&&[self.couponOrderListSearchResponseModel.couponOrderArray count]<=4) {
        //如果显示的房型不超出显示框，则通过添加footer来去除多出来的空cell
        UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)] autorelease];
        footer.backgroundColor = [UIColor clearColor];
        return footer;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CouponOrderListInfoModel * couponOrderListInfoModel = [self.couponOrderListSearchResponseModel.couponOrderArray objectAtIndex:indexPath.row];
    
    CouponOrderInfoViewController *couponOrderInfoViewController = [[CouponOrderInfoViewController alloc] initWithOrderId:couponOrderListInfoModel.orderID];
    [self.navigationController pushViewController:couponOrderInfoViewController animated:YES];
    [couponOrderInfoViewController release];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{ 
    NSLog(@"==开始加载数据"); 
    _reloading = YES; 
}

- (void)doneLoadingTableViewData{ 
    NSLog(@"===加载完数据"); 
    _reloading = NO; 
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.couponOrderListTableView];
	
	[_refreshHeaderView setFrame:CGRectMake(0, self.couponOrderListTableView.contentSize.height, 320, 70)];//调整拉动刷新框的位置，使其位于刷新后的列表下
	if ([self.couponOrderListSearchResponseModel.pageSize intValue]*[self.couponOrderListSearchResponseModel.currentPage intValue]>=[self.couponOrderListSearchResponseModel.count intValue]) {
        //如果当前页为最后一页，则隐藏拉动刷新框
        [_refreshHeaderView setHidden:YES];
    } else {
        //如果当前页不为最后一页，则显示拉动刷新框
        [_refreshHeaderView setHidden:NO];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods 
//手指屏幕上不断拖动时调用此方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{ 
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView]; 
}

//当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{     
    //停止拖动订单列表时
    if ([self.couponOrderListSearchResponseModel.pageSize intValue]*[self.couponOrderListSearchResponseModel.currentPage intValue]<[self.couponOrderListSearchResponseModel.count intValue]) {
        //显示最后一页时，可以不用调用方法来设置刷新视图
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView]; 
    }
} 

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource]; //开始加载数据
    
    self.requestType = 2;
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: COUPON_ORDERLIST_ADDRESS]] ;
    request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    
    NSInteger index = [self.couponOrderListSearchResponseModel.currentPage intValue]+1;
    [request appendPostData:[self generateCouponOrderListSearchRequestPostXMLData:[NSString stringWithFormat:@"%d",index]]];
    [request setDelegate:self];
    [request startAsynchronous]; // 执行异步post
    self.req = request;
    [request release];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading; 
} 
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];     
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

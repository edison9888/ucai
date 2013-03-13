//
//  CouponFreeListViewController.m
//  UCAI
//
//  Created by  on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CouponListViewController.h"

#import "CommonTools.h"
#import "GDataXMLNode.h"
#import "ASIFormDataRequest.h"
#import "StaticConf.h"
#import "ResponseParser.h"
#import "CouponListSearchResponseModel.h"
#import "CouponListInfoModel.h"

#import "UIHTTPImageView.h"

#import "EGORefreshTableHeaderView.h"

#import "CouponInfoViewController.h"

#import "PiosaFileManager.h"

#define kHeightForTableCell 103

#define kCouponNameLabelTag 101
#define kCouponPriceLabelTag 102
#define kCouponPopularityLabelTag 103
#define kCouponTypeLabelTag 104
#define kCouponEndTimeLabelTag 105
#define kCouponSellPriceLabelTag 106
#define kCouponImageViewTag 107

#define kHUDhiddenTag 201 //只需要消失提交框
#define kHUDhiddenAndPopTag 202 //需要在提交框消失后退出视图

@implementation CouponListViewController

@synthesize couponListCountLabel = _couponListCountLabel;
@synthesize couponListTableView = _couponListTableView;
@synthesize req = _req;
@synthesize couponListSearchResponseModel = _couponListSearchResponseModel;

@synthesize requestType = _requestType;

#pragma mark - init
- (CouponListViewController *)initWithCouponType:(NSUInteger) couponListType{
    self = [super init];
    _couponListType = couponListType;
    return self;
}

- (void)dealloc{
    [_couponListCountLabel release];
    [_couponListTableView release];
    
    _refreshHeaderView=nil;
    if (![self.req isFinished]) {//异步请求未完成时
		[self.req clearDelegatesAndCancel];
		//ASIHTTPRequest在1.8版本前没有以上的clearDelegatesAndCancel方法，可使用以下的语句替换
		//self.req.delegate = nil;
		//[self.req cancel];
	}
    [self.req release];
    
    [_couponListSearchResponseModel release];
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


- (NSData*)generateCouponListSearchRequestPostXMLData:(NSString *) pageIndex {
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *pageInfoElement = [GDataXMLElement elementWithName:@"pageInfo"];
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"currentPage" stringValue:pageIndex]];
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"pageSize" stringValue:@"4"]];
    [requestElement addChild:pageInfoElement];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"couponType"stringValue:[NSString stringWithFormat:@"%d",_couponListType]]];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    return document.XMLData;
}

#pragma mark - View lifecycle

- (void)loadView {
	[super loadView];
	
    switch (_couponListType) {
        case 1:
            self.title = @"免费优惠劵";
            break;
        case 2:
            self.title = @"购买优惠劵";
            break;
    }
	
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
    UILabel * couponListCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(200 , 0, 120 ,24)];
    couponListCountLabel.backgroundColor = [UIColor clearColor];
    couponListCountLabel.textAlignment = UITextAlignmentRight;
    couponListCountLabel.textColor = [UIColor whiteColor];
    couponListCountLabel.font = [UIFont systemFontOfSize:15];
    self.couponListCountLabel = couponListCountLabel;
    [secondTitleView addSubview:couponListCountLabel];
    [couponListCountLabel release];
    [self.view addSubview:secondTitleView];
    [secondTitleView release];
    
	UITableView * uiTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 24, 320, 392) style:UITableViewStylePlain];
    uiTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	uiTableView.dataSource = self;
	uiTableView.delegate = self;
    self.couponListTableView = uiTableView;
	[self.view addSubview:uiTableView];
    [uiTableView release];
    
    //拉动刷新框
	if (_refreshHeaderView == nil) { 
        EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, kHeightForTableCell*4, 320, 70)]; //拉动刷新框的初始化位置y坐标是在默认查出的4条数据列表下
		view1.delegate = self; 
        [self.couponListTableView addSubview:view1]; 
		//则隐藏拉动刷新框
		//[view1 setHidden:YES];
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
        //[self doneLoadingTableViewData:_hotelRefreshHeaderView]; //取消加载完成数据，修改拉动刷新框的位置与其它参数
    } else {
        NSLog(@"self.req is not Finished");
    }
    
    self.requestType = 1;
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: COUPON_LIST_ADDRESS]] ;
    request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    
    [request appendPostData:[self generateCouponListSearchRequestPostXMLData:@"1"]];
    NSString *postData = [[NSString alloc] initWithData:[self generateCouponListSearchRequestPostXMLData:@"1"] encoding:NSUTF8StringEncoding];
    NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    
    [request setDelegate:self];
    [request startAsynchronous]; // 执行异步post
    self.req = request;
    [request release];
    [postData release];
}

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应 : 但可能是错误响应, 如 404，或查询结果为空，则不跳转到下一个机票展示页面
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);
    if ((responseString != nil) && [responseString length] > 0) {
        switch (_requestType) {
            case 1:{//刷新列表
                [_hud hide:YES];
                CouponListSearchResponseModel *couponListSearchResponseModel = [ResponseParser loadCouponListSearchResponse:[request responseData] oldCouponList:nil];
                
                if (couponListSearchResponseModel.resultCode == nil || [couponListSearchResponseModel.resultCode length] == 0 || [couponListSearchResponseModel.resultCode intValue] != 0) {
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
                    hud.labelText = couponListSearchResponseModel.resultMessage;
                    hud.tag = kHUDhiddenAndPopTag;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    self.couponListSearchResponseModel = couponListSearchResponseModel;
                    self.couponListCountLabel.text = [NSString stringWithFormat:@"%@个结果",couponListSearchResponseModel.count];
                    [self.couponListTableView reloadData];
                    
                    self.couponListTableView.contentOffset = CGPointMake(0, 0);//列表回顶部
                    
                    //设置拉动刷新框
                    int numberOfRowForHotelList = self.couponListSearchResponseModel.couponArray == nil ? 0 : [self.couponListSearchResponseModel.couponArray count];
                    [_refreshHeaderView setFrame:CGRectMake(0, kHeightForTableCell*numberOfRowForHotelList, 320, 70)];//重设拉动刷新框的位置
                    
                    if ([self.couponListSearchResponseModel.pageSize intValue]*[self.couponListSearchResponseModel.currentPage intValue]>=[self.couponListSearchResponseModel.count intValue]) {
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
                CouponListSearchResponseModel *couponListSearchResponseModel = [ResponseParser loadCouponListSearchResponse:[request responseData] oldCouponList:self.couponListSearchResponseModel];
                
                if (couponListSearchResponseModel.resultCode == nil || [couponListSearchResponseModel.resultCode length] == 0 || [couponListSearchResponseModel.resultCode intValue] != 0) {
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
                    hud.labelText = couponListSearchResponseModel.resultMessage;
                    hud.tag = kHUDhiddenTag;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    self.couponListSearchResponseModel = couponListSearchResponseModel;
                    [_refreshHeaderView setHidden:TRUE];//隐藏拉动刷新框，因为当加载速度很快时，拉动刷新框在doneLoadingTableViewData里调整位置前，已经显示出了hotelListTableView的新数据
                    [self.couponListTableView reloadData];  
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
    if (self.couponListSearchResponseModel == nil) {
        return 0;
    }else{
        return [self.couponListSearchResponseModel.couponArray count];
    }
}

//设置表格单元的展现
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d",indexPath.row];
    
    UIHTTPImageView *tempCouponImageView;
    UILabel *tempCouponNameLabel;
    UILabel *tempCouponPriceLabel;
    UILabel *tempCouponPopularityLabel;
    UILabel *tempCouponTypeLabel;
    UILabel *tempCouponEndTimeLabel;
    UILabel *tempCouponSellPriceLabel;
    
    CouponListInfoModel * couponListInfoModel = [self.couponListSearchResponseModel.couponArray objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        UIHTTPImageView *uiHTTPImageView = [[UIHTTPImageView alloc] initWithFrame:CGRectMake(10, 5, 100, 74)];
        uiHTTPImageView.backgroundColor = [UIColor clearColor];
        uiHTTPImageView.tag = kCouponImageViewTag;
        NSString *imageLoadingPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"image_loading" inDirectory:@"Hotel"];
        [uiHTTPImageView setImageWithURL:[NSURL URLWithString:couponListInfoModel.couponImage] placeholderImage:[UIImage imageNamed:imageLoadingPath]];
        tempCouponImageView = uiHTTPImageView;
		[cell.contentView addSubview:uiHTTPImageView];
		[uiHTTPImageView release];
        
        UILabel *couponNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 5, 170, 15)];
        couponNameLabel.backgroundColor = [UIColor clearColor];
        couponNameLabel.tag = kCouponNameLabelTag;
        couponNameLabel.font = [UIFont systemFontOfSize:15];
        couponNameLabel.textColor = [PiosaColorManager fontColor];
        tempCouponNameLabel = couponNameLabel;
        [cell.contentView addSubview:couponNameLabel];
        [couponNameLabel release];
        
        UILabel *couponPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 27, 30, 15)];
        couponPriceShowLabel.backgroundColor = [UIColor clearColor];
        couponPriceShowLabel.font = [UIFont systemFontOfSize:14];
        couponPriceShowLabel.text = @"优惠";
        [cell.contentView addSubview:couponPriceShowLabel];
        [couponPriceShowLabel release];
        
        UILabel *couponPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 27, 100, 15)];
        couponPriceLabel.backgroundColor = [UIColor clearColor];
        couponPriceLabel.tag = kCouponPriceLabelTag;
        couponPriceLabel.font = [UIFont systemFontOfSize:14];
        couponPriceLabel.textColor = [UIColor redColor];
        tempCouponPriceLabel = couponPriceLabel;
        [cell.contentView addSubview:couponPriceLabel];
        [couponPriceLabel release];
        
        UILabel *couponPopularityShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 45, 30, 15)];
        couponPopularityShowLabel.backgroundColor = [UIColor clearColor];
        couponPopularityShowLabel.font = [UIFont systemFontOfSize:12];
        couponPopularityShowLabel.text = @"人气:";
        [cell.contentView addSubview:couponPopularityShowLabel];
        [couponPopularityShowLabel release];
        
        UILabel *couponPopularityLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 45, 100, 15)];
        couponPopularityLabel.backgroundColor = [UIColor clearColor];
        couponPopularityLabel.tag = kCouponPopularityLabelTag;
        couponPopularityLabel.font = [UIFont systemFontOfSize:12];
        couponPopularityLabel.textColor = [UIColor redColor];
        tempCouponPopularityLabel = couponPopularityLabel;
        [cell.contentView addSubview:couponPopularityLabel];
        [couponPopularityLabel release];
        
        UILabel *couponTypeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 63, 30, 15)];
        couponTypeShowLabel.backgroundColor = [UIColor clearColor];
        couponTypeShowLabel.font = [UIFont systemFontOfSize:12];
        couponTypeShowLabel.text = @"类型:";
        [cell.contentView addSubview:couponTypeShowLabel];
        [couponTypeShowLabel release];
        
        UILabel *couponTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 63, 100, 15)];
        couponTypeLabel.backgroundColor = [UIColor clearColor];
        couponTypeLabel.tag = kCouponTypeLabelTag;
        couponTypeLabel.font = [UIFont systemFontOfSize:12];
        tempCouponTypeLabel = couponTypeLabel;
        [cell.contentView addSubview:couponTypeLabel];
        [couponTypeLabel release];
        
        UILabel *couponEndTimeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 50, 20)];
        couponEndTimeShowLabel.backgroundColor = [UIColor clearColor];
        couponEndTimeShowLabel.font = [UIFont systemFontOfSize:13];
        couponEndTimeShowLabel.text = @"活动至:";
        [cell.contentView addSubview:couponEndTimeShowLabel];
        [couponEndTimeShowLabel release];
        
        UILabel *couponEndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 80, 140, 20)];
        couponEndTimeLabel.backgroundColor = [UIColor clearColor];
        couponEndTimeLabel.tag = kCouponEndTimeLabelTag;
        couponEndTimeLabel.font = [UIFont systemFontOfSize:13];
        couponEndTimeLabel.textColor = [UIColor grayColor];
        tempCouponEndTimeLabel = couponEndTimeLabel;
        [cell.contentView addSubview:couponEndTimeLabel];
        [couponEndTimeLabel release];
        
        UILabel *couponSellPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 80, 40, 20)];
        couponSellPriceShowLabel.backgroundColor = [UIColor clearColor];
        couponSellPriceShowLabel.font = [UIFont systemFontOfSize:13];
        couponSellPriceShowLabel.text = @"购买价";
        [cell.contentView addSubview:couponSellPriceShowLabel];
        [couponSellPriceShowLabel release];
        
        UILabel *couponSellPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 80 , 60, 20)];
        couponSellPriceLabel.backgroundColor = [UIColor clearColor];
        couponSellPriceLabel.tag = kCouponSellPriceLabelTag;
        couponSellPriceLabel.font = [UIFont systemFontOfSize:13];
        couponSellPriceLabel.textColor = [UIColor redColor];
        tempCouponSellPriceLabel = couponSellPriceLabel;
        [cell.contentView addSubview:couponSellPriceLabel];
        [couponSellPriceLabel release];
        
        
	} else {
        tempCouponImageView = (UIHTTPImageView *)[cell.contentView viewWithTag:kCouponImageViewTag];
        tempCouponNameLabel = (UILabel *)[cell.contentView viewWithTag:kCouponNameLabelTag];
        tempCouponPriceLabel = (UILabel *)[cell.contentView viewWithTag:kCouponPriceLabelTag];
        tempCouponPopularityLabel = (UILabel *)[cell.contentView viewWithTag:kCouponPopularityLabelTag];
        tempCouponTypeLabel = (UILabel *)[cell.contentView viewWithTag:kCouponTypeLabelTag];
        tempCouponEndTimeLabel = (UILabel *)[cell.contentView viewWithTag:kCouponEndTimeLabelTag];
        tempCouponSellPriceLabel = (UILabel *)[cell.contentView viewWithTag:kCouponSellPriceLabelTag];
    }
    
    tempCouponNameLabel.text = couponListInfoModel.couponName;
    tempCouponPriceLabel.text = [NSString stringWithFormat:@"¥%@",couponListInfoModel.couponPrice];
    tempCouponPopularityLabel.text = couponListInfoModel.couponPopularity;
    tempCouponTypeLabel.text = couponListInfoModel.couponType;
    tempCouponEndTimeLabel.text = couponListInfoModel.couponEndTime;
    if (_couponListType==1) {
        tempCouponSellPriceLabel.text = @"免费";
    } else {
        tempCouponSellPriceLabel.text = [NSString stringWithFormat:@"¥%@",couponListInfoModel.couponSellPrice];
    }
    
    NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
    UIImageView * accessoryViewTemp1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
    accessoryViewTemp1.frame = CGRectMake(0, 0, 10, 16);
    cell.accessoryView = accessoryViewTemp1;
    [accessoryViewTemp1 release];
    
    NSString *tableViewCellPlainNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_plain_normal" inDirectory:@"CommonView/TableViewCell"];
    NSString *tableViewCellPlainHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_plain_highlighted" inDirectory:@"CommonView/TableViewCell"];
    cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellPlainNormalPath]] autorelease];
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
    if (self.couponListSearchResponseModel != nil&&[self.couponListSearchResponseModel.couponArray count]<=4) {
        //如果显示的房型不超出显示框，则通过添加footer来去除多出来的空cell
        UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)] autorelease];
        footer.backgroundColor = [UIColor clearColor];
        return footer;
    } else {
        return nil;
    }
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![self.req isFinished]) {
        NSLog(@"self.req is Finished");
        [self.req clearDelegatesAndCancel]; //取消可能存在的请求
        //[self doneLoadingTableViewData:_hotelRefreshHeaderView]; //取消加载完成数据，修改拉动刷新框的位置与其它参数
    } else {
        NSLog(@"self.req is not Finished");
    }
    
    CouponListInfoModel * couponListInfoModel = [self.couponListSearchResponseModel.couponArray objectAtIndex:indexPath.row];
    
    CouponInfoViewController *couponInfoViewController = [[CouponInfoViewController alloc] initWithCouponID:couponListInfoModel.couponID couponType:_couponListType];
    [self.navigationController pushViewController:couponInfoViewController animated:YES];
    [couponInfoViewController release];
    
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
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.couponListTableView];
	
	[_refreshHeaderView setFrame:CGRectMake(0, self.couponListTableView.contentSize.height, 320, 70)];//调整拉动刷新框的位置，使其位于刷新后的列表下
	if ([self.couponListSearchResponseModel.pageSize intValue]*[self.couponListSearchResponseModel.currentPage intValue]>=[self.couponListSearchResponseModel.count intValue]) {
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
    //停止拖动机票订单列表时
    if ([self.couponListSearchResponseModel.pageSize intValue]*[self.couponListSearchResponseModel.currentPage intValue]<[self.couponListSearchResponseModel.count intValue]) {
        //显示最后一页时，可以不用调用方法来设置刷新视图
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView]; 
    }
} 

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource]; //开始加载数据
    
    self.requestType = 2;
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: COUPON_LIST_ADDRESS]] ;
    request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    
    NSInteger index = [self.couponListSearchResponseModel.currentPage intValue]+1;
    [request appendPostData:[self generateCouponListSearchRequestPostXMLData:[NSString stringWithFormat:@"%d",index]]];
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

//
//  FlightOrderCouponChoiceTableViewController.m
//  UCAI
//
//  Created by  on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"
#import "CommonTools.h"
#import "PiosaFileManager.h"
#import "GDataXMLNode.h"
#import "ASIFormDataRequest.h"
#import "StaticConf.h"
#import "ResponseParser.h"
#import "EGORefreshTableHeaderView.h"

#import "FlightOrderCouponChoiceViewController.h"
#import "FlightOrderInfoViewController.h"
#import "CouponValidQueryResponseModel.h"

#define kHUDhiddenTag 101 //只需要消失提交框
#define kHUDhiddenAndPopTag 102 //需要在提交框消失后退出视图

#define kCouponNameLabelTag 201
#define kCouponNOLabelTag 202
#define kCouponPreiceTag 203

#define kHeightForTableCell 44

@implementation FlightOrderCouponChoiceViewController

@synthesize flightOrderInfoViewController = _flightOrderInfoViewController;
@synthesize couponValidQueryResponseModel = _couponValidQueryResponseModel;

@synthesize couponCounterLabel = _couponCounterLabel;
@synthesize usedCounterLabel = _usedCounterLabel;
@synthesize couponPriceAmountContentLabel = _couponPriceAmountContentLabel;

@synthesize req = _req;
@synthesize requestType = _requestType;

- (FlightOrderCouponChoiceViewController *)initWithMaxUsedCount:(NSUInteger)maxUsedCount{
    self = [super init];
    _maxUsedCount = maxUsedCount;
    NSMutableArray * tempArray = [[NSMutableArray alloc] init];
    _selectedCouponNOArray = tempArray;
    [_selectedCouponNOArray retain];
    [tempArray release];
    return self;
}

- (void)dealloc
{
    [_selectedCouponNOArray release];
    [_couponChoiceTableView release];
    [self.flightOrderInfoViewController release];
    [self.couponValidQueryResponseModel release];
    [self.couponCounterLabel release];
    [self.usedCounterLabel release];
    [self.couponPriceAmountContentLabel release];
    if (![self.req isFinished]) {//异步请求未完成时
		[self.req clearDelegatesAndCancel];
		//ASIHTTPRequest在1.8版本前没有以上的clearDelegatesAndCancel方法，可使用以下的语句替换
		//self.req.delegate = nil;
		//[self.req cancel];
	}
    [self.req release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.title = @"选择优惠劵";
    
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
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 310, 406)];
    bgView.layer.cornerRadius = 10;
    bgView.backgroundColor = [UIColor colorWithRed:1.0 green:0.992 blue:0.918 alpha:1.0];
    [self.view addSubview:bgView];
    [bgView release];
    
    UILabel *maxUsedInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 20)];
    maxUsedInfoLabel.backgroundColor = [UIColor clearColor];
    maxUsedInfoLabel.font = [UIFont systemFontOfSize:15];
    maxUsedInfoLabel.text = [NSString stringWithFormat:@"您最多可使用%d张优惠劵",_maxUsedCount];
    [bgView addSubview:maxUsedInfoLabel];
    [maxUsedInfoLabel release];
    
    UILabel *couponCounterLabel = [[UILabel alloc] initWithFrame:CGRectMake(205, 5, 100, 20)];
    couponCounterLabel.backgroundColor = [UIColor clearColor];
    couponCounterLabel.font = [UIFont systemFontOfSize:15];
    couponCounterLabel.text = @"0个结果";
    couponCounterLabel.textAlignment = UITextAlignmentRight;
    self.couponCounterLabel = couponCounterLabel;
    [bgView addSubview:couponCounterLabel];
    [couponCounterLabel release];
    
    UILabel *usedCounterLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, 200, 20)];
    usedCounterLabel.backgroundColor = [UIColor clearColor];
    usedCounterLabel.textColor = [UIColor grayColor];
    usedCounterLabel.font = [UIFont systemFontOfSize:13];
    usedCounterLabel.text = [NSString stringWithFormat:@"当前选中优惠劵数:%d",[_selectedCouponNOArray count]];
    self.usedCounterLabel = usedCounterLabel;
    [bgView addSubview:usedCounterLabel];
    [usedCounterLabel release];
    
    UILabel *couponPriceAmountShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(205, 25, 50, 20)];
    couponPriceAmountShowLabel.backgroundColor = [UIColor clearColor];
    couponPriceAmountShowLabel.textColor = [UIColor grayColor];
    couponPriceAmountShowLabel.font = [UIFont systemFontOfSize:13];
    couponPriceAmountShowLabel.text = @"可优惠:";
    [bgView addSubview:couponPriceAmountShowLabel];
    [couponPriceAmountShowLabel release];
    
    UILabel *couponPriceAmountContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(255, 25, 50, 20)];
    couponPriceAmountContentLabel.backgroundColor = [UIColor clearColor];
    couponPriceAmountContentLabel.textColor = [UIColor redColor];
    couponPriceAmountContentLabel.font = [UIFont systemFontOfSize:13];
    couponPriceAmountContentLabel.textAlignment = UITextAlignmentCenter;
    couponPriceAmountContentLabel.text = @"¥0.0";
    self.couponPriceAmountContentLabel = couponPriceAmountContentLabel;
    [bgView addSubview:couponPriceAmountContentLabel];
    [couponPriceAmountContentLabel release];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(5, 46, 300, 2)];
    separatorView.backgroundColor = [UIColor grayColor];
    [bgView addSubview:separatorView];
    [separatorView release];
    
    UITableView *choiceTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 50, 300, 300) style:UITableViewStylePlain];
    choiceTableView.dataSource = self;
    choiceTableView.delegate = self;
    _couponChoiceTableView = choiceTableView;
    [bgView addSubview:choiceTableView];
    [choiceTableView release];
    
    //拉动刷新框
	if (_refreshHeaderView == nil) { 
        EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, kHeightForTableCell*7, 300, 70)]; //拉动刷新框的初始化位置y坐标是在默认查出的6条数据列表下
		view1.delegate = self; 
        [choiceTableView addSubview:view1]; 
		//则隐藏拉动刷新框
		[view1 setHidden:YES];
        _refreshHeaderView = view1; 
        [view1 release]; 
    } 
    [_refreshHeaderView refreshLastUpdatedDate];
    
    UIButton * tempDecidedButton = [[UIButton alloc] init];
    tempDecidedButton.frame = CGRectMake(5, 360, 300, 40);
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
    [tempDecidedButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
    [tempDecidedButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
    [tempDecidedButton setTitle:@"使    用" forState:UIControlStateNormal];
    [tempDecidedButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
    [tempDecidedButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
    [tempDecidedButton addTarget:self action:@selector(decidedButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:tempDecidedButton];
    [tempDecidedButton release];
    
}

- (void) viewDidLoad{
    [super viewDidLoad];
    
    self.requestType = 1;
    
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"查询中...";
    _hud.tag = kHUDhiddenAndPopTag;
    [_hud show:YES];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: COUPON_VALIDQUERY_ADDRESS]];
    request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    
    [request appendPostData:[self generateCouponValidQueryRequestPostXMLData:@"1"]];
    
    [request setDelegate:self];
    [request startAsynchronous]; // 执行异步post
    self.req = request;
    [request release];
}

#pragma mark - Custom method
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

- (NSData*)generateCouponValidQueryRequestPostXMLData:(NSString *) pageIndex{
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
    
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *pageInfoElement = [GDataXMLElement elementWithName:@"pageInfo"];
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"currentPage" stringValue:pageIndex]];
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"pageSize" stringValue:@"10"]];
    [requestElement addChild:pageInfoElement];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"memberID" stringValue:[memberDict objectForKey:@"memberID"]]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"type" stringValue:@"1"]];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    return document.XMLData;
}

- (void)decidedButtonPress{
    if (![self.req isFinished]) {
        NSLog(@"self.req is Finished");
        [self.req clearDelegatesAndCancel]; //取消可能存在的请求
        [self doneLoadingTableViewData]; //取消加载完成数据，修改拉动刷新框的位置与其它参数
    } else {
        NSLog(@"self.req is not Finished");
    }
    
    NSMutableString * couponNoReturnString = [[NSMutableString alloc] init];
    NSMutableString * couponIdReturnString = [[NSMutableString alloc] init];
    for (ValidCoupon * coupon in _selectedCouponNOArray) {
        [couponNoReturnString appendString:coupon.couponNO];
        [couponNoReturnString appendString:@","];
        [couponIdReturnString appendString:coupon.couponId];
        [couponIdReturnString appendString:@","];
    }
    if ([couponNoReturnString length]>0) {
        self.flightOrderInfoViewController.couponUsedContentLabel.text = [couponNoReturnString substringToIndex:[couponNoReturnString length]-1];
    }else{
        self.flightOrderInfoViewController.couponUsedContentLabel.text = @"";
    }
    if ([couponIdReturnString length]>0) {
        self.flightOrderInfoViewController.couponUsedIDs = [couponIdReturnString substringToIndex:[couponIdReturnString length]-1];
    }else{
        self.flightOrderInfoViewController.couponUsedIDs = @"";
    }
    [couponNoReturnString release];
    [couponIdReturnString release];

    self.flightOrderInfoViewController.couponPriceAmount = self.couponPriceAmountContentLabel.text;
    [self.flightOrderInfoViewController.flightOrderInfoTableView reloadData];
    
    int lineNumber = [CommonTools calculateRowCountForUTF8:self.flightOrderInfoViewController.couponUsedContentLabel.text bytes:20];
    self.flightOrderInfoViewController.couponUsedShowLabel.frame = CGRectMake(15, 10, 80, 20*(lineNumber==0?1:lineNumber));
    self.flightOrderInfoViewController.couponUsedContentLabel.frame = CGRectMake(95, 10, 180, 20*lineNumber);
    [self.flightOrderInfoViewController.payButton setFrame:CGRectMake(10, self.flightOrderInfoViewController.flightOrderInfoTableView.contentSize.height+10, 300, 40)];
    self.flightOrderInfoViewController.flightOrderInfoTableView.contentSize = CGSizeMake(300, self.flightOrderInfoViewController.flightOrderInfoTableView.contentSize.height+60);
    [self.flightOrderInfoViewController.flightOrderInfoTableView setContentOffset:CGPointMake(0, self.flightOrderInfoViewController.flightOrderInfoTableView.contentSize.height-416)];
    [self.navigationController popViewControllerAnimated:YES];
    
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
        switch (_requestType) {
            case 1:{//刷新列表
                CouponValidQueryResponseModel *couponValidQueryResponseModel = [ResponseParser loadCouponValidQueryResponse:[request responseData] oldCouponList:nil];
                
                if ([couponValidQueryResponseModel.resultCode intValue] != 0) {
                    NSString *exclamationImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"exclamation" inDirectory:@"CommonView/ProgressView"];
                    UIImageView *exclamationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:exclamationImagePath]];
                    exclamationImageView.frame = CGRectMake(0, 0, 37, 37);
                    _hud.customView = exclamationImageView;
                    [exclamationImageView release];
                    _hud.opacity = 1.0;
                    _hud.mode = MBProgressHUDModeCustomView;
                    _hud.labelText = couponValidQueryResponseModel.resultMessage;
                    [_hud hide:YES afterDelay:2];
                } else {
                    _hud.tag = kHUDhiddenTag;
                    // 关闭加载框
                    [_hud hide:YES];
                    
                    self.couponValidQueryResponseModel = couponValidQueryResponseModel;
                    self.couponCounterLabel.text = [NSString stringWithFormat:@"%@个结果",self.couponValidQueryResponseModel.count];
                    [_couponChoiceTableView reloadData];
                    
                    _couponChoiceTableView.contentOffset = CGPointMake(0, 0);//列表回顶部
                    
                    //设置拉动刷新框
                    int numberOfRowForList = self.couponValidQueryResponseModel.validCouponArray == nil ? 0 : [self.couponValidQueryResponseModel.validCouponArray count];
                    [_refreshHeaderView setFrame:CGRectMake(0, kHeightForTableCell*numberOfRowForList, 300, 70)];//重设拉动刷新框的位置
                    
                    if ([self.couponValidQueryResponseModel.pageSize intValue]*[self.couponValidQueryResponseModel.currentPage intValue]>=[self.couponValidQueryResponseModel.count intValue]) {
                        //如果当前页为最后一页，则隐藏拉动刷新框
                        [_refreshHeaderView setHidden:YES];
                    } else {
                        //如果当前页不为最后一页，则显示拉动刷新框
                        [_refreshHeaderView setHidden:NO];
                    }
                }
            }
                break;
            case 2:{
                CouponValidQueryResponseModel *couponValidQueryResponseModel = [ResponseParser loadCouponValidQueryResponse:[request responseData] oldCouponList:self.couponValidQueryResponseModel];
                
                if ([couponValidQueryResponseModel.resultCode intValue] != 0) {
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
                    hud.labelText = couponValidQueryResponseModel.resultMessage;
                    hud.tag = kHUDhiddenTag;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    self.couponValidQueryResponseModel = couponValidQueryResponseModel;
                    [_refreshHeaderView setHidden:TRUE];//隐藏拉动刷新框，因为当加载速度很快时，拉动刷新框在doneLoadingTableViewData里调整位置前，已经显示出了新数据
                    [_couponChoiceTableView reloadData];
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
    if (self.requestType == 2) {
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
        [_hud hide:YES afterDelay:3];
    }
    
    [self doneLoadingTableViewData]; //加载完成数据，修改拉动刷新框的位置与其它参数
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
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_couponChoiceTableView];
	
	[_refreshHeaderView setFrame:CGRectMake(0, _couponChoiceTableView.contentSize.height, 300, 70)];//调整拉动刷新框的位置，使其位于刷新后的列表下
	if ([self.couponValidQueryResponseModel.pageSize intValue]*[self.couponValidQueryResponseModel.currentPage intValue]>=[self.couponValidQueryResponseModel.count intValue]) {
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
    if ([self.couponValidQueryResponseModel.pageSize intValue]*[self.couponValidQueryResponseModel.currentPage intValue]<[self.couponValidQueryResponseModel.count intValue]) {
        //显示最后一页时，可以不用调用方法来设置刷新视图
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView]; 
    }
} 

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource]; //开始加载数据
    
    self.requestType = 2;
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: COUPON_VALIDQUERY_ADDRESS]] ;
    request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    
    NSInteger index = [self.couponValidQueryResponseModel.currentPage intValue]+1;
    [request appendPostData:[self generateCouponValidQueryRequestPostXMLData:[NSString stringWithFormat:@"%d",index]]];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.couponValidQueryResponseModel.validCouponArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UILabel * tempCouponNOLabel;
    UILabel * tempCouponPriceLabel;
    UILabel * tempCouponNameLabel;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        UILabel * couponNOLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, 150, 20)];
        couponNOLabel.backgroundColor = [UIColor clearColor];
        couponNOLabel.textColor = [PiosaColorManager fontColor];
        couponNOLabel.tag = kCouponNOLabelTag;
        couponNOLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:couponNOLabel];
        tempCouponNOLabel = couponNOLabel;
        [couponNOLabel release];
        
        UILabel * couponNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 23, 150, 20)];
        couponNameLabel.backgroundColor = [UIColor clearColor];
        couponNameLabel.tag = kCouponNameLabelTag;
        couponNameLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:couponNameLabel];
        tempCouponNameLabel = couponNameLabel;
        [couponNameLabel release];
        
        UILabel * couponPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(175, 5, 100, 30)];
        couponPriceLabel.backgroundColor = [UIColor clearColor];
        couponPriceLabel.textColor = [UIColor redColor];
        couponPriceLabel.tag = kCouponPreiceTag;
        couponPriceLabel.textAlignment = UITextAlignmentRight;
        couponPriceLabel.font = [UIFont boldSystemFontOfSize:18];
        [cell.contentView addSubview:couponPriceLabel];
        tempCouponPriceLabel = couponPriceLabel;
        [couponPriceLabel release];
        
        
    } else {
        tempCouponNOLabel = (UILabel *)[cell.contentView viewWithTag:kCouponNOLabelTag];
        tempCouponPriceLabel = (UILabel *)[cell.contentView viewWithTag:kCouponPreiceTag];
        tempCouponNameLabel = (UILabel *)[cell.contentView viewWithTag:kCouponNameLabelTag];
    }
    
    ValidCoupon *validCoupon = [self.couponValidQueryResponseModel.validCouponArray objectAtIndex:indexPath.row];
    
    tempCouponNOLabel.text = validCoupon.couponNO;
    tempCouponPriceLabel.text = [NSString stringWithFormat:@"¥%@",validCoupon.couponPrice];
    tempCouponNameLabel.text = validCoupon.couponName;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    for (ValidCoupon * coupon in _selectedCouponNOArray) {
        if ([coupon.couponNO isEqualToString:validCoupon.couponNO]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        }
    }
    
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ValidCoupon *validCoupon = [self.couponValidQueryResponseModel.validCouponArray objectAtIndex:indexPath.row];
    
    UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [_selectedCouponNOArray removeObject:validCoupon];
        selectedCell.accessoryType = UITableViewCellAccessoryNone;
        _couponPriceAmount = _couponPriceAmount - [validCoupon.couponPrice floatValue];
    } else {
        if ([_selectedCouponNOArray count]<_maxUsedCount) {
            [_selectedCouponNOArray addObject:validCoupon];
            selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
            _couponPriceAmount = _couponPriceAmount + [validCoupon.couponPrice floatValue];
        }
    }
       
    self.couponPriceAmountContentLabel.text = [NSString stringWithFormat:@"¥%.1f",_couponPriceAmount];
    self.usedCounterLabel.text = [NSString stringWithFormat:@"当前选中优惠劵数:%d",[_selectedCouponNOArray count]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.couponValidQueryResponseModel != nil&&[self.couponValidQueryResponseModel.validCouponArray count]<=6) {
        //如果显示的房型不超出显示框，则通过添加footer来去除多出来的空cell
        UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)] autorelease];
        footer.backgroundColor = [UIColor clearColor];
        return footer;
    } else {
        return nil;
    }
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

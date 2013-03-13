//
//  HotelOrderInfoViewController.m
//  UCAI
//
//  Created by  on 11-12-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HotelOrderInfoViewController.h"

#import "GDataXMLNode.h"
#import "ASIFormDataRequest.h"
#import "StaticConf.h"
#import "ResponseParser.h"

#import "PiosaFileManager.h"

#import "HotelOrderInfoSearchResponseModel.h"

#define kHUDhiddenTag 101 //只需要消失提交框
#define kHUDhiddenAndPopTag 102 //需要在提交框消失后退出视图

@implementation HotelOrderInfoViewController

@synthesize isMemberLogin = _isMemberLogin;
@synthesize lastContractNameForSearchHotleOrderList = _lastContractNameForSearchHotleOrderList;
@synthesize lastContractPhoneForSearchHotleOrderList = _lastContractPhoneForSearchHotleOrderList;
@synthesize tpsOrderId = _tpsOrderId;
@synthesize hotelOrderInfoTableView = _hotelOrderInfoTableView;
@synthesize orderIDContentLabel = _orderIDContentLabel;
@synthesize orderPriceContentLabel = _orderPriceContentLabel;
@synthesize orderTimeContentLabel = _orderTimeContentLabel;
@synthesize orderPayContentLabel = _orderPayContentLabel;
@synthesize orderStatusContentLabel = _orderStatusContentLabel;
@synthesize hotelNameContentLabel = _hotelNameContentLabel;
@synthesize roomTypeContentLabel = _roomTypeContentLabel;
@synthesize stayDayContentLabel = _stayDayContentLabel;
@synthesize roomCountContentLabel = _roomCountContentLabel;
@synthesize arrivedTimeContentLabel = _arrivedTimeContentLabel;
@synthesize guestArray = _guestArray;
@synthesize linkNameContentLabel = _linkNameContentLabel;
@synthesize linkMobileContentLabel = _linkMobileContentLabel;
@synthesize hotelOrderInfoSearchResponseModel = _hotelOrderInfoSearchResponseModel;

- (void)dealloc {
    [self.lastContractNameForSearchHotleOrderList release];
    [self.lastContractPhoneForSearchHotleOrderList release];
    [self.tpsOrderId release];
    [self.hotelOrderInfoTableView release];
    [self.orderIDContentLabel release];
    [self.orderPriceContentLabel release];
    [self.orderTimeContentLabel release];
    [self.orderPayContentLabel release];
    [self.orderStatusContentLabel release];
    [self.hotelNameContentLabel release];
    [self.roomTypeContentLabel release];
    [self.stayDayContentLabel release];
    [self.roomCountContentLabel release];
    [self.arrivedTimeContentLabel release];
    [self.guestArray release];
    [self.linkNameContentLabel release];
    [self.linkMobileContentLabel release];
    [self.hotelOrderInfoSearchResponseModel release];
    
    [super dealloc];
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

- (NSData*)generateHotelOrderInfoSearchRequestPostXMLData {
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
    
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
	[requestElement addChild:[GDataXMLNode elementWithName:@"tpsOrderId" stringValue:self.tpsOrderId]];
    if (self.isMemberLogin) {
        //此订单由会员订单中心查询而来
        [requestElement addChild:[GDataXMLNode elementWithName:@"memberId" stringValue:[memberDict objectForKey:@"memberID"]]];
    }else {
        //此订单由游客订单中心查询而来
        [requestElement addChild:[GDataXMLNode elementWithName:@"memberId" stringValue:@""]];
    }
	
	GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
	[document setVersion:@"1.0"]; // 设置xml版本为 1.0
	[document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
	
	NSData *xmlData = document.XMLData;
	return xmlData;
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.title = @"酒店订单详情";
    
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
    
    NSMutableArray * tempGuestArray = [[NSMutableArray alloc] init];
    self.guestArray = tempGuestArray;
    [tempGuestArray release];
    
    UITableView * tempTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
    tempTableView.dataSource = self;
    tempTableView.delegate = self;
    tempTableView.backgroundColor = [UIColor clearColor];
    self.hotelOrderInfoTableView = tempTableView;
    [self.view addSubview:tempTableView];
    [tempTableView release];
}

- (void) viewDidAppear:(BOOL)animated{
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"查询中...";
    _hud.tag = kHUDhiddenTag;
    [_hud show:YES];
    
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: HOTEL_ORDERDETAIL_ADDRESS]] autorelease] ;
    request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    
    NSString *postData = [[NSString alloc] initWithData:[self generateHotelOrderInfoSearchRequestPostXMLData] encoding:NSUTF8StringEncoding];
    NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    [request setPostValue:postData forKey:@"requestXml"];
    
    [request setDelegate:self];
    [request startAsynchronous]; // 执行异步post
    [postData release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

        HotelOrderInfoSearchResponseModel *hotelOrderInfoSearchResponseModel = [ResponseParser loadHotelOrderInfoSearchResponse:[request responseData]];
                
        if (hotelOrderInfoSearchResponseModel.resultCode == nil || [hotelOrderInfoSearchResponseModel.resultCode length] == 0 || [hotelOrderInfoSearchResponseModel.resultCode intValue] != 1) {
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
            hud.labelText = hotelOrderInfoSearchResponseModel.resultMessage;
            hud.tag = kHUDhiddenAndPopTag;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
        } else {
            self.hotelOrderInfoSearchResponseModel = hotelOrderInfoSearchResponseModel;
            
            NSMutableString * guests = [NSMutableString stringWithString:self.hotelOrderInfoSearchResponseModel.guests];
            
            for (NSString * guest in [guests componentsSeparatedByString:@"|"]) {
                if (![@"" isEqualToString:guest]) {
                    [self.guestArray addObject:[NSString stringWithString:guest]];
                }
            }
        }
    }
    
    [self.hotelOrderInfoTableView reloadData];
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
    _hud.tag = kHUDhiddenAndPopTag;
    [_hud hide:YES afterDelay:3];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return 3;
            break;
        case 2:
            if ([self.guestArray count]==0) {
                return 2;
            }else{
                return [self.guestArray count]+1;
            }
            break;
        case 3:
            return 3;
            break;
        default:
            return 0;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", indexPath.row, indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont systemFontOfSize:18];
                        cell.textLabel.text = @"订单信息";
                        break;
                    case 1:
                    {
                        UILabel * orderIDShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 80, 20)];
                        orderIDShowLabel.backgroundColor = [UIColor clearColor];
                        orderIDShowLabel.font = [UIFont systemFontOfSize:16];
                        orderIDShowLabel.text = @"订单编号:";
                        [cell.contentView addSubview:orderIDShowLabel];
                        [orderIDShowLabel release];
                        
                        UILabel * orderIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 5, 180, 20)];
                        orderIDLabel.backgroundColor = [UIColor clearColor];
                        orderIDLabel.font = [UIFont systemFontOfSize:16];
                        orderIDLabel.textColor = [PiosaColorManager fontColor];
                        self.orderIDContentLabel = orderIDLabel;
                        [cell.contentView addSubview:self.orderIDContentLabel];
                        [orderIDLabel release];
                        
                        UILabel * orderPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 80, 20)];
                        orderPriceShowLabel.backgroundColor = [UIColor clearColor];
                        orderPriceShowLabel.font = [UIFont systemFontOfSize:16];
                        orderPriceShowLabel.text = @"订单金额:";
                        [cell.contentView addSubview:orderPriceShowLabel];
                        [orderPriceShowLabel release];
                        
                        UILabel * orderPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, 180, 20)];
                        orderPriceLabel.backgroundColor = [UIColor clearColor];
                        orderPriceLabel.font = [UIFont systemFontOfSize:16];
                        orderPriceLabel.textColor = [UIColor redColor];
                        self.orderPriceContentLabel = orderPriceLabel;
                        [cell.contentView addSubview:self.orderPriceContentLabel];
                        [orderPriceLabel release];
                        
                        UILabel * orderStatusShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 55, 80, 20)];
                        orderStatusShowLabel.backgroundColor = [UIColor clearColor];
                        orderStatusShowLabel.font = [UIFont systemFontOfSize:16];
                        orderStatusShowLabel.text = @"订单状态:";
                        [cell.contentView addSubview:orderStatusShowLabel];
                        [orderStatusShowLabel release];
                        
                        UILabel * orderStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 55, 180, 20)];
                        orderStatusLabel.backgroundColor = [UIColor clearColor];
                        orderStatusLabel.textColor = [UIColor grayColor];
                        orderStatusLabel.font = [UIFont systemFontOfSize:16];
                        self.orderStatusContentLabel = orderStatusLabel;
                        [cell.contentView addSubview:self.orderStatusContentLabel];
                        [orderStatusLabel release];
                    }
                        break;
                    case 2:
                    {
                        UILabel * orderTimeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 80, 20)];
                        orderTimeShowLabel.backgroundColor = [UIColor clearColor];
                        orderTimeShowLabel.font = [UIFont systemFontOfSize:16];
                        orderTimeShowLabel.text = @"订购时间:";
                        [cell.contentView addSubview:orderTimeShowLabel];
                        [orderTimeShowLabel release];
                        
                        UILabel * orderTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 5, 180, 20)];
                        orderTimeLabel.backgroundColor = [UIColor clearColor];
                        orderTimeLabel.textColor = [UIColor grayColor];
                        orderTimeLabel.font = [UIFont systemFontOfSize:16];
                        self.orderTimeContentLabel = orderTimeLabel;
                        [cell.contentView addSubview:self.orderTimeContentLabel];
                        [orderTimeLabel release];
                        
                        UILabel * orderPayShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 80, 20)];
                        orderPayShowLabel.backgroundColor = [UIColor clearColor];
                        orderPayShowLabel.font = [UIFont systemFontOfSize:16];
                        orderPayShowLabel.text = @"支付方式:";
                        [cell.contentView addSubview:orderPayShowLabel];
                        [orderPayShowLabel release];
                        
                        UILabel * orderPayLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, 180, 20)];
                        orderPayLabel.backgroundColor = [UIColor clearColor];
                        orderPayLabel.textColor = [UIColor grayColor];
                        orderPayLabel.font = [UIFont systemFontOfSize:16];
                        self.orderPayContentLabel = orderPayLabel;
                        [cell.contentView addSubview:self.orderPayContentLabel];
                        [orderPayLabel release];

                    }
                        break;
                }
                break;
            case 1:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont systemFontOfSize:18];
                        cell.textLabel.text = @"酒店信息";
                        break;
                    case 1:
                    {
                        UILabel * hotelNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 80, 20)];
                        hotelNameShowLabel.backgroundColor = [UIColor clearColor];
                        hotelNameShowLabel.font = [UIFont systemFontOfSize:16];
                        hotelNameShowLabel.text = @"酒店名称:";
                        [cell.contentView addSubview:hotelNameShowLabel];
                        [hotelNameShowLabel release];
                        
                        UILabel * hotelNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 5, 200, 20)];
                        hotelNameLabel.backgroundColor = [UIColor clearColor];
                        hotelNameLabel.textColor = [UIColor grayColor];
                        hotelNameLabel.font = [UIFont systemFontOfSize:16];
                        hotelNameLabel.adjustsFontSizeToFitWidth = YES;
                        self.hotelNameContentLabel = hotelNameLabel;
                        [cell.contentView addSubview:self.hotelNameContentLabel];
                        [hotelNameLabel release];
                        
                        UILabel * roomTypeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 80, 20)];
                        roomTypeShowLabel.backgroundColor = [UIColor clearColor];
                        roomTypeShowLabel.font = [UIFont systemFontOfSize:16];
                        roomTypeShowLabel.text = @"房\t\t\t\t\t\t\t型:";
                        [cell.contentView addSubview:roomTypeShowLabel];
                        [roomTypeShowLabel release];
                        
                        UILabel * roomTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, 180, 20)];
                        roomTypeLabel.backgroundColor = [UIColor clearColor];
                        roomTypeLabel.textColor = [UIColor grayColor];
                        roomTypeLabel.font = [UIFont systemFontOfSize:16];
                        self.roomTypeContentLabel = roomTypeLabel;
                        [cell.contentView addSubview:self.roomTypeContentLabel];
                        [roomTypeLabel release];
                    }
                        break;
                    case 2:
                    {
                        
                        UILabel * stayDayShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 80, 20)];
                        stayDayShowLabel.backgroundColor = [UIColor clearColor];
                        stayDayShowLabel.font = [UIFont systemFontOfSize:16];
                        stayDayShowLabel.text = @"住店时间:";
                        [cell.contentView addSubview:stayDayShowLabel];
                        [stayDayShowLabel release];
                        
                        UILabel * stayDayContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 5, 200, 20)];
                        stayDayContentLabel.backgroundColor = [UIColor clearColor];
                        stayDayContentLabel.textColor = [UIColor grayColor];
                        stayDayContentLabel.font = [UIFont systemFontOfSize:16];
                        self.stayDayContentLabel = stayDayContentLabel;
                        [cell.contentView addSubview:self.stayDayContentLabel];
                        [stayDayContentLabel release];
                        
                        UILabel * roomCountShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 80, 20)];
                        roomCountShowLabel.backgroundColor = [UIColor clearColor];
                        roomCountShowLabel.font = [UIFont systemFontOfSize:16];
                        roomCountShowLabel.text = @"房间数量:";
                        [cell.contentView addSubview:roomCountShowLabel];
                        [roomCountShowLabel release];
                        
                        UILabel * roomCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, 180, 20)];
                        roomCountLabel.backgroundColor = [UIColor clearColor];
                        roomCountLabel.textColor = [UIColor grayColor];
                        roomCountLabel.font = [UIFont systemFontOfSize:16];
                        self.roomCountContentLabel = roomCountLabel;
                        [cell.contentView addSubview:self.roomCountContentLabel];
                        [roomCountLabel release];
                        
                        UILabel * arrivedTimeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 55, 80, 20)];
                        arrivedTimeShowLabel.backgroundColor = [UIColor clearColor];
                        arrivedTimeShowLabel.font = [UIFont systemFontOfSize:16];
                        arrivedTimeShowLabel.text = @"到店时间:";
                        [cell.contentView addSubview:arrivedTimeShowLabel];
                        [arrivedTimeShowLabel release];
                        
                        UILabel * arrivedTimeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 55, 180, 20)];
                        arrivedTimeContentLabel.backgroundColor = [UIColor clearColor];
                        arrivedTimeContentLabel.textColor = [UIColor grayColor];
                        arrivedTimeContentLabel.font = [UIFont systemFontOfSize:16];
                        self.arrivedTimeContentLabel = arrivedTimeContentLabel;
                        [cell.contentView addSubview:self.arrivedTimeContentLabel];
                        [arrivedTimeContentLabel release];
                        
                    }
                        break;
                }
                break;
            case 2:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont systemFontOfSize:18];
                        cell.textLabel.text = @"旅客信息";
                        break;
                }
                break;
            case 3:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.textColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor clearColor];
                        cell.textLabel.font = [UIFont systemFontOfSize:18];
                        cell.textLabel.text = @"联系信息";
                        break;
                    case 1:
                    {
                        UILabel * linkNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 80, 20)];
                        linkNameShowLabel.backgroundColor = [UIColor clearColor];
                        linkNameShowLabel.font = [UIFont systemFontOfSize:16];
                        linkNameShowLabel.text = @"\t\t联系人:";
                        [cell.contentView addSubview:linkNameShowLabel];
                        [linkNameShowLabel release];
                        
                        UILabel * linkNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 10, 180, 20)];
                        linkNameLabel.backgroundColor = [UIColor clearColor];
                        linkNameLabel.textColor = [UIColor grayColor];
                        linkNameLabel.font = [UIFont systemFontOfSize:16];
                        self.linkNameContentLabel = linkNameLabel;
                        [cell.contentView addSubview:self.linkNameContentLabel];
                        [linkNameLabel release];
                    }
                        break;
                    case 2:
                    {
                        UILabel * linkMobileShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 80, 20)];
                        linkMobileShowLabel.backgroundColor = [UIColor clearColor];
                        linkMobileShowLabel.font = [UIFont systemFontOfSize:16];
                        linkMobileShowLabel.text = @"手机号码:";
                        [cell.contentView addSubview:linkMobileShowLabel];
                        [linkMobileShowLabel release];
                        
                        UILabel * linkMobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 10, 180, 20)];
                        linkMobileLabel.backgroundColor = [UIColor clearColor];
                        linkMobileLabel.textColor = [UIColor grayColor];
                        linkMobileLabel.font = [UIFont systemFontOfSize:16];
                        self.linkMobileContentLabel = linkMobileLabel;
                        [cell.contentView addSubview:self.linkMobileContentLabel];
                        [linkMobileLabel release];
                    }
                        break;
                }
                break;
        }
    }
    
    if (self.hotelOrderInfoSearchResponseModel != nil) {
        
        switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 1:
                        self.orderIDContentLabel.text = self.tpsOrderId;
                        self.orderPriceContentLabel.text = [NSString stringWithFormat:@"¥%@",self.hotelOrderInfoSearchResponseModel.amount];
                        NSString * payMent = nil;
                        switch ([self.hotelOrderInfoSearchResponseModel.payment intValue]) {
                            case 0:
                                payMent = @"前台现付";
                                break;
                            case 1:
                                payMent = @"网银支付";
                                break;
                            case 2:
                                payMent = @"支付宝";
                                break;
                            case 3:
                                payMent = @"信用卡";
                                break;
                            case 4:
                                payMent = @"银联付款";
                                break;
                            case 5:
                                payMent = @"前台现付";
                                break;
                            case 6:
                                payMent = @"指纹识别";
                                break;
                            case 7:
                                payMent = @"优付宝";
                                break;
                            case 8:
                                payMent = @"易商卡";
                                break;
                        }
                        self.orderPayContentLabel.text = payMent;
                        break;
                    case 2:
                        self.orderTimeContentLabel.text = self.hotelOrderInfoSearchResponseModel.bookingTime;
                        NSString * resStatus = nil;
                        if ([@"HAC" isEqualToString:self.hotelOrderInfoSearchResponseModel.resStatus]) {
                            resStatus = @"拒绝";
                        } else if ([@"TST" isEqualToString:self.hotelOrderInfoSearchResponseModel.resStatus]){
                            resStatus = @"测试";
                        } else if ([@"CON" isEqualToString:self.hotelOrderInfoSearchResponseModel.resStatus]){
                            resStatus = @"确认";
                        } else if ([@"RCM" isEqualToString:self.hotelOrderInfoSearchResponseModel.resStatus]){
                            resStatus = @"房间确认";
                        } else if ([@"RES" isEqualToString:self.hotelOrderInfoSearchResponseModel.resStatus]){
                            resStatus = @"申请";
                        } else if ([@"MOD" isEqualToString:self.hotelOrderInfoSearchResponseModel.resStatus]){
                            resStatus = @"修改";
                        } else if ([@"XXX" isEqualToString:self.hotelOrderInfoSearchResponseModel.resStatus]){
                            resStatus = @"客户取消";
                        } else if ([@"CAN" isEqualToString:self.hotelOrderInfoSearchResponseModel.resStatus]){
                            resStatus = @"取消确认";
                        }
                        self.orderStatusContentLabel.text = resStatus;
                        break;
                }
                break;
            case 1:
                switch (indexPath.row) {
                    case 1:
                        self.hotelNameContentLabel.text = self.hotelOrderInfoSearchResponseModel.hotelName;
                        self.roomTypeContentLabel.text = self.hotelOrderInfoSearchResponseModel.roomName;
                        break;
                    case 2:
                        self.stayDayContentLabel.text = [NSString stringWithFormat:@"%@至%@",self.hotelOrderInfoSearchResponseModel.inDate,self.hotelOrderInfoSearchResponseModel.outDate];
                        self.roomCountContentLabel.text = [NSString stringWithFormat:@"%@间",self.hotelOrderInfoSearchResponseModel.roomNum];
                        NSMutableString * earlyTimeTemp = [NSMutableString stringWithString:self.hotelOrderInfoSearchResponseModel.earlyTime];
                        [earlyTimeTemp insertString:@":" atIndex:2];
                        NSMutableString * lateTimeTemp = [NSMutableString stringWithString:self.hotelOrderInfoSearchResponseModel.lateTime];
                        [lateTimeTemp insertString:@":" atIndex:2];
                        self.arrivedTimeContentLabel.text = [NSString stringWithFormat:@"%@时～%@时",earlyTimeTemp,lateTimeTemp];
                        break;
                }
                break;
            case 2:
            {
                if (indexPath.row!=0&&[self.guestArray count]!=0) {
                    
                    for (UIView * vi in [cell.contentView subviews]) {
                        [vi removeFromSuperview];
                    }
                    
                    NSString * guest = [self.guestArray objectAtIndex:indexPath.row-1];
                    
                    NSArray * guestInfo = [guest componentsSeparatedByString:@"/"];
                    
                    UILabel * contractNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 80, 20)];
                    contractNameShowLabel.backgroundColor = [UIColor clearColor];
                    contractNameShowLabel.font = [UIFont systemFontOfSize:16];
                    contractNameShowLabel.text = [NSString stringWithFormat:@"\t\t旅客(%d):",indexPath.row];
                    [cell.contentView addSubview:contractNameShowLabel];
                    [contractNameShowLabel release];
                    
                    UILabel * contractNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 5, 200, 20)];
                    contractNameLabel.backgroundColor = [UIColor clearColor];
                    contractNameLabel.textColor = [UIColor grayColor];
                    contractNameLabel.font = [UIFont systemFontOfSize:16];
                    contractNameLabel.text = [guestInfo objectAtIndex:0];
                    [cell.contentView addSubview:contractNameLabel];
                    [contractNameLabel release];
                    
                    UILabel * contractPhoneShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 80, 20)];
                    contractPhoneShowLabel.backgroundColor = [UIColor clearColor];
                    contractPhoneShowLabel.font = [UIFont systemFontOfSize:16];
                    contractPhoneShowLabel.text = @"旅客手机:";
                    [cell.contentView addSubview:contractPhoneShowLabel];
                    [contractPhoneShowLabel release];
                    
                    UILabel * contractPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, 180, 20)];
                    contractPhoneLabel.backgroundColor = [UIColor clearColor];
                    contractPhoneLabel.textColor = [UIColor grayColor];
                    contractPhoneLabel.font = [UIFont systemFontOfSize:16];
                    contractPhoneLabel.text = [guestInfo objectAtIndex:1];
                    [cell.contentView addSubview:contractPhoneLabel];
                    [contractPhoneLabel release];
                }
                
            }
                break;
            case 3:
                switch (indexPath.row) {
                    case 1:
                        self.linkNameContentLabel.text = self.hotelOrderInfoSearchResponseModel.linkName;
                        break;
                    case 2:
                        self.linkMobileContentLabel.text = self.hotelOrderInfoSearchResponseModel.linkMobile;
                        break;
                }
                break;
                
        }
    }
    
    if (indexPath.row == 0) {
        NSString *tableViewCellGroupTopTitlePath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_group_topTitle" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellGroupTopTitlePath]] autorelease];
    } else if(indexPath.row == [self.hotelOrderInfoTableView numberOfRowsInSection:indexPath.section]-1){
        NSString *tableViewCellBottomNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_normal" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomNormalPath]] autorelease];
    } else {
        NSString *tableViewCellCenterNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_normal" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterNormalPath]] autorelease];
    }
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath row]==0) {
        return 36;
    } else if([indexPath section] == 0 && [indexPath row] == 1){//第一区第二行
        return 80;
    }else if([indexPath section] == 0 && [indexPath row] == 2){//第一区第三行
        return 55;
    }else if([indexPath section] == 1 && [indexPath row] == 1){//第二区第二行
        return 55;
    }else if([indexPath section] == 1 && [indexPath row] == 2){//第二区第三行
        return 80;
    }else if([indexPath section] == 3 && [indexPath row] == 1){//第四区第二行
        return 40;
    }else if([indexPath section] == 3 && [indexPath row] == 2){//第四区第三行
        return 40;
    }else {
        return 55;
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

//
//  OrderSearchMemberViewController.m
//  UCAI
//
//  Created by  on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "OrderSearchMemberViewController.h"
#import "CommonTools.h"
#import "GDataXMLNode.h"
#import "ASIFormDataRequest.h"
#import "StaticConf.h"
#import "ResponseParser.h"

#import "HotelOrderListSearchResponseModel.h"
#import "HotelOrderListInfoModel.h"

#import "PiosaFileManager.h"

#import "HotelOrderInfoViewController.h"

#import "FlightOrderListSearchResponseModel.h"
#import "FlightOrderListInfoModel.h"
#import "FlightOrderInfoViewController.h"

#define kHeightForTableCell 65

#define kFlightOrderLeftSegmentControlButtonTag 101
#define kHotelOrderRightSegmentControlButtonTag 102

#define kSearchInputTableViewTag 201
#define kHotelTableViewTag 202
#define kFlightTableViewTag 203

#define kHotelRefreshTableHeaderViewTag 301
#define kFlightRefreshTableHeaderViewTag 302

#define kHotelCellOrderIDTag 401
#define kHotelCellStatusTag 402
#define kHotelCellHotelNameTag 403
#define kHotelCellBookTimeTag 404
#define kHotelCellPriceAmountTag 405

#define kFlightCellOrderIDTag 501
#define kFlightCellStatusTag 502
#define kFlightCellCityTag 503
#define kFlightCellTypeTag 504
#define kFlightCellOrderTimeTag 505
#define kFlightCellPriceAmountTag 506

@implementation OrderSearchMemberViewController

@synthesize bigLeftSegmentControlButton = _bigLeftSegmentControlButton;
@synthesize bigRightSegmentControlButton = _bigRightSegmentControlButton;

@synthesize hotelTableView = _hotelTableView;
@synthesize flightTableView = _flightTableView;

@synthesize hotelOrderListSearchResponseModel = _hotelOrderListSearchResponseModel;
@synthesize flightOrderListSearchResponseModel = _flightOrderListSearchResponseModel;

@synthesize req = _req;

- (void)dealloc{
    [self.bigLeftSegmentControlButton release];
    [self.bigRightSegmentControlButton release];
    
    [self.hotelTableView release];
    [self.flightTableView release];
    
    if (![self.req isFinished]) {//异步请求未完成时
		[self.req clearDelegatesAndCancel];
	}
    [self.req release];
    
    [self.hotelOrderListSearchResponseModel release];
    
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

//信息标签按钮按下后的触发函数
- (void)infoSegmentControlAction:(UIButton *)segmentControlButton
{
    switch (segmentControlButton.tag) {
        case kFlightOrderLeftSegmentControlButtonTag:
            //设置机票订单按钮为选中
            [self.bigLeftSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.bigLeftSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            NSString *titleLeftSegmentControlButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleLeftSegmentControlButton_selected" inDirectory:@"CommonView/TitleSegmentedControl"];
            [self.bigLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonSelectedPath] forState:UIControlStateNormal];
            [self.bigLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonSelectedPath] forState:UIControlStateHighlighted];
            //设置酒店订单按钮为非选中
            [self.bigRightSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateNormal];
            [self.bigRightSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateHighlighted];
            NSString *titleRightSegmentControlButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleRightSegmentControlButton_normal" inDirectory:@"CommonView/TitleSegmentedControl"];
            [self.bigRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonNormalPath] forState:UIControlStateNormal];
            [self.bigRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonNormalPath] forState:UIControlStateHighlighted];
            
            self.flightTableView.hidden = NO;
            self.hotelTableView.hidden = YES;
            break;
        case kHotelOrderRightSegmentControlButtonTag:
            //设置房型信息按钮为非选中
            [self.bigLeftSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateNormal];
            [self.bigLeftSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateHighlighted];
            NSString *titleLeftSegmentControlButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleLeftSegmentControlButton_normal" inDirectory:@"CommonView/TitleSegmentedControl"];
            [self.bigLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonNormalPath] forState:UIControlStateNormal];
            [self.bigLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonNormalPath] forState:UIControlStateHighlighted];
            //设置酒店信息按钮为选中
            [self.bigRightSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.bigRightSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            NSString *titleRightSegmentControlButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleRightSegmentControlButton_selected" inDirectory:@"CommonView/TitleSegmentedControl"];
            [self.bigRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonSelectedPath] forState:UIControlStateNormal];
            [self.bigRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonSelectedPath] forState:UIControlStateHighlighted];
            
            self.flightTableView.hidden = YES;
            self.hotelTableView.hidden = NO;
            break;
    }
    [self searchOrderList];
}



- (void)searchOrderList{
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"查询中...";
    [_hud show:YES];
    
    if (![self.req isFinished]) {
        NSLog(@"self.req is Finished");
        [self.req clearDelegatesAndCancel]; //取消可能存在的请求
        [self doneLoadingTableViewData:_hotelRefreshHeaderView]; //取消加载完成数据，修改拉动刷新框的位置与其它参数
    } else {
        NSLog(@"self.req is not Finished");
    }

    
    if (self.hotelTableView.hidden) {
        _requestType = 3;
        
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:FLIGHT_MEMBER_ORDERLIST_ADDRESS]];
        request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
        
        NSString *postData = [[NSString alloc] initWithData:[self generateFlightOrderListSearchRequestPostXMLData:@"1"] encoding:NSUTF8StringEncoding];
        NSLog(@"requestStart\n");
        NSLog(@"%@\n", postData);
        [postData release];
        
        [request appendPostData:[self generateFlightOrderListSearchRequestPostXMLData:@"1"]];
        [request setDelegate:self];
        [request startAsynchronous]; // 执行异步post
        self.req = request;
        [request release];
    } else {
        _requestType = 1;
        
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:HOTEL_ORDERLIST_ADDRESS]] ;
        request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
        
        NSString *postData = [[NSString alloc] initWithData:[self generateHotelOrderListSearchRequestPostXMLData:@"1"] encoding:NSUTF8StringEncoding];
        NSLog(@"requestStart\n");
        NSLog(@"%@\n", postData);
        [request setPostValue:postData forKey:@"requestXml"];
        
        [request setDelegate:self];
        [request startAsynchronous]; // 执行异步post
        self.req = request;
        [request release];
        [postData release];
    }
}

- (NSData*)generateFlightOrderListSearchRequestPostXMLData:(NSString *) pageIndex {
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
    
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *pageInfoElement = [GDataXMLElement elementWithName:@"pageInfo"];
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"currentPage" stringValue:pageIndex]];
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"pageSize" stringValue:@"10"]];
    [requestElement addChild:pageInfoElement];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"memberID" stringValue:[memberDict objectForKey:@"memberID"]]];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    return document.XMLData;
}

- (NSData*)generateHotelOrderListSearchRequestPostXMLData:(NSString *) pageIndex {
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
    
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
	[requestElement addChild:[GDataXMLNode elementWithName:@"memberId" stringValue:[memberDict objectForKey:@"memberID"]]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"password" stringValue:@""]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"sj" stringValue:[UIDevice currentDevice].uniqueIdentifier]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"linkman" stringValue:@""]];
    [requestElement addChild:[GDataXMLNode elementWithName:@"mobile" stringValue:@""]];
    [requestElement addChild:[GDataXMLNode elementWithName:@"pageIndex" stringValue:pageIndex]];
    [requestElement addChild:[GDataXMLNode elementWithName:@"pageSize" stringValue:@"10"]];
    
	GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
	[document setVersion:@"1.0"]; // 设置xml版本为 1.0
	[document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
	
	NSData *xmlData = document.XMLData;
	return xmlData;
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
            case 1:{//酒店订单列表查询
                // 关闭加载框
                [_hud hide:YES];
                
                HotelOrderListSearchResponseModel *hotelOrderListSearchResponseModel = [ResponseParser loadHotelOrderListSearchResponse:[request responseData] oldHotelOrderList:nil];
                
                if (hotelOrderListSearchResponseModel.resultCode == nil || [hotelOrderListSearchResponseModel.resultCode length] == 0 || [hotelOrderListSearchResponseModel.resultCode intValue] != 1) {
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
                    hud.labelText = hotelOrderListSearchResponseModel.resultMessage;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    
                    self.hotelOrderListSearchResponseModel = hotelOrderListSearchResponseModel;
                    [self.hotelTableView reloadData];
                    self.hotelTableView.contentOffset = CGPointMake(0, 0);//列表回顶部
                    
                    //设置拉动刷新框
                    int numberOfRowForHotelList = self.hotelOrderListSearchResponseModel.hotelOrderArray == nil ? 0 : [self.hotelOrderListSearchResponseModel.hotelOrderArray count];
                    [_hotelRefreshHeaderView setFrame:CGRectMake(0, kHeightForTableCell*numberOfRowForHotelList, 320, 70)];//重设拉动刷新框的位置
                    
                    if ([self.hotelOrderListSearchResponseModel.pageSize intValue]*[self.hotelOrderListSearchResponseModel.pageIndex intValue]>=[self.hotelOrderListSearchResponseModel.orderNum intValue]) {
                        //如果当前页为最后一页，则隐藏拉动刷新框
                        [_hotelRefreshHeaderView setHidden:YES];
                    } else {
                        //如果当前页不为最后一页，则显示拉动刷新框
                        [_hotelRefreshHeaderView setHidden:NO];
                    }
                }
            }
                break;
            case 2:{//酒店订单列表加载更多
                HotelOrderListSearchResponseModel *hotelOrderListSearchResponseModel = [ResponseParser loadHotelOrderListSearchResponse:[request responseData] oldHotelOrderList:self.hotelOrderListSearchResponseModel];
                
                if (hotelOrderListSearchResponseModel.resultCode == nil || [hotelOrderListSearchResponseModel.resultCode length] == 0 || [hotelOrderListSearchResponseModel.resultCode intValue] != 1) {
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
                    hud.labelText = hotelOrderListSearchResponseModel.resultMessage;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    self.hotelOrderListSearchResponseModel = hotelOrderListSearchResponseModel;
                    [_hotelRefreshHeaderView setHidden:TRUE];//隐藏拉动刷新框，因为当加载速度很快时，拉动刷新框在doneLoadingTableViewData里调整位置前，已经显示出了hotelListTableView的新数据
                    [self.hotelTableView reloadData];
                }
                [self doneLoadingTableViewData:_hotelRefreshHeaderView]; //加载完成数据，修改拉动刷新框的位置与其它参数
            }
                break;
            case 3:{//机票订单列表查询
                // 关闭加载框
                [_hud hide:YES];
                FlightOrderListSearchResponseModel *flightOrderListSearchResponseModel = [ResponseParser loadFlightOrderListSearchResponse:[request responseData] oldFlightOrderList:nil];
                if (flightOrderListSearchResponseModel.resultCode == 0 || [flightOrderListSearchResponseModel.orders count] == 0) {
                    // 提示用户打开网络联接
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
                    hud.labelText = flightOrderListSearchResponseModel.resultMessage;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                }
                else {
                    self.flightOrderListSearchResponseModel = flightOrderListSearchResponseModel;
                    [self.flightTableView reloadData];
                    self.flightTableView.contentOffset = CGPointMake(0, 0);//列表回顶部
                    
                    //设置拉动刷新框
                    int numberOfRowForFlightList = self.flightOrderListSearchResponseModel.orders == nil ? 0 : [self.flightOrderListSearchResponseModel.orders count];
                    [_flightRefreshHeaderView setFrame:CGRectMake(0, kHeightForTableCell*numberOfRowForFlightList, 320, 70)];//重设拉动刷新框的位置
                    
                    if ([self.flightOrderListSearchResponseModel.pageSize intValue]*[self.flightOrderListSearchResponseModel.currentPage intValue]>=[self.flightOrderListSearchResponseModel.count intValue]) {
                        //如果当前页为最后一页，则隐藏拉动刷新框
                        [_flightRefreshHeaderView setHidden:YES];
                    } else {
                        //如果当前页不为最后一页，则显示拉动刷新框
                        [_flightRefreshHeaderView setHidden:NO];
                    }
                }
            }
                break;
                
            case 4:{//机票订单列表加载更多
                FlightOrderListSearchResponseModel *flightOrderListSearchResponseModel = [ResponseParser loadFlightOrderListSearchResponse:[request responseData] oldFlightOrderList:self.flightOrderListSearchResponseModel];
                if ([@"1" isEqualToString:flightOrderListSearchResponseModel.resultCode]) {
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
                    hud.labelText = flightOrderListSearchResponseModel.resultMessage;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else if (flightOrderListSearchResponseModel.resultCode == 0 || [flightOrderListSearchResponseModel.orders count] == 0) {
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
                    hud.labelText = @"没有满足条件的订单!";
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    self.flightOrderListSearchResponseModel = flightOrderListSearchResponseModel;
                    [_flightRefreshHeaderView setHidden:TRUE];//隐藏拉动刷新框，因为当加载速度很快时，拉动刷新框在doneLoadingTableViewData里调整位置前，已经显示出了flightListTableView的新数据
                    [self.flightTableView reloadData];
                    
                }
                [self doneLoadingTableViewData:_flightRefreshHeaderView]; //加载完成数据，修改拉动刷新框的位置与其它参数   
            }
                break;
        }
    }
}

// 网络无响应
- (void)requestFailed:(ASIFormDataRequest *)request
{
	// 提示用户打开网络联接
    if (_requestType == 2 || _requestType == 4) {
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
    
    if (_requestType == 1 || _requestType == 2) {
        [self doneLoadingTableViewData:_hotelRefreshHeaderView]; //加载完成数据，修改拉动刷新框的位置与其它参数
    } else {
        [self doneLoadingTableViewData:_flightRefreshHeaderView]; //加载完成数据，修改拉动刷新框的位置与其它参数
    }
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    self.title = @"会员订单中心";
    
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
    
    //机票订单左按钮
    UIButton * tempLeftSegmentedButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 150, 34)];
    tempLeftSegmentedButton.tag = kFlightOrderLeftSegmentControlButtonTag;
    [tempLeftSegmentedButton setTitle:@"机票" forState:UIControlStateNormal];
    [tempLeftSegmentedButton setTitle:@"机票" forState:UIControlStateSelected];
    tempLeftSegmentedButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [tempLeftSegmentedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tempLeftSegmentedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    NSString *titleLeftSegmentControlButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleLeftSegmentControlButton_selected" inDirectory:@"CommonView/TitleSegmentedControl"];
    [tempLeftSegmentedButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonSelectedPath] forState:UIControlStateNormal];
    [tempLeftSegmentedButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonSelectedPath] forState:UIControlStateHighlighted];
    [tempLeftSegmentedButton addTarget:self action:@selector(infoSegmentControlAction:) forControlEvents:UIControlEventTouchDown];
    self.bigLeftSegmentControlButton = tempLeftSegmentedButton;
    [self.view addSubview:self.bigLeftSegmentControlButton];
    [tempLeftSegmentedButton release];
    
    //酒店订单右按钮
    UIButton * tempRightSegmentedButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 10, 150, 34)];
    tempRightSegmentedButton.tag =kHotelOrderRightSegmentControlButtonTag;
    [tempRightSegmentedButton setTitle:@"酒店" forState:UIControlStateNormal];
    [tempRightSegmentedButton setTitle:@"酒店" forState:UIControlStateSelected];
    tempRightSegmentedButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [tempRightSegmentedButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateNormal];
    [tempRightSegmentedButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateHighlighted];
    NSString *titleRightSegmentControlButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleRightSegmentControlButton_normal" inDirectory:@"CommonView/TitleSegmentedControl"];
    [tempRightSegmentedButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonNormalPath] forState:UIControlStateNormal];
    [tempRightSegmentedButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonNormalPath] forState:UIControlStateHighlighted];
    [tempRightSegmentedButton addTarget:self action:@selector(infoSegmentControlAction:) forControlEvents:UIControlEventTouchDown];
    self.bigRightSegmentControlButton = tempRightSegmentedButton;
    [self.view addSubview:self.bigRightSegmentControlButton];
    [tempRightSegmentedButton release];
    
    UITableView * tempFlightTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 54, 300, 360) style:UITableViewStylePlain];
    tempFlightTableView.dataSource = self;
    tempFlightTableView.delegate = self;
    tempFlightTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    tempFlightTableView.tag = kFlightTableViewTag;
    self.flightTableView = tempFlightTableView;
    [self.view addSubview:self.flightTableView];
    [tempFlightTableView release];
    FlightOrderListSearchResponseModel * flightOrderListSearchResponseModel = [[FlightOrderListSearchResponseModel alloc] init];
    self.flightOrderListSearchResponseModel = flightOrderListSearchResponseModel;
    [flightOrderListSearchResponseModel release];
    
    //机票订单列表的拉动刷新框
	if (_flightRefreshHeaderView == nil) {
        EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
		view1.delegate = self; 
        //隐藏机票订单列表的拉动刷新框
        [view1 setHidden:YES];
        [self.flightTableView addSubview:view1]; 
        _flightRefreshHeaderView = view1; 
        _flightRefreshHeaderView.tag = kFlightRefreshTableHeaderViewTag;
        [view1 release]; 
    } 
    [_hotelRefreshHeaderView refreshLastUpdatedDate];
    
    UITableView * tempHotelTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 54, 300, 360) style:UITableViewStylePlain];
    tempHotelTableView.dataSource = self;
    tempHotelTableView.delegate = self;
    tempHotelTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tempHotelTableView.tag = kHotelTableViewTag;
    tempHotelTableView.hidden = YES;
    self.hotelTableView = tempHotelTableView;
    [self.view addSubview:self.hotelTableView];
    [tempHotelTableView release];
    
    HotelOrderListSearchResponseModel * hotelOrderListSearchResponseModelTemp = [[HotelOrderListSearchResponseModel alloc] init];
    self.hotelOrderListSearchResponseModel = hotelOrderListSearchResponseModelTemp;
    [hotelOrderListSearchResponseModelTemp release];
    
    //酒店订单列表的拉动刷新框
	if (_hotelRefreshHeaderView == nil) {
        EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
		view1.delegate = self; 
        //隐藏酒店订单列表的拉动刷新框
        [view1 setHidden:YES];
        [self.hotelTableView addSubview:view1]; 
        _hotelRefreshHeaderView = view1; 
        _hotelRefreshHeaderView.tag = kHotelRefreshTableHeaderViewTag;
        [view1 release]; 
    } 
    [_hotelRefreshHeaderView refreshLastUpdatedDate];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self searchOrderList];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource:(EGORefreshTableHeaderView *) eGORefreshTableHeaderView{ 
    NSLog(@"==开始加载数据"); 
    if (eGORefreshTableHeaderView.tag == kHotelRefreshTableHeaderViewTag) {
        _hotelReloading = YES;
    } else if (eGORefreshTableHeaderView.tag == kFlightRefreshTableHeaderViewTag){
        _flightReloading = YES;
    }
    
}

- (void)doneLoadingTableViewData:(EGORefreshTableHeaderView *) eGORefreshTableHeaderView{
    NSLog(@"===加载完数据");
    if (eGORefreshTableHeaderView.tag == kHotelRefreshTableHeaderViewTag) {
        _hotelReloading = NO; 
        [_hotelRefreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.hotelTableView];
        
        //设置拉动刷新框
        int numberOfRowForHotelList = self.hotelOrderListSearchResponseModel.hotelOrderArray == nil ? 0 : [self.hotelOrderListSearchResponseModel.hotelOrderArray count];
        [_hotelRefreshHeaderView setFrame:CGRectMake(0, kHeightForTableCell*numberOfRowForHotelList, 320, 70)];//调整拉动刷新框的位置，使其位于刷新后的酒店列表下
        if ([self.hotelOrderListSearchResponseModel.pageSize intValue]*[self.hotelOrderListSearchResponseModel.pageIndex intValue]>=[self.hotelOrderListSearchResponseModel.orderNum intValue]) {
            //如果当前页为最后一页，则隐藏拉动刷新框
            [_hotelRefreshHeaderView setHidden:YES];
        } else {
            //如果当前页不为最后一页，则显示拉动刷新框
            [_hotelRefreshHeaderView setHidden:NO];
        }
    } else if (eGORefreshTableHeaderView.tag == kFlightRefreshTableHeaderViewTag){
        _flightReloading = NO; 
        [_flightRefreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.flightTableView];
        
        //设置拉动刷新框
        int numberOfRowForFlightList = self.flightOrderListSearchResponseModel.orders == nil ? 0 : [self.flightOrderListSearchResponseModel.orders count];
        [_flightRefreshHeaderView setFrame:CGRectMake(0, kHeightForTableCell*numberOfRowForFlightList, 320, 70)];//调整拉动刷新框的位置，使其位于刷新后的酒店列表下
        if ([self.flightOrderListSearchResponseModel.pageSize intValue]*[self.flightOrderListSearchResponseModel.currentPage intValue]>=[self.flightOrderListSearchResponseModel.count intValue]) {
            //如果当前页为最后一页，则隐藏拉动刷新框
            [_flightRefreshHeaderView setHidden:YES];
        } else {
            //如果当前页不为最后一页，则显示拉动刷新框
            [_flightRefreshHeaderView setHidden:NO];
        }
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods 
//手指屏幕上不断拖动时调用此方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{ 
    if (scrollView.tag == kHotelTableViewTag) {
        //拖动酒店订单列表时
        [_hotelRefreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    } else if(scrollView.tag == kFlightTableViewTag){
        //拖动机票订单列表时
        [_flightRefreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
     
}

//当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (scrollView.tag == kHotelTableViewTag) {
        //停止拖动酒店订单列表时
        if ([self.hotelOrderListSearchResponseModel.pageSize intValue]*[self.hotelOrderListSearchResponseModel.pageIndex intValue]<[self.hotelOrderListSearchResponseModel.orderNum intValue]) {
            //显示最后一页时，可以不用调用方法来设置刷新视图
            [_hotelRefreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView]; 
        }
    } else if(scrollView.tag == kFlightTableViewTag){
        //停止拖动机票订单列表时
        if ([self.flightOrderListSearchResponseModel.pageSize intValue]*[self.flightOrderListSearchResponseModel.currentPage intValue]<[self.flightOrderListSearchResponseModel.count intValue]) {
            //显示最后一页时，可以不用调用方法来设置刷新视图
            [_flightRefreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView]; 
        }
    }
} 

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods 
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    if (![self.req isFinished]) {
        NSLog(@"self.req is Finished");
        [self.req clearDelegatesAndCancel]; //取消可能存在的请求
        [self doneLoadingTableViewData:_hotelRefreshHeaderView]; //取消加载完成数据，修改拉动刷新框的位置与其它参数
    } else {
        NSLog(@"self.req is not Finished");
    }
    
    switch (view.tag) {
        case kHotelRefreshTableHeaderViewTag:{
            [self reloadTableViewDataSource:_hotelRefreshHeaderView]; //开始加载更多数据
            
            _requestType = 2;
            
            ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: HOTEL_ORDERLIST_ADDRESS]];
            request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
            
            NSInteger index = [self.hotelOrderListSearchResponseModel.pageIndex intValue]+1;
            NSString *postData = [[NSString alloc] initWithData:[self generateHotelOrderListSearchRequestPostXMLData:[NSString stringWithFormat:@"%d",index]] encoding:NSUTF8StringEncoding];
            NSLog(@"requestStart\n");
            NSLog(@"%@\n", postData);
            [request setPostValue:postData forKey:@"requestXml"];
            [request setDelegate:self];
            [request startAsynchronous]; // 执行异步post
            self.req = request;
            [request release];
            [postData release];
        }
            break;
        case kFlightRefreshTableHeaderViewTag:{
            [self reloadTableViewDataSource:_flightRefreshHeaderView]; //开始加载更多数据
            
            _requestType = 4;
            
            ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:FLIGHT_MEMBER_ORDERLIST_ADDRESS]];
            request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
            
            NSInteger index = [self.flightOrderListSearchResponseModel.currentPage intValue]+1;
            [request appendPostData:[self generateFlightOrderListSearchRequestPostXMLData:[NSString stringWithFormat:@"%d",index]]];
            
            NSString *postData2 = [[NSString alloc] initWithData:[self generateFlightOrderListSearchRequestPostXMLData:[NSString stringWithFormat:@"%d",index]] encoding:NSUTF8StringEncoding];
            NSLog(@"requestStart\n");
            NSLog(@"%@\n", postData2);
            [postData2 release];
            
            [request setDelegate:self];
            [request startAsynchronous]; // 执行异步post
            self.req = request;
            [request release];
        }
            break;
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    BOOL result;
    switch (view.tag) {
        case kHotelRefreshTableHeaderViewTag:{
            result = _hotelReloading;
        }
            break;
        case kFlightRefreshTableHeaderViewTag:{
            result = _flightReloading;
        }
            break;
    }
    return result; 
} 

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];     
} 


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (tableView.tag) {
        case kHotelTableViewTag:
            return self.hotelOrderListSearchResponseModel.hotelOrderArray == nil ? 0 : [self.hotelOrderListSearchResponseModel.hotelOrderArray count];
            break;
        case kFlightTableViewTag:
            return self.flightOrderListSearchResponseModel.orders == nil ? 0 : [self.flightOrderListSearchResponseModel.orders count];
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return kHeightForTableCell;
}

//设置表格单元的展现
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        if (tableView.tag == kHotelTableViewTag){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            //设置酒店订单号
            UILabel * initCellOrderIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 140, 20)];
            initCellOrderIDLabel.tag = kHotelCellOrderIDTag;
            initCellOrderIDLabel.backgroundColor = [UIColor clearColor];
            initCellOrderIDLabel.font = [UIFont systemFontOfSize:12];
            initCellOrderIDLabel.textColor = [PiosaColorManager fontColor];
            [cell.contentView addSubview:initCellOrderIDLabel];
            [initCellOrderIDLabel release];
            
            //设置酒店订单状态
            UILabel * initCellStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 5, 130, 20)];
            initCellStatusLabel.tag = kHotelCellStatusTag;
            initCellStatusLabel.backgroundColor = [UIColor clearColor];
            initCellStatusLabel.textColor = [UIColor grayColor];
            initCellStatusLabel.font = [UIFont systemFontOfSize:12];
            initCellStatusLabel.textAlignment =  UITextAlignmentRight;
            [cell.contentView addSubview:initCellStatusLabel];
            [initCellStatusLabel release];
            
            //设置酒店名称
            UILabel * initCellHotelNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 26, 270, 20)];
            initCellHotelNameLabel.tag = kHotelCellHotelNameTag;
            initCellHotelNameLabel.backgroundColor = [UIColor clearColor];
            initCellHotelNameLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:initCellHotelNameLabel];
            [initCellHotelNameLabel release];
            
            //设置订购时间
            UILabel * initCellBookTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 44, 190, 20)];
            initCellBookTimeLabel.tag = kHotelCellBookTimeTag;
            initCellBookTimeLabel.backgroundColor = [UIColor clearColor];
            initCellBookTimeLabel.font = [UIFont systemFontOfSize:12];
            initCellBookTimeLabel.textColor = [UIColor grayColor];
            [cell.contentView addSubview:initCellBookTimeLabel];
            [initCellBookTimeLabel release];
            
            //设置订单金额
            UILabel * initCellPriceAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 44, 80, 20)];
            initCellPriceAmountLabel.tag = kHotelCellPriceAmountTag;
            initCellPriceAmountLabel.backgroundColor = [UIColor clearColor];
            initCellPriceAmountLabel.textAlignment =  UITextAlignmentRight;
            initCellPriceAmountLabel.textColor = [UIColor redColor];
            initCellPriceAmountLabel.font = [UIFont boldSystemFontOfSize:12];
            [cell.contentView addSubview:initCellPriceAmountLabel];
            [initCellPriceAmountLabel release];
        } else if (tableView.tag == kFlightTableViewTag){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            //设置机票订单号
            UILabel * initCellOrderIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 140, 20)];
            initCellOrderIDLabel.tag = kFlightCellOrderIDTag;
            initCellOrderIDLabel.backgroundColor = [UIColor clearColor];
            initCellOrderIDLabel.font = [UIFont systemFontOfSize:12];
            initCellOrderIDLabel.textColor = [PiosaColorManager fontColor];
            [cell.contentView addSubview:initCellOrderIDLabel];
            [initCellOrderIDLabel release];
            
            //设置机票订单状态
            UILabel * initCellStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 5, 127, 20)];
            initCellStatusLabel.tag = kFlightCellStatusTag;
            initCellStatusLabel.backgroundColor = [UIColor clearColor];
            initCellStatusLabel.textColor = [UIColor grayColor];
            initCellStatusLabel.font = [UIFont systemFontOfSize:12];
            initCellStatusLabel.textAlignment =  UITextAlignmentRight;
            [cell.contentView addSubview:initCellStatusLabel];
            [initCellStatusLabel release];
            
            //设置机票订单出发到达城市
            UILabel * initCellCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 190, 20)];
            initCellCityLabel.tag = kFlightCellCityTag;
            initCellCityLabel.backgroundColor = [UIColor clearColor];
            initCellCityLabel.textColor = [UIColor blackColor];
            initCellCityLabel.font = [UIFont systemFontOfSize:14];
            initCellCityLabel.textAlignment =  UITextAlignmentLeft;
            [cell.contentView addSubview:initCellCityLabel];
            [initCellCityLabel release];
            
            //设置机票订单航程类型
            UILabel * initCellTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 25, 77, 20)];
            initCellTypeLabel.tag = kFlightCellTypeTag;
            initCellTypeLabel.backgroundColor = [UIColor clearColor];
            initCellTypeLabel.textColor = [UIColor blackColor];
            initCellTypeLabel.font = [UIFont systemFontOfSize:14];
            initCellTypeLabel.textAlignment =  UITextAlignmentRight;
            [cell.contentView addSubview:initCellTypeLabel];
            [initCellTypeLabel release];
            
            
            //设置机票订单时间
            UILabel * initCellOrderTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 44, 190, 20)];
            initCellOrderTimeLabel.tag = kFlightCellOrderTimeTag;
            initCellOrderTimeLabel.backgroundColor = [UIColor clearColor];
            initCellOrderTimeLabel.textColor = [UIColor grayColor];
            initCellOrderTimeLabel.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:initCellOrderTimeLabel];
            [initCellOrderTimeLabel release];
            
            //设置机票订单金额
            UILabel * initCellPriceAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 44, 77, 20)];
            initCellPriceAmountLabel.tag = kFlightCellPriceAmountTag;
            initCellPriceAmountLabel.backgroundColor = [UIColor clearColor];
            initCellPriceAmountLabel.textAlignment =  UITextAlignmentRight;
            initCellPriceAmountLabel.textColor = [UIColor redColor];
            initCellPriceAmountLabel.font = [UIFont boldSystemFontOfSize:12];
            [cell.contentView addSubview:initCellPriceAmountLabel];
            [initCellPriceAmountLabel release];
        }
	}
    
    if (tableView.tag == kHotelTableViewTag) {
        HotelOrderListInfoModel * hotelOrderListInfoModel = (HotelOrderListInfoModel *)[self.hotelOrderListSearchResponseModel.hotelOrderArray objectAtIndex:indexPath.row];
        
        UILabel * cellOrderIDLabel = (UILabel *)[cell.contentView viewWithTag:kHotelCellOrderIDTag];
        cellOrderIDLabel.text = hotelOrderListInfoModel.tpsOrderId;
        
        NSString * resStatus = nil;
        if ([@"HAC" isEqualToString:hotelOrderListInfoModel.resStatus]) {
            resStatus = @"拒绝";
        } else if ([@"TST" isEqualToString:hotelOrderListInfoModel.resStatus]){
            resStatus = @"测试";
        } else if ([@"CON" isEqualToString:hotelOrderListInfoModel.resStatus]){
            resStatus = @"确认";
        } else if ([@"RCM" isEqualToString:hotelOrderListInfoModel.resStatus]){
            resStatus = @"房间确认";
        } else if ([@"RES" isEqualToString:hotelOrderListInfoModel.resStatus]){
            resStatus = @"申请";
        } else if ([@"MOD" isEqualToString:hotelOrderListInfoModel.resStatus]){
            resStatus = @"修改";
        } else if ([@"XXX" isEqualToString:hotelOrderListInfoModel.resStatus]){
            resStatus = @"客户取消";
        } else if ([@"CAN" isEqualToString:hotelOrderListInfoModel.resStatus]){
            resStatus = @"取消确认";
        }
        NSString * payStatus = nil;
        if ([@"1" isEqualToString:hotelOrderListInfoModel.payStatus]) {
            payStatus = @"已支付";
        } else {
            payStatus = @"未支付";
        }
        UILabel * cellStatusLabel = (UILabel *)[cell.contentView viewWithTag:kHotelCellStatusTag];
        cellStatusLabel.text = [NSString stringWithFormat:@"状态:%@(%@)",resStatus,payStatus];
        
        UILabel * cellHotelNameLabel = (UILabel *)[cell.contentView viewWithTag:kHotelCellHotelNameTag];
        cellHotelNameLabel.text = hotelOrderListInfoModel.hotelName;
        
        UILabel * cellBookTimeLabel = (UILabel *)[cell.contentView viewWithTag:kHotelCellBookTimeTag];
        cellBookTimeLabel.text = [NSString stringWithFormat:@"订购时间:%@",hotelOrderListInfoModel.bookTime];
        
        UILabel * cellPriceAmountLabel = (UILabel *)[cell.contentView viewWithTag:kHotelCellPriceAmountTag];
        cellPriceAmountLabel.text = [NSString stringWithFormat:@"¥%@",hotelOrderListInfoModel.amount];
    } else if (tableView.tag == kFlightTableViewTag){
        FlightOrderListInfoModel * flightOrderListInfoModel = (FlightOrderListInfoModel *)[self.flightOrderListSearchResponseModel.orders objectAtIndex:indexPath.row];
        
        UILabel * cellOrderIDLabel = (UILabel *)[cell.contentView viewWithTag:kFlightCellOrderIDTag];
        cellOrderIDLabel.text = flightOrderListInfoModel.orderID;
        
        NSString * payStatus = nil;
        if ([@"1" isEqualToString:flightOrderListInfoModel.orderStatus]) {
            payStatus = @"已支付";
        } else {
            payStatus = @"未支付";
        }
        UILabel * cellStatusLabel = (UILabel *)[cell.contentView viewWithTag:kFlightCellStatusTag];
        cellStatusLabel.text = [NSString stringWithFormat:@"%@",payStatus];
        
        UILabel * cellCityLabel = (UILabel *)[cell.contentView viewWithTag:kFlightCellCityTag];
        
        NSString * orderType = nil;
        if ([@"1" isEqualToString:flightOrderListInfoModel.orderType]) {
            orderType = @"单程";
            cellCityLabel.text = [NSString stringWithFormat:@"%@ ⇒ %@",flightOrderListInfoModel.fromCity,flightOrderListInfoModel.toCity];
        } else {
            orderType = @"往返";
            cellCityLabel.text = [NSString stringWithFormat:@"%@ ⇔ %@",flightOrderListInfoModel.fromCity,flightOrderListInfoModel.toCity];
        }
        UILabel * cellTypeLabel = (UILabel *)[cell.contentView viewWithTag:kFlightCellTypeTag];
        cellTypeLabel.text = [NSString stringWithFormat:@"%@",orderType];
        
        UILabel * cellOrderTimeLabel = (UILabel *)[cell.contentView viewWithTag:kFlightCellOrderTimeTag];
        cellOrderTimeLabel.text = [NSString stringWithFormat:@"订购时间:%@",flightOrderListInfoModel.orderTime];
        
        UILabel * cellPriceAmountLabel = (UILabel *)[cell.contentView viewWithTag:kFlightCellPriceAmountTag];
        cellPriceAmountLabel.text = [NSString stringWithFormat:@"¥%@",flightOrderListInfoModel.orderPrice];
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


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kHotelTableViewTag) {
        HotelOrderInfoViewController * hotelOrderInfoViewController = [[HotelOrderInfoViewController alloc] init];
        HotelOrderListInfoModel * hotelOrderListInfoModel = (HotelOrderListInfoModel *)[self.hotelOrderListSearchResponseModel.hotelOrderArray objectAtIndex:indexPath.row];
        hotelOrderInfoViewController.tpsOrderId = hotelOrderListInfoModel.tpsOrderId;
        hotelOrderInfoViewController.isMemberLogin = YES;
        [self.navigationController pushViewController:hotelOrderInfoViewController animated:YES];
        [hotelOrderInfoViewController release];
    } else if (tableView.tag == kFlightTableViewTag){
        FlightOrderInfoViewController * flightOrderInfoViewController = [[FlightOrderInfoViewController alloc] init];
        FlightOrderListInfoModel * flightOrderListInfoModel = (FlightOrderListInfoModel *)[self.flightOrderListSearchResponseModel.orders objectAtIndex:indexPath.row];
        flightOrderInfoViewController.orderId = flightOrderListInfoModel.orderID;
        [self.navigationController pushViewController:flightOrderInfoViewController animated:YES];
        [flightOrderInfoViewController release];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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


//
//  HotelListController.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-21.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "HotelSearchController.h"
#import "HotelListController.h"
#import "HotelListInfo.h"
#import "UIHTTPImageView.h"

#import "ASIFormDataRequest.h"

#import "StaticConf.h"
#import "GDataXMLNode.h"
#import "PiosaFileManager.h"

#import "HotelSingleSearchResponse.h"
#import "HotelListSearchResponse.h"
#import "HotelListSearchRequest.h"
#import "ResponseParser.h"
#import "DoubleTapSegmentedControl.h"
#import "HotelSingleController.h"

#import "HotelCityChoiceController.h"

static NSUInteger imgIndex;

#define kSortLeftSegmentControlButtonTag 101
#define kSortRightSegmentControlButtonTag 102

@implementation HotelListController

@synthesize hotelSearchController = _hotelSearchController;
@synthesize hotelListSearchRequest = _hotelListSearchRequest;
@synthesize hotelListSearchResponse = _hotelListSearchResponse;

@synthesize cityName = _cityName;

@synthesize titleShowView = _titleShowView;
@synthesize cityLabel = _cityLabel;
@synthesize checkInDataLabel = _checkInDataLabel;
@synthesize checkOutDataLabel = _checkOutDataLabel;
@synthesize hotelCountLabel = _hotelCountLabel;

@synthesize segmentView = _segmentView;
@synthesize sortLeftSegmentControlButton = _sortLeftSegmentControlButton;
@synthesize sortRightSegmentControlButton = sortRightSegmentControlButton;
@synthesize lastSegmentTag = _lastSegmentTag;
@synthesize lastSegmentTitle = _lastSegmentTitle;
@synthesize orderBy = _orderBy;
@synthesize newSegmentTag = _newSegmentTag;
@synthesize reOrderBy = _reOrderBy;

@synthesize hotelListTableView = _hotelListTableView;

@synthesize req = _req;
@synthesize requestType = _requestType;
@synthesize loadDate = _loadDate;

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

- (void) sortSegmentControlAction:(UIButton *) actionButton{
    if (![self.req isFinished]) {
		NSLog(@"self.req is Finished");
		[self.req clearDelegatesAndCancel]; //取消可能存在的请求
		[self doneLoadingTableViewData]; //取消加载完成数据，修改拉动刷新框的位置与其它参数
	} else {
		NSLog(@"self.req is not Finished");
	}
    
    self.lastSegmentTitle = [actionButton titleForState:UIControlStateSelected];
    NSLog(@"%@",self.lastSegmentTitle);
    switch (actionButton.tag) {
        case kSortLeftSegmentControlButtonTag:
            //按动左排序按钮
            if (self.lastSegmentTag == actionButton.tag) {//在价格高低之间跳转
				if ([self.lastSegmentTitle isEqualToString:@"↑价格"]) {
                    [actionButton setTitle:@"↓价格" forState:UIControlStateNormal];
                    [actionButton setTitle:@"↓价格" forState:UIControlStateSelected];
					self.reOrderBy = @"PRICEHTL";
				} else {
                    [actionButton setTitle:@"↑价格" forState:UIControlStateNormal];
                    [actionButton setTitle:@"↑价格" forState:UIControlStateSelected];
					self.reOrderBy = @"PRICELTH";
				}
			} else { //星级跳转价格
				if ([self.lastSegmentTitle isEqualToString:@"↑价格"]) {
					self.reOrderBy = @"PRICELTH";
				} else {
					self.reOrderBy = @"PRICEHTL";
				}
                self.sortLeftSegmentControlButton.selected = YES;
                self.sortRightSegmentControlButton.selected = NO;
			}
			break;
        case kSortRightSegmentControlButtonTag:
            if (self.lastSegmentTag == actionButton.tag) {//在星级高低之间跳转
				if ([self.lastSegmentTitle isEqualToString:@"↑星级"]) {
                    [actionButton setTitle:@"↓星级" forState:UIControlStateNormal];
                    [actionButton setTitle:@"↓星级" forState:UIControlStateSelected];
					self.reOrderBy = @"STARHTL";
				} else {
                    [actionButton setTitle:@"↑星级" forState:UIControlStateNormal];
                    [actionButton setTitle:@"↑星级" forState:UIControlStateSelected];
					self.reOrderBy = @"STARLTH";
				}
			} else { //价格跳转星级
				if ([self.lastSegmentTitle isEqualToString:@"↑星级"]) {
					self.reOrderBy = @"STARLTH";
				} else {
					self.reOrderBy = @"STARHTL";
				}
                self.sortLeftSegmentControlButton.selected = NO;
                self.sortRightSegmentControlButton.selected = YES;
			}
            //按动右排序按钮
            
            break;
    }
    self.newSegmentTag = actionButton.tag;
    
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"查询中...";
    [_hud show:YES];
	
	self.requestType = 2;
	self.hotelListSearchRequest.hotelOrderBy = self.reOrderBy;
	self.hotelListSearchRequest.hotelPageNo = [NSString stringWithFormat:@"%d",1];
	NSData* nsData = [self generateHotelListSearchRequestPostXMLData:self.hotelListSearchRequest];
	ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: HOTEL_SEARCH_ADDRESS]];
	request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
	NSString *postData = [[NSString alloc] initWithData:nsData encoding:NSUTF8StringEncoding];
	NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    [request setPostValue:postData forKey:@"requestXml"];//测试
	
	[request setDelegate:self];
	[request startAsynchronous]; // 执行异步post
	self.req = request;
	[request release];
	[postData release];
    
}

// 酒店列表查询POST数据拼装函数
- (NSData*)generateHotelListSearchRequestPostXMLData:(HotelListSearchRequest *)request{
	//编辑会员资料查询请求的xml数据
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"HotelRequest"];
	[requestElement addChild:[GDataXMLNode elementWithName:@"CheckInDate" stringValue:request.hotelCheckInDate]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"CheckOutDate" stringValue:request.hotelCheckOutDate]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"CityCode" stringValue:request.hotelCityCode]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"HotelName" stringValue:request.hotelName]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"District" stringValue:request.hotelDistrict]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"Rank" stringValue:request.hotelRank]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"MaxRate" stringValue:request.hotelMaxRate]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"MinRate" stringValue:request.hotelMinRate]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"PageNo" stringValue:request.hotelPageNo]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"OrderBy" stringValue:request.hotelOrderBy]];
	GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
	[document setVersion:@"1.0"]; // 设置xml版本为 1.0
	[document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
	
	NSData *xmlData = document.XMLData;
	return xmlData;
}

// 酒店详情查询POST数据拼装函数
- (NSData*)generateHotelSingleSearchRequestPostXMLData:(NSString *)hotelCode {
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"HotelRequest"];
	[requestElement addChild:[GDataXMLNode elementWithName:@"CheckInDate" stringValue:self.checkInDataLabel.text]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"CheckOutDate" stringValue:self.checkOutDataLabel.text]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"HotelCode" stringValue:hotelCode]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"Source" stringValue:@"M"]];
	GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
	[document setVersion:@"1.0"]; // 设置xml版本为 1.0
	[document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
	
	NSData *xmlData = document.XMLData;
	return xmlData;
}

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应 : 但可能是错误响应, 如 404
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);
	switch (self.requestType) {
		case 1:
			//列表加载
			if ((responseString != nil) && [responseString length] > 0) {
				
				HotelListSearchResponse *newHotelListSearchResponse = [ResponseParser loadHotelListSearchResponse:[request responseData] oldHotelList:self.hotelListSearchResponse];
				
				if (newHotelListSearchResponse.result_code == nil || [newHotelListSearchResponse.result_code length] == 0 || [newHotelListSearchResponse.result_code intValue] != 1) {
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
                    hud.labelText = newHotelListSearchResponse.result_message;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
				}else {
					if ([@"查询结果为空" isEqualToString:newHotelListSearchResponse.result_message]) {
						//查询不出酒店时
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
                        hud.labelText = @"您好，暂时没有符合您要求的酒店";
                        hud.detailsLabelText = @"请您修改条件重新搜索";
                        [hud show:YES];
                        [hud hide:YES afterDelay:2];
					} else {
						self.hotelListSearchResponse = newHotelListSearchResponse;
						[_refreshHeaderView setHidden:TRUE];//隐藏拉动刷新框，因为当加载速度很快时，拉动刷新框在doneLoadingTableViewData里调整位置前，已经显示出了hotelListTableView的新数据
						[self.hotelListTableView reloadData];
					}
				}
			}
			[self doneLoadingTableViewData]; //加载完成数据，修改拉动刷新框的位置与其它参数
			break;
		case 2:
			//重新排序加载
            [_hud hide:YES];
			if ((responseString != nil) && [responseString length] > 0) {
				
				HotelListSearchResponse *newHotelListSearchResponse = [ResponseParser loadHotelListSearchResponse:[request responseData] oldHotelList:nil];
				
				if (newHotelListSearchResponse.result_code == nil || [newHotelListSearchResponse.result_code length] == 0 || [newHotelListSearchResponse.result_code intValue] != 1) {
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
                    hud.labelText = newHotelListSearchResponse.result_message;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
				} else {
					if ([@"查询结果为空" isEqualToString:newHotelListSearchResponse.result_message]) {
						//查询不出酒店时
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
                        hud.labelText = @"您好，暂时没有符合您要求的酒店";
                        hud.detailsLabelText = @"请您修改条件重新搜索";
                        [hud show:YES];
                        [hud hide:YES afterDelay:2];
					} else {
						self.hotelListSearchResponse = newHotelListSearchResponse;
						
						self.lastSegmentTag = self.newSegmentTag;		//更新排序选择控件标识
						self.orderBy = self.reOrderBy;			//更新排序选择参数
						
						self.loadDate = [NSDate date];							//重设酒店列表查询时间
						[self.hotelListTableView reloadData];					//重新加载酒店列表
						self.hotelListTableView.contentOffset = CGPointMake(0, 0);//列表回顶部
						//设置拉动刷新框
						[_refreshHeaderView setFrame:CGRectMake(0, self.hotelListTableView.contentSize.height, 320, 70)];//重设拉动刷新框的位置
						if ([self.hotelListSearchResponse.curPage intValue]>=[self.hotelListSearchResponse.totalPageNum intValue]) {
							//如果当前页为最后一页，则隐藏拉动刷新框
							[_refreshHeaderView setHidden:YES];
						} else {
							//如果当前页不为最后一页，则显示拉动刷新框
							[_refreshHeaderView setHidden:NO];
						}

					}
				}
			}
			break;
		case 3:
			//酒店详情加载
            [_hud hide:YES];
			if ((responseString != nil) && [responseString length] > 0) {
				HotelSingleSearchResponse *hotelSingleSearchResponse = [ResponseParser loadHotelSingleSearchResponse:[request responseData]];
				
				if (hotelSingleSearchResponse.result_code == nil || [hotelSingleSearchResponse.result_code length] == 0 || [hotelSingleSearchResponse.result_code intValue] != 1) {
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
                    hud.labelText = hotelSingleSearchResponse.result_message;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
				}else {
					HotelListInfo *hotelListInfo = (HotelListInfo *)[self.hotelListSearchResponse.hotelArray objectAtIndex:imgIndex];
					
					HotelSingleController *hotelSingleController = [[HotelSingleController alloc] init];
					hotelSingleSearchResponse.hotelImage = hotelListInfo.hotelImage;		//图片地址
					hotelSingleSearchResponse.hotelDistrict = hotelListInfo.hotelDistrict;  //行政区
					hotelSingleSearchResponse.hotelPOR = hotelListInfo.hotelPor;			//地标位置
					hotelSingleSearchResponse.hotelAddress = hotelListInfo.hotelAddress;	//详细地址
					hotelSingleController.checkInDate = self.checkInDataLabel.text;		//入住日期
					hotelSingleController.checkOutDate = self.checkOutDataLabel.text;	//退房日期
					hotelSingleController.hotelSingleSearchResponse = hotelSingleSearchResponse;
					[self.navigationController pushViewController:hotelSingleController animated:YES];
					[hotelSingleController release];
				}
			}
			[self doneLoadingTableViewData]; //加载完成数据，修改拉动刷新框的位置与其它参数
			break;
	}
    
}

// 网络无响应
- (void)requestFailed:(ASIFormDataRequest *)request
{
    // 提示用户打开网络联接
    if (_requestType == 1) {
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
	
	switch (self.requestType) {
		case 1:
			//列表加载
			[self doneLoadingTableViewData]; //加载完成数据，修改拉动刷新框的位置与其它参数
			break;
		case 2:
			//重新排序加载
            switch (self.lastSegmentTag) {
                case kSortLeftSegmentControlButtonTag:
                    if (self.lastSegmentTag == self.newSegmentTag) {
                        //重新排序前与重新排序后为同一个排序按钮，则只修改排序按钮的标题
                        [self.sortLeftSegmentControlButton setTitle:self.lastSegmentTitle forState:UIControlStateNormal];
                        [self.sortLeftSegmentControlButton setTitle:self.lastSegmentTitle forState:UIControlStateSelected];
                    }else{
                        //重新排序前与重新排序后不为同一个排序按钮，则只修改排序按钮的选中状态
                        self.sortLeftSegmentControlButton.selected = YES;
                        self.sortRightSegmentControlButton.selected = NO;
                    }
                    break;
                case kSortRightSegmentControlButtonTag:
                    if (self.lastSegmentTag == self.newSegmentTag) {
                        [self.sortRightSegmentControlButton setTitle:self.lastSegmentTitle forState:UIControlStateNormal];
                        [self.sortRightSegmentControlButton setTitle:self.lastSegmentTitle forState:UIControlStateSelected];
                    }else{
                        self.sortLeftSegmentControlButton.selected = NO;
                        self.sortRightSegmentControlButton.selected = YES;
                    }
                    break;
            }
			break;
	}
}

#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"选择酒店";
	
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
	
    //二级标题
    UIView * tempTitleShowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    tempTitleShowView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.titleShowView = tempTitleShowView;
	[self.view addSubview:self.titleShowView];
    [self.titleShowView release];
	
    //城市名称显示
	self.cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 7, 60, 12)];
	[self.cityLabel release];
	self.cityLabel.font = [UIFont boldSystemFontOfSize:12];
    self.cityLabel.textColor = [UIColor whiteColor];
	self.cityLabel.text = self.cityName;
	self.cityLabel.textAlignment = UITextAlignmentCenter;
	self.cityLabel.backgroundColor = [UIColor clearColor];
	[self.titleShowView addSubview:self.cityLabel];
	
	UILabel *inLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 7, 20, 12)];
	inLabel.font = [UIFont boldSystemFontOfSize:12];
    inLabel.textColor = [UIColor whiteColor];
	inLabel.text = @"入:";
	inLabel.backgroundColor = [UIColor clearColor];
	[self.titleShowView addSubview:inLabel];
	[inLabel release];
	
	self.checkInDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 7, 65, 12)];
	[self.checkInDataLabel release];
	self.checkInDataLabel.font = [UIFont boldSystemFontOfSize:12];
    self.checkInDataLabel.textColor = [UIColor whiteColor];
	self.checkInDataLabel.text = self.hotelListSearchResponse.checkInDate;
	self.checkInDataLabel.backgroundColor = [UIColor clearColor];
	[self.titleShowView addSubview:self.checkInDataLabel];
	
	UILabel *outLabel = [[UILabel alloc] initWithFrame:CGRectMake(165, 7, 20, 12)];
	outLabel.font = [UIFont boldSystemFontOfSize:12];
    outLabel.textColor = [UIColor whiteColor];
	outLabel.text = @"离:";
	outLabel.backgroundColor = [UIColor clearColor];
	[self.titleShowView addSubview:outLabel];
	[outLabel release];
	
	self.checkOutDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 7, 65, 12)];
	[self.checkOutDataLabel release];
	self.checkOutDataLabel.font = [UIFont boldSystemFontOfSize:12];
    self.checkOutDataLabel.textColor = [UIColor whiteColor];
	self.checkOutDataLabel.text = self.hotelListSearchResponse.checkOutDate;
	self.checkOutDataLabel.backgroundColor = [UIColor clearColor];
	[self.titleShowView addSubview:self.checkOutDataLabel];
	
	self.hotelCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 7, 55, 12)];
	[self.hotelCountLabel release];
	self.hotelCountLabel.font = [UIFont boldSystemFontOfSize:12];
	NSMutableString *hotelcount = [NSMutableString stringWithString:self.hotelListSearchResponse.totalNum];
	[hotelcount appendString:@"家"];
    self.hotelCountLabel.textColor = [UIColor whiteColor];
	self.hotelCountLabel.text = hotelcount;
	self.hotelCountLabel.textAlignment = UITextAlignmentRight;
	self.hotelCountLabel.backgroundColor = [UIColor clearColor];
	[self.titleShowView addSubview:self.hotelCountLabel];
    
    //排序选择分隔视图
	self.segmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 24, 320, 31)];
	[self.segmentView release];
	self.segmentView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:self.segmentView];
    
    //排序左按钮
    UIButton * tempLeftSegmentedButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 29, 75, 25)];
    tempLeftSegmentedButton.tag = kSortLeftSegmentControlButtonTag;
    [tempLeftSegmentedButton setTitle:@"↑价格" forState:UIControlStateNormal];
    [tempLeftSegmentedButton setTitle:@"↑价格" forState:UIControlStateSelected];
    tempLeftSegmentedButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [tempLeftSegmentedButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateNormal];
    [tempLeftSegmentedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    NSString *sortLeftSegmentControlButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"sortLeftSegmentControlButton_normal" inDirectory:@"CommonView/SortSegmentedControl"];
    NSString *sortLeftSegmentControlButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"sortLeftSegmentControlButton_selected" inDirectory:@"CommonView/SortSegmentedControl"];
    [tempLeftSegmentedButton setBackgroundImage:[UIImage imageNamed:sortLeftSegmentControlButtonNormalPath] forState:UIControlStateNormal];
    [tempLeftSegmentedButton setBackgroundImage:[UIImage imageNamed:sortLeftSegmentControlButtonSelectedPath] forState:UIControlStateSelected];
    [tempLeftSegmentedButton setSelected:YES];
    [tempLeftSegmentedButton addTarget:self action:@selector(sortSegmentControlAction:) forControlEvents:UIControlEventTouchDown];
    self.sortLeftSegmentControlButton = tempLeftSegmentedButton;
    [self.view addSubview:self.sortLeftSegmentControlButton];
    [tempLeftSegmentedButton release];
    
    //排序右按钮
    UIButton * tempRightSegmentedButton = [[UIButton alloc] initWithFrame:CGRectMake(80, 29, 75, 25)];
    tempRightSegmentedButton.tag = kSortRightSegmentControlButtonTag;
    [tempRightSegmentedButton setTitle:@"↑星级" forState:UIControlStateNormal];
    [tempRightSegmentedButton setTitle:@"↑星级" forState:UIControlStateSelected];
    tempRightSegmentedButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [tempRightSegmentedButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateNormal];
    [tempRightSegmentedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    NSString *sortRightSegmentControlButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"sortRightSegmentControlButton_normal" inDirectory:@"CommonView/SortSegmentedControl"];
    NSString *sortRightSegmentControlButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"sortRightSegmentControlButton_selected" inDirectory:@"CommonView/SortSegmentedControl"];
    [tempRightSegmentedButton setBackgroundImage:[UIImage imageNamed:sortRightSegmentControlButtonNormalPath] forState:UIControlStateNormal];
    [tempRightSegmentedButton setBackgroundImage:[UIImage imageNamed:sortRightSegmentControlButtonSelectedPath] forState:UIControlStateSelected];
    [tempRightSegmentedButton addTarget:self action:@selector(sortSegmentControlAction:) forControlEvents:UIControlEventTouchDown];
    self.sortRightSegmentControlButton = tempRightSegmentedButton;
    [self.view addSubview:self.sortRightSegmentControlButton];
    [tempRightSegmentedButton release];
	
	//酒店列表
	self.hotelListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 56, 320, 360) style:UITableViewStylePlain];
	[self.hotelListTableView release];
    self.hotelListTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.hotelListTableView.separatorColor = [UIColor grayColor];
	self.hotelListTableView.delegate = self;
	self.hotelListTableView.dataSource = self;
	[self.view addSubview:self.hotelListTableView];
	
	//拉动刷新框
	if (_refreshHeaderView == nil) { 
        EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 70*20, 320, 70)]; //拉动刷新框的初始化位置y坐标是在默认查出的10条酒店数据列表下
		view1.delegate = self; 
        [self.hotelListTableView addSubview:view1]; 
		if ([self.hotelListSearchResponse.curPage intValue]>=[self.hotelListSearchResponse.totalPageNum intValue]) {
			//如果当前页为最后一页，则隐藏拉动刷新框
			[view1 setHidden:YES];
		}
        _refreshHeaderView = view1; 
        [view1 release]; 
    } 
    [_refreshHeaderView refreshLastUpdatedDate];
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
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.hotelListTableView];
	
	[_refreshHeaderView setFrame:CGRectMake(0, self.hotelListTableView.contentSize.height, 320, 70)];//调整拉动刷新框的位置，使其位于刷新后的酒店列表下
	if ([self.hotelListSearchResponse.curPage intValue]<[self.hotelListSearchResponse.totalPageNum intValue]) {
		[_refreshHeaderView setHidden:FALSE];//当前页不是最后一页时才显示拉动刷新框
	}
} 
#pragma mark -
#pragma mark UIScrollViewDelegate Methods 
//手指屏幕上不断拖动时调用此方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{ 
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView]; 
}

//手指在屏幕上开始拖动时调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
}

//当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{ 
	if ([self.hotelListSearchResponse.curPage intValue]<[self.hotelListSearchResponse.totalPageNum intValue]) {
		//显示最后一页时，可以不用调用方法来设置刷新视图
		[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView]; 
	}
} 
#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods 
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource]; //开始加载数据
	
	self.requestType = 1;
	self.hotelListSearchRequest.hotelOrderBy = self.orderBy;
	self.hotelListSearchRequest.hotelPageNo = [NSString stringWithFormat:@"%d",[self.hotelListSearchResponse.curPage intValue]+1];
	NSData* nsData = [self generateHotelListSearchRequestPostXMLData:self.hotelListSearchRequest];
	ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: HOTEL_SEARCH_ADDRESS]];
	request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
	NSString *postData = [[NSString alloc] initWithData:nsData encoding:NSUTF8StringEncoding];
	NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    [request setPostValue:postData forKey:@"requestXml"];//测试
	
	[request setDelegate:self];
	[request startAsynchronous]; // 执行异步post
	self.req = request;
	[request release];
	[postData release];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading; 
} 
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];     
} 


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSLog(@"HotelListController numberOfSectionsInTableView");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"HotelListController numberOfRowsInSection");
    return [self.hotelListSearchResponse.hotelArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d %d %d", indexPath.row, indexPath.section, [self.loadDate timeIntervalSince1970]];
    
	HotelListInfo *hotelListInfo = (HotelListInfo *)[self.hotelListSearchResponse.hotelArray objectAtIndex:indexPath.row];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		UIHTTPImageView *uiHTTPImageView = [[UIHTTPImageView alloc] initWithFrame:CGRectMake(3, 3, 74, 64)];
        NSString *imageLoadingPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"image_loading" inDirectory:@"Hotel"];
		[uiHTTPImageView setImageWithURL:[NSURL URLWithString:hotelListInfo.hotelImage] placeholderImage:[UIImage imageNamed:imageLoadingPath]];
		[cell.contentView addSubview:uiHTTPImageView];
		[uiHTTPImageView release];
		
		UILabel *hotelNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 220, 30)];
		hotelNameLabel.text = hotelListInfo.hotelName;
		hotelNameLabel.textColor = [PiosaColorManager fontColor];
		hotelNameLabel.font = [UIFont boldSystemFontOfSize:15];
		hotelNameLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:hotelNameLabel];
		[hotelNameLabel release];
		
		UILabel *hotelAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 30, 220, 15)];
		hotelAddressLabel.text = hotelListInfo.hotelAddress;
		hotelAddressLabel.textColor = [UIColor grayColor];
		hotelAddressLabel.font = [UIFont boldSystemFontOfSize:13];
		hotelAddressLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:hotelAddressLabel];
		[hotelAddressLabel release];
		
		NSString *starImageName = nil;
		if ([@"5S" isEqualToString:hotelListInfo.hotelRank]) {
			starImageName = @"star5";
		} else if ([@"5A" isEqualToString:hotelListInfo.hotelRank]) {
			starImageName = @"star4_1";
		} else if ([@"4S" isEqualToString:hotelListInfo.hotelRank]) {
			starImageName = @"star4";
		} else if ([@"4A" isEqualToString:hotelListInfo.hotelRank]) {
			starImageName = @"star3_1";
		} else if ([@"3S" isEqualToString:hotelListInfo.hotelRank]) {
			starImageName = @"star3";
		} else if ([@"3A" isEqualToString:hotelListInfo.hotelRank]) {
			starImageName = @"star2_1";
		} else if ([@"2S" isEqualToString:hotelListInfo.hotelRank]) {
			starImageName = @"star2";
		} else if ([@"2A" isEqualToString:hotelListInfo.hotelRank]) {
			starImageName = @"star1_1";
		} else if ([@"1S" isEqualToString:hotelListInfo.hotelRank]) {
			starImageName = @"star1";
		} else if ([@"1A" isEqualToString:hotelListInfo.hotelRank]) {
			starImageName = @"star0_1";
		}
        NSString *starImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:starImageName inDirectory:@"Hotel/star"];
		UIImageView *hotelStarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:starImagePath]];
		hotelStarView.frame = CGRectMake(80, 52, 70, 12);
		[cell.contentView addSubview:hotelStarView];
		[hotelStarView release];
		
		UILabel *hotelMinRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 50, 100, 20)];
		NSMutableString *hotelMinRateString = [NSMutableString stringWithString:@"¥"];
		[hotelMinRateString appendString:hotelListInfo.hotelMinRate];
		[hotelMinRateString appendString:@"起"];
		hotelMinRateLabel.text = hotelMinRateString;
		hotelMinRateLabel.textColor = [UIColor redColor];
		hotelMinRateLabel.textAlignment = UITextAlignmentRight;
		hotelMinRateLabel.font = [UIFont boldSystemFontOfSize:18];
		hotelMinRateLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:hotelMinRateLabel];
		[hotelMinRateLabel release];
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	if ([self.hotelListSearchResponse.hotelArray count]<=5) {
		//如果显示的酒店不超出显示框，则通过添加footer来去除多出来的空cell
		UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)] autorelease];
		footer.backgroundColor = [UIColor clearColor];
		return footer;
	} else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (![self.req isFinished]) {
		NSLog(@"self.req is Finished");
		[self.req clearDelegatesAndCancel]; //取消可能存在的请求
		[self doneLoadingTableViewData]; //取消加载完成数据，修改拉动刷新框的位置与其它参数
	} else {
		NSLog(@"self.req is not Finished");
	}
	
	_hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"查询中...";
    [_hud show:YES];
	
	self.requestType = 3;
	HotelListInfo *hotelListInfo = (HotelListInfo *)[self.hotelListSearchResponse.hotelArray objectAtIndex:indexPath.row];
	imgIndex = indexPath.row;
	ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: HOTEL_DETAIL_ADDRESS]];
	request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
	NSMutableString *postData = [[NSMutableString alloc] initWithData:[self generateHotelSingleSearchRequestPostXMLData:hotelListInfo.hotelCode] encoding:NSUTF8StringEncoding];
	[postData deleteCharactersInRange:NSMakeRange(0,39)];//删除xml中的“<?xml version="1.0" encoding="UTF-8"?>”
	NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    [request setPostValue:postData forKey:@"requestXml"];//测试
    
	[request setDelegate:self];
	[request startAsynchronous]; // 执行异步post
	self.req = request;
	[request release];
	[postData release];
	
	[self.hotelListTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Memory management


- (void)viewDidUnload {
    [super viewDidUnload];
	
	self.titleShowView = nil;
    self.hotelListTableView = nil;
	
	self.cityLabel = nil;
	self.checkInDataLabel = nil;
	self.checkOutDataLabel = nil;
	self.hotelCountLabel = nil;
	
	self.hotelListSearchRequest = nil;
	self.hotelListSearchResponse = nil;
	
	self.segmentView = nil;
	
    _refreshHeaderView=nil; 
	
	self.loadDate = nil;
}


- (void)dealloc {
	[self.titleShowView release];
	[self.hotelListTableView release];
    
    [self.cityName release];
	
	[self.cityLabel release];
	[self.checkInDataLabel release];
	[self.checkOutDataLabel release];
	[self.hotelCountLabel release];
	
	[self.hotelSearchController release];
	[self.hotelListSearchRequest release];
	[self.hotelListSearchResponse release];
	
	[self.segmentView release];
    [self.orderBy release];
    
    [self.sortLeftSegmentControlButton release];
    [self.sortRightSegmentControlButton release];
	
	_refreshHeaderView=nil; 
	
	if (![self.req isFinished]) {//异步请求未完成时
		[self.req clearDelegatesAndCancel];
	}
	
	[self.req release];
	[self.loadDate release];
	
    [super dealloc];
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

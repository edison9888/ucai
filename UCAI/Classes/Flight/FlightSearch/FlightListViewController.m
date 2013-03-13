//
//  FlightListViewController.m
//  UCAI
//
//  Created by  on 12-1-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FlightListViewController.h"
#import "FlightListSearchResponseModel.h"
#import "FlightSeatViewController.h"
#import "FlightBookViewController.h"

#import "UIPiosaLabel.h"

#import "ResponseParser.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "StaticConf.h"
#import "CommonTools.h"
#import "PiosaFileManager.h"


#define kTableViewCellRowHeight 65

#define kSortLeftSegmentControlButtonTag 101
#define kSortRightSegmentControlButtonTag 102

#define kCompanyImageViewTag 201
#define kCompanyNameLabelTag 202
#define kFlightCodeLabelTag 203
#define kFromTimeLabelTag 204
#define kFromAirportNameLabelTag 205
#define kToTimeLabelTag 206
#define kToAirportNameLabelTag 207
#define kFlightSeatLabelTag 208
#define kUcaiPriceLabelTag 209
#define kUcaiSaveLabelTag 210
#define kPriceAndRebateLabelTag 211
#define kStopLabelTag 212

@implementation FlightListViewController

@synthesize startedDate = _startedDate;
@synthesize startedCityName = _startedCityName;
@synthesize arrivedCityName = _arrivedCityName;
@synthesize startCityCode = _startCityCode;
@synthesize arrivedCityCode = _arrivedCityCode;
@synthesize searchCompanyCode = _searchCompanyCode;
@synthesize startedDateLabel = _startedDateLabel;
@synthesize countLabel = _countLabel;
@synthesize sortLeftSegmentControlButton = _sortLeftSegmentControlButton;
@synthesize sortRightSegmentControlButton = _sortRightSegmentControlButton;
@synthesize lastSegmentTag = _lastSegmentTag;
@synthesize lastSegmentTitle = _lastSegmentTitle;
@synthesize sortOrder = _sortOrder;
@synthesize newSegmentTag = _newSegmentTag;
@synthesize reSortOrder = _reSortOrder;
@synthesize flightListTableView = _flightListTableView;
@synthesize flightListSearchResponseModel = _flightListSearchResponseModel;
@synthesize req = _req;
@synthesize requestType = _requestType;
@synthesize loadDate = _loadDate;

- (FlightListViewController *)initWithFlightLineStyle:(UCAIFlightLineStyle) flightLineType{
    self = [super init];
    _flightLineType = flightLineType;
    return self;
}

- (void)dealloc {
    [_flightSeatDic release];
    [_flightCompanyDic release];
    [_refreshHeaderView release];
    [self.startedDate release];
    [self.startedCityName release];
    [self.arrivedCityName release];
    [self.startCityCode release];
    [self.arrivedCityCode release];
    [self.searchCompanyCode release];
    [self.startedDateLabel release];
    [self.countLabel release];
    [self.sortLeftSegmentControlButton release];
    [self.sortRightSegmentControlButton release];
    [self.lastSegmentTitle release];
    [self.sortOrder release];
    [self.reSortOrder release];
    [self.flightListTableView release];
    [self.flightListSearchResponseModel release];
    [self.req release];
	[self.loadDate release];
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

- (void)accessoryDetailDisclosureButtonPress:(UIButton *)button{
    UITableViewCell *cell = (UITableViewCell *)button.superview;
    NSIndexPath * indexPath = [self.flightListTableView indexPathForCell:cell];
    FLightListInfoModel *fLightListInfoModel = [self.flightListSearchResponseModel.flights objectAtIndex:indexPath.row];
    
    FlightSeatViewController *flightSeatViewController = [[FlightSeatViewController alloc] initWithFlightLineStyle:_flightLineType];
    flightSeatViewController.startedCityName = self.startedCityName;
    flightSeatViewController.arrivedCityName = self.arrivedCityName;
    flightSeatViewController.startCityCode = self.startCityCode;
    flightSeatViewController.arrivedCityCode = self.arrivedCityCode;
    flightSeatViewController.goDate = self.startedDate;
    flightSeatViewController.searchFlightCompanyCode = self.searchCompanyCode;
    flightSeatViewController.flightId = fLightListInfoModel.flightID;
    [self.navigationController pushViewController:flightSeatViewController animated:YES];
    [flightSeatViewController release];
}

- (void)flightPreDateButtonPress{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSLog(@"%@",[userDefaults stringForKey:@"flightGoDate"]);
    if (_flightLineType == UCAIFlightLineStyleSingle 
        && [[formatter dateFromString:self.startedDate] compare:[formatter dateFromString:[formatter stringFromDate:[NSDate date]]]] == NSOrderedSame) {
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
        hud.labelText = @"去程日期不可早于今日";
        [hud show:YES];
        [hud hide:YES afterDelay:2];
    }else if ([userDefaults integerForKey:@"flightSearchLineType"] == UCAIFlightLineStyleDouble && _flightLineType == UCAIFlightLineStyleDouble 
        && [[formatter dateFromString:[userDefaults stringForKey:@"flightGoDate"]] compare:[formatter dateFromString:self.startedDate]] == NSOrderedSame) {
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
        hud.labelText = @"回程日期不可早于去程日期";
        [hud show:YES];
        [hud hide:YES afterDelay:2];
    }else{
        if (![self.req isFinished]) {
            [self.req clearDelegatesAndCancel]; //取消可能存在的请求
            [self doneLoadingTableViewData]; //取消加载完成数据，修改拉动刷新框的位置与其它参数
        }
        
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _hud.bgRGB = [PiosaColorManager progressColor];
        [self.navigationController.view addSubview:_hud];
        _hud.delegate = self;
        _hud.minSize = CGSizeMake(135.f, 135.f);
        _hud.labelText = @"查询中...";
        [_hud show:YES];
        
        self.requestType = 4;
        
        NSString *postData = [[NSString alloc] initWithData:[self generateFlightBookingRequestPostXMLData:@"1" sortType:(self.lastSegmentTag == kSortLeftSegmentControlButtonTag?@"1":@"2") sortOrder:self.sortOrder] encoding:NSUTF8StringEncoding];
        NSLog(@"requestStart\n");
        NSLog(@"%@\n", postData);
        [postData release];
        
        ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: FLIGHT_LIST_SEARCH_ADDRESS]];
        [req addRequestHeader:@"API-Version" value:API_VERSION];
        req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
        [req appendPostData:[self generateFlightBookingRequestPostXMLData:@"1" sortType:(self.lastSegmentTag == kSortLeftSegmentControlButtonTag?@"1":@"2") sortOrder:self.sortOrder]];
        [req setDelegate:self];
        [req startAsynchronous]; // 执行异步post
        self.req = req;
    }
    [formatter release];
}

- (void)flightNextDateButtonPress{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    if ([userDefaults integerForKey:@"flightSearchLineType"] == UCAIFlightLineStyleDouble && _flightLineType == UCAIFlightLineStyleSingle 
        && [[formatter dateFromString:self.startedDate] compare:[formatter dateFromString:[userDefaults stringForKey:@"flightBackDate"]]] == NSOrderedSame) {
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
        hud.labelText = @"去程日期不可晚于回程日期";
        [hud show:YES];
        [hud hide:YES afterDelay:2];
    }else{
        if (![self.req isFinished]) {
            [self.req clearDelegatesAndCancel]; //取消可能存在的请求
            [self doneLoadingTableViewData]; //取消加载完成数据，修改拉动刷新框的位置与其它参数
        }
        
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _hud.bgRGB = [PiosaColorManager progressColor];
        [self.navigationController.view addSubview:_hud];
        _hud.delegate = self;
        _hud.minSize = CGSizeMake(135.f, 135.f);
        _hud.labelText = @"查询中...";
        [_hud show:YES];
        
        self.requestType = 5;
        
        NSString *postData = [[NSString alloc] initWithData:[self generateFlightBookingRequestPostXMLData:@"1" sortType:(self.lastSegmentTag == kSortLeftSegmentControlButtonTag?@"1":@"2") sortOrder:self.sortOrder] encoding:NSUTF8StringEncoding];
        NSLog(@"requestStart\n");
        NSLog(@"%@\n", postData);
        [postData release];
        
        ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: FLIGHT_LIST_SEARCH_ADDRESS]];
        [req addRequestHeader:@"API-Version" value:API_VERSION];
        req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
        [req appendPostData:[self generateFlightBookingRequestPostXMLData:@"1" sortType:(self.lastSegmentTag == kSortLeftSegmentControlButtonTag?@"1":@"2") sortOrder:self.sortOrder]];
        [req setDelegate:self];
        [req startAsynchronous]; // 执行异步post
        self.req = req;
    }
    [formatter release];
}

- (void) sortSegmentControlAction:(UIButton *) actionButton{
    if (![self.req isFinished]) {
		[self.req clearDelegatesAndCancel]; //取消可能存在的请求
		[self doneLoadingTableViewData]; //取消加载完成数据，修改拉动刷新框的位置与其它参数
	}
    
    self.lastSegmentTitle = [actionButton titleForState:UIControlStateSelected];
    switch (actionButton.tag) {
        case kSortLeftSegmentControlButtonTag:
            //按动左排序按钮
            if (self.lastSegmentTag == actionButton.tag) {//在时间高低之间跳转
				if ([self.lastSegmentTitle isEqualToString:@"↑时间"]) {
                    [actionButton setTitle:@"↓时间" forState:UIControlStateNormal];
                    [actionButton setTitle:@"↓时间" forState:UIControlStateSelected];
                    self.reSortOrder = @"2";
				} else {
                    [actionButton setTitle:@"↑时间" forState:UIControlStateNormal];
                    [actionButton setTitle:@"↑时间" forState:UIControlStateSelected];
                    self.reSortOrder = @"1";
				}
			} else { //价格跳转时间
				if ([self.lastSegmentTitle isEqualToString:@"↑时间"]) {
                    self.reSortOrder = @"1";
				} else {
                    self.reSortOrder = @"2";
				}
                self.sortLeftSegmentControlButton.selected = YES;
                self.sortRightSegmentControlButton.selected = NO;
			}
			break;
        case kSortRightSegmentControlButtonTag:
            if (self.lastSegmentTag == actionButton.tag) {//在价格高低之间跳转
				if ([self.lastSegmentTitle isEqualToString:@"↑价格"]) {
                    [actionButton setTitle:@"↓价格" forState:UIControlStateNormal];
                    [actionButton setTitle:@"↓价格" forState:UIControlStateSelected];
                    self.reSortOrder = @"2";
				} else {
                    [actionButton setTitle:@"↑价格" forState:UIControlStateNormal];
                    [actionButton setTitle:@"↑价格" forState:UIControlStateSelected];
                    self.reSortOrder = @"1";
				}
			} else { //时间跳转价格
				if ([self.lastSegmentTitle isEqualToString:@"↑价格"]) {
                    self.reSortOrder = @"1";
				} else {
                    self.reSortOrder = @"2";
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

    NSString *postData = [[NSString alloc] initWithData:[self generateFlightBookingRequestPostXMLData:@"1" sortType:(self.newSegmentTag == kSortLeftSegmentControlButtonTag?@"1":@"2") sortOrder:self.reSortOrder] encoding:NSUTF8StringEncoding];
    NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    [postData release];
    
    ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: FLIGHT_LIST_SEARCH_ADDRESS]];
    [req addRequestHeader:@"API-Version" value:API_VERSION];
    req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    [req appendPostData:[self generateFlightBookingRequestPostXMLData:@"1" sortType:(self.newSegmentTag == kSortLeftSegmentControlButtonTag?@"1":@"2") sortOrder:self.reSortOrder]];
    [req setDelegate:self];
    [req startAsynchronous]; // 执行异步post
    self.req = req;
    
}

- (NSData*)generateFlightBookingRequestPostXMLData:(NSString *)pageIndex sortType:(NSString *)sortType sortOrder:(NSString *)sortOrder{
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *pageInfoElement = [GDataXMLElement elementWithName:@"pageInfo"]; 
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"currentPage" stringValue:pageIndex]];
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"pageSize" stringValue:@"20"]];  // 查到爆
    [requestElement addChild:pageInfoElement];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    switch (self.requestType) {
        case 1:
        case 2:
            [conditionElement addChild:[GDataXMLNode elementWithName:@"fromCity" stringValue:self.startCityCode]];
            [conditionElement addChild:[GDataXMLNode elementWithName:@"toCity" stringValue:self.arrivedCityCode]];
            [conditionElement addChild:[GDataXMLNode elementWithName:@"fromDate" stringValue:self.startedDate]];
            break;
        case 3:{
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [conditionElement addChild:[GDataXMLNode elementWithName:@"fromCity" stringValue:self.arrivedCityCode]];
            [conditionElement addChild:[GDataXMLNode elementWithName:@"toCity" stringValue:self.startCityCode]];
            [conditionElement addChild:[GDataXMLNode elementWithName:@"fromDate" stringValue:[userDefaults objectForKey:@"flightBackDate"]]];
        }
            break;
        case 4:
        case 5:
            [conditionElement addChild:[GDataXMLNode elementWithName:@"fromCity" stringValue:self.startCityCode]];
            [conditionElement addChild:[GDataXMLNode elementWithName:@"toCity" stringValue:self.arrivedCityCode]];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            if (self.requestType == 4) {
                //前一天
                [conditionElement addChild:[GDataXMLNode elementWithName:@"fromDate" stringValue:[formatter stringFromDate:[[formatter dateFromString:self.startedDate] dateByAddingTimeInterval:-86400]]]];
            } else {
                //后一天
                [conditionElement addChild:[GDataXMLNode elementWithName:@"fromDate" stringValue:[formatter stringFromDate:[[formatter dateFromString:self.startedDate] dateByAddingTimeInterval:86400]]]];
            }
            [formatter release];
            break;
    }
    
    [conditionElement addChild:[GDataXMLNode elementWithName:@"companyCode" stringValue:self.searchCompanyCode]];
    GDataXMLElement *sortElement = [GDataXMLElement elementWithName:@"sort"]; 
    [sortElement addChild:[GDataXMLNode elementWithName:@"sortType" stringValue:sortType]];
    [sortElement addChild:[GDataXMLNode elementWithName:@"sortOrder" stringValue:sortOrder]];
    [conditionElement addChild:sortElement];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    
    return document.XMLData;
}

#pragma mark -
#pragma mark View lifecycle

- (void) loadView{
    [super loadView];
    
    switch (_flightLineType) {
        case UCAIFlightLineStyleSingle:
            self.title = @"选择去程航班";
            break;
        case UCAIFlightLineStyleDouble:
            self.title = @"选择返程航班";
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
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    titleView.backgroundColor = [PiosaColorManager secondTitleColor];
    
    UILabel *startedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 80, 20)];
    startedDateLabel.backgroundColor = [UIColor clearColor];
    startedDateLabel.textColor = [UIColor whiteColor];
    startedDateLabel.font = [UIFont systemFontOfSize:12];
    startedDateLabel.text = self.startedDate;
    self.startedDateLabel = startedDateLabel;
    [titleView addSubview:startedDateLabel];
    [startedDateLabel release];
    
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 120, 25)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.font = [UIFont boldSystemFontOfSize:14];
    cityLabel.textAlignment = UITextAlignmentCenter;
    cityLabel.text = [NSString stringWithFormat:@"%@ ⇀ %@",self.startedCityName,self.arrivedCityName];
    [titleView addSubview:cityLabel];
    [cityLabel release];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(235, 5, 80, 20)];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.font = [UIFont boldSystemFontOfSize:12];
    countLabel.textAlignment = UITextAlignmentRight;
    countLabel.text = [NSString stringWithFormat:@"%@个结果",self.flightListSearchResponseModel.count];
    self.countLabel = countLabel;
    [titleView addSubview:countLabel];
    [countLabel release];
    
    [self.view addSubview:titleView];
    [titleView release];
    
    //排序选择分隔视图
	UIView *segmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 25, 320, 33)];
	segmentView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:segmentView];
    [segmentView release];
    
    //前一天航班
    UIButton *preFlightButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 27, 30, 30)];
    NSString *flightPreDateButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"flightPreDateButton_normal" inDirectory:@"Flight/FlightControl"];
    NSString *flightPreDateButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"flightPreDateButton_highlighted" inDirectory:@"Flight/FlightControl"];
    [preFlightButton setBackgroundImage:[UIImage imageNamed:flightPreDateButtonNormalPath] forState:UIControlStateNormal];
    [preFlightButton setBackgroundImage:[UIImage imageNamed:flightPreDateButtonHighlightedPath] forState:UIControlStateHighlighted];
    [preFlightButton addTarget:self action:@selector(flightPreDateButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:preFlightButton];
    [preFlightButton release];
    
    //后一天航班
    UIButton *nextFlightButton = [[UIButton alloc] initWithFrame:CGRectMake(285, 27, 30, 30)];
    NSString *flightNextDateButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"flightNextDateButton_normal" inDirectory:@"Flight/FlightControl"];
    NSString *flightNextDateButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"flightNextDateButton_highlighted" inDirectory:@"Flight/FlightControl"];
    [nextFlightButton setBackgroundImage:[UIImage imageNamed:flightNextDateButtonNormalPath] forState:UIControlStateNormal];
    [nextFlightButton setBackgroundImage:[UIImage imageNamed:flightNextDateButtonHighlightedPath] forState:UIControlStateHighlighted];
    [nextFlightButton addTarget:self action:@selector(flightNextDateButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextFlightButton];
    [nextFlightButton release];
    
    //排序左按钮
    UIButton * tempLeftSegmentedButton = [[UIButton alloc] initWithFrame:CGRectMake(85, 29, 75, 25)];
    tempLeftSegmentedButton.tag = kSortLeftSegmentControlButtonTag;
    [tempLeftSegmentedButton setTitle:@"↑时间" forState:UIControlStateNormal];
    [tempLeftSegmentedButton setTitle:@"↑时间" forState:UIControlStateSelected];
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
    UIButton * tempRightSegmentedButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 29, 75, 25)];
    tempRightSegmentedButton.tag = kSortRightSegmentControlButtonTag;
    [tempRightSegmentedButton setTitle:@"↑价格" forState:UIControlStateNormal];
    [tempRightSegmentedButton setTitle:@"↑价格" forState:UIControlStateSelected];
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
    
    UITableView *flightListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 59, 320, 357) style:UITableViewStylePlain];
    flightListTableView.dataSource = self;
    flightListTableView.delegate = self;
    self.flightListTableView = flightListTableView;
    [self.view addSubview:flightListTableView];
    [flightListTableView release];
    
    //拉动刷新框
	if (_refreshHeaderView == nil) { 
        EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, kTableViewCellRowHeight*20, 320, 70)]; //拉动刷新框的初始化位置y坐标是在默认查出的10条酒店数据列表下
		view1.delegate = self; 
        [self.flightListTableView addSubview:view1]; 
        if ([self.flightListSearchResponseModel.pageSize intValue]*[self.flightListSearchResponseModel.currentPage intValue]>=[self.flightListSearchResponseModel.count intValue]) {
			//如果当前页为最后一页，则隐藏拉动刷新框
			[view1 setHidden:YES];
		}
        _refreshHeaderView = view1; 
        [_refreshHeaderView retain];
        [view1 release]; 
    } 
    [_refreshHeaderView refreshLastUpdatedDate];
    
    NSArray * flightCompanyCodeArray = [[NSArray alloc] initWithObjects:@"CA",@"CZ",@"MU",@"FM",@"HU",@"SC",@"MF",@"3U",@"ZH",@"JD",@"HO",@"KN",@"8L",@"BK",@"EU",@"8C",@"G5",@"PN",@"OQ",@"NS",@"CN",@"GS",@"JR",nil];
    NSArray * flightCompanyImageArray = [[NSArray alloc] initWithObjects:@"air_line_ca",@"air_line_cz",@"air_line_mu",@"air_line_fm",@"air_line_hu",@"air_line_sc",@"air_line_mf",@"air_line_3u",@"air_line_zh",@"air_line_pn",@"air_line_ho",@"air_line_kn",@"air_line_8l",@"air_line_bk",@"air_line_eu",@"air_line_8c",@"air_line_g5",@"air_line_jd",@"air_line_oq",@"air_line_ns",@"air_line_hu",@"air_line_gs",@"air_line_jr",nil];
    _flightCompanyDic = [NSDictionary dictionaryWithObjects:flightCompanyImageArray forKeys:flightCompanyCodeArray];
    [_flightCompanyDic retain];
    [flightCompanyImageArray release];
    [flightCompanyCodeArray release];

    
    NSArray * flightSeatCodeArray = [[NSArray alloc] initWithObjects:@"F",@"A",@"C",@"D",@"J",@"Y",@"Z",@"V",@"B",@"H",@"K",@"L",@"M",@"Q",@"X",@"E",@"W",@"G",@"T",@"P",@"S",@"R",@"O",@"N",nil];
    NSArray * flightSeatNameArray = [[NSArray alloc] initWithObjects:@"头等舱",@"头等舱",@"公务舱",@"公务舱",@"公务舱",@"全价舱",@"专用舱",@"专用舱",@"经济舱",@"经济舱",@"经济舱",@"经济舱",@"经济舱",@"经济舱",@"经济舱",@"经济舱",@"经济舱",@"经济舱",@"经济舱",@"经济舱",@"特殊舱",@"经济舱",@"经济舱",@"经济舱",nil];
    _flightSeatDic = [NSDictionary dictionaryWithObjects:flightSeatNameArray forKeys:flightSeatCodeArray];
    [_flightSeatDic retain];
    [flightSeatNameArray release];
    [flightSeatCodeArray release];
}

#pragma mark -
#pragma mark Table view cell piosa delegate

- (void)cellBeHighlighted:(UIPiosaTableViewCell *)cell{
    [(UIButton *)cell.accessoryView setHighlighted:NO];
}

- (void)cellBeSelected:(UIPiosaTableViewCell *)cell{
    [(UIButton *)cell.accessoryView setHighlighted:NO];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.flightListSearchResponseModel.flights count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"Cell";
    
    UIImageView * tempCompanyImageView;
    UILabel * tempCompanyNameLabel;
    UILabel * tempFlightCodeLabel;
    UILabel * tempFromTimeLabel;
    UILabel * tempFromAirportNameLabel;
    UILabel * tempToTimeLabel;
    UILabel * tempToAirportNameLabel;
    UILabel * tempFlightSeatLabel;
    UILabel * tempUcaiPriceLabel;
    UILabel * tempUcaiSaveLabel;
    UIPiosaLabel * tempPriceAndRebateLabel;
    UILabel * tempStopLabel;
    
    FLightListInfoModel *fLightListInfoModel = (FLightListInfoModel *)[self.flightListSearchResponseModel.flights objectAtIndex:indexPath.row];
    
    UIPiosaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UIPiosaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        UIImageView * companyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 20, 20)];
        companyImageView.tag = kCompanyImageViewTag;
        tempCompanyImageView = companyImageView;
        [cell.contentView addSubview:companyImageView];
        [companyImageView release];
        
        UILabel * companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 5, 70, 15)];
        companyNameLabel.tag = kCompanyNameLabelTag;
        companyNameLabel.backgroundColor = [UIColor clearColor];
        companyNameLabel.font = [UIFont systemFontOfSize:13];
        tempCompanyNameLabel = companyNameLabel;
        [cell.contentView addSubview:companyNameLabel];
        [companyNameLabel release];
        
        UILabel * flightCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(94, 5, 70, 15)];
        flightCodeLabel.tag = kFlightCodeLabelTag;
        flightCodeLabel.backgroundColor = [UIColor clearColor];
        flightCodeLabel.textColor = [UIColor redColor];
        flightCodeLabel.font = [UIFont systemFontOfSize:13];
        tempFlightCodeLabel = flightCodeLabel;
        [cell.contentView addSubview:flightCodeLabel];
        [flightCodeLabel release];
        
        UILabel * stopLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 5, 30, 15)];
        stopLabel.tag = kStopLabelTag;
        stopLabel.backgroundColor = [UIColor clearColor];
        stopLabel.textColor = [UIColor orangeColor];
        stopLabel.font = [UIFont systemFontOfSize:12];
        tempStopLabel = stopLabel;
        [cell.contentView addSubview:stopLabel];
        [stopLabel release];
        
        UILabel * fromTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, 57, 15)];
        fromTimeLabel.tag = kFromTimeLabelTag;
        fromTimeLabel.backgroundColor = [UIColor clearColor];
        fromTimeLabel.textColor = [PiosaColorManager fontColor];
        fromTimeLabel.font = [UIFont systemFontOfSize:15];
        tempFromTimeLabel = fromTimeLabel;
        [cell.contentView addSubview:fromTimeLabel];
        [fromTimeLabel release];
        
        UILabel * fromAirportNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 25, 100, 15)];
        fromAirportNameLabel.tag = kFromAirportNameLabelTag;
        fromAirportNameLabel.backgroundColor = [UIColor clearColor];
        fromAirportNameLabel.textColor = [PiosaColorManager fontColor];
        fromAirportNameLabel.font = [UIFont systemFontOfSize:15];
        tempFromAirportNameLabel = fromAirportNameLabel;
        [cell.contentView addSubview:fromAirportNameLabel];
        [fromAirportNameLabel release];
        
        UILabel * toTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 45, 57, 15)];
        toTimeLabel.tag = kToTimeLabelTag;
        toTimeLabel.backgroundColor = [UIColor clearColor];
        toTimeLabel.textColor = [UIColor grayColor];
        toTimeLabel.font = [UIFont systemFontOfSize:15];
        tempToTimeLabel = toTimeLabel;
        [cell.contentView addSubview:toTimeLabel];
        [toTimeLabel release];
        
        UILabel * toAirportNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 45, 100, 15)];
        toAirportNameLabel.tag = kToAirportNameLabelTag;
        toAirportNameLabel.backgroundColor = [UIColor clearColor];
        toAirportNameLabel.textColor = [UIColor grayColor];
        toAirportNameLabel.font = [UIFont systemFontOfSize:15];
        tempToAirportNameLabel = toAirportNameLabel;
        [cell.contentView addSubview:toAirportNameLabel];
        [toAirportNameLabel release];
        
        UILabel * flightSeatLabel = [[UILabel alloc] initWithFrame:CGRectMake(164, 5, 115, 15)];
        flightSeatLabel.tag = kFlightSeatLabelTag;
        flightSeatLabel.backgroundColor = [UIColor clearColor];
        flightSeatLabel.font = [UIFont systemFontOfSize:12];
        flightSeatLabel.textAlignment = UITextAlignmentRight;
        tempFlightSeatLabel = flightSeatLabel;
        [cell.contentView addSubview:flightSeatLabel];
        [flightSeatLabel release];
        
        UILabel * ucaiPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(164, 25, 70, 15)];
        ucaiPriceLabel.tag = kUcaiPriceLabelTag;
        ucaiPriceLabel.backgroundColor = [UIColor clearColor];
        ucaiPriceLabel.textColor = [UIColor redColor];
        ucaiPriceLabel.textAlignment = UITextAlignmentRight;
        ucaiPriceLabel.font = [UIFont boldSystemFontOfSize:15];
        tempUcaiPriceLabel = ucaiPriceLabel;
        [cell.contentView addSubview:ucaiPriceLabel];
        [ucaiPriceLabel release];
        
        UILabel * ucaiSaveLabel = [[UILabel alloc] initWithFrame:CGRectMake(234, 25, 50, 15)];
        ucaiSaveLabel.tag = kUcaiSaveLabelTag;
        ucaiSaveLabel.backgroundColor = [UIColor clearColor];
        ucaiSaveLabel.textColor = [UIColor redColor];
        ucaiSaveLabel.font = [UIFont boldSystemFontOfSize:12];
        tempUcaiSaveLabel = ucaiSaveLabel;
        [cell.contentView addSubview:ucaiSaveLabel];
        [ucaiSaveLabel release];
        
        UIPiosaLabel * priceAndRebateLabel = [[UIPiosaLabel alloc] initWithFrame:CGRectMake(164, 45, 115, 15)];
        priceAndRebateLabel.tag = kPriceAndRebateLabelTag;
        priceAndRebateLabel.backgroundColor = [UIColor clearColor];
        priceAndRebateLabel.textColor = [UIColor grayColor];
        priceAndRebateLabel.font = [UIFont systemFontOfSize:12];
        priceAndRebateLabel.textAlignment = UITextAlignmentRight;
        tempPriceAndRebateLabel = priceAndRebateLabel;
        [cell.contentView addSubview:priceAndRebateLabel];
        [priceAndRebateLabel release];
        
        UIButton * accessoryDetailDisclosureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        NSString *accessoryDetailDisclosureButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDetailDisclosureButton_normal" inDirectory:@"CommonView/TableViewCell"];
        NSString *accessoryDetailDisclosureButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDetailDisclosureButton_highlighted" inDirectory:@"CommonView/TableViewCell"];
        [accessoryDetailDisclosureButton setImage:[UIImage imageNamed:accessoryDetailDisclosureButtonNormalPath] forState:UIControlStateNormal];
        [accessoryDetailDisclosureButton setImage:[UIImage imageNamed:accessoryDetailDisclosureButtonHighlightedPath] forState:UIControlStateHighlighted];
        [accessoryDetailDisclosureButton addTarget:self action:@selector(accessoryDetailDisclosureButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = accessoryDetailDisclosureButton;
        [accessoryDetailDisclosureButton release];
        
        cell.piosaDelegate = self;
    } else {
        tempCompanyImageView = (UIImageView *)[cell.contentView viewWithTag:kCompanyImageViewTag];
        tempCompanyNameLabel = (UILabel *)[cell.contentView viewWithTag:kCompanyNameLabelTag];
        tempFlightCodeLabel = (UILabel *)[cell.contentView viewWithTag:kFlightCodeLabelTag];
        tempStopLabel = (UILabel *)[cell.contentView viewWithTag:kStopLabelTag]; 
        tempFromTimeLabel = (UILabel *)[cell.contentView viewWithTag:kFromTimeLabelTag];
        tempFromAirportNameLabel = (UILabel *)[cell.contentView viewWithTag:kFromAirportNameLabelTag];
        tempToTimeLabel = (UILabel *)[cell.contentView viewWithTag:kToTimeLabelTag];
        tempToAirportNameLabel = (UILabel *)[cell.contentView viewWithTag:kToAirportNameLabelTag];
        tempFlightSeatLabel = (UILabel *)[cell.contentView viewWithTag:kFlightSeatLabelTag];
        tempUcaiPriceLabel = (UILabel *)[cell.contentView viewWithTag:kUcaiPriceLabelTag];
        tempUcaiSaveLabel = (UILabel *)[cell.contentView viewWithTag:kUcaiSaveLabelTag];
        tempPriceAndRebateLabel = (UIPiosaLabel *)[cell.contentView viewWithTag:kPriceAndRebateLabelTag];
    }
    
    NSString *flightCompanyPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:[_flightCompanyDic objectForKey:fLightListInfoModel.companyCode] inDirectory:@"Flight/FlightCompany"];
    tempCompanyImageView.image = [UIImage imageNamed:flightCompanyPath];
    tempCompanyNameLabel.text = fLightListInfoModel.companyName;
    tempFlightCodeLabel.text = fLightListInfoModel.flightCode;
    tempStopLabel.text = [@"0" isEqualToString:fLightListInfoModel.stopNum]?@"":@"经停";
    tempFromTimeLabel.text = fLightListInfoModel.fromTime;
    tempFromAirportNameLabel.text = fLightListInfoModel.fromAirportName;
    tempToTimeLabel.text = fLightListInfoModel.toTime;
    tempToAirportNameLabel.text = fLightListInfoModel.toAirportName;
    tempFlightSeatLabel.text = [NSString stringWithFormat:@"%@/%@",[_flightSeatDic objectForKey:fLightListInfoModel.cheapest.classCode],fLightListInfoModel.cheapest.classCode];
    tempUcaiPriceLabel.text = [NSString stringWithFormat:@"¥%@",fLightListInfoModel.cheapest.ucaiPrice];
    tempUcaiSaveLabel.text = [NSString stringWithFormat:@"/省%@元",fLightListInfoModel.cheapest.save];
    tempPriceAndRebateLabel.text = [NSString stringWithFormat:@"¥%@/%@折",fLightListInfoModel.cheapest.price,fLightListInfoModel.cheapest.rebate];
    
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
	if ([self.flightListSearchResponseModel.flights count]<=5) {
		//如果显示的航班不超出显示框，则通过添加footer来去除多出来的空cell
		UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)] autorelease];
		footer.backgroundColor = [UIColor clearColor];
		return footer;
	} else {
		return nil;
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kTableViewCellRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![self.req isFinished]) {
        [self.req clearDelegatesAndCancel]; //取消可能存在的请求
        [self doneLoadingTableViewData]; //取消加载完成数据，修改拉动刷新框的位置与其它参数
    }
    
    FLightListInfoModel *fLightListInfoModel = [self.flightListSearchResponseModel.flights objectAtIndex:indexPath.row];
    
    NSMutableDictionary* flightInfoDictionary = [[NSMutableDictionary alloc] init];
    [flightInfoDictionary setObject:self.startedDate forKey:@"goDate"];//出发日期
    [flightInfoDictionary setObject:self.startedCityName forKey:@"startedCityName"];//出发城市名称
    [flightInfoDictionary setObject:self.startCityCode forKey:@"dpt"];//出发城市三字码
    [flightInfoDictionary setObject:self.arrivedCityName forKey:@"arrivedCityName"];//到达城市名称
    [flightInfoDictionary setObject:self.arrivedCityCode forKey:@"arr"];//到达城市三字码
    [flightInfoDictionary setObject:fLightListInfoModel.fromAirportName forKey:@"fromAirportName"];//出发机场名称
    [flightInfoDictionary setObject:fLightListInfoModel.fromTime forKey:@"fromTime"];//出发时间(hh:mm)
    [flightInfoDictionary setObject:fLightListInfoModel.toAirportName forKey:@"toAirportName"];//到达机场名称
    [flightInfoDictionary setObject:fLightListInfoModel.toTime forKey:@"toTime"];//到达时间(hh:mm)
    [flightInfoDictionary setObject:fLightListInfoModel.flightCode forKey:@"flightNo"];//航班编号
    [flightInfoDictionary setObject:fLightListInfoModel.companyCode forKey:@"carrier"];//航空公司二字码
    [flightInfoDictionary setObject:fLightListInfoModel.companyName forKey:@"carrierName"];//航空公司名字
    [flightInfoDictionary setObject:fLightListInfoModel.cheapest.rebate forKey:@"discount"];//折扣
    [flightInfoDictionary setObject:fLightListInfoModel.cheapest.classCode forKey:@"classCode"];//舱位代码
    [flightInfoDictionary setObject:fLightListInfoModel.cheapest.price forKey:@"prePrice"];//原价价
    [flightInfoDictionary setObject:fLightListInfoModel.cheapest.ucaiPrice forKey:@"ucaiPrice"];//油菜价
    [flightInfoDictionary setObject:fLightListInfoModel.tax forKey:@"tax"];//燃油费
    [flightInfoDictionary setObject:fLightListInfoModel.airTax forKey:@"airTax"];//机建费
    [flightInfoDictionary setObject:fLightListInfoModel.plantype forKey:@"flightType"];//机型
    [flightInfoDictionary setObject:fLightListInfoModel.yPrice forKey:@"yPrice"];//y舱价格
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    switch ([userDefaults integerForKey:@"flightSearchLineType"]) {
        case UCAIFlightLineStyleSingle:
            [userDefaults setObject:flightInfoDictionary forKey:@"flightBookingLineSingle"];
            
            FlightBookViewController *flightBookViewController = [[FlightBookViewController alloc] init];
            [self.navigationController pushViewController:flightBookViewController animated:YES];
            [flightBookViewController release];
            
            break;
        case UCAIFlightLineStyleDouble:
            switch (_flightLineType) {
                case UCAIFlightLineStyleSingle:
                    [userDefaults setObject:flightInfoDictionary forKey:@"flightBookingLineSingle"];
                    
                    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                    _hud.bgRGB = [PiosaColorManager progressColor];
                    [self.navigationController.view addSubview:_hud];
                    _hud.delegate = self;
                    _hud.minSize = CGSizeMake(135.f, 135.f);
                    _hud.labelText = @"查询返程航班...";
                    [_hud show:YES];
                    
                    self.requestType = 3;
                    
                    NSString *postData = [[NSString alloc] initWithData:[self generateFlightBookingRequestPostXMLData:@"1" sortType:@"1" sortOrder:@"1"] encoding:NSUTF8StringEncoding];
                    NSLog(@"requestStart\n");
                    NSLog(@"%@\n", postData);
                    [postData release];
                    
                    ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: FLIGHT_LIST_SEARCH_ADDRESS]];
                    [req addRequestHeader:@"API-Version" value:API_VERSION];
                    req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
                    [req appendPostData:[self generateFlightBookingRequestPostXMLData:@"1" sortType:@"1" sortOrder:@"1"]];
                    [req setDelegate:self];
                    [req startAsynchronous]; // 执行异步post
                    self.req = req;
                    [req release];
                    
                    break;
                case UCAIFlightLineStyleDouble:
                    [userDefaults setObject:flightInfoDictionary forKey:@"flightBookingLineDouble"];
                    
                    FlightBookViewController *flightBookViewController = [[FlightBookViewController alloc] init];
                    [self.navigationController pushViewController:flightBookViewController animated:YES];
                    [flightBookViewController release];
                    break;
            }
            break;
    }
    
    [flightInfoDictionary release];
    
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
    
    if ((responseString != nil) && [responseString length] > 0) {
        switch (self.requestType) {
            case 1:{//航班列表加载更多
                FlightListSearchResponseModel *flightListSearchResponseModel = [ResponseParser loadFlightListSearchResponse:[request responseData] oldFlightList:self.flightListSearchResponseModel];
                if ([@"1" isEqualToString:flightListSearchResponseModel.resultCode]) {
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
                    hud.labelText = flightListSearchResponseModel.resultMessage;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    self.flightListSearchResponseModel = flightListSearchResponseModel;
                    [_refreshHeaderView setHidden:TRUE];//隐藏拉动刷新框，因为当加载速度很快时，拉动刷新框在doneLoadingTableViewData里调整位置前，已经显示出了flightListTableView的新数据
                    [self.flightListTableView reloadData];
                    
                }
                [self doneLoadingTableViewData]; //加载完成数据，修改拉动刷新框的位置与其它参数   
            }
                break;
            case 2:{//航班列表查询
                // 关闭加载框
                [_hud hide:YES];
                FlightListSearchResponseModel *flightListSearchResponseModel = [ResponseParser loadFlightListSearchResponse:[request responseData] oldFlightList:nil];
                if (![@"0" isEqualToString:flightListSearchResponseModel.resultCode]) {
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
                    hud.labelText = flightListSearchResponseModel.resultMessage;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    self.flightListSearchResponseModel = flightListSearchResponseModel;
                    
                    self.lastSegmentTag = self.newSegmentTag;		//更新排序选择控件标识
                    self.sortOrder = self.reSortOrder;
                    
                    [self.flightListTableView reloadData];
                    self.flightListTableView.contentOffset = CGPointMake(0, 0);//列表回顶部
                    
                    //设置拉动刷新框
                    int numberOfRowForFlightList = self.flightListSearchResponseModel.flights == nil ? 0 : [self.flightListSearchResponseModel.flights count];
                    [_refreshHeaderView setFrame:CGRectMake(0, kTableViewCellRowHeight*numberOfRowForFlightList, 320, 70)];//重设拉动刷新框的位置
                    
                    if ([self.flightListSearchResponseModel.pageSize intValue]*[self.flightListSearchResponseModel.currentPage intValue]>=[self.flightListSearchResponseModel.count intValue]) {
                        //如果当前页为最后一页，则隐藏拉动刷新框
                        [_refreshHeaderView setHidden:YES];
                    } else {
                        //如果当前页不为最后一页，则显示拉动刷新框
                        [_refreshHeaderView setHidden:NO];
                    }
                }
            }
                break;
            case 3:{//查询反程航班数据
                // 关闭加载框
                [_hud hide:YES];
                FlightListSearchResponseModel *flightListSearchResponseModel = [ResponseParser loadFlightListSearchResponse:[request responseData] oldFlightList:nil];
                if (flightListSearchResponseModel.resultCode == nil || [flightListSearchResponseModel.resultCode length] == 0 || [flightListSearchResponseModel.resultCode intValue] != 0) {
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
                    hud.labelText = flightListSearchResponseModel.resultMessage;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setValue:self.startedDate forKey:@"flightGoDate"];
                    FlightListViewController *flightListViewController = [[FlightListViewController alloc] initWithFlightLineStyle:UCAIFlightLineStyleDouble];
                    flightListViewController.startedDate = [userDefaults objectForKey:@"flightBackDate"];
                    flightListViewController.startedCityName = self.arrivedCityName;
                    flightListViewController.arrivedCityName = self.startedCityName;
                    flightListViewController.startCityCode = self.arrivedCityCode;
                    flightListViewController.arrivedCityCode = self.startCityCode;
                    flightListViewController.searchCompanyCode = self.searchCompanyCode;
                    flightListViewController.lastSegmentTag = 101;
                    flightListViewController.sortOrder = @"1";
                    flightListViewController.flightListSearchResponseModel = flightListSearchResponseModel;
                    [self.navigationController pushViewController:flightListViewController animated:YES];
                    [flightListViewController release];
                }
            }
                break;
            case 4:
            case 5:{
                // 关闭加载框
                [_hud hide:YES];
                FlightListSearchResponseModel *flightListSearchResponseModel = [ResponseParser loadFlightListSearchResponse:[request responseData] oldFlightList:nil];
                if ([@"1" isEqualToString:flightListSearchResponseModel.resultCode]) {
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
                    hud.labelText = flightListSearchResponseModel.resultMessage;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    self.flightListSearchResponseModel = flightListSearchResponseModel;
                    [self.flightListTableView reloadData];
                    [self.flightListTableView setContentOffset:CGPointZero animated:YES];
                    
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyy-MM-dd";
                    if (self.requestType == 4) {
                        //前一天
                        self.startedDate = [formatter stringFromDate:[[formatter dateFromString:self.startedDate] dateByAddingTimeInterval:-86400]];
                    } else {
                        //后一天
                        self.startedDate = [formatter stringFromDate:[[formatter dateFromString:self.startedDate] dateByAddingTimeInterval:86400]];
                    }
                    [formatter release];
                    self.startedDateLabel.text = self.startedDate;
                    self.countLabel.text = [NSString stringWithFormat:@"%@个结果",self.flightListSearchResponseModel.count];
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    switch (_flightLineType) {
                        case UCAIFlightLineStyleSingle:
                            [userDefaults setValue:self.startedDate forKey:@"flightGoDate"];
                            break;
                        case UCAIFlightLineStyleDouble:
                            [userDefaults setValue:self.startedDate forKey:@"flightBackDate"];
                            break;
                    }
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
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{ 
    _reloading = YES; 
}

- (void)doneLoadingTableViewData{ 
    _reloading = NO; 
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.flightListTableView];
	
	[_refreshHeaderView setFrame:CGRectMake(0, self.flightListTableView.contentSize.height, 320, 70)];//调整拉动刷新框的位置，使其位于刷新后的酒店列表下
    
    if ([self.flightListSearchResponseModel.pageSize intValue]*[self.flightListSearchResponseModel.currentPage intValue]>=[self.flightListSearchResponseModel.count intValue]) {
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

//手指在屏幕上开始拖动时调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
}

//当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{ 
	if ([self.flightListSearchResponseModel.pageSize intValue]*[self.flightListSearchResponseModel.currentPage intValue]<[self.flightListSearchResponseModel.count intValue]) {
        //显示最后一页时，可以不用调用方法来设置刷新视图
		[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView]; 
	}
} 
#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods 
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource]; //开始加载数据
	
	self.requestType = 1;
    
    NSInteger index = [self.flightListSearchResponseModel.currentPage intValue]+1;
    NSString *postData = [[NSString alloc] initWithData:[self generateFlightBookingRequestPostXMLData:[NSString stringWithFormat:@"%d",index] sortType:(self.lastSegmentTag == kSortLeftSegmentControlButtonTag?@"1":@"2") sortOrder:self.sortOrder] encoding:NSUTF8StringEncoding];
    NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    [postData release];
    
    ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: FLIGHT_LIST_SEARCH_ADDRESS]];
    [req addRequestHeader:@"API-Version" value:API_VERSION];
    req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    [req appendPostData:[self generateFlightBookingRequestPostXMLData:[NSString stringWithFormat:@"%d",index] sortType:(self.lastSegmentTag == kSortLeftSegmentControlButtonTag?@"1":@"2") sortOrder:self.sortOrder]];
    [req setDelegate:self];
    [req startAsynchronous]; // 执行异步post
    self.req = req;
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
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    [hud release];
	hud = nil;
}


@end

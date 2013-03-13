//
//  FlightSeatViewController.m
//  UCAI
//
//  Created by  on 12-1-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIPiosaLabel.h"

#import "FlightSeatViewController.h"
#import "FlightDetailSearchResponseModel.h"
#import "FlightBookViewController.h"

#import "FlightListSearchResponseModel.h"
#import "FlightListViewController.h"

#import "ResponseParser.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "StaticConf.h"
#import "CommonTools.h"
#import "PiosaFileManager.h"

#define kHUDhiddenTag 101 //只需要消失提交框
#define kHUDhiddenAndPopTag 102 //需要在提交框消失后退出视图

#define kTableViewCellRowHeight 50

#define kPriceAndRebateLabelTag 101
#define kSeatclassLabelTag 102
#define kUcaiPriceShowLabelTag 103
#define kUcaiPriceLabelTag 104
#define kUcaiSaveLabelTag 105
#define kSeatCountLabelTag 106

@implementation FlightSeatViewController

@synthesize startedCityName = _startedCityName;
@synthesize arrivedCityName = _arrivedCityName;
@synthesize startCityCode = _startCityCode;
@synthesize arrivedCityCode = _arrivedCityCode;
@synthesize goDate = _goDate;
@synthesize searchFlightCompanyCode = _searchFlightCompanyCode;
@synthesize flightId = _flightId;
@synthesize flightDetailSearchResponseModel = _flightDetailSearchResponseModel;
@synthesize req = _req;
@synthesize requestType = _requestType;

- (FlightSeatViewController *)initWithFlightLineStyle:(UCAIFlightLineStyle) flightLineType{
    self = [super init];
    _flightLineType = flightLineType;
    return self;
}

- (void)dealloc{
    [_flightSeatDic release];
    [_flightCompanyDic release];
    [self.startedCityName release];
    [self.arrivedCityName release];
    [self.startCityCode release];
    [self.arrivedCityCode release];
    [self.goDate release];
    [self.searchFlightCompanyCode release];
    [self.flightId release]; 
    [self.flightDetailSearchResponseModel release];
    [self.req release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadView{
    [super loadView];
    
    self.title = @"全部舱位";
    
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
    
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"查询中...";
    [_hud show:YES];
    
    self.requestType = 1;
    
    NSString *postData = [[NSString alloc] initWithData:[self generateFlightSeatRequestPostXMLData] encoding:NSUTF8StringEncoding];
    NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    [postData release];
    
    ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: FLIGHT_DETAIL_SEARCH_ADDRESS]];
    [req addRequestHeader:@"API-Version" value:API_VERSION];
    req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    [req appendPostData:[self generateFlightSeatRequestPostXMLData]];
    [req setDelegate:self];
    [req startAsynchronous]; // 执行异步post
    
    self.req = req;
    [req release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.flightDetailSearchResponseModel.classSeats count];
}

//设置表格单元的展现
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"cell";
    
    UIPiosaLabel * priceAndRebateLabel;
    UILabel * seatclassLabel;
    UILabel * ucaiPriceShowLabel;
    UILabel * ucaiPriceLabel;
    UILabel * ucaiSaveLabel;
    UILabel * seatCountLabel;
    
    FlightClassSeat * classSeat = [self.flightDetailSearchResponseModel.classSeats objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        UIPiosaLabel * tempPriceAndRebateLabel = [[UIPiosaLabel alloc] initWithFrame:CGRectMake(7, 1, 115, 25)];
        tempPriceAndRebateLabel.backgroundColor = [UIColor clearColor];
        tempPriceAndRebateLabel.textColor = [UIColor grayColor];
        tempPriceAndRebateLabel.font = [UIFont systemFontOfSize:14];
        priceAndRebateLabel = tempPriceAndRebateLabel;
        tempPriceAndRebateLabel.tag = kPriceAndRebateLabelTag;
        [cell.contentView addSubview:tempPriceAndRebateLabel];
        [tempPriceAndRebateLabel release];
        
        UILabel * tempSeatclassLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 1, 80, 25)];
        tempSeatclassLabel.backgroundColor = [UIColor clearColor];
        tempSeatclassLabel.font = [UIFont systemFontOfSize:13];
        tempSeatclassLabel.textAlignment = UITextAlignmentRight;
        seatclassLabel = tempSeatclassLabel;
        tempSeatclassLabel.tag = kSeatclassLabelTag;
        [cell.contentView addSubview:tempSeatclassLabel];
        [tempSeatclassLabel release];
        
        UILabel *tempUcaiPriceShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 24, 50, 25)];
        tempUcaiPriceShowLabel.backgroundColor = [UIColor clearColor];
        tempUcaiPriceShowLabel.textColor = [UIColor grayColor];
        tempUcaiPriceShowLabel.font = [UIFont systemFontOfSize:15];
        ucaiPriceShowLabel = tempUcaiPriceShowLabel;
        tempUcaiPriceShowLabel.tag = kUcaiPriceShowLabelTag;
        [cell.contentView addSubview:tempUcaiPriceShowLabel];
        [tempUcaiPriceShowLabel release];
        
        UILabel * tempUcaiPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 24, 55, 25)];
        tempUcaiPriceLabel.backgroundColor = [UIColor clearColor];
        tempUcaiPriceLabel.textColor = [UIColor redColor];
        tempUcaiPriceLabel.textAlignment = UITextAlignmentRight;
        tempUcaiPriceLabel.font = [UIFont boldSystemFontOfSize:15];
        ucaiPriceLabel = tempUcaiPriceLabel;
        tempUcaiPriceLabel.tag = kUcaiPriceLabelTag;
        [cell.contentView addSubview:tempUcaiPriceLabel];
        [tempUcaiPriceLabel release];
        
        UILabel * tempUcaiSaveLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 26, 50, 25)];
        tempUcaiSaveLabel.backgroundColor = [UIColor clearColor];
        tempUcaiSaveLabel.textColor = [UIColor redColor];
        tempUcaiSaveLabel.font = [UIFont boldSystemFontOfSize:12];
        ucaiSaveLabel = tempUcaiSaveLabel;
        tempUcaiSaveLabel.tag = kUcaiSaveLabelTag;
        [cell.contentView addSubview:tempUcaiSaveLabel];
        [tempUcaiSaveLabel release];
        
        UILabel * tempSeatCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 24, 80, 25)];
        tempSeatCountLabel.backgroundColor = [UIColor clearColor];
        tempSeatCountLabel.font = [UIFont systemFontOfSize:15];
        tempSeatCountLabel.textAlignment = UITextAlignmentRight;
        seatCountLabel = tempSeatCountLabel;
        tempSeatCountLabel.tag = kSeatCountLabelTag;
        [cell.contentView addSubview:tempSeatCountLabel];
        [tempSeatCountLabel release];
        
    } else {
        priceAndRebateLabel = (UIPiosaLabel *)[cell.contentView viewWithTag:kPriceAndRebateLabelTag];
        seatclassLabel = (UILabel *)[cell.contentView viewWithTag:kSeatclassLabelTag];
        ucaiPriceShowLabel = (UILabel *)[cell.contentView viewWithTag:kUcaiPriceShowLabelTag];
        ucaiPriceLabel = (UILabel *)[cell.contentView viewWithTag:kUcaiPriceLabelTag];
        ucaiSaveLabel = (UILabel *)[cell.contentView viewWithTag:kUcaiSaveLabelTag];
        seatCountLabel = (UILabel *)[cell.contentView viewWithTag:kSeatCountLabelTag];
    }
    
    priceAndRebateLabel.text = [NSString stringWithFormat:@"¥%@/%@折",classSeat.price,classSeat.rebate];
    seatclassLabel.text = [NSString stringWithFormat:@"%@/%@",[_flightSeatDic objectForKey:classSeat.classCode],classSeat.classCode];
    ucaiPriceShowLabel.text = @"油菜价";
    ucaiPriceLabel.text = [NSString stringWithFormat:@"¥%@",classSeat.ucaiPrice];
    ucaiSaveLabel.text = [NSString stringWithFormat:@"/省%@元",classSeat.save];
    seatCountLabel.text = [NSString stringWithFormat:@"座位数:%@",[classSeat.status isEqualToString:@"A"]?@"9↥":classSeat.status];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	if ([self.flightDetailSearchResponseModel.classSeats count]<=5) {
		//如果显示的舱位不超出显示框，则通过添加footer来去除多出来的空cell
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
    
    FlightClassSeat *classSeat = [self.flightDetailSearchResponseModel.classSeats objectAtIndex:indexPath.row];
    
    NSMutableDictionary* flightInfoDictionary = [[NSMutableDictionary alloc] init];
    [flightInfoDictionary setObject:self.goDate forKey:@"goDate"];//出发日期
    [flightInfoDictionary setObject:self.startedCityName forKey:@"startedCityName"];//出发城市名称
    [flightInfoDictionary setObject:self.startCityCode forKey:@"dpt"];//出发城市三字码
    [flightInfoDictionary setObject:self.arrivedCityName forKey:@"arrivedCityName"];//到达城市名称
    [flightInfoDictionary setObject:self.arrivedCityCode forKey:@"arr"];//到达城市三字码
    [flightInfoDictionary setObject:self.flightDetailSearchResponseModel.fromAirportName forKey:@"fromAirportName"];//出发机场名称
    [flightInfoDictionary setObject:self.flightDetailSearchResponseModel.fromTime forKey:@"fromTime"];//出发时间(hh:mm)
    [flightInfoDictionary setObject:self.flightDetailSearchResponseModel.toAirportName forKey:@"toAirportName"];//到达机场名称
    [flightInfoDictionary setObject:self.flightDetailSearchResponseModel.toTime forKey:@"toTime"];//到达时间(hh:mm)
    [flightInfoDictionary setObject:self.flightDetailSearchResponseModel.flightCode forKey:@"flightNo"];//航班编号
    [flightInfoDictionary setObject:self.flightDetailSearchResponseModel.companyCode forKey:@"carrier"];//航空公司二字码
    [flightInfoDictionary setObject:self.flightDetailSearchResponseModel.companyName forKey:@"carrierName"];//航空公司名字
    [flightInfoDictionary setObject:classSeat.rebate forKey:@"discount"];//折扣
    [flightInfoDictionary setObject:classSeat.classCode forKey:@"classCode"];//舱位代码
    [flightInfoDictionary setObject:classSeat.price forKey:@"prePrice"];//原价价
    [flightInfoDictionary setObject:classSeat.ucaiPrice forKey:@"ucaiPrice"];//油菜价
    [flightInfoDictionary setObject:self.flightDetailSearchResponseModel.tax forKey:@"tax"];//燃油费
    [flightInfoDictionary setObject:self.flightDetailSearchResponseModel.airTax forKey:@"airTax"];//机建费
    [flightInfoDictionary setObject:self.flightDetailSearchResponseModel.plantype forKey:@"flightType"];//机型
    [flightInfoDictionary setObject:self.flightDetailSearchResponseModel.yPrice forKey:@"yPrice"];//y舱价格
    
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
                    
                    self.requestType = 2;
                    
                    NSString *postData = [[NSString alloc] initWithData:[self generateFlightBookingRequestPostXMLData] encoding:NSUTF8StringEncoding];
                    NSLog(@"requestStart\n");
                    NSLog(@"%@\n", postData);
                    [postData release];
                    
                    ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: FLIGHT_LIST_SEARCH_ADDRESS]];
                    [req addRequestHeader:@"API-Version" value:API_VERSION];
                    req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
                    [req appendPostData:[self generateFlightBookingRequestPostXMLData]];
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
                    break;
            }
            break;
    }
    
    [flightInfoDictionary release];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        
        switch (self.requestType) {
            case 1:{
                FlightDetailSearchResponseModel *flightDetailSearchResponseModel = [ResponseParser loadFlightDetailSearchResponse:[request responseData]];
                self.flightDetailSearchResponseModel = flightDetailSearchResponseModel;
                
                if (flightDetailSearchResponseModel.resultCode == nil || [flightDetailSearchResponseModel.resultCode length] == 0 || [flightDetailSearchResponseModel.resultCode intValue] != 0) {
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
                    hud.labelText = flightDetailSearchResponseModel.resultMessage;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
                    titleView.backgroundColor = [PiosaColorManager secondTitleColor];
                    
                    UILabel *startedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 80, 20)];
                    startedDateLabel.backgroundColor = [UIColor clearColor];
                    startedDateLabel.textColor = [UIColor whiteColor];
                    startedDateLabel.font = [UIFont systemFontOfSize:12];
                    startedDateLabel.text = self.goDate;
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
                    countLabel.text = [NSString stringWithFormat:@"%d种舱位",[flightDetailSearchResponseModel.classSeats count]];
                    [titleView addSubview:countLabel];
                    [countLabel release];
                    
                    [self.view addSubview:titleView];
                    [titleView release];
                    
                    UIView *flightInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 25, 320, 66)];
                    flightInfoView.backgroundColor = [UIColor whiteColor];
                    [self.view addSubview:flightInfoView];
                    
                    UILabel * flightCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 70, 15)];
                    flightCodeLabel.backgroundColor = [UIColor clearColor];
                    flightCodeLabel.textColor = [UIColor redColor];
                    flightCodeLabel.font = [UIFont systemFontOfSize:13];
                    flightCodeLabel.text = flightDetailSearchResponseModel.flightCode;
                    [flightInfoView addSubview:flightCodeLabel];
                    [flightCodeLabel release];
                    
                    UIImageView * companyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(122, 2, 20, 20)];
                    NSString *flightCompanyPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:[_flightCompanyDic objectForKey:flightDetailSearchResponseModel.companyCode] inDirectory:@"Flight/FlightCompany"];
                    companyImageView.image = [UIImage imageNamed:flightCompanyPath];
                    [flightInfoView addSubview:companyImageView];
                    [companyImageView release];
                    
                    UILabel * companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(142, 5, 70, 15)];
                    companyNameLabel.backgroundColor = [UIColor clearColor];
                    companyNameLabel.font = [UIFont systemFontOfSize:13];
                    companyNameLabel.text = flightDetailSearchResponseModel.companyName;
                    [flightInfoView addSubview:companyNameLabel];
                    [companyNameLabel release];
                    
                    UILabel * plantypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(245, 5, 70, 15)];
                    plantypeLabel.backgroundColor = [UIColor clearColor];
                    plantypeLabel.font = [UIFont systemFontOfSize:13];
                    plantypeLabel.textAlignment = UITextAlignmentRight;
                    plantypeLabel.text = [NSString stringWithFormat:@"机型%@",flightDetailSearchResponseModel.plantype];
                    [flightInfoView addSubview:plantypeLabel];
                    [plantypeLabel release];
                    
                    UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, 32, 15)];
                    fromLabel.backgroundColor = [UIColor clearColor];
                    fromLabel.textColor = [UIColor grayColor];
                    fromLabel.font = [UIFont systemFontOfSize:15];
                    fromLabel.text = @"起飞";
                    [flightInfoView addSubview:fromLabel];
                    [fromLabel release];
                    
                    UILabel * fromTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 25, 57, 15)];
                    fromTimeLabel.backgroundColor = [UIColor clearColor];
                    fromTimeLabel.font = [UIFont systemFontOfSize:15];
                    fromTimeLabel.text = flightDetailSearchResponseModel.fromTime;
                    [flightInfoView addSubview:fromTimeLabel];
                    [fromTimeLabel release];
                    
                    UILabel * fromAirportNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 25, 100, 15)];
                    fromAirportNameLabel.backgroundColor = [UIColor clearColor];
                    fromAirportNameLabel.textColor = [PiosaColorManager fontColor];
                    fromAirportNameLabel.font = [UIFont systemFontOfSize:15];
                    fromAirportNameLabel.text = flightDetailSearchResponseModel.fromAirportName;
                    [flightInfoView addSubview:fromAirportNameLabel];
                    [fromAirportNameLabel release];
                    
                    UILabel * taxLabel = [[UILabel alloc] initWithFrame:CGRectMake(235, 25, 80, 15)];
                    taxLabel.backgroundColor = [UIColor clearColor];
                    taxLabel.textColor = [PiosaColorManager fontColor];
                    taxLabel.font = [UIFont systemFontOfSize:15];
                    taxLabel.textAlignment = UITextAlignmentRight;
                    taxLabel.text = [NSString stringWithFormat:@"燃油¥%@",flightDetailSearchResponseModel.tax];
                    [flightInfoView addSubview:taxLabel];
                    [taxLabel release];
                    
                    UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 45, 32, 15)];
                    toLabel.backgroundColor = [UIColor clearColor];
                    toLabel.textColor = [UIColor grayColor];
                    toLabel.font = [UIFont systemFontOfSize:15];
                    toLabel.text = @"到达";
                    [flightInfoView addSubview:toLabel];
                    [toLabel release];
                    
                    UILabel * toTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 45, 57, 15)];
                    toTimeLabel.backgroundColor = [UIColor clearColor];
                    toTimeLabel.font = [UIFont systemFontOfSize:15];
                    toTimeLabel.text = flightDetailSearchResponseModel.toTime;
                    [flightInfoView addSubview:toTimeLabel];
                    [toTimeLabel release];
                    
                    UILabel * toAirportNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 45, 100, 15)];
                    toAirportNameLabel.backgroundColor = [UIColor clearColor];
                    toAirportNameLabel.textColor = [UIColor grayColor];
                    toAirportNameLabel.font = [UIFont systemFontOfSize:15];
                    toAirportNameLabel.text = flightDetailSearchResponseModel.toAirportName;
                    [flightInfoView addSubview:toAirportNameLabel];
                    [toAirportNameLabel release];
                    
                    UILabel * airTaxLabel = [[UILabel alloc] initWithFrame:CGRectMake(235, 45, 80, 15)];
                    airTaxLabel.backgroundColor = [UIColor clearColor];
                    airTaxLabel.textColor = [PiosaColorManager fontColor];
                    airTaxLabel.font = [UIFont systemFontOfSize:15];
                    airTaxLabel.textAlignment = UITextAlignmentRight;
                    airTaxLabel.text = [NSString stringWithFormat:@"机建¥%@",flightDetailSearchResponseModel.airTax];
                    [flightInfoView addSubview:airTaxLabel];
                    [airTaxLabel release];
                    
                    [flightInfoView release];
                    
                    UIView *seatInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 91, 320, 25)];
                    seatInfoView.backgroundColor = [PiosaColorManager secondTitleColor];
                    
                    UILabel *seatShowTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, 80, 20)];
                    seatShowTitleLabel.backgroundColor = [UIColor clearColor];
                    seatShowTitleLabel.textColor = [UIColor whiteColor];
                    seatShowTitleLabel.font = [UIFont systemFontOfSize:15];
                    seatShowTitleLabel.text = @"全部舱位";
                    [seatInfoView addSubview:seatShowTitleLabel];
                    [seatShowTitleLabel release];
                    
                    [self.view addSubview:seatInfoView];
                    [seatInfoView release];
                    
                    UITableView *seatListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 116, 320, 300) style:UITableViewStylePlain];
                    seatListTableView.dataSource = self;
                    seatListTableView.delegate = self;
                    [self.view addSubview:seatListTableView];
                    [seatListTableView release];  
                }
            }
                break;
            case 2:{
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
                    [userDefaults setValue:self.goDate forKey:@"flightGoDate"];
                    FlightListViewController *flightListViewController = [[FlightListViewController alloc] initWithFlightLineStyle:UCAIFlightLineStyleDouble];
                    flightListViewController.startedDate = [userDefaults objectForKey:@"flightBackDate"];
                    flightListViewController.startedCityName = self.arrivedCityName;
                    flightListViewController.arrivedCityName = self.startedCityName;
                    flightListViewController.startCityCode = self.arrivedCityCode;
                    flightListViewController.arrivedCityCode = self.startCityCode;
                    flightListViewController.searchCompanyCode = self.searchFlightCompanyCode;
                    flightListViewController.lastSegmentTag = 101;
                    flightListViewController.sortOrder = @"1";
                    flightListViewController.flightListSearchResponseModel = flightListSearchResponseModel;
                    [self.navigationController pushViewController:flightListViewController animated:YES];
                    [flightListViewController release];
                }
            }
                break;
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
    if (self.requestType == 1) {
        _hud.tag = kHUDhiddenAndPopTag;
    }
    [_hud hide:YES afterDelay:3];
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

- (NSData*)generateFlightSeatRequestPostXMLData{
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"fromCity" stringValue:self.startCityCode]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"toCity" stringValue:self.arrivedCityCode]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"fromDate" stringValue:self.goDate]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"companyCode" stringValue:self.searchFlightCompanyCode]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"id" stringValue:self.flightId]];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    
    return document.XMLData;
}

- (NSData*)generateFlightBookingRequestPostXMLData{
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *pageInfoElement = [GDataXMLElement elementWithName:@"pageInfo"]; 
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"currentPage" stringValue:@"1"]];
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"pageSize" stringValue:@"20"]];  // 查到爆
    [requestElement addChild:pageInfoElement];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"fromCity" stringValue:self.arrivedCityCode]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"toCity" stringValue:self.startCityCode]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"fromDate" stringValue:[userDefaults objectForKey:@"flightBackDate"]]];
    
    [conditionElement addChild:[GDataXMLNode elementWithName:@"companyCode" stringValue:self.searchFlightCompanyCode]];
    GDataXMLElement *sortElement = [GDataXMLElement elementWithName:@"sort"]; 
    [sortElement addChild:[GDataXMLNode elementWithName:@"sortType" stringValue:@"1"]];
    [sortElement addChild:[GDataXMLNode elementWithName:@"sortOrder" stringValue:@"1"]];
    [conditionElement addChild:sortElement];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    
    return document.XMLData;
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

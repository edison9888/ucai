//
//  HotelSearchController.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-18.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "UIView-ModalAnimationHelper.h"

#import "HotelSearchController.h"
#import "HotelCityChoiceController.h"
#import "HotelStarChoiceController.h"
#import "HotelPriceChoiceController.h"
#import "HotelListController.h"
#import "HotelListSearchRequest.h"

#import "ResponseParser.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "StaticConf.h"
#import "CommonTools.h"

#import "HotelListSearchResponse.h"

#import "PiosaFileManager.h"

@implementation HotelSearchController

@synthesize hotelSearchTableView = _hotelSearchTableView;
@synthesize cityLabel = _cityLabel;
@synthesize checkInDataLabel = _checkInDataLabel;
@synthesize checkOutDataLabel = _checkOutDataLabel;
@synthesize rankLabel = _rankLabel;
@synthesize priceRateLabel = _priceRateLabel;

@synthesize hotelNameField = _hotelNameField;

@synthesize cityCode = _cityCode;
@synthesize hotelRank = _hotelRank;
@synthesize maxPriceRate = _maxPriceRate;
@synthesize minPriceRate = _minPriceRate;

@synthesize dateBar = _dateBar;
@synthesize datePicker = _datePicker;

@synthesize isCheckInDateSelect = _isCheckInDateSelect;

@synthesize hotelListSearchRequest = _hotelListSearchRequest;

- (void)viewDidUnload {
    self.hotelSearchTableView = nil;
    self.cityLabel = nil;
	self.checkInDataLabel = nil;
	self.checkOutDataLabel = nil;
	self.rankLabel = nil;
	self.priceRateLabel = nil;
	self.hotelNameField = nil;
	
	self.cityCode = nil;
	self.hotelRank = nil;
	self.maxPriceRate = nil;
	self.minPriceRate = nil;
	
	self.dateBar = nil;
	self.datePicker = nil;
	
	self.hotelListSearchRequest = nil;
}


- (void)dealloc {
    [self.hotelSearchTableView release];
	[self.cityLabel release];
	[self.checkInDataLabel release];
	[self.checkOutDataLabel release];
	[self.rankLabel release];
	[self.priceRateLabel release];
	[self.hotelNameField release];
	
	[self.cityCode release];
	[self.hotelRank release];
	[self.maxPriceRate release];
	[self.minPriceRate release];
	
	[self.dateBar release];
	[self.datePicker release];
	
	[self.hotelListSearchRequest release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom

- (void)phoneCall{
    if ([[UIApplication  sharedApplication] canOpenURL:[NSURL  URLWithString:@"tel://4006840060"]]) {
        UIActionSheet * phoneActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拨打电话40068 40060" otherButtonTitles:nil, nil];
        phoneActionSheet.delegate = self;
        [phoneActionSheet showInView:[UIApplication sharedApplication].keyWindow];
		[phoneActionSheet release];
    }
}

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

//响应文本输入框的完成按钮操作，用于收回键盘
- (IBAction)textFieldDone:(id)sender{
	[self.hotelSearchTableView becomeFirstResponder];
}

- (void)hotelSearch{
	_hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"查询中...";
    [_hud show:YES];
	
	ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: HOTEL_SEARCH_ADDRESS]] autorelease];
	req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
	
	NSString *postData = [[NSString alloc] initWithData:[self generateHotelListSearchRequestPostXMLData:@"PRICELTH" pageNO:1] encoding:NSUTF8StringEncoding];
	NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    [req setPostValue:postData forKey:@"requestXml"];
	
	[req setDelegate:self];
	[req startAsynchronous]; // 执行异步post
	[postData release];
}

- (void)dateCancel{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	self.dateBar.frame = CGRectMake(0, 416, 320, 40);
	self.datePicker.frame = CGRectMake(0, 446, 320, 216);
	[UIView commitModalAnimations];
    self.dateBar.hidden = YES;
    self.datePicker.hidden = YES;
    [self.hotelSearchTableView setScrollEnabled:YES];
}

- (void)dateDone{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	self.dateBar.frame = CGRectMake(0, 416, 320, 40);
	self.datePicker.frame = CGRectMake(0, 446, 320, 216);
	[UIView commitModalAnimations];
    self.dateBar.hidden = YES;
    self.datePicker.hidden = YES;
	[self.hotelSearchTableView setScrollEnabled:YES];
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"yyyy-MM-dd";
	
	if (self.isCheckInDateSelect) {
		//入住日期的选择
		self.checkInDataLabel.text = [formatter stringFromDate:[self.datePicker date]];
		
		// 判断入住日期是否晚于离店日期，若是，则要设置离店日期为入住日期的后一天
		if ([[formatter dateFromString:self.checkOutDataLabel.text] compare:[self.datePicker date]] != NSOrderedDescending) {
			//入住日期晚于离店日期
			self.checkOutDataLabel.text = [formatter stringFromDate:[[self.datePicker date] dateByAddingTimeInterval:86400]];
		}
	} else {
		//离店日期的选择
		self.checkOutDataLabel.text = [formatter stringFromDate:[self.datePicker date]];
	}
}

- (NSData*)generateHotelListSearchRequestPostXMLData:(NSString *)orderBy pageNO:(NSInteger)searchPage{
	HotelListSearchRequest *searchRequest = [[HotelListSearchRequest alloc] init];
	searchRequest.hotelCheckInDate = self.checkInDataLabel.text;
	searchRequest.hotelCheckOutDate = self.checkOutDataLabel.text;
	searchRequest.hotelCityCode = self.cityCode;
	searchRequest.hotelName = [self.hotelNameField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	searchRequest.hotelDistrict = @"";
	searchRequest.hotelRank = self.hotelRank;
	searchRequest.hotelMaxRate = self.maxPriceRate;
	searchRequest.hotelMinRate = self.minPriceRate;
	searchRequest.hotelPageNo = [NSString stringWithFormat:@"%d", searchPage];
	searchRequest.hotelOrderBy = orderBy;
	self.hotelListSearchRequest = searchRequest;
	[searchRequest release];
	
	
	//编辑会员资料查询请求的xml数据
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@" "];
	[requestElement addChild:[GDataXMLNode elementWithName:@"CheckInDate" stringValue:self.checkInDataLabel.text]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"CheckOutDate" stringValue:self.checkOutDataLabel.text]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"CityCode" stringValue:self.cityCode]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"HotelName" stringValue:[self.hotelNameField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"District" stringValue:@""]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"Rank" stringValue:self.hotelRank]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"MaxRate" stringValue:self.maxPriceRate]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"MinRate" stringValue:self.minPriceRate]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"PageNo" stringValue:[NSString stringWithFormat: @"%d", searchPage]]];
	[requestElement addChild:[GDataXMLNode elementWithName:@"OrderBy" stringValue:orderBy]];
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
    
    [_hud hide:YES];
    if ((responseString != nil) && [responseString length] > 0) {
        
		HotelListSearchResponse *hotelListSearchResponse = [ResponseParser loadHotelListSearchResponse:[request responseData] oldHotelList:nil];
		
		if (hotelListSearchResponse.result_code == nil || [hotelListSearchResponse.result_code length] == 0 || [hotelListSearchResponse.result_code intValue] != 1) {
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
            hud.labelText = hotelListSearchResponse.result_message;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
		}else {
			if ([@"查询结果为空" isEqualToString:hotelListSearchResponse.result_message]) {
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
				HotelListController * hotelListController = [[HotelListController alloc] init];
                hotelListController.cityName = self.cityLabel.text;
				hotelListController.orderBy = @"PRICELTH";
				//hotelListController.lastSegment = 0;
                hotelListController.lastSegmentTag = 101;
				hotelListController.loadDate = [NSDate date];
				hotelListController.hotelSearchController = self;
				hotelListController.hotelListSearchRequest = self.hotelListSearchRequest;
				hotelListController.hotelListSearchResponse = hotelListSearchResponse;
				[self.navigationController pushViewController:hotelListController animated:YES];
				[hotelListController release];
			}
		}
    }
}

// 网络无响应
- (void)requestFailed:(ASIFormDataRequest *)request
{
    NSLog(@"网络无响应");
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
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.title = @"酒店查询";
        
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
    
    UITableView * tempTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 386) style:UITableViewStyleGrouped];
    tempTableView.backgroundColor = [UIColor clearColor];
    tempTableView.dataSource = self;
    tempTableView.delegate = self;
    self.hotelSearchTableView = tempTableView;
    [self.view addSubview:self.hotelSearchTableView];
    [tempTableView release];
    
    UIButton *hotelSearchButton = [[UIButton alloc] init];
	[hotelSearchButton setFrame:CGRectMake(10, 335, 300, 40)];
	[hotelSearchButton setTitle:@"查    询" forState:UIControlStateNormal];
    [hotelSearchButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
    [hotelSearchButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
	[hotelSearchButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
	[hotelSearchButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
	[hotelSearchButton addTarget:self action:@selector(hotelSearch) forControlEvents:UIControlEventTouchUpInside];
	[self.hotelSearchTableView addSubview:hotelSearchButton];
	[hotelSearchButton release];
    
    //底部视图的设置
    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 386, 320, 30)];
    bottomView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    UIButton * phoneButton = [[UIButton alloc] initWithFrame:CGRectMake(82, 2, 156, 26)];
    NSString *phonecallButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"phonecall_normal" inDirectory:@"CommonView/BottomItem"];
    NSString *phonecallButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"phonecall_highlighted" inDirectory:@"CommonView/BottomItem"];
    [phoneButton setImage:[UIImage imageNamed:phonecallButtonNormalPath] forState:UIControlStateNormal];
    [phoneButton setImage:[UIImage imageNamed:phonecallButtonHighlightedPath] forState:UIControlStateHighlighted];
    [phoneButton addTarget:self action:@selector(phoneCall) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:phoneButton];
    [self.view addSubview:bottomView];
    [phoneButton release];
    [bottomView release];
	
	//初始化dataPicker
	UIDatePicker * tempDatePicker = [[UIDatePicker alloc] init];
	[tempDatePicker setFrame:CGRectMake(0, 446, 320, 100)];//大小固定为320＊216
    tempDatePicker.hidden = YES;
	tempDatePicker.datePickerMode = UIDatePickerModeDate;//时间选择只有日期
    self.datePicker = tempDatePicker;
	[self.view addSubview:self.datePicker];
    [tempDatePicker release];
	
	//初始化dataBar
	NSMutableArray *buttons = [[NSMutableArray alloc] init]; 
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: @"取消" style:UIBarButtonItemStyleBordered target: self action: @selector(dateCancel)]; 
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"确定" style:UIBarButtonItemStyleBordered target: self action: @selector(dateDone)]; 
	[buttons addObject:cancelButton];
    [buttons addObject:flexibleSpace]; 
    [buttons addObject:doneButton]; 
	[cancelButton release];
	[flexibleSpace release]; 
	[doneButton release];
    
	UIToolbar * dataToolBar = [[UIToolbar alloc] init];
	dataToolBar.tintColor = [PiosaColorManager tableViewPlainHeaderColor];
	[dataToolBar setFrame:CGRectMake(0, 416, 320, 40)];
    dataToolBar.hidden = YES;
	[dataToolBar setItems:buttons animated:TRUE]; 
    self.dateBar = dataToolBar;
	[self.view addSubview:self.dateBar];
    [dataToolBar release];
	[buttons release];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 0:
			return 2;
			break;
		case 1:
			return 2;
			break;
		case 2:
			return 2;
			break;
		default:
			return 0;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", indexPath.row, indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		switch (indexPath.section) {
			case 0:{
                switch (indexPath.row) {
                    case 0:{
                        UILabel *labelCity = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        labelCity.backgroundColor = [UIColor clearColor];
                        labelCity.textAlignment = UITextAlignmentRight;
                        labelCity.text = @"入住城市:";
                        [cell.contentView addSubview:labelCity];
                        [labelCity release];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                        UILabel * cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        cityLabel.backgroundColor = [UIColor clearColor];
                        cityLabel.textColor = [UIColor grayColor];
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        NSString * hotelDefaultCityName = [userDefaults stringForKey:@"hotelDefaultCityName"];
                        cityLabel.text = hotelDefaultCityName == nil ?@"深圳":hotelDefaultCityName;
                        self.cityLabel = cityLabel;
                        [cell.contentView addSubview:cityLabel];
                        [cityLabel release];
                        
                        NSString * hotelDefaultCityCode = [userDefaults stringForKey:@"hotelDefaultCityCode"];
                        self.cityCode = hotelDefaultCityCode == nil ?@"SZX":hotelDefaultCityCode;
                        
                        NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                        UIImageView * accessoryViewTemp1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                        accessoryViewTemp1.frame = CGRectMake(0, 0, 10, 16);
                        cell.accessoryView = accessoryViewTemp1;
                        [accessoryViewTemp1 release];
                    }
                        break;
					case 1:
                    {
                        UILabel *labelHotelName = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        labelHotelName.backgroundColor = [UIColor clearColor];
						labelHotelName.textAlignment = UITextAlignmentRight;
						labelHotelName.text = @"酒店名称:";
						[cell.contentView addSubview:labelHotelName];
						[labelHotelName release];
						cell.selectionStyle = UITableViewCellSelectionStyleNone;
						
						UITextField * hotelNameField = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 190, 25)];
						hotelNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
						hotelNameField.borderStyle = UITextBorderStyleRoundedRect;
						hotelNameField.returnKeyType = UIReturnKeyDone;
						hotelNameField.text = @"";
						[hotelNameField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        self.hotelNameField = hotelNameField;
						[cell.contentView addSubview:hotelNameField];
                        [hotelNameField release];
                    }
                        break;
                }
				
			}
				break;
			case 1:
            {
				NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				formatter.dateFormat = @"yyyy-MM-dd";
				switch (indexPath.row) 
                {
					case 0:{
						UILabel *labelCheckInDate = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        labelCheckInDate.backgroundColor = [UIColor clearColor];
						labelCheckInDate.textAlignment = UITextAlignmentRight;
						labelCheckInDate.text = @"入住日期:";
						[cell.contentView addSubview:labelCheckInDate];
						[labelCheckInDate release];
						
						UILabel * checkInDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        checkInDataLabel.backgroundColor = [UIColor clearColor];
						checkInDataLabel.textColor = [UIColor grayColor];
						checkInDataLabel.text = [formatter stringFromDate:[NSDate date]];
                        self.checkInDataLabel = checkInDataLabel;
						[cell.contentView addSubview:checkInDataLabel];
                        [checkInDataLabel release];
					}
						break;
					case 1:{
						UILabel *labelCheckOutDate = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        labelCheckOutDate.backgroundColor = [UIColor clearColor];
						labelCheckOutDate.textAlignment = UITextAlignmentRight;
						labelCheckOutDate.text = @"离店日期:";
						[cell.contentView addSubview:labelCheckOutDate];
						[labelCheckOutDate release];
						
						UILabel *checkOutDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        checkOutDataLabel.backgroundColor = [UIColor clearColor];
						checkOutDataLabel.textColor = [UIColor grayColor];
						checkOutDataLabel.text = [formatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:86400]];
                        self.checkOutDataLabel = checkOutDataLabel;
						[cell.contentView addSubview:checkOutDataLabel];
                        [checkOutDataLabel release];
					}
						break;
				}
                [formatter release];
			}
                NSString *accessoryTimeIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryTimeIndicator" inDirectory:@"CommonView/TableViewCell"];
                UIImageView * accessoryViewTemp2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryTimeIndicatorPath]];
                accessoryViewTemp2.frame = CGRectMake(0, 0, 20, 20);
                cell.accessoryView = accessoryViewTemp2;
                [accessoryViewTemp2 release];
				break;
			case 2:{
				switch (indexPath.row) {
					case 0:{
						UILabel *labelRank = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        labelRank.backgroundColor = [UIColor clearColor];
						labelRank.textAlignment = UITextAlignmentRight;
						labelRank.text = @"酒店星级:";
						[cell.contentView addSubview:labelRank];
						[labelRank release];
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						
						UILabel *rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        rankLabel.backgroundColor = [UIColor clearColor];
						rankLabel.textColor = [UIColor grayColor];
						rankLabel.text = @"不限";
                        self.rankLabel = rankLabel;
						[cell.contentView addSubview:rankLabel];
                        [rankLabel release];
						
						self.hotelRank = @"";
					}
						break;
					case 1:{
						UILabel *labelPriceRate = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        labelPriceRate.backgroundColor = [UIColor clearColor];
						labelPriceRate.textAlignment = UITextAlignmentRight;
						labelPriceRate.text = @"房价范围:";
						[cell.contentView addSubview:labelPriceRate];
						[labelPriceRate release];
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						
						UILabel *priceRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        priceRateLabel.backgroundColor = [UIColor clearColor];
						priceRateLabel.textColor = [UIColor grayColor];
						priceRateLabel.text = @"不限";
                        self.priceRateLabel = priceRateLabel;
						[cell.contentView addSubview:priceRateLabel];
                        [priceRateLabel release];
						
						self.maxPriceRate = @"";
						self.minPriceRate = @"";
					}
						break;
				}
			}
            NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
            UIImageView * accessoryViewTemp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
            accessoryViewTemp.frame = CGRectMake(0, 0, 10, 16);
            cell.accessoryView = accessoryViewTemp;
            [accessoryViewTemp release];
            break;
		}
    }
    
    if ([self.hotelSearchTableView numberOfRowsInSection:indexPath.section] == 1) 
    {
        NSString *tableViewCellSingleNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_single_normal" inDirectory:@"CommonView/TableViewCell"];
        NSString *tableViewCellSingleHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_single_highlighted" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellSingleNormalPath]] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellSingleHighlightedPath]] autorelease];
    } 
    else 
    {
        if (indexPath.row == 0) 
        {
            NSString *tableViewCellTopNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_top_normal" inDirectory:@"CommonView/TableViewCell"];
            NSString *tableViewCellTopHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_top_highlighted" inDirectory:@"CommonView/TableViewCell"];
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellTopNormalPath]] autorelease];
            cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellTopHighlightedPath]] autorelease];
        } else if(indexPath.row == [self.hotelSearchTableView numberOfRowsInSection:indexPath.section]-1){
            NSString *tableViewCellBottomNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_normal" inDirectory:@"CommonView/TableViewCell"];
            NSString *tableViewCellBottomHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_highlighted" inDirectory:@"CommonView/TableViewCell"];
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomNormalPath]] autorelease];
            cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomHighlightedPath]] autorelease];
        } else {
            NSString *tableViewCellCenterNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_normal" inDirectory:@"CommonView/TableViewCell"];
            NSString *tableViewCellCenterHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_highlighted" inDirectory:@"CommonView/TableViewCell"];
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterNormalPath]] autorelease];
            cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterHighlightedPath]] autorelease];
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    switch (indexPath.section) {
		case 0:
        {
            if (indexPath.row == 0) {
                [self.hotelNameField resignFirstResponder];
                
                HotelCityChoiceController *hotelCityChoiceController = [[HotelCityChoiceController alloc] initWithStyle:UITableViewStylePlain];
                hotelCityChoiceController.hotelSearchController = self;
                [self.navigationController pushViewController:hotelCityChoiceController animated:YES];
                [hotelCityChoiceController release];
            }
		}
			break;
		case 1:
        {
			[self.hotelNameField resignFirstResponder];
			
			NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
			formatter.dateFormat = @"yyyy-MM-dd";
			switch (indexPath.row) {
				case 0:{
					[self.datePicker setDate:[formatter dateFromString:self.checkInDataLabel.text]];//设置日期滚轮的当前显示
					self.datePicker.minimumDate = [NSDate date];//最小选择日期，当日
					self.isCheckInDateSelect = YES;//标记当前是在选择入住日期
				}
					break;
				case 1:{
					[self.datePicker setDate:[formatter dateFromString:self.checkOutDataLabel.text]];//设置日期滚轮的当前显示
					self.datePicker.minimumDate = [[formatter dateFromString:self.checkInDataLabel.text] dateByAddingTimeInterval:86400];//最小选择日期，入住日期的后一天
					self.isCheckInDateSelect = NO;//标记当前是在选择离店日期
				}
					break;
			}
            self.dateBar.hidden = NO;
            self.datePicker.hidden = NO;
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationDelegate:self];
			self.dateBar.frame = CGRectMake(0, 180, 320, 40);
			self.datePicker.frame = CGRectMake(0, 210, 320, 216);
			[UIView commitAnimations];
			[self.hotelSearchTableView setScrollEnabled:NO];
		}
			break;
		case 2:
			switch (indexPath.row) {
				case 0:{
					HotelStarChoiceController *hotelStarChoiceController = [[HotelStarChoiceController alloc] initWithStyle:UITableViewStyleGrouped];
					hotelStarChoiceController.hotelSearchController = self;
					[self.navigationController pushViewController:hotelStarChoiceController animated:YES];
					[hotelStarChoiceController release];
				}
					break;
				case 1:{
					HotelPriceChoiceController *hotelPriceChoiceController = [[HotelPriceChoiceController alloc] initWithStyle:UITableViewStyleGrouped];
					hotelPriceChoiceController.hotelSearchController = self;
					[self.navigationController pushViewController:hotelPriceChoiceController animated:YES];
					[hotelPriceChoiceController release];
				}
					break;
			}
			break;
	}
	
	[self.hotelSearchTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark ActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([actionSheet cancelButtonIndex] != buttonIndex) {
        //拨打客服电话
        [[UIApplication  sharedApplication] openURL:[NSURL  URLWithString:@"tel://4006840060"]];
    }
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


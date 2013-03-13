//
//  HotelSingleController.m
//  JingDuTianXia
//
//  Created by Piosa on 11-11-1.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "HotelSingleController.h"
#import "HotelListInfo.h"
#import "HotelSingleSearchResponse.h"
#import "UIHTTPImageView.h"
#import "HotelRoomInfo.h"
#import "HotelBookController.h"

#import "CommonTools.h"
#import "PiosaFileManager.h"

#define kRoomInfoLeftSegmentControlButtonTag 101
#define kHotelInfoRightSegmentControlButtonTag 102

#define ROOM_TABLEVIEW_TAG 1
#define INFO_TABLEVIEW_TAG 2

#define ROOM_TYPE_NAME_LABEL_TAG 11
#define ROOM_DISPLAY_PRICE_LABEL_TAG 12
#define ROOM_AMOUNT_PRICE_LABEL_TAG 13
#define ROOM_BOOK_BUTTON_TAG 14

@implementation HotelSingleController

@synthesize checkInDate = _checkInDate;
@synthesize checkOutDate = _checkOutDate;
@synthesize hotelSingleSearchResponse = _hotelSingleSearchResponse;
@synthesize hotelNameLabel = _hotelNameLabel;
@synthesize hotelStarView = _hotelStarView;
@synthesize httpImageView = _httpImageView;
@synthesize hotelAddressLabel = _hotelAddressLabel;
@synthesize hotelPORLabel = _hotelPORLabel;
@synthesize hotelDistrictLabel = _hotelDistrictLabel;
@synthesize hotelRoomCountLabel = _hotelRoomCountLabel;
@synthesize roomInfoLeftSegmentControlButton = _roomInfoLeftSegmentControlButton;
@synthesize hotelInfoRightSegmentControlButton = _hotelInfoRightSegmentControlButton;
@synthesize roomTableFixedCellLabel = _roomTableFixedCellLabel;
@synthesize roomTableView = _roomTableView;
@synthesize infoTableFixedCellLabel = _infoTableFixedCellLabel;
@synthesize infoTableView = _infoTableView;
@synthesize expandedCellIndexPath = _expandedCellIndexPath;
@synthesize selectingCellIndexPath = _selectingCellIndexPath;

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

//信息标签按钮按下后的触发函数
- (void)infoSegmentControlAction:(UIButton *)segmentControlButton
{
    switch (segmentControlButton.tag) {
        case kRoomInfoLeftSegmentControlButtonTag:{
            //设置房型信息按钮为选中
            [self.roomInfoLeftSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.roomInfoLeftSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            NSString *sortLeftSegmentControlButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"sortLeftSegmentControlButton_selected" inDirectory:@"CommonView/SortSegmentedControl"];
            [self.roomInfoLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:sortLeftSegmentControlButtonSelectedPath] forState:UIControlStateNormal];
            [self.roomInfoLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:sortLeftSegmentControlButtonSelectedPath] forState:UIControlStateHighlighted];
            //设置酒店信息按钮为非选中
            [self.hotelInfoRightSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateNormal];
            [self.hotelInfoRightSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateHighlighted];
            NSString *sortRightSegmentControlButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"sortRightSegmentControlButton_normal" inDirectory:@"CommonView/SortSegmentedControl"];
            [self.hotelInfoRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:sortRightSegmentControlButtonNormalPath] forState:UIControlStateNormal];
            [self.hotelInfoRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:sortRightSegmentControlButtonNormalPath] forState:UIControlStateHighlighted];
            
            [self.roomTableView setHidden:NO];
            [self.roomTableFixedCellLabel setHidden:NO];
            [self.infoTableView setHidden:YES];
            [self.infoTableFixedCellLabel setHidden:YES];
        }
            break;
        case kHotelInfoRightSegmentControlButtonTag:{
            //设置房型信息按钮为非选中
            [self.roomInfoLeftSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateNormal];
            [self.roomInfoLeftSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateHighlighted];
            NSString *sortLeftSegmentControlButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"sortLeftSegmentControlButton_normal" inDirectory:@"CommonView/SortSegmentedControl"];
            [self.roomInfoLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:sortLeftSegmentControlButtonNormalPath] forState:UIControlStateNormal];
            [self.roomInfoLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:sortLeftSegmentControlButtonNormalPath] forState:UIControlStateHighlighted];
            //设置酒店信息按钮为选中
            [self.hotelInfoRightSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.hotelInfoRightSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            NSString *sortRightSegmentControlButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"sortRightSegmentControlButton_selected" inDirectory:@"CommonView/SortSegmentedControl"];
            [self.hotelInfoRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:sortRightSegmentControlButtonSelectedPath] forState:UIControlStateNormal];
            [self.hotelInfoRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:sortRightSegmentControlButtonSelectedPath] forState:UIControlStateHighlighted];
            
            [self.roomTableView setHidden:YES];
            [self.roomTableFixedCellLabel setHidden:YES];
            [self.infoTableView setHidden:NO];
            [self.infoTableFixedCellLabel setHidden:NO];
        }
            break;
    }
}

- (void)bookButtonPress:(id)sender
{
	UIButton * tempBookButton = (UIButton *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[tempBookButton superview] superview];
	NSIndexPath * indexPath = [self.roomTableView indexPathForCell:cell];
	HotelRoomInfo *roomInfo = [self.hotelSingleSearchResponse.hotelRoomArray objectAtIndex:indexPath.row];
	
	HotelBookController *hotelBookController = [[HotelBookController alloc] init];
	hotelBookController.cityCode = self.hotelSingleSearchResponse.cityCode;		//酒店所在城市代码
	hotelBookController.hotelName = self.hotelSingleSearchResponse.hotelName;	//酒店名称
	hotelBookController.hotelCode = self.hotelSingleSearchResponse.hotelCode;	//酒店代码
	hotelBookController.roomName = roomInfo.roomTypeName;						//房型名称
	hotelBookController.roomCode = roomInfo.roomTypeCode;						//房型代码
	hotelBookController.inDate = self.checkInDate;								//入住日期
	hotelBookController.outDate = self.checkOutDate;							//退房日期
	hotelBookController.paymentType = roomInfo.roomPayment;						//支付方式
	hotelBookController.ratePlanCode = roomInfo.roomRatePlanCode;				//价格计划代码
	hotelBookController.vendorCode = roomInfo.roomVendorCode;					//供应商代码
	hotelBookController.totalAmount = roomInfo.roomAmountPrice;					//房型单间单天价格
	[self.navigationController pushViewController:hotelBookController animated:YES];
	[hotelBookController release];
}

#pragma mark -
#pragma mark View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	//设置导航栏标题
	self.title = @"酒店信息";
	
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
	[self.view addSubview:tempTitleShowView];
    [tempTitleShowView release];
	
	//设置酒店名称的位置
	UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 220, 30)];
	tempLabel.font = [UIFont boldSystemFontOfSize:15];
    tempLabel.textColor = [UIColor whiteColor];
	tempLabel.backgroundColor = [UIColor clearColor];
	self.hotelNameLabel = tempLabel;
	[self.view addSubview:self.hotelNameLabel];
	[tempLabel release];
	
	//设置酒店星级图标的位置
	UIImageView *tempView = [[UIImageView alloc] initWithFrame:CGRectMake(250, 10, 70, 12)];
	self.hotelStarView = tempView;
	[self.view addSubview:self.hotelStarView];
	[tempView release];
    
    //酒店概况信息的背景视图
    UIView * hotelMessageBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 24, 320, 85)];
    hotelMessageBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:hotelMessageBackgroundView];
    [hotelMessageBackgroundView release];
	
	//设置酒店图片的位置
	UIHTTPImageView *tempHttpImageView = [[UIHTTPImageView alloc] initWithFrame:CGRectMake(3, 32, 80, 73)];
	self.httpImageView = tempHttpImageView;
	[self.view addSubview:self.httpImageView];
	[tempHttpImageView release];
	
	//设置酒店地址的位置
	UILabel *labelAdd = [[UILabel alloc] initWithFrame:CGRectMake(85, 35, 35, 16)];
	labelAdd.font = [UIFont boldSystemFontOfSize:12];
	labelAdd.text = @"地 址:";
	//labelAdd.textColor = [UIColor blueColor];
	labelAdd.backgroundColor = [UIColor clearColor];
	[self.view addSubview:labelAdd];
	[labelAdd release];
	
	UILabel *addLable = [[UILabel alloc] initWithFrame:CGRectMake(120, 28, 195, 30)];
	addLable.lineBreakMode = UILineBreakModeWordWrap;
	addLable.numberOfLines = 0;
    addLable.textColor = [UIColor grayColor];
	addLable.font = [UIFont boldSystemFontOfSize:12];
	addLable.backgroundColor = [UIColor clearColor];
	self.hotelAddressLabel = addLable;
	[self.view addSubview:self.hotelAddressLabel];
	[addLable release];
	
	//设置酒店地标的位置
	UILabel *labelPOR = [[UILabel alloc] initWithFrame:CGRectMake(85, 58, 35, 16)];
	labelPOR.font = [UIFont boldSystemFontOfSize:12];
	labelPOR.text = @"地 标:";
	//labelPOR.textColor = [UIColor blueColor];
	labelPOR.backgroundColor = [UIColor clearColor];
	[self.view addSubview:labelPOR];
	[labelPOR release];
	
	UILabel *porLable = [[UILabel alloc] initWithFrame:CGRectMake(120, 58, 195, 16)];
    porLable.textColor = [UIColor grayColor];
	porLable.font = [UIFont boldSystemFontOfSize:12];
	porLable.backgroundColor = [UIColor clearColor];
	self.hotelPORLabel = porLable;
	[self.view addSubview:self.hotelPORLabel];
	[porLable release];
	
	//设置酒店区域的位置
	UILabel *labelDistrict = [[UILabel alloc] initWithFrame:CGRectMake(85, 75, 35, 16)];
	labelDistrict.font = [UIFont boldSystemFontOfSize:12];
	labelDistrict.text = @"区 域:";
	//labelDistrict.textColor = [UIColor blueColor];
	labelDistrict.backgroundColor = [UIColor clearColor];
	[self.view addSubview:labelDistrict];
	[labelDistrict release];
	
	UILabel *districtLable = [[UILabel alloc] initWithFrame:CGRectMake(120, 75, 195, 16)];
    districtLable.textColor = [UIColor grayColor];
	districtLable.font = [UIFont boldSystemFontOfSize:12];
	districtLable.backgroundColor = [UIColor clearColor];
	self.hotelDistrictLabel = districtLable;
	[self.view addSubview:self.hotelDistrictLabel];
	[districtLable release];
	
	//设置酒店房间数量的位置
	UILabel *labelRoomCount = [[UILabel alloc] initWithFrame:CGRectMake(85, 92, 55, 16)];
	labelRoomCount.font = [UIFont boldSystemFontOfSize:12];
	labelRoomCount.text = @"房间数量:";
	//labelRoomCount.textColor = [UIColor blueColor];
	labelRoomCount.backgroundColor = [UIColor clearColor];
	[self.view addSubview:labelRoomCount];
	[labelRoomCount release];
	
	UILabel *roomCountLable = [[UILabel alloc] initWithFrame:CGRectMake(140, 92, 175, 16)];
    roomCountLable.textColor = [UIColor grayColor];
	roomCountLable.font = [UIFont boldSystemFontOfSize:12];
	roomCountLable.backgroundColor = [UIColor clearColor];
	self.hotelRoomCountLabel = roomCountLable;
	[self.view addSubview:self.hotelRoomCountLabel];
	[roomCountLable release];
	
	//设置标签背景视图
	UIView * tempSeparatedView = [[UIView alloc] initWithFrame:CGRectMake(0, 110, 320, 306)];
	tempSeparatedView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:tempSeparatedView];
	[tempSeparatedView release];
    
    //房型信息左按钮
    UIButton * tempLeftSegmentedButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 115, 75, 23)];
    tempLeftSegmentedButton.tag = kRoomInfoLeftSegmentControlButtonTag;
    [tempLeftSegmentedButton setTitle:@"房型" forState:UIControlStateNormal];
    [tempLeftSegmentedButton setTitle:@"房型" forState:UIControlStateSelected];
    tempLeftSegmentedButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [tempLeftSegmentedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tempLeftSegmentedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    NSString *sortLeftSegmentControlButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"sortLeftSegmentControlButton_selected" inDirectory:@"CommonView/SortSegmentedControl"];
    [tempLeftSegmentedButton setBackgroundImage:[UIImage imageNamed:sortLeftSegmentControlButtonSelectedPath] forState:UIControlStateNormal];
    [tempLeftSegmentedButton setBackgroundImage:[UIImage imageNamed:sortLeftSegmentControlButtonSelectedPath] forState:UIControlStateHighlighted];
    [tempLeftSegmentedButton addTarget:self action:@selector(infoSegmentControlAction:) forControlEvents:UIControlEventTouchDown];
    self.roomInfoLeftSegmentControlButton = tempLeftSegmentedButton;
    [self.view addSubview:self.roomInfoLeftSegmentControlButton];
    [tempLeftSegmentedButton release];
    
    //酒店信息右按钮
    UIButton * tempRightSegmentedButton = [[UIButton alloc] initWithFrame:CGRectMake(80, 115, 75, 23)];
    tempRightSegmentedButton.tag =kHotelInfoRightSegmentControlButtonTag;
    [tempRightSegmentedButton setTitle:@"酒店信息" forState:UIControlStateNormal];
    [tempRightSegmentedButton setTitle:@"酒店信息" forState:UIControlStateSelected];
    tempRightSegmentedButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [tempRightSegmentedButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateNormal];
    [tempRightSegmentedButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateHighlighted];
    NSString *sortRightSegmentControlButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"sortRightSegmentControlButton_normal" inDirectory:@"CommonView/SortSegmentedControl"];
    [tempRightSegmentedButton setBackgroundImage:[UIImage imageNamed:sortRightSegmentControlButtonNormalPath] forState:UIControlStateNormal];
    [tempRightSegmentedButton setBackgroundImage:[UIImage imageNamed:sortRightSegmentControlButtonNormalPath] forState:UIControlStateHighlighted];
    [tempRightSegmentedButton addTarget:self action:@selector(infoSegmentControlAction:) forControlEvents:UIControlEventTouchDown];
    self.hotelInfoRightSegmentControlButton = tempRightSegmentedButton;
    [self.view addSubview:self.hotelInfoRightSegmentControlButton];
    [tempRightSegmentedButton release];
	
	//房型列表的标签列
	UILabel *tempRoomTableLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, 320, 30)];
	tempRoomTableLabel.font = [UIFont boldSystemFontOfSize:15];
	tempRoomTableLabel.text = @"\t\t房型\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t门市价\t\t\t\t\t\t\t\t\t\t\t\t首日价";
	tempRoomTableLabel.textColor = [UIColor whiteColor];
	tempRoomTableLabel.backgroundColor = [PiosaColorManager secondTitleColor];
	self.roomTableFixedCellLabel = tempRoomTableLabel;
	[self.view addSubview:self.roomTableFixedCellLabel];
	[self.roomTableFixedCellLabel setHidden:NO];
	[tempRoomTableLabel release];
	
	//房间列表
	UITableView * tempRoomTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 170, 320, 246) style:UITableViewStylePlain];
	tempRoomTableView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
	tempRoomTableView.delegate = self;
	tempRoomTableView.dataSource = self;
	self.roomTableView = tempRoomTableView;
	self.roomTableView.tag = ROOM_TABLEVIEW_TAG;
	[self.view addSubview:self.roomTableView];
	[self.roomTableView setHidden:NO];
	[tempRoomTableView release];
	
	//信息列表的标签列
	UILabel *tempInfoTableLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, 320, 10)];
	tempInfoTableLabel.backgroundColor = [PiosaColorManager secondTitleColor];
	self.infoTableFixedCellLabel = tempInfoTableLabel;
	[self.view addSubview:self.infoTableFixedCellLabel];
	[self.infoTableFixedCellLabel setHidden:YES];
	[tempInfoTableLabel release];
	
	//酒店信息列表
	UITableView * tempInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 150, 320, 266) style:UITableViewStyleGrouped];
	tempInfoTableView.backgroundColor = [PiosaColorManager secondTitleColor];
    tempInfoTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tempInfoTableView.delegate = self;
	tempInfoTableView.dataSource = self;
	self.infoTableView = tempInfoTableView;
	self.infoTableView.tag = INFO_TABLEVIEW_TAG;
	[self.view addSubview:self.infoTableView];
	[self.infoTableView setHidden:YES];
	[tempInfoTableView release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//设置酒店名称的内容
	self.hotelNameLabel.text = self.hotelSingleSearchResponse.hotelName;
	
	//设置酒店星级的图案
	NSString *starImageName = nil;
	if ([@"5S" isEqualToString:self.hotelSingleSearchResponse.hotelRank]) {
		starImageName = @"star5";
	} else if ([@"5A" isEqualToString:self.hotelSingleSearchResponse.hotelRank]) {
		starImageName = @"star4_1";
	} else if ([@"4S" isEqualToString:self.hotelSingleSearchResponse.hotelRank]) {
		starImageName = @"star4";
	} else if ([@"4A" isEqualToString:self.hotelSingleSearchResponse.hotelRank]) {
		starImageName = @"star3_1";
	} else if ([@"3S" isEqualToString:self.hotelSingleSearchResponse.hotelRank]) {
		starImageName = @"star3";
	} else if ([@"3A" isEqualToString:self.hotelSingleSearchResponse.hotelRank]) {
		starImageName = @"star2_1";
	} else if ([@"2S" isEqualToString:self.hotelSingleSearchResponse.hotelRank]) {
		starImageName = @"star2";
	} else if ([@"2A" isEqualToString:self.hotelSingleSearchResponse.hotelRank]) {
		starImageName = @"star1_1";
	} else if ([@"1S" isEqualToString:self.hotelSingleSearchResponse.hotelRank]) {
		starImageName = @"star1";
	} else if ([@"1A" isEqualToString:self.hotelSingleSearchResponse.hotelRank]) {
		starImageName = @"star0_1";
	}
    NSString *starImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:starImageName inDirectory:@"Hotel/star"];
	self.hotelStarView.image = [UIImage imageNamed:starImagePath];
	
	//设置酒店图片的内容
    NSString *imageLoadingPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"image_loading" inDirectory:@"Hotel"];
	[self.httpImageView setImageWithURL:[NSURL URLWithString:self.hotelSingleSearchResponse.hotelImage] placeholderImage:[UIImage imageNamed:imageLoadingPath]];
	
	//设置酒店总体概述
	self.hotelAddressLabel.text = self.hotelSingleSearchResponse.hotelAddress;
	self.hotelPORLabel.text = self.hotelSingleSearchResponse.hotelPOR;
	self.hotelDistrictLabel.text = self.hotelSingleSearchResponse.hotelDistrict;
	self.hotelRoomCountLabel.text = self.hotelSingleSearchResponse.hotelRoomCount;
	
	//设置房间列表视图的数据源和委托
	self.roomTableView.dataSource = self;
	self.roomTableView.delegate = self;
}
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	switch (tableView.tag) {
		case ROOM_TABLEVIEW_TAG:
			return 1;
			break;
		case INFO_TABLEVIEW_TAG:
			return 5;
			break;
		default:
			return 0;
			break;
	}
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (tableView.tag) {
		case ROOM_TABLEVIEW_TAG:
			return [self.hotelSingleSearchResponse.hotelRoomArray count];
			break;
		case INFO_TABLEVIEW_TAG:
			return 1;
			break;
		default:
			return 0;
			break;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell"];
	
	switch (tableView.tag) {
		case ROOM_TABLEVIEW_TAG:{
			UITableViewCell *roomCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			UILabel *roomTypeNameLabelTemp;
			UILabel *roomDisplayPriceLabelTemp;
			UILabel *roomAmountPriceLabelTemp;
			UIButton *bookButtonTemp;
			if (roomCell == nil) {
				roomCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
				
				UILabel *roomTypeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 5, 120, 30)];
				roomTypeNameLabel.backgroundColor = [UIColor clearColor];
				roomTypeNameLabel.tag = ROOM_TYPE_NAME_LABEL_TAG;//添加此Label的标签值
				[roomCell.contentView addSubview:roomTypeNameLabel];
				roomTypeNameLabelTemp = roomTypeNameLabel;
				[roomTypeNameLabel release];
				
				UILabel *roomDisplayPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(122, 5, 70, 30)];
				roomDisplayPriceLabel.backgroundColor = [UIColor clearColor];
				roomDisplayPriceLabel.textColor = [UIColor grayColor];
				roomDisplayPriceLabel.tag = ROOM_DISPLAY_PRICE_LABEL_TAG;//添加此Label的标签值
				[roomCell.contentView addSubview:roomDisplayPriceLabel];
				roomDisplayPriceLabelTemp = roomDisplayPriceLabel;
				[roomDisplayPriceLabel release];
				
				UILabel *roomAmountPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(196, 5, 70, 30)];
				roomAmountPriceLabel.backgroundColor = [UIColor clearColor];
				roomAmountPriceLabel.textAlignment = UITextAlignmentRight;
				roomAmountPriceLabel.textColor = [UIColor redColor];
				roomAmountPriceLabel.tag = ROOM_AMOUNT_PRICE_LABEL_TAG;//添加此Label的标签值
				[roomCell.contentView addSubview:roomAmountPriceLabel];
				roomAmountPriceLabelTemp = roomAmountPriceLabel;
				[roomAmountPriceLabel release];
				
				UIButton *bookButton = [[UIButton alloc] initWithFrame:CGRectMake(270, 9, 45, 25)];
				[bookButton setTitle:@"订购" forState:UIControlStateNormal];
                bookButton.titleLabel.font = [UIFont systemFontOfSize:14];
                [bookButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [bookButton setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
                NSString *smallButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"smallButton_normal" inDirectory:@"CommonView/MethodButton"];
                NSString *smallButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"smallButton_highlighted" inDirectory:@"CommonView/MethodButton"];
				[bookButton setBackgroundImage:[UIImage imageNamed:smallButtonNormalPath] forState:UIControlStateNormal];
				[bookButton setBackgroundImage:[UIImage imageNamed:smallButtonHighlightedPath] forState:UIControlStateHighlighted];
				[bookButton addTarget:self action:@selector(bookButtonPress:) forControlEvents:UIControlEventTouchUpInside];
				bookButton.tag = ROOM_BOOK_BUTTON_TAG;//添加此button的标签值
				[roomCell.contentView addSubview:bookButton];
				bookButtonTemp = bookButton;
				[bookButton release];
			} else {
				roomTypeNameLabelTemp = (UILabel *)[roomCell.contentView viewWithTag:ROOM_TYPE_NAME_LABEL_TAG];
				roomDisplayPriceLabelTemp = (UILabel *)[roomCell.contentView viewWithTag:ROOM_DISPLAY_PRICE_LABEL_TAG];
				roomAmountPriceLabelTemp = (UILabel *)[roomCell.contentView viewWithTag:ROOM_AMOUNT_PRICE_LABEL_TAG];
				bookButtonTemp = (UIButton *)[roomCell.contentView viewWithTag:ROOM_BOOK_BUTTON_TAG];
			}
			
			HotelRoomInfo * roomInfo = [self.hotelSingleSearchResponse.hotelRoomArray objectAtIndex:indexPath.row];
			
			//设置房型名称
			roomTypeNameLabelTemp.text = roomInfo.roomTypeName;
			
			//设置房型门市价格
			NSMutableString *changeDisplayPrice = [[NSMutableString alloc] initWithFormat:@"¥"];
			[changeDisplayPrice appendString:roomInfo.roomDisplayPrice];
			roomDisplayPriceLabelTemp.text = changeDisplayPrice;
			[changeDisplayPrice release];
			if ([@"¥0.0" isEqualToString:roomDisplayPriceLabelTemp.text]) {
				roomDisplayPriceLabelTemp.text = @"暂无定价";
			}
			//设置房型今天价格
			NSMutableString *changeAmountPrice = [[NSMutableString alloc] initWithFormat:@"¥"];
			[changeAmountPrice appendString:roomInfo.roomAmountPrice];
			roomAmountPriceLabelTemp.text = changeAmountPrice;
			[changeAmountPrice release];
			
			bookButtonTemp.tag = indexPath.row;
			
			//拖动时取到的cell都进行删除可能存在的展开视图
			for (UIView *v in [roomCell.contentView subviews]) {
				if (v.tag == 101) {
					[v removeFromSuperview];
				}
			}
			
			if (self.selectingCellIndexPath == nil) {
				//不适用于展开表格动作
				
				//如果此行已经展开，则必须进行展开视图的添加工作
				if (self.expandedCellIndexPath!=nil && [self.expandedCellIndexPath compare:indexPath] == NSOrderedSame) {
					UIView *uiView = [[UIView alloc] init];
					uiView.frame = CGRectMake(0, 40, 320, 60);
					uiView.tag = 101;
					uiView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
                    
                    NSString *dottedLinePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"dottedLine" inDirectory:@"CommonView"];
                    UIImageView * dottedLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
                    dottedLineView.frame = CGRectMake(0, 0, 320, 2);
                    [uiView addSubview:dottedLineView];
                    [dottedLineView release];
					
					HotelRoomInfo * roomInfo = [self.hotelSingleSearchResponse.hotelRoomArray objectAtIndex:indexPath.row];
					
					UILabel *uiLabelPayment = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 12)];
					uiLabelPayment.font = [UIFont systemFontOfSize:12];
					uiLabelPayment.backgroundColor = [UIColor clearColor];
					if ([@"T" isEqualToString:roomInfo.roomPayment]) {
						uiLabelPayment.text = @"支付方式:前台现付";
					} else if ([@"S" isEqualToString:roomInfo.roomPayment]) {
						uiLabelPayment.text = @"支付方式:代收现付";
					} else if ([@"Y" isEqualToString:roomInfo.roomPayment]) {
						uiLabelPayment.text = @"预付";
					}
					[uiView addSubview:uiLabelPayment];
					[uiLabelPayment release];
					
					UILabel *uiLabelDes = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 40)];
					uiLabelDes.font = [UIFont systemFontOfSize:11];
					uiLabelDes.backgroundColor = [UIColor clearColor];
					uiLabelDes.lineBreakMode = UILineBreakModeWordWrap;
					uiLabelDes.numberOfLines = 0;
					uiLabelDes.text = roomInfo.roomDescription;
					[uiView addSubview:uiLabelDes];
					[uiLabelDes release];
					
					[roomCell.contentView addSubview:uiView];
					[uiView release];
				}
			} else {
				//适用于展开表格动作
				if((self.expandedCellIndexPath == nil || [self.selectingCellIndexPath compare:self.expandedCellIndexPath] != NSOrderedSame ) && [self.selectingCellIndexPath compare:indexPath] == NSOrderedSame ) { 
					//没有展开的表格单元或者所选择的表格不是所展开的表格单元；
					// 状态：表格展开
					// 开始对新表格单元进行展开视图的添加工作，以及对旧表格单元进行展开视图的删除工作
					
					UIView *uiView = [[UIView alloc] init];
					uiView.frame = CGRectMake(0, 40, 320, 60);
					uiView.tag = 101;
					uiView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
                    
                    NSString *dottedLinePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"dottedLine" inDirectory:@"CommonView"];
                    UIImageView * dottedLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dottedLinePath]];
                    dottedLineView.frame = CGRectMake(0, 0, 320, 2);
                    [uiView addSubview:dottedLineView];
                    [dottedLineView release];
					
					HotelRoomInfo * roomInfo = [self.hotelSingleSearchResponse.hotelRoomArray objectAtIndex:indexPath.row];
					
					UILabel *uiLabelPayment = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 12)];
					uiLabelPayment.font = [UIFont systemFontOfSize:12];
					uiLabelPayment.backgroundColor = [UIColor clearColor];
					if ([@"T" isEqualToString:roomInfo.roomPayment]) {
						uiLabelPayment.text = @"支付方式:前台现付";
					} else if ([@"S" isEqualToString:roomInfo.roomPayment]) {
						uiLabelPayment.text = @"支付方式:代收现付";
					} else if ([@"Y" isEqualToString:roomInfo.roomPayment]) {
						uiLabelPayment.text = @"预付";
					}
					[uiView addSubview:uiLabelPayment];
					[uiLabelPayment release];
					
					UILabel *uiLabelDes = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 40)];
					uiLabelDes.font = [UIFont systemFontOfSize:11];
					uiLabelDes.backgroundColor = [UIColor clearColor];
					uiLabelDes.lineBreakMode = UILineBreakModeWordWrap;
					uiLabelDes.numberOfLines = 0;
					uiLabelDes.text = roomInfo.roomDescription;
					[uiView addSubview:uiLabelDes];
					[uiLabelDes release];
					
					[roomCell.contentView addSubview:uiView];
					[uiView release];
				}
				
				//不管点击后这个行是展开或关闭，都要进行删除原有旧cell中的扩展视图
				for (UIView *v in [[self.roomTableView cellForRowAtIndexPath:self.expandedCellIndexPath].contentView subviews]) {
					if (v.tag == 101) {
						[v removeFromSuperview];
					}
				}
			}
			
			roomCell.selectionStyle = UITableViewCellSelectionStyleNone;
			return roomCell;
		}
			break;
		case INFO_TABLEVIEW_TAG:{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
			cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
			cell.textLabel.numberOfLines = 0;
			switch (indexPath.section) {
				case 0:
					cell.textLabel.text = self.hotelSingleSearchResponse.hotelLongDesc;
					break;
				case 1:
					cell.textLabel.text = self.hotelSingleSearchResponse.hotelTraffic;
					break;
				case 2:
					cell.textLabel.text = self.hotelSingleSearchResponse.hotelSER;
					break;
				case 3:
					cell.textLabel.text = self.hotelSingleSearchResponse.hotelVicinity;
					break;
				case 4:
					cell.textLabel.text = self.hotelSingleSearchResponse.hotelTel;
					break;
			}
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		}
			break;
		default:
			return nil;
			break;
	}
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if (tableView.tag == ROOM_TABLEVIEW_TAG) {
		return 0;
	} else {
		return 20;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView.tag == ROOM_TABLEVIEW_TAG) {
        return nil;
    } else {
        
        UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 290, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        switch (section) {
            case 0:
                titleLabel.text =  @"酒店简介";
                break;
            case 1:
                titleLabel.text =  @"交通信息";
                break;
            case 2:
                titleLabel.text =  @"酒店服务";
                break;
            case 3:
                titleLabel.text =  @"周围服务";
                break;
            case 4:
                titleLabel.text =  @"酒店电话";
                break;
        }
        [footer addSubview:titleLabel];
        [titleLabel release];
        footer.backgroundColor = [UIColor clearColor];
        return footer;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	if (tableView.tag == ROOM_TABLEVIEW_TAG) {
        return 1;
    } else {
        return 5;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	if (tableView.tag == ROOM_TABLEVIEW_TAG) {
		if ([self.hotelSingleSearchResponse.hotelRoomArray count]<=6) {
			//如果显示的房型不超出显示框，则通过添加footer来去除多出来的空cell
			UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)] autorelease];
			footer.backgroundColor = [UIColor clearColor];
			return footer;
		} else {
			return nil;
		}
	} else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (tableView.tag) {
		case ROOM_TABLEVIEW_TAG:
			if (self.selectingCellIndexPath == nil) {
				return 40;
			} else {
				if((self.expandedCellIndexPath == nil || [self.selectingCellIndexPath compare:self.expandedCellIndexPath] != NSOrderedSame ) && [self.selectingCellIndexPath compare:indexPath] == NSOrderedSame ) {
					//没有展开的表格单元或者所选择的表格不是所展开的表格单元；
					return 100;
				} else 
					return 40;
			}
			break;
		case INFO_TABLEVIEW_TAG:
		{
			CGFloat tempFloat = 0;
			switch (indexPath.section) {
				case 0:{
					int len = [CommonTools calc_charsetNum:self.hotelSingleSearchResponse.hotelLongDesc];
					int num = len/48;
					int yu = len%48;
					if (yu != 0) {
						num += 1;
					}
					tempFloat = 20*num+10;
				}
					break;
				case 1:{
					int len = [CommonTools calc_charsetNum:self.hotelSingleSearchResponse.hotelTraffic];
					int num = len/48;
					int yu = len%48;
					if (yu != 0) {
						num += 1;
					}
					tempFloat = 20*num+10;
				}
					break;
				case 2:{
					int len = [CommonTools calc_charsetNum:self.hotelSingleSearchResponse.hotelSER];
					int num = len/48;
					int yu = len%48;
					if (yu != 0) {
						num += 1;
					}
					tempFloat = 20*num+10;
				}
					break;
				case 3:{
					int len = [CommonTools calc_charsetNum:self.hotelSingleSearchResponse.hotelVicinity];
					int num = len/48;
					int yu = len%48;
					if (yu != 0) {
						num += 1;
					}
					tempFloat = 20*num+10;
				}
					break;
				case 4:
					tempFloat = 20+10;
					break;
			}
			return tempFloat;
		}
			break;
		default:
			return 0;
			break;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//设置点击中的行标识
	self.selectingCellIndexPath = indexPath;
	
	//删除所点击行中cell的展开视图
	for (UIView *v in [[self.roomTableView cellForRowAtIndexPath:indexPath].contentView subviews]) {
		if (v.tag == 101) {
			[v removeFromSuperview];
		}
	}
	
	//进行所点击行的更新
	[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone]; 
	
	//设置所展开的行标识
	if (self.expandedCellIndexPath!=nil && [self.selectingCellIndexPath compare:self.expandedCellIndexPath] == NSOrderedSame) {
		self.expandedCellIndexPath = nil;
	} else {
		self.expandedCellIndexPath = indexPath;
	}
	
	//点击动作结束，设置点击中的行标识为空
	self.selectingCellIndexPath = nil;
	
	//自动滚动所展开或关闭的cell，用以美观显示
	[tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[_checkInDate  release];
	[_checkOutDate  release];
	[_hotelSingleSearchResponse release];
	[_hotelNameLabel release];
	[_hotelStarView release];
	[_httpImageView release];
	[_hotelAddressLabel release];
	[_hotelPORLabel release];
	[_hotelDistrictLabel release];
	[_hotelRoomCountLabel release];
    [_roomInfoLeftSegmentControlButton release];
    [_hotelInfoRightSegmentControlButton release];
	[_roomTableFixedCellLabel release];
	[_roomTableView release];
	[_infoTableFixedCellLabel release];
	[_infoTableView release];
	[_expandedCellIndexPath release];
	[_selectingCellIndexPath release];
    [super dealloc];
}

@end

//
//  FlightSearchViewController.m
//  UCAI
//
//  Created by  on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FlightSearchViewController.h"
#import "FlightBookingCityChoiceTableViewController.h"
#import "FlightCompanyChoiceTableViewController.h"
#import "FlightListSearchResponseModel.h"

#import "FlightListViewController.h"

#import "UIView-ModalAnimationHelper.h"

#import "ResponseParser.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "StaticConf.h"
#import "CommonTools.h"
#import "PiosaFileManager.h"

#define kSingleLeftSegmentControlButtonTag 101
#define kDoubleRightSegmentControlButtonTag 102

@implementation FlightSearchViewController

@synthesize bigLeftSegmentControlButton = _bigLeftSegmentControlButton;
@synthesize bigRightSegmentControlButton = _bigRightSegmentControlButton;
@synthesize startedCityShowlabel = _startedCityShowlabel;
@synthesize arrivedCityShowlabel = _arrivedCityShowlabel;
@synthesize startCityCode = _startCityCode;
@synthesize arrivedCityCode = _arrivedCityCode;
@synthesize goDateShowlabel = _goDateShowlabel;
@synthesize backDateShowlabel = _backDateShowlabel;
@synthesize flightCompanyShowlabel = _flightCompanyShowlabel;
@synthesize flightCompanyCode = _flightCompanyCode;
@synthesize searchTableView = _searchTableView;
@synthesize searchButton = _searchButton;
@synthesize dateBar = _dateBar;
@synthesize datePicker = _datePicker;

- (void)dealloc{
    [self.bigLeftSegmentControlButton release];
    [self.bigRightSegmentControlButton release];
    [self.startedCityShowlabel release];
    [self.arrivedCityShowlabel release];
    [self.startCityCode release];
    [self.arrivedCityCode release];
    [self.goDateShowlabel release];
    [self.backDateShowlabel release];
    [self.flightCompanyShowlabel release];
    [self.flightCompanyCode release];
    [self.searchTableView release];
    [self.searchButton release];
    [self.dateBar release];
	[self.datePicker release];
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

- (void)typeSegmentControlAction:(UIButton *)segmentControlButton
{
    switch (segmentControlButton.tag) {
        case kSingleLeftSegmentControlButtonTag:
            //设置单程按钮为选中
            [self.bigLeftSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.bigLeftSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            NSString *titleLeftSegmentControlButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleLeftSegmentControlButton_selected" inDirectory:@"CommonView/TitleSegmentedControl"];
            [self.bigLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonSelectedPath] forState:UIControlStateNormal];
            [self.bigLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonSelectedPath] forState:UIControlStateHighlighted];
            //设置往返按钮为非选中
            [self.bigRightSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateNormal];
            [self.bigRightSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateHighlighted];
            NSString *titleRightSegmentControlButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleRightSegmentControlButton_normal" inDirectory:@"CommonView/TitleSegmentedControl"];
            [self.bigRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonNormalPath] forState:UIControlStateNormal];
            [self.bigRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonNormalPath] forState:UIControlStateHighlighted];
            
            if (_flightLineType != UCAIFlightLineStyleSingle) {
                _flightLineType = UCAIFlightLineStyleSingle;
                
                NSArray *indexArray = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:1],nil];
                [self.searchTableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                [UIView setAnimationDelegate:self];
                self.searchButton.frame = CGRectMake(10, 240, 300, 40);
                [UIView commitAnimations];
            }
            break;
        case kDoubleRightSegmentControlButtonTag:
            //设置单程按钮为非选中
            [self.bigLeftSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateNormal];
            [self.bigLeftSegmentControlButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateHighlighted];
            NSString *titleLeftSegmentControlButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleLeftSegmentControlButton_normal" inDirectory:@"CommonView/TitleSegmentedControl"];
            [self.bigLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonNormalPath] forState:UIControlStateNormal];
            [self.bigLeftSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonNormalPath] forState:UIControlStateHighlighted];
            //设置往返按钮为选中
            [self.bigRightSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.bigRightSegmentControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            NSString *titleRightSegmentControlButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleRightSegmentControlButton_selected" inDirectory:@"CommonView/TitleSegmentedControl"];
            [self.bigRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonSelectedPath] forState:UIControlStateNormal];
            [self.bigRightSegmentControlButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonSelectedPath] forState:UIControlStateHighlighted];
            
            if (_flightLineType != UCAIFlightLineStyleDouble) {
                _flightLineType = UCAIFlightLineStyleDouble;
                
                NSArray *indexArray = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:1],nil];
                [self.searchTableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                [UIView setAnimationDelegate:self];
                self.searchButton.frame = CGRectMake(10, 284, 300, 40);
                [UIView commitAnimations];
            }
            break;
    }
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
    [self.searchTableView setScrollEnabled:YES];
    
    [self.searchTableView reloadData];
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
	[self.searchTableView setScrollEnabled:YES];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"yyyy-MM-dd";
    
    switch (_flightBookingDateType) {
        case UCAIFlightReserveDateTypeGo:
            //出发日期的选择
            self.goDateShowlabel.text = [formatter stringFromDate:[self.datePicker date]];
            
            // 判断出发日期是否晚于返回日期，若是，则要设置返回日期为出发日期的后一天
            if ([[formatter dateFromString:self.backDateShowlabel.text] compare:[self.datePicker date]] != NSOrderedDescending) {
                //出发日期晚于返回日期
                self.backDateShowlabel.text = [formatter stringFromDate:[[self.datePicker date] dateByAddingTimeInterval:86400]];
            }
            break;
        case UCAIFlightReserveDateTypeBack:
            //返回日期的选择
            self.backDateShowlabel.text = [formatter stringFromDate:[self.datePicker date]];
            break;
        
    }
    [formatter release];
    
    [self.searchTableView reloadData];
}

- (NSData*)generateFlightBookingRequestPostXMLData{
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *pageInfoElement = [GDataXMLElement elementWithName:@"pageInfo"]; 
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"currentPage" stringValue:@"1"]];
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"pageSize" stringValue:@"20"]];  // 查到爆
    [requestElement addChild:pageInfoElement];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"fromCity" stringValue:self.startCityCode]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"toCity" stringValue:self.arrivedCityCode]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"fromDate" stringValue:self.goDateShowlabel.text]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"companyCode" stringValue:self.flightCompanyCode]];
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

- (void)searchButtonPress{
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"查询中...";
    [_hud show:YES];
    
    NSString *postData = [[NSString alloc] initWithData:[self generateFlightBookingRequestPostXMLData] encoding:NSUTF8StringEncoding];
    NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    [postData release];
    
    ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: FLIGHT_LIST_SEARCH_ADDRESS]] autorelease];
    [req addRequestHeader:@"API-Version" value:API_VERSION];
    req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    [req appendPostData:[self generateFlightBookingRequestPostXMLData]];
    [req setDelegate:self];
    [req startAsynchronous]; // 执行异步post
}

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应 : 但可能是错误响应, 如 404，或查询结果为空，则不跳转到下一个机票展示页面
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);
    // 关闭加载框
    [_hud hide:YES];
    if ((responseString != nil) && [responseString length] > 0) {
        
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
			FlightListViewController *flightListViewController = [[FlightListViewController alloc] initWithFlightLineStyle:UCAIFlightLineStyleSingle];
            flightListViewController.startedDate = self.goDateShowlabel.text;
            flightListViewController.startedCityName = self.startedCityShowlabel.text;
            flightListViewController.arrivedCityName = self.arrivedCityShowlabel.text;
            flightListViewController.startCityCode = self.startCityCode;
            flightListViewController.arrivedCityCode = self.arrivedCityCode;
            flightListViewController.searchCompanyCode = self.flightCompanyCode;
            flightListViewController.lastSegmentTag = 101;
            flightListViewController.sortOrder = @"1";
            flightListViewController.flightListSearchResponseModel = flightListSearchResponseModel;
            [self.navigationController pushViewController:flightListViewController animated:YES];
            [flightListViewController release];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setInteger:_flightLineType forKey:@"flightSearchLineType"];
            [userDefaults setObject:self.backDateShowlabel.text forKey:@"flightBackDate"];
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
    [_hud hide:YES afterDelay:3];
}

#pragma mark -
#pragma mark View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	self.title = @"航班查询";
	
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
    
    //单程左按钮
    UIButton * tempLeftSegmentedButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 150, 34)];
    tempLeftSegmentedButton.tag = kSingleLeftSegmentControlButtonTag;
    [tempLeftSegmentedButton setTitle:@"单程" forState:UIControlStateNormal];
    [tempLeftSegmentedButton setTitle:@"单程" forState:UIControlStateSelected];
    tempLeftSegmentedButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [tempLeftSegmentedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tempLeftSegmentedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    NSString *titleLeftSegmentControlButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleLeftSegmentControlButton_selected" inDirectory:@"CommonView/TitleSegmentedControl"];
    [tempLeftSegmentedButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonSelectedPath] forState:UIControlStateNormal];
    [tempLeftSegmentedButton setBackgroundImage:[UIImage imageNamed:titleLeftSegmentControlButtonSelectedPath] forState:UIControlStateHighlighted];
    [tempLeftSegmentedButton addTarget:self action:@selector(typeSegmentControlAction:) forControlEvents:UIControlEventTouchDown];
    self.bigLeftSegmentControlButton = tempLeftSegmentedButton;
    [self.view addSubview:self.bigLeftSegmentControlButton];
    [tempLeftSegmentedButton release];
    
    //往返右按钮
    UIButton * tempRightSegmentedButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 10, 150, 34)];
    tempRightSegmentedButton.tag =kDoubleRightSegmentControlButtonTag;
    [tempRightSegmentedButton setTitle:@"往返" forState:UIControlStateNormal];
    [tempRightSegmentedButton setTitle:@"往返" forState:UIControlStateSelected];
    tempRightSegmentedButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [tempRightSegmentedButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateNormal];
    [tempRightSegmentedButton setTitleColor:[PiosaColorManager fontColor] forState:UIControlStateHighlighted];
    NSString *titleRightSegmentControlButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"titleRightSegmentControlButton_normal" inDirectory:@"CommonView/TitleSegmentedControl"];
    [tempRightSegmentedButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonNormalPath] forState:UIControlStateNormal];
    [tempRightSegmentedButton setBackgroundImage:[UIImage imageNamed:titleRightSegmentControlButtonNormalPath] forState:UIControlStateHighlighted];
    [tempRightSegmentedButton addTarget:self action:@selector(typeSegmentControlAction:) forControlEvents:UIControlEventTouchDown];
    self.bigRightSegmentControlButton = tempRightSegmentedButton;
    [self.view addSubview:self.bigRightSegmentControlButton];
    [tempRightSegmentedButton release];
    
    UITableView * uiTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 54, 320, 332) style:UITableViewStyleGrouped];
    uiTableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    uiTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	uiTableView.backgroundColor = [UIColor clearColor];
	uiTableView.dataSource = self;
	uiTableView.delegate = self;
    self.searchTableView = uiTableView;
	[self.view addSubview:uiTableView];
	[uiTableView release];
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 240, 300, 40)];
	[searchButton setTitle:@"查    询" forState:UIControlStateNormal];
    [searchButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
    [searchButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
	[searchButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
	[searchButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
	[searchButton addTarget:self action:@selector(searchButtonPress) forControlEvents:UIControlEventTouchUpInside];
    self.searchButton = searchButton;
	[self.searchTableView addSubview:searchButton];
	[searchButton release];
    
    _flightLineType = UCAIFlightLineStyleSingle;
    
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

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.searchTableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            switch (_flightLineType) {
                case UCAIFlightLineStyleSingle:
                    return 2;
                    break;
                case UCAIFlightLineStyleDouble:
                    return 3;
                    break;
                default:
                    return 0;
                    break;
            }
            break;
        default:
            return 0;
            break;
    }
}

//设置表格单元的展现
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger realRow = indexPath.row;
    if (_flightLineType == UCAIFlightLineStyleSingle) {
        if (indexPath.section == 1 && realRow == 1) {
            realRow ++;
        }
    }
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell%d%d",indexPath.section,realRow];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        switch (indexPath.section) {
            case 0:
                switch (realRow) {
                    case 0:{
                        UILabel *startedCityTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        startedCityTitlelabel.backgroundColor = [UIColor clearColor];
                        startedCityTitlelabel.textAlignment = UITextAlignmentRight;
                        startedCityTitlelabel.text = @"出发城市:";
                        [cell.contentView addSubview:startedCityTitlelabel];
                        [startedCityTitlelabel release];
                        
                        UILabel *startedCityShowlabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        startedCityShowlabel.backgroundColor = [UIColor clearColor];
                        startedCityShowlabel.textColor = [UIColor grayColor];
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        NSString * flightDefaultStartedCityName = [userDefaults stringForKey:@"flightDefaultStartedCityName"];
                        startedCityShowlabel.text = flightDefaultStartedCityName == nil ?@"深圳":flightDefaultStartedCityName;
                        self.startedCityShowlabel = startedCityShowlabel;
                        [cell.contentView addSubview:startedCityShowlabel];
                        [startedCityShowlabel release];
                        
                        NSString * flightDefaultStartedCityCode = [userDefaults stringForKey:@"flightDefaultStartedCityCode"];
                        self.startCityCode = flightDefaultStartedCityCode == nil ?@"SZX":flightDefaultStartedCityCode;
                    }
                        break;
                    case 1:{
                        UILabel *arrivedCityTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        arrivedCityTitlelabel.backgroundColor = [UIColor clearColor];
                        arrivedCityTitlelabel.textAlignment = UITextAlignmentRight;
                        arrivedCityTitlelabel.text = @"目的城市:";
                        [cell.contentView addSubview:arrivedCityTitlelabel];
                        [arrivedCityTitlelabel release];
                        
                        UILabel *arrivedCityShowlabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        arrivedCityShowlabel.backgroundColor = [UIColor clearColor];
                        arrivedCityShowlabel.textColor = [UIColor grayColor];
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        NSString * flightDefaultArrivedCityName = [userDefaults stringForKey:@"flightDefaultArrivedCityName"];
                        arrivedCityShowlabel.text = flightDefaultArrivedCityName == nil ?@"北京":flightDefaultArrivedCityName;
                        self.arrivedCityShowlabel = arrivedCityShowlabel;
                        [cell.contentView addSubview:arrivedCityShowlabel];
                        [arrivedCityShowlabel release];
                        
                        NSString * flightDefaultArrivedCityCode = [userDefaults stringForKey:@"flightDefaultArrivedCityCode"];
                        self.arrivedCityCode = flightDefaultArrivedCityCode == nil ?@"PEK":flightDefaultArrivedCityCode;
                    }
                        break;
                }
                NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                UIImageView * accessoryViewTemp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                accessoryViewTemp.frame = CGRectMake(0, 0, 10, 16);
                cell.accessoryView = accessoryViewTemp;
                [accessoryViewTemp release];
                break;
            case 1:{
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				formatter.dateFormat = @"yyyy-MM-dd";
                switch (realRow) {
                    case 0:{
                        UILabel *goDateTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        goDateTitlelabel.backgroundColor = [UIColor clearColor];
                        goDateTitlelabel.textAlignment = UITextAlignmentRight;
                        goDateTitlelabel.text = @"出发日期:";
                        [cell.contentView addSubview:goDateTitlelabel];
                        [goDateTitlelabel release];
                        
                        UILabel *goDateShowlabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        goDateShowlabel.backgroundColor = [UIColor clearColor];
                        goDateShowlabel.textColor = [UIColor grayColor];
                        goDateShowlabel.text = [formatter stringFromDate:[NSDate date]];
                        self.goDateShowlabel = goDateShowlabel;
                        [cell.contentView addSubview:goDateShowlabel];
                        [goDateShowlabel release];
                    }
                        NSString *accessoryTimeIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryTimeIndicator" inDirectory:@"CommonView/TableViewCell"];
                        UIImageView * accessoryViewTemp1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryTimeIndicatorPath]];
                        accessoryViewTemp1.frame = CGRectMake(0, 0, 20, 20);
                        cell.accessoryView = accessoryViewTemp1;
                        [accessoryViewTemp1 release];
                        break;
                    case 1:{
                        UILabel *backDateTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        backDateTitlelabel.backgroundColor = [UIColor clearColor];
                        backDateTitlelabel.textAlignment = UITextAlignmentRight;
                        backDateTitlelabel.text = @"返回日期:";
                        [cell.contentView addSubview:backDateTitlelabel];
                        [backDateTitlelabel release];
                        
                        UILabel *backDateShowlabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        backDateShowlabel.backgroundColor = [UIColor clearColor];
                        backDateShowlabel.textColor = [UIColor grayColor];
                        backDateShowlabel.text = [formatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:86400]];
                        self.backDateShowlabel = backDateShowlabel;
                        [cell.contentView addSubview:backDateShowlabel];
                        [backDateShowlabel release];  
                        
                        // 判断出发日期是否晚于返回日期，若是，则要设置返回日期为出发日期的后一天
                        if ([[formatter dateFromString:self.backDateShowlabel.text] compare:[self.datePicker date]] != NSOrderedDescending) {
                            //出发日期晚于返回日期
                            self.backDateShowlabel.text = [formatter stringFromDate:[[self.datePicker date] dateByAddingTimeInterval:86400]];
                        }
                    }
                        NSString *accessoryTimeIndicatorPath2 = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryTimeIndicator" inDirectory:@"CommonView/TableViewCell"];
                        UIImageView * accessoryViewTemp2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryTimeIndicatorPath2]];
                        accessoryViewTemp2.frame = CGRectMake(0, 0, 20, 20);
                        cell.accessoryView = accessoryViewTemp2;
                        [accessoryViewTemp2 release];
                        break;
                    case 2:{
                        UILabel *flightCompanyTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 90, 25)];
                        flightCompanyTitlelabel.backgroundColor = [UIColor clearColor];
                        flightCompanyTitlelabel.textAlignment = UITextAlignmentRight;
                        flightCompanyTitlelabel.text = @"航空公司:";
                        [cell.contentView addSubview:flightCompanyTitlelabel];
                        [flightCompanyTitlelabel release];
                        
                        UILabel *flightCompanyShowlabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 25)];
                        flightCompanyShowlabel.backgroundColor = [UIColor clearColor];
                        flightCompanyShowlabel.textColor = [UIColor grayColor];
                        flightCompanyShowlabel.text = @"所有";
                        self.flightCompanyShowlabel = flightCompanyShowlabel;
                        [cell.contentView addSubview:flightCompanyShowlabel];
                        [flightCompanyShowlabel release];  
                        
                        self.flightCompanyCode = @"";
                        
                        
                    }
                        NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                        UIImageView * accessoryViewTemp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                        accessoryViewTemp.frame = CGRectMake(0, 0, 10, 16);
                        cell.accessoryView = accessoryViewTemp;
                        [accessoryViewTemp release];
                        break;
                }
                [formatter release];
                
            } 
                break;
        }
    }
    
    if ([self.searchTableView numberOfRowsInSection:indexPath.section] == 1) {
        NSString *tableViewCellSingleNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_single_normal" inDirectory:@"CommonView/TableViewCell"];
        NSString *tableViewCellSingleHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_single_highlighted" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellSingleNormalPath]] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellSingleHighlightedPath]] autorelease];
    } else {
        if (indexPath.row == 0) {
            NSString *tableViewCellTopNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_top_normal" inDirectory:@"CommonView/TableViewCell"];
            NSString *tableViewCellTopHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_top_highlighted" inDirectory:@"CommonView/TableViewCell"];
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellTopNormalPath]] autorelease];
            cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellTopHighlightedPath]] autorelease];
        } else if(indexPath.row == [self.searchTableView numberOfRowsInSection:indexPath.section]-1){
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger realRow = indexPath.row;
    if (_flightLineType == UCAIFlightLineStyleSingle) {
        if (indexPath.section == 1 && realRow == 1) {
            realRow ++;
        }
    }
    
    switch (indexPath.section) {
        case 0:
            switch (realRow) {
                case 0:
                {
                    FlightBookingCityChoiceTableViewController *flightBookingCityChoiceTableViewController = [[FlightBookingCityChoiceTableViewController alloc] initWithCityType:1];
                    flightBookingCityChoiceTableViewController.flightSearchViewController = self;
                    [self.navigationController pushViewController:flightBookingCityChoiceTableViewController animated:YES];
                    [flightBookingCityChoiceTableViewController release];
                }
                    break;
                case 1:
                {
                    FlightBookingCityChoiceTableViewController *flightBookingCityChoiceTableViewController = [[FlightBookingCityChoiceTableViewController alloc] initWithCityType:2];
                    flightBookingCityChoiceTableViewController.flightSearchViewController = self;
                    [self.navigationController pushViewController:flightBookingCityChoiceTableViewController animated:YES];
                    [flightBookingCityChoiceTableViewController release];
                }
                    break;
            }
            break;
        case 1:
            if (realRow != 2) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd";
                switch (indexPath.row) {
                    case 0:{
                        [self.datePicker setDate:[formatter dateFromString:self.goDateShowlabel.text]];//设置日期滚轮的当前显示
                        self.datePicker.minimumDate = [NSDate date];//最小选择日期，当日
                        _flightBookingDateType = UCAIFlightReserveDateTypeGo;//标记当前是在选择出发日期
                    }
                        break;
                    case 1:{
                        [self.datePicker setDate:[formatter dateFromString:self.backDateShowlabel.text]];//设置日期滚轮的当前显示
                        self.datePicker.minimumDate = [[formatter dateFromString:self.goDateShowlabel.text] dateByAddingTimeInterval:86400];//最小选择日期，入住日期的后一天
                        _flightBookingDateType = UCAIFlightReserveDateTypeBack;//标记当前是在选择返程日期
                    }
                        break;
                }
                [formatter release];
                self.dateBar.hidden = NO;
                self.datePicker.hidden = NO;
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                [UIView setAnimationDelegate:self];
                self.dateBar.frame = CGRectMake(0, 180, 320, 40);
                self.datePicker.frame = CGRectMake(0, 210, 320, 216);
                [UIView commitAnimations];
                [self.searchTableView setScrollEnabled:NO];
            } else {
                FlightCompanyChoiceTableViewController *flightCompanyChoiceTableViewController = [[FlightCompanyChoiceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                flightCompanyChoiceTableViewController.flightSearchViewController = self;
                [self.navigationController pushViewController:flightCompanyChoiceTableViewController animated:YES];
                [flightCompanyChoiceTableViewController release];
                
            }
            break;
    }
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

//
//  FlightCompanyChoiceTableViewController.m
//  UCAI
//
//  Created by  on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FlightCompanyChoiceTableViewController.h"
#import "FlightSearchViewController.h"
#import "PiosaFileManager.h"

@implementation FlightCompanyChoiceTableViewController

@synthesize companyTextArray = _companyTextArray;
@synthesize companyImgArray = _companyImgArray;
@synthesize flightSearchViewController = _flightSearchViewController;
@synthesize nowSelectRow = _nowSelectRow;

- (void)dealloc {
	[self.companyTextArray release];
	[self.companyImgArray release];
	[self.flightSearchViewController release];
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

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择航空公司";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
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
	[self.tableView setBackgroundView:bgImageView];
	[bgImageView release];
	
	self.companyTextArray = [[NSArray alloc] initWithObjects:@"所有",@"国际航空",@"南方航空",@"东方航空",@"上海航空",@"海南航空",@"山东航空",@"厦门航空",@"四川航空",@"深圳航空",@"首都航空",@"吉祥航空",@"中联航空",@"祥鹏航空",@"奥凯航空",@"成都航空",@"东星航空",@"华夏航空",@"西部航空",@"重庆航空",@"东北航空",@"大新华航空",@"天津航空",@"幸福航空",nil];
    [self.companyTextArray release];
	self.companyImgArray = [[NSArray alloc] initWithObjects:@"",@"air_line_ca",@"air_line_cz",@"air_line_mu",@"air_line_fm",@"air_line_hu",@"air_line_sc",@"air_line_mf",@"air_line_3u",@"air_line_zh",@"air_line_pn",@"air_line_ho",@"air_line_kn",@"air_line_8l",@"air_line_bk",@"air_line_eu",@"air_line_8c",@"air_line_g5",@"air_line_jd",@"air_line_oq",@"air_line_ns",@"air_line_hu",@"air_line_gs",@"air_line_jr",nil];
    [self.companyImgArray release];
    NSString *companyCode = self.flightSearchViewController.flightCompanyCode;
    
	if ([@"" isEqualToString:companyCode]) {//不限
		self.nowSelectRow = 0;
	} else if ([@"CA" isEqualToString:companyCode]) {//国际航空
		self.nowSelectRow = 1;
	}else if ([@"CZ" isEqualToString:companyCode]) {//南方航空
		self.nowSelectRow = 2;
	}else if ([@"MU" isEqualToString:companyCode]) {//东方航空
		self.nowSelectRow = 3;
	}else if ([@"FM" isEqualToString:companyCode]) {//上海航空
		self.nowSelectRow = 4;
	}else if ([@"HU" isEqualToString:companyCode]) {//海南航空
		self.nowSelectRow = 5;
	}else if ([@"SC" isEqualToString:companyCode]) {//山东航空
		self.nowSelectRow = 6;
	}else if ([@"MF" isEqualToString:companyCode]) {//厦门航空
		self.nowSelectRow = 7;
	}else if ([@"3U" isEqualToString:companyCode]) {//四川航空
		self.nowSelectRow = 8;
	}else if ([@"ZH" isEqualToString:companyCode]) {//深圳航空
		self.nowSelectRow = 9;
	}else if ([@"JD" isEqualToString:companyCode]) {//首都航空
		self.nowSelectRow = 10;
	}else if ([@"HO" isEqualToString:companyCode]) {//吉祥航空
		self.nowSelectRow = 11;
	}else if ([@"KN" isEqualToString:companyCode]) {//中联航空
		self.nowSelectRow = 12;
	}else if ([@"8L" isEqualToString:companyCode]) {//祥鹏航空
		self.nowSelectRow = 13;
	}else if ([@"BK" isEqualToString:companyCode]) {//奥凯航空
		self.nowSelectRow = 14;
	}else if ([@"EU" isEqualToString:companyCode]) {//成都航空
		self.nowSelectRow = 15;
	}else if ([@"8C" isEqualToString:companyCode]) {//东星航空
		self.nowSelectRow = 16;
	}else if ([@"G5" isEqualToString:companyCode]) {//华夏航空
		self.nowSelectRow = 17;
	}else if ([@"PN" isEqualToString:companyCode]) {//西部航空
		self.nowSelectRow = 18;
	}else if ([@"OQ" isEqualToString:companyCode]) {//重庆航空
		self.nowSelectRow = 19;
	}else if ([@"NS" isEqualToString:companyCode]) {//东北航空
		self.nowSelectRow = 20;
	}else if ([@"CN" isEqualToString:companyCode]) {//大新华航空
		self.nowSelectRow = 21;
	}else if ([@"GS" isEqualToString:companyCode]) {//天津航空
		self.nowSelectRow = 22;
	}else if ([@"JR" isEqualToString:companyCode]) {//幸福航空
		self.nowSelectRow = 23;
	}
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 24;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.textLabel.text = [self.companyTextArray objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        cell.imageView.image = nil;
    } else {
        NSString *flightCompanyPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:[self.companyImgArray objectAtIndex:indexPath.row] inDirectory:@"Flight/FlightCompany"];
        cell.imageView.image = [UIImage imageNamed:flightCompanyPath];
    }
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.highlightedTextColor = [PiosaColorManager themeColor];
	
    //设置cell的附件类型
	if (indexPath.row == self.nowSelectRow) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if ([self.tableView numberOfRowsInSection:indexPath.section] == 1) {
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
        } else if(indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section]-1){
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
    
    NSString *companyText;
    NSString *companyCode;
    
    switch (indexPath.row) {
		case 0:
			companyText = @"所有";
			companyCode = @"";
			break;
		case 1:
			companyText = @"国际航空";
			companyCode = @"CA";
			break;
		case 2:
			companyText = @"南方航空";
			companyCode = @"CZ";
			break;
		case 3:
			companyText = @"东方航空";
			companyCode = @"MU";
			break;
        case 4:
			companyText = @"上海航空";
			companyCode = @"FM";
			break;
        case 5:
			companyText = @"海南航空";
			companyCode = @"HU";
			break;
        case 6:
			companyText = @"山东航空";
			companyCode = @"SC";
			break;
        case 7:
			companyText = @"厦门航空";
			companyCode = @"MF";
			break;
        case 8:
			companyText = @"四川航空";
			companyCode = @"3U";
			break;
        case 9:
			companyText = @"深圳航空";
			companyCode = @"ZH";
			break;
        case 10:
			companyText = @"首都航空";
			companyCode = @"JD";
			break;
        case 11:
			companyText = @"吉祥航空";
			companyCode = @"HO";
			break;
        case 12:
			companyText = @"中联航空";
			companyCode = @"KN";
			break;
        case 13:
			companyText = @"祥鹏航空";
			companyCode = @"8L";
			break;
        case 14:
			companyText = @"奥凯航空";
			companyCode = @"BK";
			break;
        case 15:
			companyText = @"成都航空";
			companyCode = @"EU";
			break;
        case 16:
			companyText = @"东星航空";
			companyCode = @"8C";
			break;
        case 17:
			companyText = @"华夏航空";
			companyCode = @"G5";
			break;
        case 18:
			companyText = @"西部航空";
			companyCode = @"PN";
			break;
        case 19:
			companyText = @"重庆航空";
			companyCode = @"OQ";
			break;
        case 20:
			companyText = @"东北航空";
			companyCode = @"NS";
			break;
        case 21:
			companyText = @"大新华航空";
			companyCode = @"CN";
			break;
        case 22:
			companyText = @"天津航空";
			companyCode = @"GS";
			break;
        case 23:
			companyText = @"幸福航空";
			companyCode = @"JR";
			break;
    }
    
    self.flightSearchViewController.flightCompanyShowlabel.text = companyText;
    self.flightSearchViewController.flightCompanyCode = companyCode;
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end

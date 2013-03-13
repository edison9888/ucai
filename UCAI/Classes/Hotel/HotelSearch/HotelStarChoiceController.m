//
//  HotelStarChoiceController.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-19.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "HotelStarChoiceController.h"
#import "HotelSearchController.h"


@implementation HotelStarChoiceController

@synthesize hotelStarText = _hotelStarText;
@synthesize hotelStarImg = _hotelStarImg;
@synthesize hotelSearchController = _hotelSearchController;
@synthesize nowSelectRow = _nowSelectRow;

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    self.hotelStarText = nil;
	self.hotelStarImg = nil;
}

- (void)dealloc {
	[self.hotelStarText release];
	[self.hotelStarImg release];
	[self.hotelSearchController release];
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

    self.title = @"选择酒店星级";
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
	
    NSArray *hotelStarText = [[NSArray alloc] initWithObjects:@"不限",@"五星级",@"准五星级",@"四星级",@"准四星级",@"三星级",@"准三星级",@"二星级",@"准二星级",@"一星级",@"准一星级",nil];
	self.hotelStarText = hotelStarText;
    [hotelStarText release];
    
    NSArray *hotelStarImg = [[NSArray alloc] initWithObjects:@"",@"star5",@"star4_1",@"star4",@"star3_1",@"star3",@"star2_1",@"star2",@"star1_1",@"star1",@"star0_1",nil];
	self.hotelStarImg = hotelStarImg;
    [hotelStarImg release];

	if ([@"" isEqualToString:self.hotelSearchController.hotelRank]) {//不限
		self.nowSelectRow = 0;
	} else if ([@"5S" isEqualToString:self.hotelSearchController.hotelRank]) {//五星级
		self.nowSelectRow = 1;
	}else if ([@"5A" isEqualToString:self.hotelSearchController.hotelRank]) {//准五星级
		self.nowSelectRow = 2;
	}else if ([@"4S" isEqualToString:self.hotelSearchController.hotelRank]) {//四星级
		self.nowSelectRow = 3;
	}else if ([@"4A" isEqualToString:self.hotelSearchController.hotelRank]) {//准四星级
		self.nowSelectRow = 4;
	}else if ([@"3S" isEqualToString:self.hotelSearchController.hotelRank]) {//三星级
		self.nowSelectRow = 5;
	}else if ([@"3A" isEqualToString:self.hotelSearchController.hotelRank]) {//准三星级
		self.nowSelectRow = 6;
	}else if ([@"2S" isEqualToString:self.hotelSearchController.hotelRank]) {//二星级
		self.nowSelectRow = 7;
	}else if ([@"2A" isEqualToString:self.hotelSearchController.hotelRank]) {//准二星级
		self.nowSelectRow = 8;
	}else if ([@"1S" isEqualToString:self.hotelSearchController.hotelRank]) {//一星级
		self.nowSelectRow = 9;
	}else if ([@"1A" isEqualToString:self.hotelSearchController.hotelRank]) {//准一星级
		self.nowSelectRow = 10;
	}
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 11;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.textLabel.text = [self.hotelStarText objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        cell.imageView.image = nil;
    } else {
        NSString *starImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:[self.hotelStarImg objectAtIndex:indexPath.row] inDirectory:@"Hotel/star"];
        cell.imageView.image = [UIImage imageNamed:starImagePath];
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
    switch (indexPath.row) {
		case 0:
			self.hotelSearchController.rankLabel.text = @"不限";
			self.hotelSearchController.hotelRank = @"";
			break;
		case 1:
			self.hotelSearchController.rankLabel.text = @"五星级";
			self.hotelSearchController.hotelRank = @"5S";
			break;
		case 2:
			self.hotelSearchController.rankLabel.text = @"准五星级";
			self.hotelSearchController.hotelRank = @"5A";
			break;
		case 3:
			self.hotelSearchController.rankLabel.text = @"四星级";
			self.hotelSearchController.hotelRank = @"4S";
			break;
		case 4:
			self.hotelSearchController.rankLabel.text = @"准四星级";
			self.hotelSearchController.hotelRank = @"4A";
			break;
		case 5:
			self.hotelSearchController.rankLabel.text = @"三星级";
			self.hotelSearchController.hotelRank = @"3S";
			break;
		case 6:
			self.hotelSearchController.rankLabel.text = @"准三星级";
			self.hotelSearchController.hotelRank = @"3A";
			break;
		case 7:
			self.hotelSearchController.rankLabel.text = @"二星级";
			self.hotelSearchController.hotelRank = @"2S";
			break;
		case 8:
			self.hotelSearchController.rankLabel.text = @"准二星级";
			self.hotelSearchController.hotelRank = @"2A";
			break;
		case 9:
			self.hotelSearchController.rankLabel.text = @"一星级";
			self.hotelSearchController.hotelRank = @"1S";
			break;
		case 10:
			self.hotelSearchController.rankLabel.text = @"准一星级";
			self.hotelSearchController.hotelRank = @"1A";
			break;
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}


@end


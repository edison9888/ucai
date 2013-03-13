//
//  FlightBookingDiscountChoiceTableViewController.m
//  UCAI
//
//  Created by  on 11-12-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FlightReserveDiscountChoiceTableViewController.h"
#import "FlightReserveViewController.h"
#import "PiosaFileManager.h"


@implementation FlightReserveDiscountChoiceTableViewController

@synthesize discountArray = _discountArray;
@synthesize flightReserveViewController = _flightReserveViewController;
@synthesize nowSelectRow = _nowSelectRow;

- (void)dealloc {
	[self.discountArray release];
	[self.flightReserveViewController release];
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
	
	self.title = @"选择折扣";
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
    
    NSArray *discountArray = [[NSArray alloc] initWithObjects:@"全价",@"9折及以下",@"8折及以下",@"7折及以下",@"6折及以下",@"5折及以下",@"4折及以下",@"3折及以下",@"2折及以下",nil];
    self.discountArray = discountArray;
    [discountArray release];
    
	if ([@"全价" isEqualToString:self.flightReserveViewController.discountChoiceShowlabel.text]) {
		self.nowSelectRow = 0;
	} else if ([@"9折及以下" isEqualToString:self.flightReserveViewController.discountChoiceShowlabel.text]) {
		self.nowSelectRow = 1;
	}else if ([@"8折及以下" isEqualToString:self.flightReserveViewController.discountChoiceShowlabel.text]) {
		self.nowSelectRow = 2;
	}else if ([@"7折及以下" isEqualToString:self.flightReserveViewController.discountChoiceShowlabel.text]) {
		self.nowSelectRow = 3;
	}else if ([@"6折及以下" isEqualToString:self.flightReserveViewController.discountChoiceShowlabel.text]) {
		self.nowSelectRow = 4;
	}else if ([@"5折及以下" isEqualToString:self.flightReserveViewController.discountChoiceShowlabel.text]) {
		self.nowSelectRow = 5;
	}else if ([@"4折及以下" isEqualToString:self.flightReserveViewController.discountChoiceShowlabel.text]) {
		self.nowSelectRow = 6;
	} else if ([@"3折及以下" isEqualToString:self.flightReserveViewController.discountChoiceShowlabel.text]) {
		self.nowSelectRow = 7;
	} else if ([@"2折及以下" isEqualToString:self.flightReserveViewController.discountChoiceShowlabel.text]) {
		self.nowSelectRow = 8;
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [self.discountArray objectAtIndex:indexPath.row];
	if (indexPath.row == self.nowSelectRow) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    NSString *discountShowString;
    NSUInteger discountUInteger;
    switch (indexPath.row) {
		case 0:
			discountShowString = @"全价";
			discountUInteger = 100;
			break;
		case 1:
			discountShowString = @"9折及以下";
			discountUInteger = 90;
			break;
		case 2:
			discountShowString = @"8折及以下";
			discountUInteger = 80;
			break;
		case 3:
			discountShowString = @"7折及以下";
			discountUInteger = 70;
			break;
		case 4:
			discountShowString = @"6折及以下";
			discountUInteger = 60;
			break;
        case 5:
			discountShowString = @"5折及以下";
			discountUInteger = 50;
			break;
        case 6:
			discountShowString = @"4折及以下";
			discountUInteger = 40;
			break;
        case 7:
			discountShowString = @"3折及以下";
			discountUInteger = 30;
			break;
        case 8:
			discountShowString = @"2折及以下";
			discountUInteger = 20;
			break;
    }
	self.flightReserveViewController.discountChoiceShowlabel.text = discountShowString;
    self.flightReserveViewController.discount = discountUInteger;
	[self.navigationController popViewControllerAnimated:YES];
}

@end

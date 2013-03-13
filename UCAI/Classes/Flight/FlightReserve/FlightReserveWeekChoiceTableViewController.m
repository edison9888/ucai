//
//  FlightBookingWeekChoiceTableViewController.m
//  UCAI
//
//  Created by  on 11-12-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FlightReserveWeekChoiceTableViewController.h"
#import "FlightReserveViewController.h"


@implementation FlightReserveWeekChoiceTableViewController

@synthesize dayOfWeekArray = _dayOfWeekArray;
@synthesize flightReserveViewController = _flightReserveViewController;
@synthesize nowSelectRow = _nowSelectRow;

- (void)dealloc {
	[self.dayOfWeekArray release];
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
	
	self.title = @"选择星期";
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
    
    NSArray *dayOfWeekArray = [[NSArray alloc] initWithObjects:@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期日",nil];
    self.dayOfWeekArray = dayOfWeekArray;
    [dayOfWeekArray release];
	
	if ([@"星期一" isEqualToString:self.flightReserveViewController.dayOfWeekShowlabel.text]) {
		self.nowSelectRow = 0;
	} else if ([@"星期二" isEqualToString:self.flightReserveViewController.dayOfWeekShowlabel.text]) {
		self.nowSelectRow = 1;
	}else if ([@"星期三" isEqualToString:self.flightReserveViewController.dayOfWeekShowlabel.text]) {
		self.nowSelectRow = 2;
	}else if ([@"星期四" isEqualToString:self.flightReserveViewController.dayOfWeekShowlabel.text]) {
		self.nowSelectRow = 3;
	}else if ([@"星期五" isEqualToString:self.flightReserveViewController.dayOfWeekShowlabel.text]) {
		self.nowSelectRow = 4;
	}else if ([@"星期六" isEqualToString:self.flightReserveViewController.dayOfWeekShowlabel.text]) {
		self.nowSelectRow = 5;
	}else if ([@"星期日" isEqualToString:self.flightReserveViewController.dayOfWeekShowlabel.text]) {
		self.nowSelectRow = 6;
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [self.dayOfWeekArray objectAtIndex:indexPath.row];
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
    NSString *dayOfWeekShowString;
    NSUInteger weekUInteger;
    switch (indexPath.row) {
		case 0:
			dayOfWeekShowString = @"星期一";
			weekUInteger = 1;
			break;
		case 1:
			dayOfWeekShowString = @"星期二";
			weekUInteger = 2;
			break;
		case 2:
			dayOfWeekShowString = @"星期三";
			weekUInteger = 3;
			break;
		case 3:
			dayOfWeekShowString = @"星期四";
			weekUInteger = 4;
			break;
		case 4:
			dayOfWeekShowString = @"星期五";
			weekUInteger = 5;
			break;
        case 5:
			dayOfWeekShowString = @"星期六";
			weekUInteger = 6;
			break;
        case 6:
			dayOfWeekShowString = @"星期日";
			weekUInteger = 7;
			break;
    }
	self.flightReserveViewController.dayOfWeekShowlabel.text = dayOfWeekShowString;
    self.flightReserveViewController.week = weekUInteger;
	[self.navigationController popViewControllerAnimated:YES];
}

@end

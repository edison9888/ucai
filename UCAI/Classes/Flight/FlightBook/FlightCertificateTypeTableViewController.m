//
//  FlightCertificateTypeTableViewController.m
//  UCAI
//
//  Created by  on 12-2-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FlightCertificateTypeTableViewController.h"
#import "FlightCustomerAddController.h"
#import "PiosaFileManager.h"

@implementation FlightCertificateTypeTableViewController

@synthesize certificateTypeArray = _certificateTypeArrays;
@synthesize flightCustomerAddController = _flightCustomerAddController;
@synthesize nowSelectRow = _nowSelectRow;

- (void)dealloc {
	[self.certificateTypeArray release];
	[self.flightCustomerAddController release];
	
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
	
	self.title = @"选择证件类型";
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
    
    self.certificateTypeArray = [[NSArray alloc] initWithObjects:@"身份证",@"军官证",@"港澳通行证",@"护照",@"台胞证",@"士兵证",@"回乡证",@"其他",nil];
    [self.certificateTypeArray release];
	
	if ([@"身份证" isEqualToString:self.flightCustomerAddController.certificateTypeShowLabel.text]) {
		self.nowSelectRow = 0;
	} else if ([@"军官证" isEqualToString:self.flightCustomerAddController.certificateTypeShowLabel.text]) {
		self.nowSelectRow = 1;
	}else if ([@"港澳通行证" isEqualToString:self.flightCustomerAddController.certificateTypeShowLabel.text]) {
		self.nowSelectRow = 2;
	}else if ([@"护照" isEqualToString:self.flightCustomerAddController.certificateTypeShowLabel.text]) {
		self.nowSelectRow = 3;
	}else if ([@"台胞证" isEqualToString:self.flightCustomerAddController.certificateTypeShowLabel.text]) {
		self.nowSelectRow = 4;
	}else if ([@"士兵证" isEqualToString:self.flightCustomerAddController.certificateTypeShowLabel.text]) {
		self.nowSelectRow = 5;
	}else if ([@"回乡证" isEqualToString:self.flightCustomerAddController.certificateTypeShowLabel.text]) {
		self.nowSelectRow = 6;
	}else if ([@"其他" isEqualToString:self.flightCustomerAddController.certificateTypeShowLabel.text]) {
		self.nowSelectRow = 7;
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [self.certificateTypeArray objectAtIndex:indexPath.row];
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
#pragma mark Table view delegate@"身份证",@"军官证",@"港澳通行证",@"护照",@"台胞证",@"士兵证",@"回乡证",@"其他"

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
		case 0:
			self.flightCustomerAddController.certificateTypeShowLabel.text = @"身份证";
			self.flightCustomerAddController.certificateType = @"1";
			break;
		case 1:
			self.flightCustomerAddController.certificateTypeShowLabel.text = @"军官证";
			self.flightCustomerAddController.certificateType = @"2";
			break;
		case 2:
			self.flightCustomerAddController.certificateTypeShowLabel.text = @"港澳通行证";
			self.flightCustomerAddController.certificateType = @"3";
			break;
        case 3:
			self.flightCustomerAddController.certificateTypeShowLabel.text = @"护照";
			self.flightCustomerAddController.certificateType = @"4";
			break;
        case 4:
			self.flightCustomerAddController.certificateTypeShowLabel.text = @"台胞证";
			self.flightCustomerAddController.certificateType = @"5";
			break;
        case 5:
			self.flightCustomerAddController.certificateTypeShowLabel.text = @"士兵证";
			self.flightCustomerAddController.certificateType = @"6";
			break;
        case 6:
			self.flightCustomerAddController.certificateTypeShowLabel.text = @"回乡证";
			self.flightCustomerAddController.certificateType = @"7";
			break;
        case 7:
			self.flightCustomerAddController.certificateTypeShowLabel.text = @"其他";
			self.flightCustomerAddController.certificateType = @"8";
			break;
    }
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end

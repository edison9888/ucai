//
//  FlightCustomerTypeTableViewController.m
//  UCAI
//
//  Created by  on 12-2-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FlightCustomerTypeTableViewController.h"
#import "FlightCustomerAddController.h"
#import "PiosaFileManager.h"


@implementation FlightCustomerTypeTableViewController

@synthesize customerTypeArray = _customerTypeArray;
@synthesize flightCustomerAddController = _flightCustomerAddController;
@synthesize nowSelectRow = _nowSelectRow;

- (void)dealloc {
	[self.customerTypeArray release];
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
	
	self.title = @"选择乘客类型";
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
    
    self.customerTypeArray = [[NSArray alloc] initWithObjects:@"成人",@"儿童",@"婴儿",nil];
    [self.customerTypeArray release];
	
	if ([@"成人" isEqualToString:self.flightCustomerAddController.customerTypeShowLabel.text]) {
		self.nowSelectRow = 0;
	} else if ([@"儿童" isEqualToString:self.flightCustomerAddController.customerTypeShowLabel.text]) {
		self.nowSelectRow = 1;
	}else if ([@"婴儿" isEqualToString:self.flightCustomerAddController.customerTypeShowLabel.text]) {
		self.nowSelectRow = 2;
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [self.customerTypeArray objectAtIndex:indexPath.row];
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
    switch (indexPath.row) {
		case 0:
            self.flightCustomerAddController.isAdult = YES;
			self.flightCustomerAddController.customerTypeShowLabel.text = @"成人";
			self.flightCustomerAddController.customerType = @"1";
            self.flightCustomerAddController.certificateTypeShowLabel.text = @"身份证";
			self.flightCustomerAddController.certificateType = @"1";
            
            if (self.nowSelectRow != 0) {
                NSArray *indexArray1 = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0],nil];
                [self.flightCustomerAddController.addTableView insertRowsAtIndexPaths:indexArray1 withRowAnimation:UITableViewRowAnimationNone];
                
                NSArray *indexArray2 = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:3 inSection:0],nil];
                [self.flightCustomerAddController.addTableView reloadRowsAtIndexPaths:indexArray2 withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
		case 1:
            self.flightCustomerAddController.isAdult = NO;
			self.flightCustomerAddController.customerTypeShowLabel.text = @"儿童";
			self.flightCustomerAddController.customerType = @"2";
            self.flightCustomerAddController.certificateTypeShowLabel.text = @"其他";
			self.flightCustomerAddController.certificateType = @"8";
            
            if (self.nowSelectRow == 0) {
                NSArray *indexArray3 = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0],nil];
                [self.flightCustomerAddController.addTableView deleteRowsAtIndexPaths:indexArray3 withRowAnimation:UITableViewRowAnimationNone];
                
                NSArray *indexArray4 = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0],nil];
                [self.flightCustomerAddController.addTableView reloadRowsAtIndexPaths:indexArray4 withRowAnimation:UITableViewRowAnimationNone];
            }
			break;
		case 2:
            self.flightCustomerAddController.isAdult = NO;
			self.flightCustomerAddController.customerTypeShowLabel.text = @"婴儿";
			self.flightCustomerAddController.customerType = @"3";
            self.flightCustomerAddController.certificateTypeShowLabel.text = @"其他";
			self.flightCustomerAddController.certificateType = @"8";
            
            if (self.nowSelectRow == 0) {
                NSArray *indexArray5 = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0],nil];
                [self.flightCustomerAddController.addTableView deleteRowsAtIndexPaths:indexArray5 withRowAnimation:UITableViewRowAnimationNone];
                
                NSArray *indexArray6 = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0],nil];
                [self.flightCustomerAddController.addTableView reloadRowsAtIndexPaths:indexArray6 withRowAnimation:UITableViewRowAnimationNone];
            }
			break;
    }
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end

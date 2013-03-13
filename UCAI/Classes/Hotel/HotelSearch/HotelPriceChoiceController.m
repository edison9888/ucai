//
//  HotelPriceChoiceController.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-19.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "HotelPriceChoiceController.h"
#import "HotelSearchController.h"


@implementation HotelPriceChoiceController

@synthesize hotelPriceRate = _hotelPriceRate;
@synthesize hotelSearchController = _hotelSearchController;
@synthesize nowSelectRow = _nowSelectRow;

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    self.hotelPriceRate = nil;
}


- (void)dealloc {
	[self.hotelPriceRate release];
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
	
	self.title = @"选择酒店价格";
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
    
    NSArray *hotelPriceRate = [[NSArray alloc] initWithObjects:@"不限",@"¥150以下",@"¥150~¥300",@"¥300~¥600",@"¥600以上",nil];
    self.hotelPriceRate = hotelPriceRate;
    [hotelPriceRate release];
	
	if ([@"不限" isEqualToString:self.hotelSearchController.priceRateLabel.text]) {//@"不限"
		self.nowSelectRow = 0;
	} else if ([@"¥150以下" isEqualToString:self.hotelSearchController.priceRateLabel.text]) {//@"¥150以下"
		self.nowSelectRow = 1;
	}else if ([@"¥150~¥300" isEqualToString:self.hotelSearchController.priceRateLabel.text]) {//@"¥150~¥300"
		self.nowSelectRow = 2;
	}else if ([@"¥300~¥600" isEqualToString:self.hotelSearchController.priceRateLabel.text]) {//@"¥300~¥600"
		self.nowSelectRow = 3;
	}else if ([@"¥600以上" isEqualToString:self.hotelSearchController.priceRateLabel.text]) {//@"¥600以上"
		self.nowSelectRow = 4;
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [self.hotelPriceRate objectAtIndex:indexPath.row];
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
			self.hotelSearchController.priceRateLabel.text = @"不限";
			self.hotelSearchController.maxPriceRate = @"";
			self.hotelSearchController.minPriceRate = @"";
			break;
		case 1:
			self.hotelSearchController.priceRateLabel.text = @"¥150以下";
			self.hotelSearchController.maxPriceRate = @"150";
			self.hotelSearchController.minPriceRate = @"";
			break;
		case 2:
			self.hotelSearchController.priceRateLabel.text = @"¥150~¥300";
			self.hotelSearchController.maxPriceRate = @"300";
			self.hotelSearchController.minPriceRate = @"150";
			break;
		case 3:
			self.hotelSearchController.priceRateLabel.text = @"¥300~¥600";
			self.hotelSearchController.maxPriceRate = @"600";
			self.hotelSearchController.minPriceRate = @"300";
			break;
		case 4:
			self.hotelSearchController.priceRateLabel.text = @"¥600以上";
			self.hotelSearchController.maxPriceRate = @"";
			self.hotelSearchController.minPriceRate = @"600";
			break;
		}
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end


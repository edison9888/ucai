//
//  HotelRoomArrivalLastTimeChoiceController.m
//  JingDuTianXia
//
//  Created by Piosa on 11-11-14.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "HotelRoomArrivalLastTimeChoiceController.h"
#import "HotelBookController.h"


@implementation HotelRoomArrivalLastTimeChoiceController

@synthesize arrivalTime = _arrivalTime;
@synthesize hotelBookController = _hotelBookController;
@synthesize nowSelectRow = _nowSelectRow;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"选择最晚到店时间";
    }
    return self;
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
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
    self.arrivalTime = [[NSArray alloc] initWithObjects:@"23:00",@"22:00",@"21:00",@"20:00",@"19:00",@"18:00",@"17:00",@"16:00",@"15:00",@"14:00",@"13:00",@"12:00",nil];
    [self.arrivalTime release];
	
	if ([@"23:00" isEqualToString:self.hotelBookController.hotelLastTimeLabel.text]) {//23点
		self.nowSelectRow = 0;
	} else if ([@"22:00" isEqualToString:self.hotelBookController.hotelLastTimeLabel.text]) {//22点
		self.nowSelectRow = 1;
	}else if ([@"21:00" isEqualToString:self.hotelBookController.hotelLastTimeLabel.text]) {//21点
		self.nowSelectRow = 2;
	}else if ([@"20:00" isEqualToString:self.hotelBookController.hotelLastTimeLabel.text]) {//20点
		self.nowSelectRow = 3;
	}else if ([@"19:00" isEqualToString:self.hotelBookController.hotelLastTimeLabel.text]) {//19点
		self.nowSelectRow = 4;
	}else if ([@"18:00" isEqualToString:self.hotelBookController.hotelLastTimeLabel.text]) {//18点
		self.nowSelectRow = 5;
	}else if ([@"17:00" isEqualToString:self.hotelBookController.hotelLastTimeLabel.text]) {//17点
		self.nowSelectRow = 6;
	}else if ([@"16:00" isEqualToString:self.hotelBookController.hotelLastTimeLabel.text]) {//16点
		self.nowSelectRow = 7;
	}else if ([@"15:00" isEqualToString:self.hotelBookController.hotelLastTimeLabel.text]) {//15点
		self.nowSelectRow = 8;
	}else if ([@"14:00" isEqualToString:self.hotelBookController.hotelLastTimeLabel.text]) {//14点
		self.nowSelectRow = 9;
	}else if ([@"13:00" isEqualToString:self.hotelBookController.hotelLastTimeLabel.text]) {//13点
		self.nowSelectRow = 10;
	}else if ([@"12:00" isEqualToString:self.hotelBookController.hotelLastTimeLabel.text]) {//12点
		self.nowSelectRow = 11;
	}
	
	//滚动列表也显示所先时间
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.nowSelectRow inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrivalTime count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [self.arrivalTime objectAtIndex:indexPath.row];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.highlightedTextColor = [PiosaColorManager themeColor];
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
	self.hotelBookController.hotelLastTimeLabel.text = [self.arrivalTime objectAtIndex:indexPath.row];
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[_arrivalTime release];
	[_hotelBookController release];
    [super dealloc];
}


@end


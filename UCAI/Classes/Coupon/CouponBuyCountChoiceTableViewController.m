//
//  CouponBuyCountChoiceTableViewController.m
//  UCAI
//
//  Created by  on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"
#import "CouponBuyCountChoiceTableViewController.h"


#import "CouponInfoViewController.h"
#import "PiosaFileManager.h"

@implementation CouponBuyCountChoiceTableViewController

@synthesize couponInfoViewController = _couponInfoViewController;

-(void)dealloc{
    [_couponInfoViewController release];
    [super dealloc];
}

#pragma mark - Init

- (CouponBuyCountChoiceTableViewController *)initWithSelectRow:(NSUInteger)selectedRow{
    self = [super initWithStyle:UITableViewStyleGrouped];
    _nowSelectRow = selectedRow;
    return self;
}

- (void)cancelPress{
    CATransition * animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.4;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"reveal";
    animation.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:animation forKey:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)loadView {
    [super loadView];
    self.title = @"选择张数";
    
    self.navigationItem.hidesBackButton = TRUE;
    
    //右铵钮的设置
    UIButton * cancelButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 29)]; 
    NSString *loginOutButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"loginOut_normal" inDirectory:@"RootView"];
    NSString *loginOutButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"loginOut_highlighted" inDirectory:@"RootView"];
    [cancelButton setBackgroundImage:[UIImage imageNamed:loginOutButtonNormalPath] forState:UIControlStateNormal]; 
    [cancelButton setBackgroundImage:[UIImage imageNamed:loginOutButtonHighlightedPath] forState:UIControlStateHighlighted]; 
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
    cancelButton.titleLabel.font=[UIFont systemFontOfSize:14];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelPress) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * cancelBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:cancelButton]; 
    [self.navigationItem setRightBarButtonItem:cancelBarButtonItem];
    [cancelBarButtonItem release];
	[cancelButton release];
    
    //设置背景图片
    NSString *bgPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"background" inDirectory:@"CommonView"];
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bgPath]];
    bgImageView.frame = CGRectMake(0, 0, 320, 416);
	[self.tableView setBackgroundView:bgImageView];
	[bgImageView release];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.highlightedTextColor = [PiosaColorManager themeColor];
    cell.textLabel.text = [NSString stringWithFormat:@"%d",indexPath.row+1];
    
    //设置cell的附件类型
	if (indexPath.row == _nowSelectRow) {
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.couponInfoViewController.couponBuyCount = indexPath.row+1;
    [self.couponInfoViewController.couponBuyCountChoiceButton setTitle:[NSString stringWithFormat:@"%d",indexPath.row+1] forState:UIControlStateNormal];
    
    CATransition * animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.4;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"reveal";
    animation.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:animation forKey:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
}

@end

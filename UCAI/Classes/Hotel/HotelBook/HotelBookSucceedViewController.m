//
//  HotelBookSucceedTableViewController.m
//  UCAI
//
//  Created by  on 11-12-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HotelBookSucceedViewController.h"

#import "PiosaFileManager.h"

@implementation HotelBookSucceedViewController

@synthesize hotelOrderID = _hotelOrderID;
@synthesize hotelOrderPrice = _hotelOrderPrice;

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

- (void)phoneCall{
    if ([[UIApplication  sharedApplication] canOpenURL:[NSURL  URLWithString:@"tel://4006840060"]]) {
        UIActionSheet * phoneActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拨打电话40068 40060" otherButtonTitles:nil, nil];
        phoneActionSheet.delegate = self;
        [phoneActionSheet showInView:[UIApplication sharedApplication].keyWindow];
		[phoneActionSheet release];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    //设置导航栏标题
	self.title = @"预订结果";
    
    self.navigationItem.hidesBackButton = YES;
    
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
    
    UITableView * resultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 386) style:UITableViewStyleGrouped];
    resultTableView.dataSource = self;
    resultTableView.delegate = self;
    resultTableView.backgroundColor = [UIColor clearColor];
    resultTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:resultTableView];
    [resultTableView release];
    
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
    [bottomView release];}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{   
    [self.hotelOrderID release];
    [self.hotelOrderPrice release];
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch (indexPath.section) {
        case 0:{
            UIImageView * sucessView = [[UIImageView alloc] initWithFrame:CGRectMake(45, 20, 28, 28)];
            NSString *sucessPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"sucess" inDirectory:@"CommonView"];
			sucessView.image = [UIImage imageNamed:sucessPath];
			[cell.contentView addSubview:sucessView];
			[sucessView release];
			
			UILabel * sucessLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 15, 165, 40)];
			sucessLabel.backgroundColor = [UIColor clearColor];
            sucessLabel.font = [UIFont boldSystemFontOfSize:22];
			sucessLabel.textColor = [UIColor redColor];
			sucessLabel.text = @"恭喜您预订成功!";
			[cell.contentView addSubview:sucessLabel];
			[sucessLabel release];
			
			UILabel * aramLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 55, 280, 60)];
			aramLabel.backgroundColor = [UIColor clearColor];
			aramLabel.lineBreakMode = UILineBreakModeWordWrap;
			aramLabel.font = [UIFont boldSystemFontOfSize:15];
			aramLabel.numberOfLines = 0;
            aramLabel.textColor = [UIColor grayColor];
			aramLabel.text = @"请记住订单信息，以方便您咨询，您可进入“我的订单”进行订单查询\n客户服务热线40068-40060";
			[cell.contentView addSubview:aramLabel];
			[aramLabel release];
        }
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                {
                    UILabel * orderNOShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 22)];
                    orderNOShowLabel.backgroundColor = [UIColor clearColor];
                    orderNOShowLabel.font = [UIFont systemFontOfSize:16];
                    orderNOShowLabel.text = @"订单编号:";
                    [cell.contentView addSubview:orderNOShowLabel];
                    [orderNOShowLabel release];
                    
                    UILabel * orderNOContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 270, 22)];
                    orderNOContentLabel.backgroundColor = [UIColor clearColor];
                    orderNOContentLabel.textColor = [UIColor redColor];
                    orderNOContentLabel.font = [UIFont systemFontOfSize:16];
                    orderNOContentLabel.text = self.hotelOrderID;
                    [cell.contentView addSubview:orderNOContentLabel];
                    [orderNOContentLabel release];
                }
                    break; 
                case 1:
                {
                    UILabel * orderNOShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 22)];
                    orderNOShowLabel.backgroundColor = [UIColor clearColor];
                    orderNOShowLabel.font = [UIFont systemFontOfSize:16];
                    orderNOShowLabel.text = @"订单总额:";
                    [cell.contentView addSubview:orderNOShowLabel];
                    [orderNOShowLabel release];
                    
                    UILabel * orderNOContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 270, 22)];
                    orderNOContentLabel.backgroundColor = [UIColor clearColor];
                    orderNOContentLabel.textColor = [UIColor redColor];
                    orderNOContentLabel.font = [UIFont systemFontOfSize:16];
                    orderNOContentLabel.text = [NSString stringWithFormat:@"¥%@",self.hotelOrderPrice];
                    [cell.contentView addSubview:orderNOContentLabel];
                    [orderNOContentLabel release];
                }
                    break;
            }
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    if (indexPath.section == 0) {
        return 132;
    } else {
        return 44;
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

@end

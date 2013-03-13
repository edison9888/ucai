//
//  FlightBookSucceedViewController.m
//  UCAI
//
//  Created by  on 12-2-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FlightBookSucceedViewController.h"
#import "FlightBookSucceedCouponChoiceViewController.h"

#import "AllinTelPayViewController.h"

#import "FlightCustomer.h"
#import "CommonTools.h"
#import "PiosaFileManager.h"
#import "StaticConf.h"

@implementation FlightBookSucceedViewController

@synthesize customers = _customers;

@synthesize flightOrderID = _flightOrderID;
@synthesize flightOrderPrice = _flightOrderPrice;

@synthesize couponPriceAmount = _couponPriceAmount;
@synthesize couponPriceAmountContentLabel = _couponPriceAmountContentLabel;
@synthesize couponUsedShowLabel = _couponUsedShowLabel;
@synthesize couponUsedContentLabel = _couponUsedContentLabel;
@synthesize couponUsedIDs = _couponUsedIDs;

@synthesize flightOrderInfoTableView = _flightOrderInfoTableView;

@synthesize payButton = _payButton;

@synthesize modelBGView = _modelBGView;
@synthesize modelButtonView = _modelButtonView;

- (void)dealloc
{   
    [self.customers release];
    
    [self.couponPriceAmount release];
    [self.couponPriceAmountContentLabel release];
    [self.couponUsedShowLabel release];
    [self.couponUsedContentLabel release];
    [self.couponUsedIDs release];
    
    [self.flightOrderID release];
    [self.flightOrderPrice release];
    
    [self.flightOrderInfoTableView release];
    
    [self.payButton release];
    [self.modelBGView release];
    [self.modelButtonView release];
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

- (void)phoneCall{
    if ([[UIApplication  sharedApplication] canOpenURL:[NSURL  URLWithString:@"tel://4006840060"]]) {
        UIActionSheet * phoneActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拨打电话40068 40060" otherButtonTitles:nil, nil];
        phoneActionSheet.delegate = self;
        [phoneActionSheet showInView:[UIApplication sharedApplication].keyWindow];
		[phoneActionSheet release];
    }
}

- (void)payButtonPress{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.modelBGView.alpha = 1;
    self.modelButtonView.frame = CGRectMake(0, 316, 320, 100);
    [UIView commitAnimations];
}

- (void)aLiPay{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.modelBGView.alpha = 0;
    self.modelButtonView.frame = CGRectMake(0, 416, 320, 80);
    [UIView commitModalAnimations];
    
    NSLog(@"%@",[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@%@%@",FLIGHT_ORDER_ALIPAY_ADDRESS,self.flightOrderID,@"&couponID=",self.couponUsedIDs]]);
    [[UIApplication  sharedApplication] openURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@%@%@",FLIGHT_ORDER_ALIPAY_ADDRESS,self.flightOrderID,@"&couponID=",self.couponUsedIDs]]];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)aLlinTelPay{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.modelBGView.alpha = 0;
    self.modelButtonView.frame = CGRectMake(0, 416, 320, 80);
    [UIView commitModalAnimations];
    
    float allinTelPayPrice = [self.flightOrderPrice floatValue]-[[self.couponPriceAmount substringFromIndex:1] floatValue];
    AllinTelPayViewController *allinTelPayViewController = [[AllinTelPayViewController alloc] initWithOrderID:self.flightOrderID andCouponPrice:[NSString stringWithFormat:@"%.2f",allinTelPayPrice] andType:@"1"];
    [self.navigationController pushViewController:allinTelPayViewController animated:YES];
    [allinTelPayViewController release];
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
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
    self.flightOrderInfoTableView = resultTableView;
    [self.view addSubview:resultTableView];
    [resultTableView release];
    
    UIButton *payButton = [[UIButton alloc] init];
    NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
        [payButton setFrame:CGRectMake(10, 400, 300, 40)];
        self.flightOrderInfoTableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    } else {
        [payButton setFrame:CGRectMake(10, 260, 300, 40)];
    }
    
    [payButton setTitle:@"前往支付" forState:UIControlStateNormal];
    [payButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
    [payButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
    [payButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
    [payButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
    [payButton addTarget:self action:@selector(payButtonPress) forControlEvents:UIControlEventTouchUpInside];
    self.payButton = payButton;
    [self.flightOrderInfoTableView addSubview:payButton];
    [payButton release];
    
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
    [bottomView release];
    
    ModelBackgroundView *modelBGView = [[ModelBackgroundView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    modelBGView.delegate = self;
    modelBGView.alpha = 0;
    self.modelBGView = modelBGView;
    [self.view addSubview:modelBGView];
    [modelBGView release];
    
    UIView *modelButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 416, 320, 100)];
    
    NSString *modelBottomButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"modelBottomButton_normal" inDirectory:@"CommonView/ModelBottomButton"];
    NSString *modelBottomButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"modelBottomButton_highlighted" inDirectory:@"CommonView/ModelBottomButton"];
    
    UIButton *aliWapPayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [aliWapPayButton setBackgroundImage:[UIImage imageNamed:modelBottomButtonNormalPath] forState:UIControlStateNormal];
    [aliWapPayButton setBackgroundImage:[UIImage imageNamed:modelBottomButtonHighlightedPath] forState:UIControlStateHighlighted];
    [aliWapPayButton addTarget:self action:@selector(aLiPay) forControlEvents:UIControlEventTouchUpInside];
    UILabel *aliWapPayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 40)];
    aliWapPayLabel.backgroundColor = [UIColor clearColor];
    aliWapPayLabel.text = @"支付宝(交易限额¥0.1~¥5000)";
    [aliWapPayButton addSubview:aliWapPayLabel];
    [aliWapPayLabel release];
    [modelButtonView addSubview:aliWapPayButton];
    [aliWapPayButton release];
    
    UIButton *allinTelPayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, 320, 50)];
    [allinTelPayButton setBackgroundImage:[UIImage imageNamed:modelBottomButtonNormalPath] forState:UIControlStateNormal];
    [allinTelPayButton setBackgroundImage:[UIImage imageNamed:modelBottomButtonHighlightedPath] forState:UIControlStateHighlighted];
    [allinTelPayButton addTarget:self action:@selector(aLlinTelPay) forControlEvents:UIControlEventTouchUpInside];
    UILabel *allinTelPayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 40)];
    allinTelPayLabel.backgroundColor = [UIColor clearColor];
    allinTelPayLabel.text = @"电话支付(交易限额¥100~¥5000)";
    [allinTelPayButton addSubview:allinTelPayLabel];
    [allinTelPayLabel release];
    [modelButtonView addSubview:allinTelPayButton];
    [allinTelPayButton release];
    
    self.modelButtonView = modelButtonView;
    [self.view addSubview:modelButtonView];
    [modelButtonView release];
    
    self.couponPriceAmount = @"¥0.0";
    
    for (FlightCustomer * customer in self.customers) {
        if ([@"1" isEqualToString:customer.customerType]) {
            _adultCount++;
        }
    }
}

#pragma mark -
#pragma mark ModelBackgroundView Delegate Methods

- (void) touchDownForCancel{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.modelBGView.alpha = 0;
    self.modelButtonView.frame = CGRectMake(0, 416, 320, 80);
    [UIView commitAnimations];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    
    if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
        return 3;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if(section == 1){
        return 2;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", indexPath.row, indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
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
                
                UILabel * aramLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 55, 280, 80)];
                aramLabel.backgroundColor = [UIColor clearColor];
                aramLabel.lineBreakMode = UILineBreakModeWordWrap;
                aramLabel.font = [UIFont boldSystemFontOfSize:14];
                aramLabel.numberOfLines = 4;
                aramLabel.textColor = [UIColor grayColor];
                aramLabel.text = @"请在20分钟内完成支付。记住订单信息，以方便您咨询，也可进入\"我的订单\"进行查询、支付等操作。\n客户服务热线40068-40060";
                [cell.contentView addSubview:aramLabel];
                [aramLabel release];
            }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
                        orderNOContentLabel.textColor = [UIColor grayColor];
                        orderNOContentLabel.font = [UIFont systemFontOfSize:16];
                        orderNOContentLabel.text = self.flightOrderID;
                        [cell.contentView addSubview:orderNOContentLabel];
                        [orderNOContentLabel release];
                        
                        NSString *tableViewCellTopNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_top_normal" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellTopNormalPath]] autorelease];
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
                        orderNOContentLabel.text = [NSString stringWithFormat:@"¥%@",self.flightOrderPrice];
                        [cell.contentView addSubview:orderNOContentLabel];
                        [orderNOContentLabel release];
                        
                        NSString *tableViewCellBottomNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_normal" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomNormalPath]] autorelease];
                    }
                        break;
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
                
            case 2:
                switch (indexPath.row) {
                    case 0:{
                        UILabel * infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 280, 35)];
                        infoLabel.backgroundColor = [UIColor clearColor];
                        infoLabel.textColor = [UIColor grayColor];
                        infoLabel.font = [UIFont systemFontOfSize:14];
                        infoLabel.lineBreakMode = UILineBreakModeWordWrap;
                        infoLabel.numberOfLines = 0;
                        infoLabel.text = @"如果您有优惠劵，可使用优惠劵享受相应的优惠(每张成人票可使用一张)";
                        [cell.contentView addSubview:infoLabel];
                        [infoLabel release];
                        
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        NSString *tableViewCellTopNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_top_normal" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellTopNormalPath]] autorelease];
                    }
                        break;
                    case 1:
                    {
                        UILabel * couponUsedShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 80, 20)];
                        couponUsedShowLabel.backgroundColor = [UIColor clearColor];
                        couponUsedShowLabel.font = [UIFont systemFontOfSize:16];
                        couponUsedShowLabel.text = @"    已使用:";
                        self.couponUsedShowLabel = couponUsedShowLabel;
                        [cell.contentView addSubview:couponUsedShowLabel];
                        [couponUsedShowLabel release];
                        
                        UILabel * couponUsedContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 10, 180, 20)];
                        couponUsedContentLabel.backgroundColor = [UIColor clearColor];
                        couponUsedContentLabel.textColor = [UIColor grayColor];
                        couponUsedContentLabel.lineBreakMode = UILineBreakModeWordWrap;
                        couponUsedContentLabel.numberOfLines = 0;
                        couponUsedContentLabel.font = [UIFont systemFontOfSize:16];
                        self.couponUsedContentLabel = couponUsedContentLabel;
                        [cell.contentView addSubview:self.couponUsedContentLabel];
                        [couponUsedContentLabel release];
                        
                        NSString *accessoryDisclosureIndicatorPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"accessoryDisclosureIndicator" inDirectory:@"CommonView/TableViewCell"];
                        UIImageView * accessoryViewTemp1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryDisclosureIndicatorPath]];
                        accessoryViewTemp1.frame = CGRectMake(0, 0, 10, 16);
                        cell.accessoryView = accessoryViewTemp1;
                        [accessoryViewTemp1 release];
                        
                        NSString *tableViewCellCenterNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_normal" inDirectory:@"CommonView/TableViewCell"];
                        NSString *tableViewCellCenterHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_highlighted" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterNormalPath]] autorelease];
                        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterHighlightedPath]] autorelease];
                    }
                        break;
                    case 2:
                    {
                        UILabel * couponPriceAmountShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 80, 20)];
                        couponPriceAmountShowLabel.backgroundColor = [UIColor clearColor];
                        couponPriceAmountShowLabel.font = [UIFont systemFontOfSize:16];
                        couponPriceAmountShowLabel.text = @"为您优惠:";
                        [cell.contentView addSubview:couponPriceAmountShowLabel];
                        [couponPriceAmountShowLabel release];
                        
                        UILabel * couponPriceAmountContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 10, 180, 20)];
                        couponPriceAmountContentLabel.backgroundColor = [UIColor clearColor];
                        couponPriceAmountContentLabel.textColor = [UIColor redColor];
                        couponPriceAmountContentLabel.font = [UIFont systemFontOfSize:16];
                        self.couponPriceAmountContentLabel = couponPriceAmountContentLabel;
                        [cell.contentView addSubview:self.couponPriceAmountContentLabel];
                        [couponPriceAmountContentLabel release];
                        
                        NSString *tableViewCellBottomNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_normal" inDirectory:@"CommonView/TableViewCell"];
                        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomNormalPath]] autorelease];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                }
                break;
        }
    }
    
    if (indexPath.section == 2&& indexPath.row == 2) {
        self.couponPriceAmountContentLabel.text = self.couponPriceAmount;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    if (indexPath.section == 0) {
        return 138;
    } else if([indexPath section] == 2 && [indexPath row] == 1){//第三区第二行
        int numberOfLine = [CommonTools calculateRowCountForUTF8:self.couponUsedContentLabel.text bytes:20];
        if (numberOfLine>1) {
            return 22+20*numberOfLine;
        } else {
            return 44;
        }
    } else {
        return 44;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[[UIView alloc] init] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[[UIView alloc] init] autorelease];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2 && indexPath.row == 1) {
        FlightBookSucceedCouponChoiceViewController *flightBookSucceedCouponChoiceViewController = [[FlightBookSucceedCouponChoiceViewController alloc] initWithMaxUsedCount:_adultCount];
        flightBookSucceedCouponChoiceViewController.flightBookSucceedViewController = self;
        [self.navigationController pushViewController:flightBookSucceedCouponChoiceViewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

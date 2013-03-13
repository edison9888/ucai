//
//  HotelGuestAddController.m
//  JingDuTianXia
//
//  Created by Piosa on 11-11-15.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HotelGuestAddController.h"
#import "HotelBookController.h"
#import "CommonTools.h"
#import "HotelGuest.h"
#import "PiosaFileManager.h"

@implementation HotelGuestAddController

@synthesize guestNameField = _guestNameField;
@synthesize guestPhoneField = _guestPhoneField;
@synthesize hotelBookController = _hotelBookController;

#pragma mark -
#pragma mark custom

//响应文本输入框的完成按钮操作，用于换行
- (IBAction)textFieldDone:(id)sender{
	UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
	UITableView *table = (UITableView *)[cell superview];
	NSIndexPath *textFieldIndexPath = [table indexPathForCell:cell];
	NSUInteger row = [textFieldIndexPath row];
	row++;
	if (row >= 2) {
		row = 0;
	}
	NSUInteger newIndex[] = {0,row};
	NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
	UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:newPath];
	[newPath release];
	UITextField *nextField = nil;
	for (UIView *oneView in nextCell.contentView.subviews) {
		if ([oneView isMemberOfClass:[UITextField class]]) {
			nextField = (UITextField *)oneView;
		}
	}
	[nextField becomeFirstResponder];
}

//返回按钮的响应方法
- (void) back{
	CATransition *transition = [CATransition animation];
	transition.delegate = self; 
	transition.duration = 0.5f;//间隔时间
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];//动画的开始与结束的快慢
	transition.type = kCATransitionReveal; // 各种动画效果
	transition.subtype = kCATransitionFromBottom;// 动画方向
	[self.navigationController.view.layer addAnimation:transition forKey:nil];
	
	[self.navigationController popViewControllerAnimated:NO];
}

//保存按钮的响应方法
- (void) saveGuest{
	
	int check = [self checkAndSaveIn];
	
	NSString * showMes = nil;
	switch (check) {
		case 1:
			showMes = @"您似乎还未输入旅客姓名";
			break;
		case 2:
			showMes = @"您似乎还未输入旅客手机号";
			break;
		case 3:
			showMes = @"请您输入有效的手机号码";
			break;
	}
	
	if (check!=0) {
		UIAlertView *showAlert = [[[UIAlertView alloc] initWithTitle:nil message:showMes 
															delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
		[showAlert show];
	} else {
		HotelGuest * hotelGuest = [[HotelGuest alloc] init];
		hotelGuest.guestName = self.guestNameField.text;
		hotelGuest.guestPhone = self.guestPhoneField.text;
		[self.hotelBookController.guests addObject:hotelGuest];
		[hotelGuest release];
		
		CATransition *transition = [CATransition animation];
		transition.delegate = self; 
		transition.duration = 0.5f;//间隔时间
		transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];//动画的开始与结束的快慢
		transition.type = kCATransitionReveal; // 各种动画效果
		transition.subtype = kCATransitionFromBottom;// 动画方向
		[self.navigationController.view.layer addAnimation:transition forKey:nil];
		
		[self.navigationController popViewControllerAnimated:NO];
	}
}

//检查并保存所输入的登陆帐号与登陆密码是否合法
//0-合法;
//1-未输入姓名;
//2-未输入手机号码;
//3-未输入密码;
- (int) checkAndSaveIn {
	if (self.guestNameField.text == nil || [@"" isEqualToString:[self.guestNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
		return 1;
	}
	
	if (self.guestPhoneField.text == nil) {
		return 2;
	} else if ([CommonTools verifyPhoneFormat:self.guestPhoneField.text]) {
		return 0;
	} else {
		return 3;
	}
}

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"新增旅客";
    }
    return self;
}



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	//保存旅客铵钮的设置
	UIBarButtonItem *saveGuestButton = [[UIBarButtonItem alloc]
											 initWithTitle:@"保存" 
											 style:UIBarButtonItemStyleDone
											 target:self 
											 action:@selector(saveGuest)];
	self.navigationItem.rightBarButtonItem = saveGuestButton;
	[saveGuestButton release];
	
	//保存旅客铵钮的设置
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
										initWithTitle:@"返回" 
										style:UIBarButtonItemStylePlain
										target:self 
										action:@selector(back)];
	[self.navigationItem setLeftBarButtonItem:backButton];
	[backButton release];
	

    //设置背景图片
    NSString *bgPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"background" inDirectory:@"CommonView"];
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bgPath]];
    bgImageView.frame = CGRectMake(0, 0, 320, 416);
	[self.tableView setBackgroundView:bgImageView];
	[bgImageView release];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0 );
	
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	//在视图消失前，隐藏起键盘
	[self.guestNameField resignFirstResponder];
	[self.guestPhoneField resignFirstResponder];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %d %d",indexPath.section,indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		switch (indexPath.row) {
			case 0:{
				UILabel * contractShowLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 80, 30)];
                contractShowLabel1.backgroundColor = [UIColor clearColor];
				contractShowLabel1.text = @"姓     名:";
				[cell.contentView addSubview:contractShowLabel1];
				[contractShowLabel1 release];
				
				UITextField * contractInputTextField1 = [[UITextField alloc] initWithFrame:CGRectMake(100, 6, 180, 30)];
				contractInputTextField1.borderStyle = UITextBorderStyleRoundedRect;
				contractInputTextField1.clearButtonMode = UITextFieldViewModeWhileEditing;
				contractInputTextField1.returnKeyType = UIReturnKeyNext;
				[contractInputTextField1 addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
				self.guestNameField = contractInputTextField1;
                [self.guestNameField becomeFirstResponder];
				[cell.contentView addSubview:self.guestNameField];
				[contractInputTextField1 release];
			}
				break;
			case 1:{
				UILabel * contractShowLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 80, 30)];
                contractShowLabel2.backgroundColor = [UIColor clearColor];
				contractShowLabel2.text = @"手     机:";
				[cell.contentView addSubview:contractShowLabel2];
				[contractShowLabel2 release];
				
				UITextField * contractInputTextField2 = [[UITextField alloc] initWithFrame:CGRectMake(100, 6, 180, 30)];
				contractInputTextField2.borderStyle = UITextBorderStyleRoundedRect;
				contractInputTextField2.clearButtonMode = UITextFieldViewModeWhileEditing;
				contractInputTextField2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
				contractInputTextField2.returnKeyType = UIReturnKeyNext;
				self.guestPhoneField = contractInputTextField2;
				[contractInputTextField2 addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
				[cell.contentView addSubview:self.guestPhoneField];
				[contractInputTextField2 release];
			}
				break;
		}
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    self.guestNameField = nil;
	self.guestPhoneField = nil;
}


- (void)dealloc {
	[_guestNameField release];
	[_guestPhoneField release];
	[_hotelBookController release];
    [super dealloc];
}


@end


//
//  MemberPasswordBackController.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-9.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "MemberPasswordBackController.h"
#import "MemberPasswordBackResponse.h"
#import "ResponseParser.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "StaticConf.h"
#import "CommonTools.h"

#import "PiosaFileManager.h"

#define kHUDhiddenTag 101 //只需要消失提交框
#define kHUDhiddenAndPopTag 102 //需要在提交框消失后退出视图

#define kPasswordBackCellLabelTag 201 //标签tag
#define kPasswordBackCellTextFieldTag 202 //输入文本tag

@implementation MemberPasswordBackController

@synthesize fieldLabels;
@synthesize memberName;
@synthesize registerPhone;

- (void)viewDidUnload {
    self.fieldLabels = nil;
	self.memberName = nil;
	self.registerPhone = nil;
}

- (void)dealloc {
	[self.fieldLabels release];
	[self.memberName release];
	[self.registerPhone release];
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


- (void)sendPassword{
    for (UIView *oneView in self.tableView.subviews) {
		if ([oneView isMemberOfClass:[UITableViewCell class]]) {
			UITableViewCell *registerCell = (UITableViewCell *)oneView;
			UITextField *textField = (UITextField *)[registerCell viewWithTag:kPasswordBackCellTextFieldTag];
			[textField resignFirstResponder];
		}
	}
    
	int check = [self checkAndSaveIn];
	
	NSString * showMes = nil;
    NSString * deShowMes = nil;
	switch (check) {
		case 1:
			showMes = @"您似乎还未输入用户名";
			break;
		case 2:
			showMes = @"用户名不符合规则(长度3-20)";
            deShowMes = @"请重新输入";
			break;
		case 3:
			showMes = @"您似乎还未输入手机号码";
			break;
		case 4:
			showMes = @"请您输入有效的手机号码";
			break;
	}
	
	if (check != 0) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        hud.bgRGB = [PiosaColorManager progressColor];
        [self.navigationController.view addSubview:hud];
        hud.delegate = self;
        NSString *exclamationImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"exclamation" inDirectory:@"CommonView/ProgressView"];
        UIImageView *exclamationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:exclamationImagePath]];
        exclamationImageView.frame = CGRectMake(0, 0, 37, 37);
        hud.customView = exclamationImageView;
        [exclamationImageView release];
        //hud.opacity = 1.0;
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = showMes;
        hud.detailsLabelText = deShowMes;
        hud.tag = kHUDhiddenTag;
        [hud show:YES];
        [hud hide:YES afterDelay:2];
	} else {
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _hud.bgRGB = [PiosaColorManager progressColor];
        [self.navigationController.view addSubview:_hud];
        _hud.delegate = self;
        _hud.minSize = CGSizeMake(135.f, 135.f);
        _hud.labelText = @"提交中...";
        _hud.tag = kHUDhiddenTag;
        [_hud show:YES];
		
		NSString *url = MEMBER_PASSWORD_BACK_ADDRESS;
		ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: url]] autorelease];
		[req addRequestHeader:@"API-Version" value:API_VERSION];
		req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
		[req appendPostData:[self generateMemberPasswordBackRequestPostXMLData]];
		[req setDelegate:self];
		[req startAsynchronous]; // 执行异步post
		[url release];
	}
	
}

//检查并保存所输入的找回密码所用用户资料是否合法
//0-合法;
//1-未输入用户名;
//2-用户名不符合规则(长度3-20)
//3-未输入手机号码;
//4-未输入有效的手机号码;
- (int) checkAndSaveIn {
	
	UITableViewCell *registerCell = nil;
	for (UIView *oneView in self.tableView.subviews) {
		if ([oneView isMemberOfClass:[UITableViewCell class]]) {
			registerCell = (UITableViewCell *)oneView;
			
			NSIndexPath *textFieldIndexPath = [self.tableView indexPathForCell:registerCell];
			NSUInteger row = [textFieldIndexPath row];
			
			UITextField *textField = (UITextField *)[registerCell viewWithTag:kPasswordBackCellTextFieldTag];
			if (textField.text!=nil) {
				switch (row) {
					case 0:
						self.memberName = [[NSString alloc] initWithString:textField.text];
						break;
					case 1:
						self.registerPhone = [[NSString alloc] initWithString:textField.text];
						break;
				}
			}
		}
	}
	
	if (self.memberName == nil||[self.memberName length]==0) {
		return 1;
	} else {
		if ([self.memberName length]<3||[self.memberName length]>20) {
			return 2;
		}
	}
	
	if (self.registerPhone == nil||[self.registerPhone length]==0) {
		return 3;
	} else {
		if (![CommonTools verifyPhoneFormat:self.registerPhone]) {
			return 4;
		}
	}
	
	return 0;
}

- (NSData*)generateMemberPasswordBackRequestPostXMLData{
	//编辑用户注册请求的xml数据
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"registerName" stringValue:self.memberName]];
	[conditionElement addChild:[GDataXMLNode elementWithName:@"phone" stringValue:self.registerPhone]];
    [requestElement addChild:conditionElement];
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    
    NSData *xmlData = document.XMLData;
	return xmlData;
	
}

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应 : 但可能是错误响应, 如 404，或查询结果为空，则不跳转到下一个机票展示页面
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);
    
    // 关闭加载框
    [_hud hide:YES];
    if ((responseString != nil) && [responseString length] > 0) {
        
		MemberPasswordBackResponse *memberPasswordBackResponse = [ResponseParser loadMemberPasswordBackResponse:[request responseData]];
		
		if (memberPasswordBackResponse.result_code == nil || [memberPasswordBackResponse.result_code length] == 0 || [memberPasswordBackResponse.result_code intValue] != 0) { 
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            hud.bgRGB = [PiosaColorManager progressColor];
            [self.navigationController.view addSubview:hud];
            hud.delegate = self;
            hud.minSize = CGSizeMake(135.f, 135.f);
            NSString *exclamationImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"exclamation" inDirectory:@"CommonView/ProgressView"];
            UIImageView *exclamationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:exclamationImagePath]];
            exclamationImageView.frame = CGRectMake(0, 0, 37, 37);
            hud.customView = exclamationImageView;
            [exclamationImageView release];
            hud.opacity = 1.0;
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = memberPasswordBackResponse.result_message;
            hud.tag = kHUDhiddenTag;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
		} else {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            hud.bgRGB = [PiosaColorManager progressColor];
            [self.navigationController.view addSubview:hud];
            hud.delegate = self;
            hud.minSize = CGSizeMake(135.f, 135.f);
            NSString *tickImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"tick" inDirectory:@"CommonView/ProgressView"];
            UIImageView *tickImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:tickImagePath]];
            tickImageView.frame = CGRectMake(0, 0, 37, 37);
            hud.customView = tickImageView;
            [tickImageView release];
            hud.opacity = 1.0;
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"请求已接收,请留意手机短信!";
            hud.tag = kHUDhiddenAndPopTag;
            [hud show:YES];
            [hud hide:YES afterDelay:4];
		}
    }
}

// 网络无响应
- (void)requestFailed:(ASIFormDataRequest *)request
{
	// 提示用户打开网络联接
    NSString *badFaceImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"badFace" inDirectory:@"CommonView/ProgressView"];
    UIImageView *badFaceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:badFaceImagePath]];
    badFaceImageView.frame = CGRectMake(0, 0, 37, 37);
    _hud.customView = badFaceImageView;
    [badFaceImageView release];
	_hud.mode = MBProgressHUDModeCustomView;
	_hud.labelText = @"网络连接失败啦";
    [_hud hide:YES afterDelay:3];
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"找回密码";
    
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
	[self.tableView setBackgroundView:bgImageView];
	[bgImageView release];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 85, 300, 80)];
	label.backgroundColor = [UIColor clearColor];
	label.lineBreakMode = UILineBreakModeWordWrap; 
	label.numberOfLines = 0;
	label.textColor = [UIColor orangeColor];
	label.font = [UIFont boldSystemFontOfSize:14];
	label.text = @"    我们将通过短信方式将密码发送至您的注册手机中，收到密码后请及时进入“会员中心”修改您的登陆密码.";
	[self.tableView addSubview:label];
	[label release];
    
    UIButton *sendPasswordButton = [[UIButton alloc] init];
	[sendPasswordButton setFrame:CGRectMake(10, 155, 300, 40)];
	[sendPasswordButton setTitle:@"发送密码" forState:UIControlStateNormal];
	[sendPasswordButton setBackgroundImage:[UIImage imageNamed:@"bigButton_highlighted.png"] forState:UIControlStateNormal];
	[sendPasswordButton setBackgroundImage:[UIImage imageNamed:@"bigButton_highlighted.png"] forState:UIControlStateHighlighted];
	[sendPasswordButton addTarget:self action:@selector(sendPassword) forControlEvents:UIControlEventTouchUpInside];
	[self.tableView addSubview:sendPasswordButton];
	[sendPasswordButton release];
	
	NSArray *array = [[NSArray alloc] initWithObjects:@"用户名",@"注册手机",nil];
	self.fieldLabels = array;
	[array release];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	//每次一进入登陆画面，都使帐号的输入框成为第一响应者，用以始终弹出输入框
	NSUInteger newIndex[] = {0,0};
	NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
	UITableViewCell *firstCell = [self.tableView cellForRowAtIndexPath:newPath];
	[newPath release];
	UITextField *firstField = nil;
	for (UIView *oneView in firstCell.contentView.subviews) {
		if ([oneView isMemberOfClass:[UITextField class]]) {
			firstField = (UITextField *)oneView;
		}
	}
	[firstField becomeFirstResponder];
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
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
		label.tag = kPasswordBackCellLabelTag;
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont boldSystemFontOfSize:16];
		[cell.contentView addSubview:label];
		[label release];
		
		UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
		textField.tag = kPasswordBackCellTextFieldTag;
		//判断设置第一二个表格单元的属性
		if ([indexPath row] == 0) {
			textField.placeholder = @"3-20位的注册名";
		} else {
			textField.placeholder = @"必填";
			textField.keyboardType = UIKeyboardTypePhonePad;
		}
		
        textField.font = [UIFont systemFontOfSize:16];
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		textField.clearsOnBeginEditing = NO;
		textField.returnKeyType = UIReturnKeyNext;
		[textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
		[cell.contentView addSubview:textField];
    }
    
	NSUInteger row = [indexPath row];
	
    //设置表格中标签的展现
	UILabel *label = (UILabel *)[cell viewWithTag:kPasswordBackCellLabelTag];
    label.backgroundColor = [UIColor clearColor];
	label.text = [fieldLabels objectAtIndex:row];
    
	//设置表格单元选中的格式为无
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    if (hud.tag == kHUDhiddenAndPopTag) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    [hud release];
	hud = nil;
}


@end


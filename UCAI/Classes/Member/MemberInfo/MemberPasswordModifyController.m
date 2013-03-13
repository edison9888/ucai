//
//  MemberPasswordModifyController.m
//  JingDuTianXia
//
//  Created by Piosa on 11-10-17.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "MemberPasswordModifyController.h"
#import "PiosaFileManager.h"
#import "ResponseParser.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "StaticConf.h"
#import "CommonTools.h"
#import "MemberPasswordModifyResponse.h"

#define passwordModifyCellLabelTag 1 //标签tag
#define passwordModifyCellTextFieldTag 2; //输入文本tag

#define kHUDhiddenTag 101 //只需要消失提交框
#define kHUDhiddenAndPopTag 102 //需要在提交框消失后退出视图

@implementation MemberPasswordModifyController

@synthesize fieldLabels;
@synthesize oldPassword;
@synthesize modifyPassword;
@synthesize modifyPasswordSecond;

- (void)viewDidUnload {
    self.fieldLabels = nil;
	self.oldPassword = nil;
	self.modifyPassword = nil;
	self.modifyPasswordSecond = nil;
}


- (void)dealloc {
	[self.fieldLabels release];
	[self.oldPassword release];
	[self.modifyPassword release];
	[self.modifyPasswordSecond release];
    [super dealloc];
}

#pragma mark -
#pragma mark custom

//响应文本输入框的完成按钮操作，用于换行
- (IBAction)textFieldDone:(id)sender{
	UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
	UITableView *table = (UITableView *)[cell superview];
	NSIndexPath *textFieldIndexPath = [table indexPathForCell:cell];
	NSUInteger row = [textFieldIndexPath row];
	row++;
	if (row >= 3) {
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

//修改密码按钮的反应方法
- (IBAction)modifyPassword:(id)sender{
    for (UIView *oneView in self.tableView.subviews) {
		if ([oneView isMemberOfClass:[UITableViewCell class]]) {
			UITableViewCell *registerCell = (UITableViewCell *)oneView;
			UITextField *textField = (UITextField *)[registerCell viewWithTag:2];
			[textField resignFirstResponder];
		}
	}
    
	int check = [self checkAndSaveIn];
	
	NSString * showMes = nil;
    NSString * deShowMes = nil;
	switch (check) {
		case 1:
			showMes = @"您似乎还未输入旧密码";
			break;
		case 2:
			showMes = @"您似乎还未输入新密码";
			break;
		case 3:
			showMes = @"新密码不符合规则(长度6-30)";
            deShowMes = @"请重新输入";
			break;
		case 4:
			showMes = @"您似乎还未输入确认密码";
			break;
		case 5:
			showMes = @"两次新密码输入不一致";
            deShowMes = @"请重新输入";
			break;
	}
	
	if (check != 0) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
        hud.bgRGB = [PiosaColorManager progressColor];
        [[UIApplication sharedApplication].keyWindow addSubview:hud];
        hud.delegate = self;
        NSString *exclamationImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"exclamation" inDirectory:@"CommonView/ProgressView"];
        UIImageView *exclamationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:exclamationImagePath]];
        exclamationImageView.frame = CGRectMake(0, 0, 37, 37);
        hud.customView = exclamationImageView;
        [exclamationImageView release];
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
        _hud.labelText = @"修改中...";
        _hud.tag = kHUDhiddenTag;
        [_hud show:YES];
        
        NSString *postData = [[NSString alloc] initWithData:[self generateMemberPasswordModifyRequestPostXMLData] encoding:NSUTF8StringEncoding];
        NSLog(@"requestStart\n");
        NSLog(@"%@\n", postData);
        [postData release];
        
		ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: MEMBER_PASSWORD_MODIFY_ADDRESS]] autorelease];
		[req addRequestHeader:@"API-Version" value:API_VERSION];
		req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
		[req appendPostData:[self generateMemberPasswordModifyRequestPostXMLData]];
		[req setDelegate:self];
		[req startAsynchronous]; // 执行异步post
	}
}

//检查并保存所输入的密码修改是否合法
//0-合法;
//1-未输入旧密码;
//2-未输入新密码;
//3-新密码不符合规则(长度6-30)
//4-未输入确认密码;
//5-确认密码与新密码不一致
- (int) checkAndSaveIn{
	UITableViewCell *registerCell = nil;
	for (UIView *oneView in self.tableView.subviews) {
		if ([oneView isMemberOfClass:[UITableViewCell class]]) {
			registerCell = (UITableViewCell *)oneView;
			
			NSIndexPath *textFieldIndexPath = [self.tableView indexPathForCell:registerCell];
			NSUInteger row = [textFieldIndexPath row];
			
			UITextField *textField = (UITextField *)[registerCell viewWithTag:2];
			if (textField.text!=nil) {
				switch (row) {
					case 0:
						self.oldPassword = [[NSString alloc] initWithString:textField.text];
						break;
					case 1:
						self.modifyPassword = [[NSString alloc] initWithString:textField.text];
						break;
					case 2:
						self.modifyPasswordSecond = [[NSString alloc] initWithString:textField.text];
						break;
				}
			}
		}
	}
	
	if (self.oldPassword == nil||[self.oldPassword length]==0) {
		return 1;
	}
	
	if (self.modifyPassword == nil||[self.modifyPassword length]==0) {
		return 2;
	} else if ([self.modifyPassword length]<6||[self.modifyPassword length]>30){
		return 3;
	}
	
	if (self.modifyPasswordSecond == nil||[self.modifyPasswordSecond length]==0) {
		return 4;
	} else if (![self.modifyPassword isEqualToString:self.modifyPasswordSecond]) {
		return 5;
	}
	return 0;
}

- (NSData*)generateMemberPasswordModifyRequestPostXMLData{
	NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
    
	//编辑用户注册请求的xml数据
	GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
	GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
	[conditionElement addChild:[GDataXMLNode elementWithName:@"memberID" stringValue:[memberDict objectForKey:@"memberID"]]];
	[conditionElement addChild:[GDataXMLNode elementWithName:@"oldPassword" stringValue:[CommonTools aes:self.oldPassword key:@"K14FO23EB32NE41G" iv:@"0A2B4C6D8E1F5793"]]];
	[conditionElement addChild:[GDataXMLNode elementWithName:@"newPassword" stringValue:[CommonTools aes:self.modifyPassword key:@"K14FO23EB32NE41G" iv:@"0A2B4C6D8E1F5793"]]];
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
        
		MemberPasswordModifyResponse *memberPasswordModifyResponse = [ResponseParser loadMemberPasswordModifyResponse:[request responseData]];
		
		if (memberPasswordModifyResponse.result_code == nil || [memberPasswordModifyResponse.result_code length] == 0 || [memberPasswordModifyResponse.result_code intValue] != 0) {
			// 修改失败
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
            hud.labelText = memberPasswordModifyResponse.result_message;
            hud.tag = kHUDhiddenTag;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
		}else {
			//修改成功
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
            hud.labelText = @"您的登陆密码已修改成功!";
            hud.detailsLabelText = @"下次登陆请使用新密码";
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
    [_hud hide:YES afterDelay:3];}


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
	
	self.title = @"登陆密码修改";
	
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
    
    UIButton *modifyPasswordButton = [[UIButton alloc] init];
	[modifyPasswordButton setFrame:CGRectMake(10, 150, 300, 40)];
	[modifyPasswordButton setTitle:@"修    改" forState:UIControlStateNormal];
    [modifyPasswordButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
    [modifyPasswordButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
	[modifyPasswordButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
	[modifyPasswordButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
	[modifyPasswordButton addTarget:self action:@selector(modifyPassword:) forControlEvents:UIControlEventTouchUpInside];
	[self.tableView addSubview:modifyPasswordButton];
	[modifyPasswordButton release];
	
	NSArray *array = [[NSArray alloc] initWithObjects:@"旧密码",@"新密码",@"确认密码",nil];
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
    return 3;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
        label.backgroundColor = [UIColor clearColor];
		label.tag = passwordModifyCellLabelTag;
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont boldSystemFontOfSize:16];
		[cell.contentView addSubview:label];
		[label release];
		
		UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
		textField.tag = passwordModifyCellTextFieldTag;
		//判断设置第一二个表格单元的属性
		if ([indexPath row] == 0) {
			textField.placeholder = @"请输入旧密码";
		} else if([indexPath row] == 1){
			textField.placeholder = @"请输入新密码";
		} else {
			textField.placeholder = @"请再次输入新密码";
		}
        textField.font = [UIFont systemFontOfSize:16];
		textField.secureTextEntry = TRUE;
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		textField.clearsOnBeginEditing = NO;
		textField.returnKeyType = UIReturnKeyNext;
		[textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
		[cell.contentView addSubview:textField];
		[textField release];
    }
    
	NSUInteger row = [indexPath row];
	
    //设置表格中标签的展现
	UILabel *label = (UILabel *)[cell viewWithTag:passwordModifyCellLabelTag];
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


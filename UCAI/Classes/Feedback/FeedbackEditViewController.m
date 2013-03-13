//
//  FeedbackEditViewController.m
//  UCAI
//
//  Created by  on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"
#import "FeedbackEditViewController.h"
#import "FeedbackSearchResponseModel.h"
#import "FeedbackCommitResponseModel.h"
#import "FeedbackListViewController.h"

#import "PiosaFileManager.h"
#import "ResponseParser.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "StaticConf.h"
#import "CommonTools.h"

#define KMaxTextLength 200

#define kContactNameTextFieldTag 101
#define kContactPhoneTextFieldTag 102
#define kContactEmailTextFieldTag 103

#define kOutAlertViewTag 201

@implementation FeedbackEditViewController

@synthesize editScrollView = _editScrollView;
@synthesize questionLengthLabel = _questionLengthLabel;
@synthesize editTextView = _editTextView;
@synthesize textViewPlaceholder = _textViewPlaceholder;
@synthesize suggestCheckBoxButton = _suggestCheckBoxButton;
@synthesize complainCheckBoxButton = _complainCheckBoxButton;
@synthesize contractInfoTableView =_contractInfoTableView;
@synthesize contactNameTextField =_contactNameTextField;
@synthesize contactPhoneTextField =_contactPhoneTextField;
@synthesize contactEmailTextField =_contactEmailTextField;

- (void)dealloc{
    [self.editScrollView release];
    [self.questionLengthLabel release];
    [self.editTextView release];
    [self.textViewPlaceholder release];
    [self.suggestCheckBoxButton release];
    [self.complainCheckBoxButton release];
    [self.contractInfoTableView release];
    [self.contactNameTextField release];
    [self.contactPhoneTextField release];
    [self.contactEmailTextField release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom

- (void)phoneCall{
    if ([[UIApplication  sharedApplication] canOpenURL:[NSURL  URLWithString:@"tel://4006840060"]]) {
        UIActionSheet * phoneActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拨打电话40068 40060" otherButtonTitles:nil, nil];
        phoneActionSheet.delegate = self;
        [phoneActionSheet showInView:[UIApplication sharedApplication].keyWindow];
		[phoneActionSheet release];
    }
}

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

-(void)checkboxClick:(UIButton *)btn
{
	self.suggestCheckBoxButton.selected = !self.suggestCheckBoxButton.selected;
	self.complainCheckBoxButton.selected = !self.complainCheckBoxButton.selected;
}

- (void)commitButtonPress{
    [self.editTextView resignFirstResponder];
    [self.contactNameTextField resignFirstResponder];
    [self.contactPhoneTextField resignFirstResponder];
    [self.contactEmailTextField resignFirstResponder];
    self.editScrollView.contentInset = UIEdgeInsetsZero;
    
    int check = [self checkAndSaveIn];
	
	NSString * showMes = nil;
    NSString * deShowMes = nil;
	switch (check) {
		case 1:
			showMes = @"您似乎还未输入建议或投诉";
			break;
		case 2:
			showMes = @"您似乎还未输入联系姓名";
			break;
		case 3:
			showMes = @"您似乎还未输入手机号码";
			break;
		case 4:
            showMes = @"请输入有效的手机号码";
			break;
		case 5:
			showMes = @"您输入的邮箱地址有误";
            deShowMes = @"正确格式:jindu@hotmail.com";
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
        [hud show:YES];
        [hud hide:YES afterDelay:2];
	}else{
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _hud.bgRGB = [PiosaColorManager progressColor];
        [self.navigationController.view addSubview:_hud];
        _hud.delegate = self;
        _hud.minSize = CGSizeMake(135.f, 135.f);
        _hud.labelText = @"提交中...";
        [_hud show:YES];
        
        _requestType = 1;
        
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: FEEDBACK_SUGGESTION_COMMIT_ADDRESS]];
        request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
        
        NSString *postData = [[NSString alloc] initWithData:[self generateFeedbackCommitRequestPostXMLData] encoding:NSUTF8StringEncoding];
        NSLog(@"requestStart\n");
        NSLog(@"%@\n", postData);
        [postData release];
        
        [request appendPostData:[self generateFeedbackCommitRequestPostXMLData]];
        [request setDelegate:self];
        [request startAsynchronous]; // 执行异步post
        [request release];
    }
}

- (NSData*)generateFeedbackCommitRequestPostXMLData{
    NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
    
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"type" stringValue:self.suggestCheckBoxButton.isSelected?@"2":@"1"]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"content" stringValue:self.editTextView.text]];
    if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
        [conditionElement addChild:[GDataXMLNode elementWithName:@"memberID" stringValue:[memberDict objectForKey:@"memberID"]]];
    } else {
        [conditionElement addChild:[GDataXMLNode elementWithName:@"memberID" stringValue:@""]];
    }
    [conditionElement addChild:[GDataXMLNode elementWithName:@"name" stringValue:self.contactNameTextField.text]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"phone" stringValue:self.contactPhoneTextField.text]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"email" stringValue:self.contactEmailTextField.text==nil?@"":self.contactEmailTextField.text]];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    return document.XMLData;
}


- (void)searchButtonPress{
    [self.editTextView resignFirstResponder];
    [self.contactNameTextField resignFirstResponder];
    [self.contactPhoneTextField resignFirstResponder];
    [self.contactEmailTextField resignFirstResponder];
    self.editScrollView.contentInset = UIEdgeInsetsZero;
    
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.minSize = CGSizeMake(135.f, 135.f);
    _hud.labelText = @"查询中...";
    [_hud show:YES];
    
    _requestType = 2;
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: FEEDBACK_SUGGESTION_QUERY_ADDRESS]];
    request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    
    NSString *postData = [[NSString alloc] initWithData:[self generateFeedbackSearchRequestPostXMLData] encoding:NSUTF8StringEncoding];
    NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    [postData release];
    
    [request appendPostData:[self generateFeedbackSearchRequestPostXMLData]];
    [request setDelegate:self];
    [request startAsynchronous]; // 执行异步post
    [request release];
}

- (NSData*)generateFeedbackSearchRequestPostXMLData{
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
    
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *pageInfoElement = [GDataXMLElement elementWithName:@"pageInfo"];
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"currentPage" stringValue:@"1"]];
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"pageSize" stringValue:@"10"]];
    [requestElement addChild:pageInfoElement];
    
    GDataXMLElement *conditionElement = [GDataXMLElement elementWithName:@"condition"]; 
    [conditionElement addChild:[GDataXMLNode elementWithName:@"memberID" stringValue:[memberDict objectForKey:@"memberID"]]];
    [conditionElement addChild:[GDataXMLNode elementWithName:@"type" stringValue:@"0"]];
    [requestElement addChild:conditionElement];
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:requestElement] autorelease];
    [document setVersion:@"1.0"]; // 设置xml版本为 1.0
    [document setCharacterEncoding:@"UTF-8"]; // 设置xml格式为UTF-8
    return document.XMLData;
}

//检查并保存所输入信息是否合法
//0-合法;
//1-未输入建议或投诉;
//2-未输入联系姓名;
//3-未输入手机号码;
//4-未输入有效手机号码;
//5-所输入电子邮箱格式错误;
- (int)checkAndSaveIn{
    
    if (self.editTextView.text == nil || [self.editTextView.text length]==0) {
		return 1;
	}
    
    if (self.contactNameTextField.text == nil || [self.contactNameTextField.text length]==0) {
		return 2;
	}
    
    if (self.contactPhoneTextField.text == nil || [self.contactPhoneTextField.text length]==0) {
		return 3;
	} else {
		if (![CommonTools verifyPhoneFormat:self.contactPhoneTextField.text]) {
			return 4;
		}
	}
    
    if (self.contactEmailTextField.text!=nil && [self.contactEmailTextField.text length]!=0) {
		if (![CommonTools verifyEmailFormat:self.contactEmailTextField.text]){
			return 5;
		}
	}
    
    return 0;
    
}

- (void)textFieldDone:(UITextField *)textfield{
    NSLog(@"%f",self.editScrollView.contentOffset.y);
    [textfield resignFirstResponder];
    self.editScrollView.contentInset = UIEdgeInsetsZero;
}



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	self.title = @"意见反馈";
	
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
	[self.view addSubview:bgImageView];
	[bgImageView release];
    
    UIScrollView *editScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 386)];
    editScrollView.contentSize = CGSizeMake(320, 405);
    editScrollView.backgroundColor = [UIColor clearColor];
    
    //问题信息
    UIView *questionInfoView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 190)];
    questionInfoView.backgroundColor = [UIColor whiteColor];
    questionInfoView.layer.cornerRadius = 10;
    
    UILabel *questionEditShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
    questionEditShowLabel.backgroundColor = [UIColor clearColor];
    questionEditShowLabel.text = @"问题输入:";
    [questionInfoView addSubview:questionEditShowLabel];
    [questionEditShowLabel release];
    
    UILabel *questionLengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 10, 90, 20)];
    questionLengthLabel.backgroundColor = [UIColor clearColor];
    questionLengthLabel.textAlignment = UITextAlignmentRight;
    questionLengthLabel.text = [NSString stringWithFormat:@"0/%d",KMaxTextLength];
    self.questionLengthLabel = questionLengthLabel;
    [questionInfoView addSubview:questionLengthLabel];
    [questionLengthLabel release];
    
    UIImageView *questionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 40, 280, 100)];
    NSString *textViewPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"textView" inDirectory:@"CommonView/TextView"];
    questionImageView.image = [UIImage imageNamed:textViewPath];
    [questionInfoView addSubview:questionImageView];
    [questionImageView release];
    
    UILabel *textViewPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(18, 48, 280, 20)];
    textViewPlaceholder.backgroundColor = [UIColor clearColor];
    textViewPlaceholder.textColor = [UIColor grayColor];
    textViewPlaceholder.font = [UIFont systemFontOfSize:15];
    textViewPlaceholder.text = @"您对我们的建议或者投诉";
    self.textViewPlaceholder = textViewPlaceholder;
    [questionInfoView addSubview:textViewPlaceholder];
    [textViewPlaceholder release];
    
    UITextView *editTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 40, 280, 100)];
    editTextView.backgroundColor = [UIColor clearColor];
    editTextView.delegate = self;
    editTextView.font = [UIFont systemFontOfSize:15];
    self.editTextView = editTextView;
    [questionInfoView addSubview:editTextView];
    [editTextView release];
    
    UILabel *questionTypeShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 155, 100, 20)];
    questionTypeShowLabel.backgroundColor = [UIColor clearColor];
    questionTypeShowLabel.text = @"问题类型:";
    [questionInfoView addSubview:questionTypeShowLabel];
    [questionTypeShowLabel release];
    
    UIButton *suggestCheckBoxButton = [[UIButton alloc] initWithFrame:CGRectMake(110, 153, 25, 25)];
    suggestCheckBoxButton.backgroundColor = [UIColor clearColor];
    NSString *checkboxButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"checkbox_normal" inDirectory:@"CommonView/CheckBox"];
    NSString *checkboxButtonSelectedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"checkbox_selected" inDirectory:@"CommonView/CheckBox"];
    [suggestCheckBoxButton setImage:[UIImage imageNamed:checkboxButtonNormalPath] forState:UIControlStateNormal];
    [suggestCheckBoxButton setImage:[UIImage imageNamed:checkboxButtonSelectedPath] forState:UIControlStateSelected];
    [suggestCheckBoxButton addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    self.suggestCheckBoxButton = suggestCheckBoxButton;
    suggestCheckBoxButton.selected = YES;
    [questionInfoView addSubview:suggestCheckBoxButton]; 
    [suggestCheckBoxButton release];
    
    UIButton *suggestCheckBoxTitleButton = [[UIButton alloc] initWithFrame:CGRectMake(135, 148, 60, 35)];
    suggestCheckBoxTitleButton.backgroundColor = [UIColor clearColor];
    suggestCheckBoxTitleButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [suggestCheckBoxTitleButton setTitle:@"建议    " forState:UIControlStateNormal];
    [suggestCheckBoxTitleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [suggestCheckBoxTitleButton addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    [questionInfoView addSubview:suggestCheckBoxTitleButton];
    [suggestCheckBoxTitleButton release];
    
    UIButton *complainCheckBoxButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 153, 25, 25)];
    complainCheckBoxButton.backgroundColor = [UIColor clearColor];
    [complainCheckBoxButton setImage:[UIImage imageNamed:checkboxButtonNormalPath] forState:UIControlStateNormal];
    [complainCheckBoxButton setImage:[UIImage imageNamed:checkboxButtonSelectedPath] forState:UIControlStateSelected];
    [complainCheckBoxButton addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    self.complainCheckBoxButton = complainCheckBoxButton;
    [questionInfoView addSubview:complainCheckBoxButton]; 
    [complainCheckBoxButton release];
    
    UIButton *complainCheckBoxTitleButton = [[UIButton alloc] initWithFrame:CGRectMake(225, 148, 60, 35)];
    complainCheckBoxTitleButton.backgroundColor = [UIColor clearColor];
    complainCheckBoxTitleButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [complainCheckBoxTitleButton setTitle:@"投诉    " forState:UIControlStateNormal];
    [complainCheckBoxTitleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [complainCheckBoxTitleButton addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    [questionInfoView addSubview:complainCheckBoxTitleButton];
    [complainCheckBoxTitleButton release];
    
    [editScrollView addSubview:questionInfoView];
    [questionInfoView release];
    
    UITableView *contractInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, 320, 150) style:UITableViewStyleGrouped];
    contractInfoTableView.backgroundColor = [UIColor clearColor];
    contractInfoTableView.scrollEnabled = NO;
    contractInfoTableView.dataSource = self;
    contractInfoTableView.delegate = self;
    self.contractInfoTableView = contractInfoTableView;
    [editScrollView addSubview:contractInfoTableView];
    [contractInfoTableView release];
    
    NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
    NSString *bigButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_normal" inDirectory:@"CommonView/MethodButton"];
    NSString *bigButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"bigButton_highlighted" inDirectory:@"CommonView/MethodButton"];
    
    if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
        UIButton *commitButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 355, 145, 40)];
        [commitButton setTitle:@"提    交" forState:UIControlStateNormal];
        [commitButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
        [commitButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
        [commitButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
        [commitButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
        [commitButton addTarget:self action:@selector(commitButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [editScrollView addSubview:commitButton];
        [commitButton release];
        
        UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(165, 355, 145, 40)];
        [searchButton setTitle:@"查询我的问题" forState:UIControlStateNormal];
        [searchButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
        [searchButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
        [searchButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
        [searchButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
        [searchButton addTarget:self action:@selector(searchButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [editScrollView addSubview:searchButton];
        [searchButton release];
    } else {
        UIButton *commitButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 355, 300, 40)];
        [commitButton setTitle:@"提    交" forState:UIControlStateNormal];
        [commitButton setTitleColor:[PiosaColorManager bigMethodFontNormalColor] forState:UIControlStateNormal];
        [commitButton setTitleColor:[PiosaColorManager bigMethodFontPressedColor] forState:UIControlStateHighlighted];
        [commitButton setBackgroundImage:[UIImage imageNamed:bigButtonNormalPath] forState:UIControlStateNormal];
        [commitButton setBackgroundImage:[UIImage imageNamed:bigButtonHighlightedPath] forState:UIControlStateHighlighted];
        [commitButton addTarget:self action:@selector(commitButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [editScrollView addSubview:commitButton];
        [commitButton release];
    }
    
    self.editScrollView = editScrollView;
    [self.view addSubview:editScrollView];
    [editScrollView release];
    
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
}

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应 : 但可能是错误响应, 如 404，或查询结果为空，则不跳转到下一个机票展示页面
- (void)requestFinished:(ASIFormDataRequest *)request
{    
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n",responseString);
    
    // 关闭加载框
    [_hud hide:YES];
    
    if ((responseString != nil) && [responseString length] > 0) {
        switch (_requestType) {
            case 1:
            {
                FeedbackCommitResponseModel *feedbackCommitResponseModel = [ResponseParser loadFeedbackCommitResponse:[request responseData]];
                
                if ([feedbackCommitResponseModel.resultCode intValue] != 0) {
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
                    hud.labelText = feedbackCommitResponseModel.resultMessage;
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
                    hud.labelText = @"您所反馈的问题我们已经收到!";
                    hud.detailsLabelText = @"将尽快给您答复，谢谢您的支持";
                    [hud show:YES];
                    [hud hide:YES afterDelay:4];
                }
            }
                break;
            case 2:
            {
                FeedbackSearchResponseModel *feedbackSearchResponseModel = [ResponseParser loadFeedbackSearchResponse:[request responseData] oldSuggestionList:nil];
                if ([feedbackSearchResponseModel.resultCode intValue] != 0) {
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
                    hud.labelText = feedbackSearchResponseModel.resultMessage;
                    [hud show:YES];
                    [hud hide:YES afterDelay:2];
                } else {
                    FeedbackListViewController *feedbackListViewController = [[FeedbackListViewController alloc] init];
                    feedbackListViewController.feedbackSearchResponseModel = feedbackSearchResponseModel;
                    [self.navigationController pushViewController:feedbackListViewController animated:YES];
                    [feedbackListViewController release];
                }
            }
                break;
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
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


//设置表格单元的展现
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d",indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        NSMutableDictionary *loginDict = [PiosaFileManager applicationPlistFromFile:UCAI_LOGIN_FILE_NAME];
        NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
        switch (indexPath.row) {
            case 0:
            {
                UILabel *contactNameShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 80, 34)];
                contactNameShowLabel.textAlignment = UITextAlignmentRight;
                contactNameShowLabel.text = @"姓名:";
                [cell.contentView addSubview:contactNameShowLabel];
                [contactNameShowLabel release];
                
                UITextField *contactNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 8, 200, 28)];
                contactNameTextField.borderStyle = UITextBorderStyleRoundedRect;
                contactNameTextField.placeholder = @"必填";
                contactNameTextField.returnKeyType = UIReturnKeyDone;
                contactNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [contactNameTextField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                contactNameTextField.delegate = self;
                contactNameTextField.tag = kContactNameTextFieldTag;
                if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
                    contactNameTextField.text = [memberDict objectForKey:@"realName"];
                }
                self.contactNameTextField = contactNameTextField;
                [cell.contentView addSubview:contactNameTextField];
                [contactNameTextField release];
            }
                break;
            case 1:
            {
                UILabel *contactPhoneShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 80, 34)];
                contactPhoneShowLabel.textAlignment = UITextAlignmentRight;
                contactPhoneShowLabel.text = @"手机号码:";
                [cell.contentView addSubview:contactPhoneShowLabel];
                [contactPhoneShowLabel release];
                
                UITextField *contactPhoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 8, 200, 28)];
                contactPhoneTextField.borderStyle = UITextBorderStyleRoundedRect;
                contactPhoneTextField.placeholder = @"必填";
                contactPhoneTextField.returnKeyType = UIReturnKeyDone;
                contactPhoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [contactPhoneTextField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                contactPhoneTextField.delegate = self;
                contactPhoneTextField.tag = kContactPhoneTextFieldTag;
                if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
                    contactPhoneTextField.text = [memberDict objectForKey:@"phone"];
                }
                self.contactPhoneTextField = contactPhoneTextField;
                [cell.contentView addSubview:contactPhoneTextField];
                [contactPhoneTextField release];
            }
                break;
            case 2:
            {
                UILabel *contactEmailShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 80, 34)];
                contactEmailShowLabel.textAlignment = UITextAlignmentRight;
                contactEmailShowLabel.text = @"电子邮箱:";
                [cell.contentView addSubview:contactEmailShowLabel];
                [contactEmailShowLabel release];
                
                UITextField *contactEmailTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 8, 200, 28)];
                contactEmailTextField.borderStyle = UITextBorderStyleRoundedRect;
                contactEmailTextField.placeholder = @"选填";
                contactEmailTextField.returnKeyType = UIReturnKeyDone;
                contactEmailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [contactEmailTextField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                contactEmailTextField.delegate = self;
                contactEmailTextField.tag = kContactEmailTextFieldTag;
                if ([[loginDict objectForKey:@"isLogin"] boolValue]) {
                    contactEmailTextField.text = [memberDict objectForKey:@"eMail"];
                }
                self.contactEmailTextField = contactEmailTextField;
                [cell.contentView addSubview:contactEmailTextField];
                [contactEmailTextField release];
            }
                break;
        }
        
	}
    
    if (indexPath.row == 0) {
        NSString *tableViewCellTopNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_top_normal" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellTopNormalPath]] autorelease];
    } else if(indexPath.row == [self.contractInfoTableView numberOfRowsInSection:indexPath.section]-1){
        NSString *tableViewCellBottomNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_bottom_normal" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellBottomNormalPath]] autorelease];
    } else {
        NSString *tableViewCellCenterNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"tableViewCell_center_normal" inDirectory:@"CommonView/TableViewCell"];
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:tableViewCellCenterNormalPath]] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.editTextView resignFirstResponder];
    [self.contactNameTextField resignFirstResponder];
    [self.contactPhoneTextField resignFirstResponder];
    [self.contactEmailTextField resignFirstResponder];
    self.editScrollView.contentInset = UIEdgeInsetsZero;
}

#pragma mark -
#pragma mark Text Field Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.editScrollView.contentInset = UIEdgeInsetsMake(0, 0, 220, 0);
    switch (textField.tag) {
        case kContactNameTextFieldTag:
            [self.editScrollView setContentOffset:CGPointMake(0, 200) animated:YES];
            break;
        case kContactPhoneTextFieldTag:
            [self.editScrollView setContentOffset:CGPointMake(0, 239) animated:YES];
            break;
        case kContactEmailTextFieldTag:
            [self.editScrollView setContentOffset:CGPointMake(0, 239) animated:YES];
            break;
    }
}

#pragma mark -
#pragma mark Text View Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView{
    self.editScrollView.contentInset = UIEdgeInsetsMake(0, 0, 220, 0);
}

//每次按下键盘时调用
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    int length=[textView.text length];
    int addLength=[text length];
    
    if((length>= KMaxTextLength && addLength>0) || length+addLength>KMaxTextLength)
    {
        return NO;
    }
    
    return YES;
}

//文本内容发生变化时调用
- (void)textViewDidChange:(UITextView *)textView{
    int length = [textView.text length];
    self.questionLengthLabel.text = [NSString stringWithFormat:@"%d/%d",length,KMaxTextLength];
    if (length != 0) {
        self.textViewPlaceholder.hidden = YES;
    } else {
        self.textViewPlaceholder.hidden = NO;
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

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    [hud release];
	hud = nil;
}

@end

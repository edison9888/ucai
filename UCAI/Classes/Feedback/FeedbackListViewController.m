//
//  FeedbackListViewController.m
//  UCAI
//
//  Created by  on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedbackListViewController.h"
#import "FeedbackSearchResponseModel.h"

#import "PiosaFileManager.h"
#import "ResponseParser.h"
#import "ASIFormDataRequest.h"
#import "GDataXMLNode.h"
#import "StaticConf.h"
#import "CommonTools.h"

#define kSuggestionTimeLabelTag 101
#define kSuggestionTypeLabelTag 102
#define kSuggestionCommitContentLabelTag 103
#define kSuggestionReplyShowLabelTag 104
#define kSuggestionReplyContentLabelTag 105

@implementation FeedbackListViewController

@synthesize feedbackSearchResponseModel = _feedbackSearchResponseModel;
@synthesize feedbackListCountLabel = _feedbackListCountLabel;
@synthesize feedbackListTableView = _feedbackListTableView;
@synthesize req = _req;

- (void)dealloc{
    [self.feedbackSearchResponseModel release];
    [self.feedbackListCountLabel release];
    [self.feedbackListTableView release];
    [self.req release];
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

- (NSData*)generateFeedbackSearchRequestPostXMLData:(NSString *)pageIndex{
    NSMutableDictionary *memberDict = [PiosaFileManager applicationPlistFromFile:UCAI_MEMBER_FILE_NAME];
    
    GDataXMLElement *requestElement = [GDataXMLElement elementWithName:@"request"];
    
    GDataXMLElement *pageInfoElement = [GDataXMLElement elementWithName:@"pageInfo"];
    [pageInfoElement addChild:[GDataXMLNode elementWithName:@"currentPage" stringValue:pageIndex]];
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

#pragma mark - View lifecycle

- (void)loadView {
	[super loadView];
    
    self.title = @"我的问题";
	
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
    
    UIView * secondTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    secondTitleView.backgroundColor = [PiosaColorManager secondTitleColor];
    UILabel * feedbackListCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(200 , 0, 120 ,24)];
    feedbackListCountLabel.backgroundColor = [UIColor clearColor];
    feedbackListCountLabel.textAlignment = UITextAlignmentRight;
    feedbackListCountLabel.textColor = [UIColor whiteColor];
    feedbackListCountLabel.font = [UIFont systemFontOfSize:15];
    feedbackListCountLabel.text = [NSString stringWithFormat:@"%@个结果",self.feedbackSearchResponseModel.count];
    self.feedbackListCountLabel = feedbackListCountLabel;
    [secondTitleView addSubview:feedbackListCountLabel];
    [feedbackListCountLabel release];
    [self.view addSubview:secondTitleView];
    [secondTitleView release];
    
	UITableView * uiTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 24, 320, 392) style:UITableViewStylePlain];
    uiTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	uiTableView.dataSource = self;
	uiTableView.delegate = self;
    
    //拉动刷新框
	if (_refreshHeaderView == nil) { 
        EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 10, 320, 70)];
		view1.delegate = self; 
        [view1 setHidden:YES];
        [uiTableView addSubview:view1]; 
        _refreshHeaderView = view1; 
        [view1 release]; 
    } 
    [_refreshHeaderView refreshLastUpdatedDate];
    
    self.feedbackListTableView = uiTableView;
	[self.view addSubview:uiTableView];
    [uiTableView release];
    
    NSLog(@"loadView:%d",[self.feedbackSearchResponseModel retainCount]);
}

- (void)viewDidAppear:(BOOL)animated{
    [_refreshHeaderView setFrame:CGRectMake(0, self.feedbackListTableView.contentSize.height, 320, 70)];//调整拉动刷新框的位置，使其位于刷新后的列表下
	if ([self.feedbackSearchResponseModel.pageSize intValue]*[self.feedbackSearchResponseModel.currentPage intValue]>=[self.feedbackSearchResponseModel.count intValue]) {
        //如果当前页为最后一页，则隐藏拉动刷新框
        [_refreshHeaderView setHidden:YES];
    } else {
        //如果当前页不为最后一页，则显示拉动刷新框
        [_refreshHeaderView setHidden:NO];
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"numberOfSectionsInTableView:%d",[self.feedbackSearchResponseModel retainCount]);
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.feedbackSearchResponseModel == nil) {
        return 0;
    }else{
        return [self.feedbackSearchResponseModel.suggestions count];
    }
}

//设置表格单元的展现
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"cellForRowAtIndexPath:%d",[self.feedbackSearchResponseModel retainCount]);
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell",indexPath.row];
    
    UILabel *tempSuggestionTimeLabel;
    UILabel *tempSuggestionTypeLabel;
    UILabel *tempSuggestionCommitContentLabel;
    UILabel *tempSuggestionReplyShowLabel;
    UILabel *tempSuggestionReplyContentLabel;
    
    FeedbackSuggestion * feedbackSuggestion = [self.feedbackSearchResponseModel.suggestions objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        UILabel *suggestionTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 20)];
        suggestionTimeLabel.backgroundColor = [UIColor clearColor];
        suggestionTimeLabel.textColor = [PiosaColorManager fontColor];
        suggestionTimeLabel.font = [UIFont systemFontOfSize:15];
        tempSuggestionTimeLabel = suggestionTimeLabel;
        suggestionTimeLabel.tag = kSuggestionTimeLabelTag;
        [cell.contentView addSubview:suggestionTimeLabel];
        [suggestionTimeLabel release];
        
        UILabel *suggestionTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(235, 5, 80, 20)];
        suggestionTypeLabel.backgroundColor = [UIColor clearColor];
        suggestionTypeLabel.textColor = [UIColor grayColor];
        suggestionTypeLabel.font = [UIFont systemFontOfSize:15];
        suggestionTypeLabel.textAlignment = UITextAlignmentRight;
        tempSuggestionTypeLabel = suggestionTypeLabel;
        [cell.contentView addSubview:suggestionTypeLabel];
        suggestionTypeLabel.tag = kSuggestionTypeLabelTag;
        [suggestionTypeLabel release];
        
        UILabel *suggestionCommitShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, 40, 20)];
        suggestionCommitShowLabel.backgroundColor = [UIColor clearColor];
        suggestionCommitShowLabel.font = [UIFont systemFontOfSize:15];
        suggestionCommitShowLabel.text = @"内容";
        [cell.contentView addSubview:suggestionCommitShowLabel];
        [suggestionCommitShowLabel release];
        
        UILabel *suggestionCommitContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 30, 280, 20)];
        suggestionCommitContentLabel.backgroundColor = [UIColor clearColor];
        suggestionCommitContentLabel.font = [UIFont systemFontOfSize:15];
        suggestionCommitContentLabel.lineBreakMode = UILineBreakModeWordWrap;
        suggestionCommitContentLabel.numberOfLines = 0;
        tempSuggestionCommitContentLabel = suggestionCommitContentLabel;
        [cell.contentView addSubview:suggestionCommitContentLabel];
        suggestionCommitContentLabel.tag = kSuggestionCommitContentLabelTag;
        [suggestionCommitContentLabel release];
        
        UILabel *suggestionReplyShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 30+20+10, 40, 20)];
        suggestionReplyShowLabel.backgroundColor = [UIColor clearColor];
        suggestionReplyShowLabel.textColor = [UIColor grayColor];
        suggestionReplyShowLabel.font = [UIFont systemFontOfSize:15];
        suggestionReplyShowLabel.text = @"回复";
        suggestionReplyShowLabel.tag = kSuggestionReplyShowLabelTag;
        tempSuggestionReplyShowLabel = suggestionReplyShowLabel;
        [cell.contentView addSubview:suggestionReplyShowLabel];
        [suggestionReplyShowLabel release];
        
        UILabel *suggestionReplyContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 30+20+10, 280, 20)];
        suggestionReplyContentLabel.backgroundColor = [UIColor clearColor];
        suggestionReplyContentLabel.textColor = [UIColor grayColor];
        suggestionReplyContentLabel.font = [UIFont systemFontOfSize:15];
        suggestionReplyContentLabel.lineBreakMode = UILineBreakModeWordWrap;
        suggestionReplyContentLabel.numberOfLines = 0;
        tempSuggestionReplyContentLabel = suggestionReplyContentLabel;
        [cell.contentView addSubview:suggestionReplyContentLabel];
        suggestionReplyContentLabel.tag = kSuggestionReplyContentLabelTag;
        [suggestionReplyContentLabel release];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        tempSuggestionTimeLabel = (UILabel *)[cell.contentView viewWithTag:kSuggestionTimeLabelTag];
        tempSuggestionTypeLabel = (UILabel *)[cell.contentView viewWithTag:kSuggestionTypeLabelTag];
        tempSuggestionCommitContentLabel = (UILabel *)[cell.contentView viewWithTag:kSuggestionCommitContentLabelTag];
        tempSuggestionReplyShowLabel = (UILabel *)[cell.contentView viewWithTag:kSuggestionReplyShowLabelTag];
        tempSuggestionReplyContentLabel = (UILabel *)[cell.contentView viewWithTag:kSuggestionReplyContentLabelTag];
    }
    
    tempSuggestionTimeLabel.text = [NSString stringWithFormat:@"时间 %@",feedbackSuggestion.suggestionCommitTime];
    if ([@"1" isEqualToString:feedbackSuggestion.suggestionType]) {
        tempSuggestionTypeLabel.text = @"投诉";
    } else {
        tempSuggestionTypeLabel.text = @"建议";
    }
    
    int commitContentRowNum = [CommonTools calculateRowCountForUTF8:feedbackSuggestion.suggestionCommitContent bytes:3*18];
    tempSuggestionCommitContentLabel.frame = CGRectMake(40, 30, 280, 20*commitContentRowNum);
    tempSuggestionCommitContentLabel.text = feedbackSuggestion.suggestionCommitContent;
    
    int replyContentRowNum = [CommonTools calculateRowCountForUTF8:feedbackSuggestion.suggestionReplyContent bytes:3*18];
    tempSuggestionReplyShowLabel.frame = CGRectMake(5, 30+20*commitContentRowNum+5, 40, 20);
    tempSuggestionReplyContentLabel.frame = CGRectMake(40, 30+20*commitContentRowNum+5, 280, 20*((replyContentRowNum==0)?1:replyContentRowNum));
    if ([@"" isEqualToString:feedbackSuggestion.suggestionReplyContent]) {
        tempSuggestionReplyContentLabel.text = @"正在处理中......";
    } else {
        tempSuggestionReplyContentLabel.text = feedbackSuggestion.suggestionReplyContent;
    }
    
    if ((indexPath.row+1)%2 == 0) {
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [PiosaColorManager tableViewPlainSepColor];
        cell.backgroundView = bgView;
        [bgView release];
    }  else  {
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = bgView;
        [bgView release];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	if ([self.feedbackSearchResponseModel.suggestions count]<=6) {
		UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)] autorelease];
		footer.backgroundColor = [UIColor clearColor];
		return footer;
	} else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FeedbackSuggestion * feedbackSuggestion = [self.feedbackSearchResponseModel.suggestions objectAtIndex:indexPath.row];
    int commitContentRowNum = [CommonTools calculateRowCountForUTF8:feedbackSuggestion.suggestionCommitContent bytes:3*18];
    int replyContentRowNum = [CommonTools calculateRowCountForUTF8:feedbackSuggestion.suggestionReplyContent bytes:3*18];
    return 30+20*commitContentRowNum+5+20*((replyContentRowNum==0)?1:replyContentRowNum)+10;
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{ 
    NSLog(@"==开始加载数据"); 
    _reloading = YES; 
}

- (void)doneLoadingTableViewData{ 
    NSLog(@"===加载完数据"); 
    _reloading = NO; 
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.feedbackListTableView];
	
	[_refreshHeaderView setFrame:CGRectMake(0, self.feedbackListTableView.contentSize.height, 320, 70)];//调整拉动刷新框的位置，使其位于刷新后的列表下
	if ([self.feedbackSearchResponseModel.pageSize intValue]*[self.feedbackSearchResponseModel.currentPage intValue]>=[self.feedbackSearchResponseModel.count intValue]) {
        //如果当前页为最后一页，则隐藏拉动刷新框
        [_refreshHeaderView setHidden:YES];
    } else {
        //如果当前页不为最后一页，则显示拉动刷新框
        [_refreshHeaderView setHidden:NO];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods 
//手指屏幕上不断拖动时调用此方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{ 
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView]; 
}

//当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{   
    NSLog(@"scrollViewDidEndDragging:%d",[self.feedbackSearchResponseModel retainCount]);
    //停止拖动机票订单列表时
    if ([self.feedbackSearchResponseModel.pageSize intValue]*[self.feedbackSearchResponseModel.currentPage intValue]<[self.feedbackSearchResponseModel.count intValue]) {
        //显示最后一页时，可以不用调用方法来设置刷新视图
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView]; 
    }
} 

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource]; //开始加载数据
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: FEEDBACK_SUGGESTION_QUERY_ADDRESS]] ;
    request.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    
    NSInteger index = [self.feedbackSearchResponseModel.currentPage intValue]+1;
    [request appendPostData:[self generateFeedbackSearchRequestPostXMLData:[NSString stringWithFormat:@"%d",index]]];
    
    NSString *postData = [[NSString alloc] initWithData:[self generateFeedbackSearchRequestPostXMLData:[NSString stringWithFormat:@"%d",index]] encoding:NSUTF8StringEncoding];
    NSLog(@"requestStart\n");
    NSLog(@"%@\n", postData);
    [postData release];
    
    [request setDelegate:self];
    [request startAsynchronous]; // 执行异步post
    self.req = request;
    [request release];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading; 
} 
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];     
} 

#pragma mark -
#pragma mark ASIHTTP Response

// 响应有响应 : 但可能是错误响应, 如 404，或查询结果为空，则不跳转到下一个机票展示页面
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);
    if ((responseString != nil) && [responseString length] > 0) {
        FeedbackSearchResponseModel *feedbackSearchResponseModel = [ResponseParser loadFeedbackSearchResponse:[request responseData] oldSuggestionList:self.feedbackSearchResponseModel];
        
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
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = feedbackSearchResponseModel.resultMessage;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
        } else {
            self.feedbackSearchResponseModel = feedbackSearchResponseModel;
            [_refreshHeaderView setHidden:TRUE];//隐藏拉动刷新框，因为当加载速度很快时，拉动刷新框在doneLoadingTableViewData里调整位置前，已经显示出了hotelListTableView的新数据
            [self.feedbackListTableView reloadData];
        }
        [self doneLoadingTableViewData]; //加载完成数据，修改拉动刷新框的位置与其它参数
    }
}

// 网络无响应
- (void)requestFailed:(ASIFormDataRequest *)request
{
	// 提示用户打开网络联接
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.bgRGB = [PiosaColorManager progressColor];
    [self.navigationController.view addSubview:hud];
    hud.delegate = self;
    hud.minSize = CGSizeMake(135.f, 135.f);
    NSString *badFaceImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"badFace" inDirectory:@"CommonView/ProgressView"];
    UIImageView *badFaceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:badFaceImagePath]];
    badFaceImageView.frame = CGRectMake(0, 0, 37, 37);
    hud.customView = badFaceImageView;
    [badFaceImageView release];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"网络连接失败啦";
    [hud show:YES];
    [hud hide:YES afterDelay:2];
    
    [self doneLoadingTableViewData]; //加载完成数据，修改拉动刷新框的位置与其它参数
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

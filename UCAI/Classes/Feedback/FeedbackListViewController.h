//
//  FeedbackListViewController.h
//  UCAI
//
//  Created by  on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

@class FeedbackSearchResponseModel;
@class ASIFormDataRequest;

@interface FeedbackListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate>{
    @private
    EGORefreshTableHeaderView *_refreshHeaderView;  //拉动加载视图
    BOOL _reloading;								//加载视图更新标识
}

@property (nonatomic,retain) FeedbackSearchResponseModel *feedbackSearchResponseModel;

@property (nonatomic,retain) UILabel *feedbackListCountLabel;
@property (nonatomic,retain) UITableView *feedbackListTableView;

@property (nonatomic,retain) ASIFormDataRequest *req;			// 网络请求

- (NSData*)generateFeedbackSearchRequestPostXMLData:(NSString *)pageIndex;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end

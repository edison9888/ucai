//
//  FeedbackEditViewController.h
//  UCAI
//
//  Created by  on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class FeedbackSearchResponseModel;

@interface FeedbackEditViewController : UIViewController<UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>{
    @private
    NSUInteger _requestType;//网络请求类型:1-提交反馈；2-查询反馈
    MBProgressHUD *_hud;
}

@property(nonatomic,retain) UIScrollView *editScrollView;

@property(nonatomic,retain) UILabel *questionLengthLabel;
@property(nonatomic,retain) UITextView *editTextView;
@property(nonatomic,retain) UILabel *textViewPlaceholder;
@property(nonatomic,retain) UIButton *suggestCheckBoxButton;
@property(nonatomic,retain) UIButton *complainCheckBoxButton;

@property(nonatomic,retain) UITableView *contractInfoTableView;
@property(nonatomic,retain) UITextField *contactNameTextField;
@property(nonatomic,retain) UITextField *contactPhoneTextField;
@property(nonatomic,retain) UITextField *contactEmailTextField;

- (NSData*)generateFeedbackCommitRequestPostXMLData;
- (NSData*)generateFeedbackSearchRequestPostXMLData;

//检查并保存所输入信息是否合法
//0-合法;
//1-未输入建议或投诉;
//2-未输入联系姓名;
//3-未输入手机号码;
//4-未输入有效手机号码;
//5-所输入电子邮箱格式错误;
- (int)checkAndSaveIn;


@end

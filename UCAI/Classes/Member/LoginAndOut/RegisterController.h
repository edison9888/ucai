//
//  RegisterController.h
//  JingDuTianXia
//
//  Created by admin on 11-9-30.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class ASIFormDataRequest; // 网络请求类

@interface RegisterController : UIViewController <UIActionSheetDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate,MBProgressHUDDelegate> {

	UITableView *registerTableView;
	
	NSString *loginName;
	NSString *phone;
	NSString *email;
	NSString *loginCode;
	NSString *secondLoginCode;
    
    @private
    MBProgressHUD *_hud;
}

@property (nonatomic,retain) IBOutlet UITableView *registerTableView;
@property (nonatomic,retain) NSString *loginName;
@property (nonatomic,retain) NSString *phone;
@property (nonatomic,retain) NSString *email;
@property (nonatomic,retain) NSString *loginCode;
@property (nonatomic,retain) NSString *secondLoginCode;

//检查并保存所输入的注册资料是否合法
//0-合法;
//1-未输入用户名;
//2-用户名不符合规则(长度3-20)
//3-未输入手机号码;
//4-未输入有效的手机号码;
//5-未输入有效的电子邮箱;
//6-未输入密码;
//7-密码不符合规则(长度6-30)
//8-未输入确认密码;
//9-确认密码与登陆密码不一致
- (int) checkAndSaveIn;

// 会员登陆POST数据拼装函数
- (NSData*)generateMemberRegisterRequestPostXMLData;		// 会员注册 XML Request

// 网络请求响应函数
- (void) requestFinished:(ASIFormDataRequest *)request; // 请求成功
- (void) requestFailed:(ASIFormDataRequest *)request; // 请求失败

@end

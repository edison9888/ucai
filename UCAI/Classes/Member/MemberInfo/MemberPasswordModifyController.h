//
//  MemberPasswordModifyController.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-17.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface MemberPasswordModifyController : UITableViewController<UIAlertViewDelegate,MBProgressHUDDelegate> {
	NSArray *fieldLabels;
	
	NSString *oldPassword;
	NSString *modifyPassword;
	NSString *modifyPasswordSecond;
    
    @private
    MBProgressHUD *_hud;
}

@property (nonatomic,retain) NSArray *fieldLabels;
@property (nonatomic,copy) NSString *oldPassword;
@property (nonatomic,copy) NSString *modifyPassword;
@property (nonatomic,copy) NSString *modifyPasswordSecond;

//修改密码按钮的反应方法
- (IBAction)modifyPassword:(id)sender;

//检查并保存所输入的密码修改是否合法
//0-合法;
//1-未输入旧密码;
//2-未输入新密码;
//3-新密码不符合规则(长度6-30)
//4-未输入确认密码;
//5-确认密码与新密码不一致
- (int) checkAndSaveIn;

// 会员修改会员登陆密码POST数据拼装函数
- (NSData*)generateMemberPasswordModifyRequestPostXMLData;

@end

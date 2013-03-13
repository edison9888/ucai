//
//  MemberPasswordBackController.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-9.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface MemberPasswordBackController : UITableViewController<UIAlertViewDelegate,MBProgressHUDDelegate> {

	NSArray *fieldLabels;
	
	NSString *memberName;
	NSString *registerPhone;
    
    @private
    MBProgressHUD *_hud;
}

@property (nonatomic,retain) NSArray *fieldLabels;
@property (nonatomic,retain) NSString *memberName;
@property (nonatomic,retain) NSString *registerPhone;

//检查并保存所输入的找回密码所用用户资料是否合法
//0-合法;
//1-未输入用户名;
//2-用户名不符合规则(长度3-20)
//3-未输入手机号码;
//4-未输入有效的手机号码;
- (int) checkAndSaveIn;

// 会员登陆POST数据拼装函数
- (NSData*)generateMemberPasswordBackRequestPostXMLData;		// 会员注册 XML Request

@end

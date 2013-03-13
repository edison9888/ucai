//
//  FlightHistoryCustomerViewController.h
//  UCAI
//
//  Created by  on 12-2-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class MemberFlightHistoryCustomerQueryResponse;

@interface FlightHistoryCustomerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>{
    @private
    MBProgressHUD *_hud;
}

@property(nonatomic, retain)UILabel * countLabel;
@property(nonatomic, retain)UITableView * customerTableView;
@property(nonatomic, retain)MemberFlightHistoryCustomerQueryResponse *memberFlightHistoryCustomerQueryResponse;
@property(nonatomic, assign)NSUInteger requestType;//1-查询历史乘机人；2-删除历史乘机人
@property(nonatomic, assign)NSUInteger deletingRow;//正在删除的行数


- (void)queryHistoryCustomers;

- (NSData*)generateMemberFlightHistoryCustomerDeleteRequestPostXMLData:(NSString *)customerId;

- (NSData*)generateMemberFlightHistoryCustomerQueryRequestPostXMLData;

@end

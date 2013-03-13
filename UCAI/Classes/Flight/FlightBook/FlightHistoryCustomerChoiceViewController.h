//
//  FlightHistoryCustomerChoiceViewController.h
//  UCAI
//
//  Created by  on 12-2-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class MemberFlightHistoryCustomerQueryResponse;
@class FlightBookViewController;

@interface FlightHistoryCustomerChoiceViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>{
    @private
    MBProgressHUD *_hud;
    NSUInteger _maxCount;
    NSMutableArray *_selectedRowArray;
}

@property(nonatomic, retain)UILabel * countLabel;
@property(nonatomic, retain)UITableView * customerTableView;
@property(nonatomic, retain)MemberFlightHistoryCustomerQueryResponse *memberFlightHistoryCustomerQueryResponse;

@property(nonatomic, retain) FlightBookViewController * flightBookViewController;

- (FlightHistoryCustomerChoiceViewController *)initWithMaxChoiceCount:(NSUInteger)maxCount;

- (void)queryHistoryCustomers;

- (NSData*)generateMemberFlightHistoryCustomerQueryRequestPostXMLData;

@end

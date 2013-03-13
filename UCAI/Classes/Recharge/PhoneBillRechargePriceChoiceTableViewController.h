//
//  PhoneBillRechargePriceChoiceTableViewController.h
//  UCAI
//
//  Created by  on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class PhoneBillRechargeViewController;

@interface PhoneBillRechargePriceChoiceTableViewController : UITableViewController<MBProgressHUDDelegate>{
    @private
    NSUInteger _rechargeType;
    MBProgressHUD *_hud;
}

@property (nonatomic,retain) NSArray *priceArray;
@property (nonatomic,retain) PhoneBillRechargeViewController *phoneBillRechargeViewController;

@end

//
//  CouponBuyCountChoiceTableViewController.h
//  UCAI
//
//  Created by  on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CouponInfoViewController;

@interface CouponBuyCountChoiceTableViewController : UITableViewController{
    @protected
    NSUInteger _nowSelectRow;
}

@property(nonatomic,retain) CouponInfoViewController *couponInfoViewController;

- (CouponBuyCountChoiceTableViewController *)initWithSelectRow:(NSUInteger)selectedRow;

@end

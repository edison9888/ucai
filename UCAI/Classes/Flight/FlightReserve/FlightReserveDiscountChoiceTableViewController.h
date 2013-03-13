//
//  FlightBookingDiscountChoiceTableViewController.h
//  UCAI
//
//  Created by  on 11-12-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlightReserveViewController;

@interface FlightReserveDiscountChoiceTableViewController : UITableViewController

@property (nonatomic,retain) NSArray *discountArray;
@property (nonatomic,retain) FlightReserveViewController *flightReserveViewController;
@property (nonatomic,assign) NSUInteger nowSelectRow;

@end

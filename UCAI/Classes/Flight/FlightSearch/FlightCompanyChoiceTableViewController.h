//
//  FlightCompanyChoiceTableViewController.h
//  UCAI
//
//  Created by  on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlightSearchViewController;

@interface FlightCompanyChoiceTableViewController : UITableViewController

@property (nonatomic,retain)NSArray *companyTextArray;
@property (nonatomic,retain)NSArray *companyImgArray;

@property (nonatomic, retain) FlightSearchViewController *flightSearchViewController;

@property (nonatomic) NSUInteger nowSelectRow;

@end

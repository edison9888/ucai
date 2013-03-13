//
//  FlightCertificateTypeTableViewController.h
//  UCAI
//
//  Created by  on 12-2-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlightCustomerAddController;

@interface FlightCertificateTypeTableViewController : UITableViewController

@property (nonatomic,retain)NSArray *certificateTypeArray;
@property (nonatomic,retain) FlightCustomerAddController *flightCustomerAddController;
@property (nonatomic) NSUInteger nowSelectRow;

@end

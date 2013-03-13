//
//  FlightBookingCityChoiceTableViewController.h
//  UCAI
//
//  Created by  on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlightSearchViewController;

@interface FlightBookingCityChoiceTableViewController : UITableViewController<UISearchDisplayDelegate,UISearchBarDelegate>{
    @private
    NSUInteger _cityType;
}

@property (nonatomic, retain) NSDictionary *citys;
@property (nonatomic, retain) NSMutableDictionary *filteredCitys;
@property (nonatomic, retain) NSMutableArray *keys;
@property (nonatomic, retain) NSMutableArray *filteredKeys;

@property (nonatomic, retain) UISearchDisplayController *searchController;

@property (nonatomic, retain) FlightSearchViewController *flightSearchViewController;

//type:1-出发城市,2-到达城市
- (FlightBookingCityChoiceTableViewController *)initWithCityType:(NSUInteger)cityType;

@end

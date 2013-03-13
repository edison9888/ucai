//
//  FlightReserveCityChoiceTableViewController.h
//  UCAI
//
//  Created by  on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlightReserveViewController;

@interface FlightReserveCityChoiceTableViewController : UITableViewController<UISearchDisplayDelegate,UISearchBarDelegate>{
    @private
    NSUInteger _cityType;
}

@property (nonatomic, retain) NSDictionary *citys;
@property (nonatomic, retain) NSMutableDictionary *filteredCitys;
@property (nonatomic, retain) NSMutableArray *keys;
@property (nonatomic, retain) NSMutableArray *filteredKeys;

@property (nonatomic, retain) UISearchDisplayController *searchController;

@property (nonatomic, retain) FlightReserveViewController *flightReserveViewController;

//type:1-出发城市,2-到达城市
- (FlightReserveCityChoiceTableViewController *)initWithCityType:(NSUInteger)cityType;

@end

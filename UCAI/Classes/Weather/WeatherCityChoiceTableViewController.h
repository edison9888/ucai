//
//  WeatherCityChoiceTableViewController.h
//  UCAI
//
//  Created by  on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WeatherSearchViewController;

@interface WeatherCityChoiceTableViewController : UITableViewController<UISearchDisplayDelegate,UISearchBarDelegate>

@property (nonatomic, retain) NSDictionary *citys;
@property (nonatomic, retain) NSMutableDictionary *filteredCitys;
@property (nonatomic, retain) NSMutableArray *keys;
@property (nonatomic, retain) NSMutableArray *filteredKeys;

@property (nonatomic, retain) UISearchDisplayController *searchController;

@property (nonatomic, retain) WeatherSearchViewController *weatherSearchViewController;

@end

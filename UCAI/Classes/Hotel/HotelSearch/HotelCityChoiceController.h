//
//  HotelCityChoiceController.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-18.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotelSearchController.h"


@interface HotelCityChoiceController : UITableViewController<UISearchDisplayDelegate,UISearchBarDelegate>

@property (nonatomic, retain) NSDictionary *citys;
@property (nonatomic, retain) NSMutableDictionary *filteredCitys;
@property (nonatomic, retain) NSMutableArray *keys;
@property (nonatomic, retain) NSMutableArray *filteredKeys;

@property (nonatomic, retain) UISearchDisplayController *searchController;

@property (nonatomic, retain) HotelSearchController *hotelSearchController;

@end

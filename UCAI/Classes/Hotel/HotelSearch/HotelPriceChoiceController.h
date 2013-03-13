//
//  HotelPriceChoiceController.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-19.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HotelSearchController;


@interface HotelPriceChoiceController : UITableViewController

@property (nonatomic,retain)NSArray *hotelPriceRate;

@property (nonatomic, retain) HotelSearchController *hotelSearchController;

@property (nonatomic) NSUInteger nowSelectRow;

@end

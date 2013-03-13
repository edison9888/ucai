//
//  HotelStarChoiceController.h
//  JingDuTianXia
//
//  Created by Piosa on 11-10-19.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HotelSearchController;


@interface HotelStarChoiceController : UITableViewController

@property (nonatomic,retain)NSArray *hotelStarText;
@property (nonatomic,retain)NSArray *hotelStarImg;

@property (nonatomic,retain) HotelSearchController *hotelSearchController;

@property (nonatomic) NSUInteger nowSelectRow;

@end

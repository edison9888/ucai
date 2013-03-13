//
//  HotelRoomCountChoiceController.h
//  JingDuTianXia
//
//  Created by Piosa on 11-11-14.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HotelBookController;

@interface HotelRoomCountChoiceController : UITableViewController

@property (nonatomic,retain) NSArray * roomCount;
@property (nonatomic,retain) HotelBookController * hotelBookController;
@property (nonatomic) NSUInteger nowSelectRow;

@end

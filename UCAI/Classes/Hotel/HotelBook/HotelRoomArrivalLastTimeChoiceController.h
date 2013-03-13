//
//  HotelRoomArrivalLastTimeChoiceController.h
//  JingDuTianXia
//
//  Created by Piosa on 11-11-14.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HotelBookController;

@interface HotelRoomArrivalLastTimeChoiceController : UITableViewController {
	NSArray * _arrivalTime;
	
	HotelBookController * _hotelBookController;
	
	NSUInteger _nowSelectRow;
}

@property (nonatomic,retain) NSArray * arrivalTime;
@property (nonatomic,retain) HotelBookController * hotelBookController;
@property (nonatomic) NSUInteger nowSelectRow;

@end

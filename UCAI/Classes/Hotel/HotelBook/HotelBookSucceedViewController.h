//
//  HotelBookSucceedTableViewController.h
//  UCAI
//
//  Created by  on 11-12-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotelBookSucceedViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property (nonatomic,copy) NSString * hotelOrderID;     //订单ID
@property (nonatomic,copy) NSString * hotelOrderPrice;  //订单总额

@end

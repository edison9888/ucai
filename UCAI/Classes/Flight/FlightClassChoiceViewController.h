//
//  FlightClassChoiceViewController.h
//  UCAI
//
//  Created by  on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FlightClassChoiceViewController : UIViewController<UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,retain)UITableView *choiceTableView;


@end

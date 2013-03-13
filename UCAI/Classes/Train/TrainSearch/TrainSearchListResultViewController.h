//
//  TrainSearchListResultViewController.h
//  UCAI
//
//  Created by  on 12-1-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@class TrainSearchResponseModel;

@interface TrainSearchListResultViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,MBProgressHUDDelegate>{
    @private
    MBProgressHUD *_hud;
    NSUInteger _selectedRow;
    
    UIView *_tipsView;
}

@property(nonatomic, copy) NSString *startedCityName;
@property(nonatomic, copy) NSString *arrivedCityName;

@property(nonatomic, retain) TrainSearchResponseModel *trainSearchResponseModel;

@end

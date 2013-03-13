//
//  TrainStationListResultViewController.h
//  UCAI
//
//  Created by  on 12-1-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "TrainDetailResponseModel.h"

@interface TrainStationListResultViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    @private
    UIView *_tipsView;
}

@property(nonatomic, copy) NSString *trainCode;
@property(nonatomic, copy) NSString *startedStationName;
@property(nonatomic, copy) NSString *arrivedStationName;

@property(nonatomic, retain) TrainDetailResponseModel *trainDetailResponseModel;

@end

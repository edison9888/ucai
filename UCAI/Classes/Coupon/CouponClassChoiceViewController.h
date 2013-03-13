//
//  CouponClassChoiceViewController.h
//  UCAI
//
//  Created by  on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponClassChoiceViewController : UIViewController<UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource>{
    @private
    UITableView *_choiceTableView;
}

@end

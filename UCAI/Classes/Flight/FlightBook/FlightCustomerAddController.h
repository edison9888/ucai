//
//  FlightCustomerAddController.h
//  UCAI
//
//  Created by  on 12-2-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlightBookViewController;

@interface FlightCustomerAddController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, assign) BOOL isAdult;//是否为成人;

@property(nonatomic, retain) FlightBookViewController * flightBookViewController;

@property(nonatomic, retain) UITableView * addTableView;

@property(nonatomic, retain) UITextField * customerNameTextField;
@property(nonatomic, retain) UILabel * customerTypeShowLabel;
@property(nonatomic, copy) NSString * customerType;
@property(nonatomic, retain) UILabel * certificateTypeShowLabel;
@property(nonatomic, copy) NSString * certificateType;
@property(nonatomic, retain) UITextField * certificateNoTextField;
@property(nonatomic, retain) UILabel * customerBirthdayLabel;
@property(nonatomic, retain) UILabel * secureNumShowLabel;
@property(nonatomic, copy) NSString * secureNum;

@property(nonatomic, retain) UIToolbar *dateBar;
@property(nonatomic, retain) UIDatePicker *datePicker;

- (int) checkAndSaveIn;

@end

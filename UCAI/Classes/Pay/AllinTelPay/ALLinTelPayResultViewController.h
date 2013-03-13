//
//  ALLinTelPayResultViewController.h
//  UCAI
//
//  Created by  on 11-12-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALLinTelPayResultViewController : UIViewController<UIActionSheetDelegate>{
@private
    NSString *_orderID;
    NSString *_orderPrice;
    NSString *_allinID;
    NSString *_allinCreatetime;
    NSString *_phone;
}

- (ALLinTelPayResultViewController *)initWithOrderID:(NSString *)orderID andPrice:(NSString *)orderPrice andAllinID:(NSString *)allinID andAllinCreatetime:(NSString *)allinCreatetime andPhone:(NSString *)phone;

@end

//
//  AppDelegate.h
//  UCAI
//
//  Created by  on 11-12-1.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MemberLoginResponse.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navController;

- (void) showAllpicationState;

@end

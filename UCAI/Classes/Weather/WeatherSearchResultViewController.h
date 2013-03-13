//
//  WeatherSearchResultViewController.h
//  UCAI
//
//  Created by  on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"

@class WeatherSearchResponseModel;

@interface WeatherSearchResultViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,MFMessageComposeViewControllerDelegate,MBProgressHUDDelegate>{
    @private
    NSString *_cityName; //城市名称
    NSString *_cityLat; //纬度
    NSString *_cityLng; //经度
    NSString *_provinceName; //省份名称
    
    MBProgressHUD *_hud;
}

@property(nonatomic,retain) WeatherSearchResponseModel *weatherSearchResponseModel;
@property(nonatomic,retain) UIImageView *weatherImageView;
@property(nonatomic,retain) UILabel *conditionLabel;
@property(nonatomic,retain) UILabel *humidityLabel;
@property(nonatomic,retain) UILabel *windLabel;
@property(nonatomic,retain) UILabel *temperatureLabel;
@property(nonatomic,retain) UITableView *weatherPreviewTableView;

- (WeatherSearchResultViewController *)initWithCityName:(NSString *)cityName andCityLat:(NSString *)cityLat andCithLng:(NSString *)cityLng andProvinceName:(NSString *)provinceName;

- (void)reflashButtonPress;

- (void)shareButtonPress;

@end

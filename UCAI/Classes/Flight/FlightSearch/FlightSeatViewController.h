//
//  FlightSeatViewController.h
//  UCAI
//
//  Created by  on 12-1-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "StaticConf.h"

@class ASIFormDataRequest;
@class FlightDetailSearchResponseModel;

@interface FlightSeatViewController : UIViewController<MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate>{
    @private
    UCAIFlightLineStyle _flightLineType; //航程类型
    
    MBProgressHUD *_hud;
    
    NSDictionary *_flightCompanyDic;
    NSDictionary *_flightSeatDic;
}

- (NSData*)generateFlightSeatRequestPostXMLData;

@property(nonatomic,copy) NSString * startedCityName;
@property(nonatomic,copy) NSString * arrivedCityName;
@property(nonatomic,copy) NSString * startCityCode;         //出发城市三字码
@property(nonatomic,copy) NSString * arrivedCityCode;       //到达城市三字码
@property(nonatomic,copy) NSString * goDate;                //出发日期
@property(nonatomic,copy) NSString * searchFlightCompanyCode;     //航空公司代码
@property(nonatomic,copy) NSString * flightId;              //航班ID

@property(nonatomic,retain) FlightDetailSearchResponseModel *flightDetailSearchResponseModel;

@property(nonatomic, retain) ASIFormDataRequest *req;                   // 网络请求
@property(nonatomic, assign) NSInteger requestType;                     //网络请求类型:1-查询单航班所有价格;2-查询反程航班数据

- (FlightSeatViewController *)initWithFlightLineStyle:(UCAIFlightLineStyle) flightLineType;

- (NSData*)generateFlightBookingRequestPostXMLData;


@end

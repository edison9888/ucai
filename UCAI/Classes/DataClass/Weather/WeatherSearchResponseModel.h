//
//  WeatherSearchResponseModel.h
//  UCAI
//
//  Created by  on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherPreviewModel : NSObject

@property(nonatomic,copy) NSString *weatherCondition;           //概况
@property(nonatomic,copy) NSString *weatherLowTemperature;      //最低摄氏温度
@property(nonatomic,copy) NSString *weatherHighTemperature;     //最高摄氏温度
@property(nonatomic,copy) NSString *weatherDayOfWeek;           //温度
@property(nonatomic,copy) NSString *weatherIcon;                //图像

@end

@interface WeatherSearchResponseModel : NSObject

@property(nonatomic,copy) NSString *weatherCondition;       //概况
@property(nonatomic,copy) NSString *weatherTemperature;     //摄氏温度
@property(nonatomic,copy) NSString *weatherHumidity;        //温度
@property(nonatomic,copy) NSString *weatherWind;            //风向
@property(nonatomic,copy) NSString *weatherIcon;            //图像
@property(nonatomic,retain) NSMutableArray *weatherPreviewConditions; //未来天气状态(WeatherPreviewModel)

@end

//
//  WeatherSearchResponseModel.m
//  UCAI
//
//  Created by  on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WeatherSearchResponseModel.h"

@implementation WeatherPreviewModel

@synthesize weatherCondition = _weatherCondition;
@synthesize weatherLowTemperature = _weatherLowTemperature;
@synthesize weatherHighTemperature = _weatherHighTemperature;
@synthesize weatherDayOfWeek = _weatherDayOfWeek;
@synthesize weatherIcon = _weatherIcon;

- (void)dealloc{
    [self.weatherCondition release];
    [self.weatherLowTemperature release];
    [self.weatherHighTemperature release];
    [self.weatherDayOfWeek release];
    [self.weatherIcon release];
    [super dealloc];
}

@end

@implementation WeatherSearchResponseModel

@synthesize weatherCondition = _weatherCondition;
@synthesize weatherTemperature = _weatherTemperature;
@synthesize weatherHumidity = _weatherHumidity;
@synthesize weatherWind = _weatherWind;
@synthesize weatherIcon = _weatherIcon;
@synthesize weatherPreviewConditions = _weatherPreviewConditions;

- (void)dealloc{
    [self.weatherCondition release];
    [self.weatherTemperature release];
    [self.weatherHumidity release];
    [self.weatherWind release];
    [self.weatherIcon release];
    [self.weatherPreviewConditions release];
    [super dealloc];
}

@end

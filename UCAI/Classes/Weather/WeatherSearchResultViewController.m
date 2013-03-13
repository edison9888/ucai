//
//  WeatherSearchResultViewController.m
//  UCAI
//
//  Created by  on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WeatherSearchResultViewController.h"
#import "WeatherSearchResponseModel.h"

#import "CommonTools.h"
#import "GDataXMLNode.h"
#import "ASIFormDataRequest.h"
#import "StaticConf.h"
#import "ResponseParser.h"
#import "PiosaFileManager.h"

@implementation WeatherSearchResultViewController

@synthesize weatherSearchResponseModel = _weatherSearchResponseModel;
@synthesize weatherImageView = _weatherImageView;
@synthesize conditionLabel = _conditionLabel;
@synthesize humidityLabel = _humidityLabel;
@synthesize windLabel = _windLabel;
@synthesize temperatureLabel = _temperatureLabel;
@synthesize weatherPreviewTableView = _weatherPreviewTableView;

- (WeatherSearchResultViewController *)initWithCityName:(NSString *)cityName andCityLat:(NSString *)cityLat andCithLng:(NSString *)cityLng andProvinceName:(NSString *)provinceName{
    self = [super init];
    _cityName = [cityName copy];
    _cityLat = [cityLat copy];
    _cityLng = [cityLng copy];
    _provinceName = [provinceName copy];
    return self;
}

- (void)dealloc{
    [_cityName release];
    [_cityLat release];
    [_cityLng release];
    [_provinceName release];
    NSLog(@"dealloc before:%d",[self.weatherSearchResponseModel retainCount]);
    [self.weatherSearchResponseModel release];
    [self.weatherImageView release];
    [self.conditionLabel release];
    [self.humidityLabel release];
    [self.windLabel release];
    [self.temperatureLabel release];
    [self.weatherPreviewTableView release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom

- (void)backOrHome:(UIButton *) button
{
    [self.navigationController setToolbarHidden:YES animated:NO];
    switch (button.tag) {
        case 101:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 102:
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
    }
}

- (void)reflashButtonPress{
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.bgRGB = [PiosaColorManager progressColor];
	[self.navigationController.view addSubview:_hud];
    _hud.delegate = self;
    _hud.labelText = @"加载中...";
    [_hud show:YES];
    
    NSString * addr = [NSString stringWithFormat:@"%@%@,%@",WEATHER_ADDRESS,_cityLat,_cityLng];
    NSLog(@"%@",addr);
    ASIFormDataRequest *req = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString: addr]] autorelease];
    [req addRequestHeader:@"API-Version" value:API_VERSION];
    req.timeOutSeconds = TIME_OUT_SECONDS;//设置超时时间
    [req setDelegate:self];
    [req startAsynchronous]; // 执行异步post
}

- (void)shareButtonPress{
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
	
	if (messageClass != nil) { 			
		// Check whether the current device is configured for sending SMS messages
		if ([messageClass canSendText]) {
			MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.navigationBar.tintColor = [PiosaColorManager barColor];
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            formatter.dateFormat = @"yyyy-MM-dd";
            
            WeatherPreviewModel *weatherPreviewModel1 = (WeatherPreviewModel *)[self.weatherSearchResponseModel.weatherPreviewConditions objectAtIndex:0];
            WeatherPreviewModel *weatherPreviewModel2 = (WeatherPreviewModel *)[self.weatherSearchResponseModel.weatherPreviewConditions objectAtIndex:1];
            WeatherPreviewModel *weatherPreviewModel3 = (WeatherPreviewModel *)[self.weatherSearchResponseModel.weatherPreviewConditions objectAtIndex:2];
            WeatherPreviewModel *weatherPreviewModel4 = (WeatherPreviewModel *)[self.weatherSearchResponseModel.weatherPreviewConditions objectAtIndex:3];
            
            picker.body = [NSString stringWithFormat:@"Hi~,油菜•悠行宝 %@ 提醒您:%@,%@%@-%@度,%@;%@%@-%@度,%@;%@%@-%@度,%@;%@%@-%@度,%@;"
                           ,[formatter stringFromDate:[NSDate date]],_cityName
                           ,weatherPreviewModel1.weatherDayOfWeek,weatherPreviewModel1.weatherLowTemperature,weatherPreviewModel1.weatherHighTemperature,weatherPreviewModel1.weatherCondition
                           ,weatherPreviewModel2.weatherDayOfWeek,weatherPreviewModel2.weatherLowTemperature,weatherPreviewModel2.weatherHighTemperature,weatherPreviewModel2.weatherCondition
                           ,weatherPreviewModel3.weatherDayOfWeek,weatherPreviewModel3.weatherLowTemperature,weatherPreviewModel3.weatherHighTemperature,weatherPreviewModel3.weatherCondition
                           ,weatherPreviewModel4.weatherDayOfWeek,weatherPreviewModel4.weatherLowTemperature,weatherPreviewModel4.weatherHighTemperature,weatherPreviewModel4.weatherCondition];
            picker.messageComposeDelegate = self;
            
            [self presentModalViewController:picker animated:YES];
            [picker release];
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
		}
	}
}

#pragma mark -
#pragma mark View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
    
	self.title = @"城市天气";
	
	//返回按钮
    NSString *backButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"backButton_normal" inDirectory:@"CommonView/NavigationItem"];
    NSString *backButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"backButton_highlighted" inDirectory:@"CommonView/NavigationItem"];
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    backButton.tag = 101;
    [backButton setBackgroundImage:[UIImage imageNamed:backButtonNormalPath] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:backButtonHighlightedPath] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backOrHome:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    [backBarButtonItem release];
    [backButton release];
    
    //主页按钮
    NSString *homeButtonNormalPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"homeButton_normal" inDirectory:@"CommonView/NavigationItem"];
    NSString *homeButtonHighlightedPath = [PiosaFileManager ucaiResourcesBoundleThemeFilePath:@"homeButton_highlighted" inDirectory:@"CommonView/NavigationItem"];
    UIButton * homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    homeButton.tag = 102;
    [homeButton setBackgroundImage:[UIImage imageNamed:homeButtonNormalPath] forState:UIControlStateNormal];
    [homeButton setBackgroundImage:[UIImage imageNamed:homeButtonHighlightedPath] forState:UIControlStateHighlighted];
    [homeButton addTarget:self action:@selector(backOrHome:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *homeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
    self.navigationItem.rightBarButtonItem = homeBarButtonItem;
    [homeBarButtonItem release];
    [homeButton release];
    
    //设置白色背景
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *weatherImageView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 0, 100, 100)];
    weatherImageView.backgroundColor = [UIColor clearColor];
    weatherImageView.image = [UIImage imageNamed:[CommonTools changToCurrentWeatherImageName:self.weatherSearchResponseModel.weatherIcon]];
    self.weatherImageView = weatherImageView;
    [self.view addSubview:weatherImageView];
    [weatherImageView release];
    
    UILabel *cityNameAndProvinceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 40)];
    cityNameAndProvinceNameLabel.backgroundColor = [UIColor clearColor];
    cityNameAndProvinceNameLabel.textColor = [PiosaColorManager barColor];
    cityNameAndProvinceNameLabel.textAlignment = UITextAlignmentCenter;
    cityNameAndProvinceNameLabel.font = [UIFont boldSystemFontOfSize:20];
    cityNameAndProvinceNameLabel.text = [NSString stringWithFormat:@"%@-%@",_cityName,_provinceName];
    [self.view addSubview:cityNameAndProvinceNameLabel];
    [cityNameAndProvinceNameLabel release];
    
    UILabel *conditionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 140, 220, 20)];
    conditionLabel.backgroundColor = [UIColor clearColor];
    conditionLabel.font = [UIFont boldSystemFontOfSize:17];
    conditionLabel.text = [NSString stringWithFormat:@"%@",self.weatherSearchResponseModel.weatherCondition];
    self.conditionLabel = conditionLabel;
    [self.view addSubview:conditionLabel];
    [conditionLabel release];
    
    UILabel *humidityLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 160, 220, 20)];
    humidityLabel.backgroundColor = [UIColor clearColor];
    humidityLabel.font = [UIFont boldSystemFontOfSize:15];
    humidityLabel.text = [NSString stringWithFormat:@"%@",self.weatherSearchResponseModel.weatherHumidity];
    self.humidityLabel = humidityLabel;
    [self.view addSubview:humidityLabel];
    [humidityLabel release];
    
    UILabel *windLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 180, 220, 20)];
    windLabel.backgroundColor = [UIColor clearColor];
    windLabel.font = [UIFont boldSystemFontOfSize:15];
    windLabel.text = [NSString stringWithFormat:@"%@",self.weatherSearchResponseModel.weatherWind];
    self.windLabel = windLabel;
    [self.view addSubview:windLabel];
    [windLabel release];
    
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 140, 100, 60)];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.font = [UIFont boldSystemFontOfSize:40];
    temperatureLabel.textAlignment = UITextAlignmentCenter;
    temperatureLabel.textColor = [UIColor orangeColor];
    if ([@"" isEqualToString:self.weatherSearchResponseModel.weatherTemperature]) {
        temperatureLabel.text = @"";
    } else {
        temperatureLabel.text = [NSString stringWithFormat:@"%@°",self.weatherSearchResponseModel.weatherTemperature];
    }
    self.temperatureLabel = temperatureLabel;
    [self.view addSubview:temperatureLabel];
    [temperatureLabel release];
	
	UITableView * uiTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, 320, 180) style:UITableViewStylePlain];
    uiTableView.scrollEnabled = NO;
	uiTableView.dataSource = self;
	uiTableView.delegate = self;
    [self.view addSubview:uiTableView];
    [uiTableView release];
    
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    UIButton *reflashButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    reflashButton.backgroundColor = [UIColor clearColor];
    NSString *reflashPath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"reflash" inDirectory:@"CommonView"];
    [reflashButton setImage:[UIImage imageNamed:reflashPath] forState:UIControlStateNormal];
    [reflashButton addTarget:self action:@selector(reflashButtonPress) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *reflashBarItem = [[UIBarButtonItem alloc] initWithCustomView:reflashButton];
    [reflashButton release];
    
    UIBarButtonItem *centerBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    shareButton.backgroundColor = [UIColor clearColor];
    NSString *sharePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"share" inDirectory:@"CommonView"];
    [shareButton setImage:[UIImage imageNamed:sharePath] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonPress) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareBarItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    [shareButton release];
    
    NSArray * toolBarItemArray = [[NSArray alloc] initWithObjects:reflashBarItem,centerBarItem,shareBarItem, nil];
    [reflashBarItem release];
    [centerBarItem release];
    [shareBarItem release];
    
    [self setToolbarItems:toolBarItemArray];
    //[toolBarItemArray release];
    
    NSLog(@"loadView:%d",[self.weatherSearchResponseModel retainCount]);
    
}

#pragma mark -
#pragma mark MFMessageComposeViewControllerDelegate Methods

// Dismisses the message composition interface when users tap Cancel or Send. Proceeds to update the 
// feedback message field with the result of the operation.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller 
                 didFinishWithResult:(MessageComposeResult)result {
	
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MessageComposeResultCancelled:	
            break;
		case MessageComposeResultSent:
            break;
		case MessageComposeResultFailed:
            break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark ASIHTTP Delegate Methods

// 响应有响应 : 但可能是错误响应, 如 404
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSLog(@"requestFinished\n");
    NSString *responseString = [request responseString];
    NSLog(@"%@\n", responseString);
    
    [_hud hide:YES];
    if ((responseString != nil) && [responseString length] > 0) {
		WeatherSearchResponseModel *weatherSearchResponseModel = [ResponseParser loadWeatherSearchResponse:[request responseString]];
        
        if (weatherSearchResponseModel == nil) {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            hud.bgRGB = [PiosaColorManager progressColor];
            [self.navigationController.view addSubview:hud];
            hud.delegate = self;
            NSString *exclamationImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"exclamation" inDirectory:@"CommonView/ProgressView"];
            UIImageView *exclamationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:exclamationImagePath]];
            exclamationImageView.frame = CGRectMake(0, 0, 37, 37);
            hud.customView = exclamationImageView;
            [exclamationImageView release];
            hud.opacity = 1.0;
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"没有相关城市天气信息!";
            hud.detailsLabelText = @"请重新选择城市";
            [hud show:YES];
            [hud hide:YES afterDelay:3];
        } else {
            self.weatherImageView.image = [UIImage imageNamed:[CommonTools changToCurrentWeatherImageName:self.weatherSearchResponseModel.weatherIcon]];
            self.weatherSearchResponseModel = weatherSearchResponseModel;
            self.conditionLabel.text = [NSString stringWithFormat:@"%@",self.weatherSearchResponseModel.weatherCondition];
            self.humidityLabel.text = [NSString stringWithFormat:@"%@",self.weatherSearchResponseModel.weatherHumidity];
            self.windLabel.text = [NSString stringWithFormat:@"%@",self.weatherSearchResponseModel.weatherWind];
            if ([@"" isEqualToString:self.weatherSearchResponseModel.weatherTemperature]) {
                self.temperatureLabel.text = @"";
            } else {
                self.temperatureLabel.text = [NSString stringWithFormat:@"%@°",self.weatherSearchResponseModel.weatherTemperature];
            }
            [self.weatherPreviewTableView reloadData];
        } 
    }
}

// 网络无响应
- (void)requestFailed:(ASIFormDataRequest *)request
{
	// 提示用户打开网络联接
    NSString *badFaceImagePath = [PiosaFileManager ucaiResourcesBoundleCommonFilePath:@"badFace" inDirectory:@"CommonView/ProgressView"];
    UIImageView *badFaceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:badFaceImagePath]];
    badFaceImageView.frame = CGRectMake(0, 0, 37, 37);
    _hud.customView = badFaceImageView;
    [badFaceImageView release];
	_hud.mode = MBProgressHUDModeCustomView;
	_hud.labelText = @"网络连接失败啦";
    [_hud hide:YES afterDelay:3];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

//设置表格单元的展现
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        WeatherPreviewModel *weatherPreviewModel = (WeatherPreviewModel *)[self.weatherSearchResponseModel.weatherPreviewConditions objectAtIndex:indexPath.row];
        
        UIImageView *weatherImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 1, 40, 40)];
        weatherImageView.backgroundColor = [UIColor clearColor];
        weatherImageView.image = [UIImage imageNamed:[CommonTools changToCurrentWeatherImageName:weatherPreviewModel.weatherIcon]];
        [cell.contentView addSubview:weatherImageView];
        [weatherImageView release];
        
        UILabel *dayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 12, 60, 20)];
        dayOfWeekLabel.backgroundColor = [UIColor clearColor];
        //dayOfWeekLabel.font = [UIFont boldSystemFontOfSize:40];
        dayOfWeekLabel.textAlignment = UITextAlignmentCenter;
        dayOfWeekLabel.text = [NSString stringWithFormat:@"%@",weatherPreviewModel.weatherDayOfWeek];
        [cell.contentView addSubview:dayOfWeekLabel];
        [dayOfWeekLabel release];
        
        UILabel *conditionLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 12, 90, 20)];
        conditionLabel.backgroundColor = [UIColor clearColor];
        conditionLabel.textColor = [PiosaColorManager barColor];
        conditionLabel.textAlignment = UITextAlignmentRight;
        conditionLabel.text = [NSString stringWithFormat:@"%@",weatherPreviewModel.weatherCondition];
        [cell.contentView addSubview:conditionLabel];
        [conditionLabel release];
        
        UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 12, 80, 20)];
        temperatureLabel.backgroundColor = [UIColor clearColor];
        temperatureLabel.textColor = [UIColor grayColor];
        temperatureLabel.textAlignment = UITextAlignmentRight;
        temperatureLabel.text = [NSString stringWithFormat:@"%@°/%@°",weatherPreviewModel.weatherLowTemperature,weatherPreviewModel.weatherHighTemperature];
        [cell.contentView addSubview:temperatureLabel];
        [temperatureLabel release];
        
	}
    
    return cell;
}

#pragma mark -
#pragma mark Table delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 43;
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    [hud release];
	hud = nil;
}


@end

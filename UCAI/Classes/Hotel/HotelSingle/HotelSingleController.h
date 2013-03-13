//
//  HotelSingleController.h
//  JingDuTianXia
//
//  Created by Piosa on 11-11-1.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HotelSingleSearchResponse;
@class UIHTTPImageView;

@interface HotelSingleController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,copy) NSString * checkInDate;  //入住时间
@property (nonatomic,copy) NSString * checkOutDate; //退房时间
@property (nonatomic,retain) HotelSingleSearchResponse * hotelSingleSearchResponse;

@property (nonatomic,retain) UILabel * hotelNameLabel;
@property (nonatomic,retain) UIImageView * hotelStarView;

@property (nonatomic,retain) UIHTTPImageView * httpImageView;
@property (nonatomic,retain) UILabel * hotelAddressLabel;
@property (nonatomic,retain) UILabel * hotelPORLabel;
@property (nonatomic,retain) UILabel * hotelDistrictLabel;
@property (nonatomic,retain) UILabel * hotelRoomCountLabel;

@property(nonatomic, retain) UIButton * roomInfoLeftSegmentControlButton;           //房型信息左按钮
@property(nonatomic, retain) UIButton * hotelInfoRightSegmentControlButton;         //酒店信息右按钮

@property (nonatomic,retain) UILabel * roomTableFixedCellLabel; 
@property (nonatomic,retain) UITableView * roomTableView;       //房型列表

@property (nonatomic,retain) UILabel * infoTableFixedCellLabel;
@property (nonatomic,retain) UITableView * infoTableView;       //酒店信息列表

@property (nonatomic,retain) NSIndexPath * expandedCellIndexPath;
@property (nonatomic,retain) NSIndexPath * selectingCellIndexPath;

@end

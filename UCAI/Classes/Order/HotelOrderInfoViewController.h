//
//  HotelOrderInfoViewController.h
//  UCAI
//
//  Created by  on 11-12-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class HotelOrderInfoSearchResponseModel;

@interface HotelOrderInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>{
    @private
    MBProgressHUD *_hud;
}

@property(nonatomic,assign) BOOL isMemberLogin; //标识此订单是否由会员订单列表查询而出(如果为YES,则以下两个属性为nil)
@property(nonatomic,copy) NSString * lastContractNameForSearchHotleOrderList;   //用于游客酒店订单列表查询时的联系人姓名
@property(nonatomic,copy) NSString * lastContractPhoneForSearchHotleOrderList;  //用于游客酒店订单列表查询时的联系手机

@property(nonatomic,copy) NSString * tpsOrderId;

@property(nonatomic,retain) UITableView * hotelOrderInfoTableView;

@property(nonatomic,retain) UILabel * orderIDContentLabel;
@property(nonatomic,retain) UILabel * orderPriceContentLabel;
@property(nonatomic,retain) UILabel * orderTimeContentLabel;
@property(nonatomic,retain) UILabel * orderPayContentLabel;
@property(nonatomic,retain) UILabel * orderStatusContentLabel;
@property(nonatomic,retain) UILabel * hotelNameContentLabel;
@property(nonatomic,retain) UILabel * roomTypeContentLabel;
@property(nonatomic,retain) UILabel * stayDayContentLabel;
@property(nonatomic,retain) UILabel * roomCountContentLabel;
@property(nonatomic,retain) UILabel * arrivedTimeContentLabel;
@property(nonatomic,retain) NSMutableArray * guestArray;
@property(nonatomic,retain) UILabel * linkNameContentLabel;  //联系人姓名
@property(nonatomic,retain) UILabel * linkMobileContentLabel;//联系人手机号码

@property(nonatomic,retain) HotelOrderInfoSearchResponseModel *hotelOrderInfoSearchResponseModel;

- (NSData*)generateHotelOrderInfoSearchRequestPostXMLData;

@end

//
//  FlightDetailSearchResponseModel.h
//  UCAI
//
//  Created by  on 12-1-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightClassSeat : NSObject

@property (nonatomic, copy) NSString *price;        // 销售价格
@property (nonatomic, copy) NSString *rebate;       // 折扣
@property (nonatomic, copy) NSString *classType;    // 舱位类型(1为公布运价舱位，0为特价舱位)
@property (nonatomic, copy) NSString *classCode;    // 舱位代码
@property (nonatomic, copy) NSString *status;       // 最低舱的舱位可售状态, 值A: >9个仓位可售, 1-9: 可售仓位个数, 其他字母： S,Q等，我们系统视作不可售
@property (nonatomic, copy) NSString *scgd;         // 升舱补差
@property (nonatomic, copy) NSString *tpgd;         // 收取30%的退票费
@property (nonatomic, copy) NSString *qzgd;         // 不允许签转，每次更改收取20%的改期费
@property (nonatomic, copy) NSString *bz;           // 备注
@property (nonatomic, copy) NSString *ucaiPrice;    // 最低舱的油菜价
@property (nonatomic, copy) NSString *save;         // 使用油菜价时所节省的金钱数额

@end

@interface FlightDetailSearchResponseModel : NSObject

@property (nonatomic, copy) NSString *resultCode;       // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;    // 返回结果信息

@property (nonatomic, copy) NSString *flightID;
@property (nonatomic, copy) NSString *flightCode;
@property (nonatomic, copy) NSString *companyCode;
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *fromTime;
@property (nonatomic, copy) NSString *toTime;
@property (nonatomic, copy) NSString *fromAirportCode;
@property (nonatomic, copy) NSString *fromAirportName;
@property (nonatomic, copy) NSString *toAirportCode;
@property (nonatomic, copy) NSString *toAirportName;
@property (nonatomic, copy) NSString *plantype;
@property (nonatomic, copy) NSString *stopNum;
@property (nonatomic, copy) NSString *meal;
@property (nonatomic, copy) NSString *tax;
@property (nonatomic, copy) NSString *airTax;
@property (nonatomic, copy) NSString *yPrice;
@property (nonatomic, copy) NSString *eTicket;
@property (nonatomic, retain) NSMutableArray *classSeats; //(FlightClassSeat)

@end

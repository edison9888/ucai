//
//  FlightListSearchResponseModel.h
//  UCAI
//
//  Created by  on 12-1-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheapestFlight : NSObject

@property (nonatomic, copy) NSString *classCode;    // 舱位代码
@property (nonatomic, copy) NSString *classType;    // 舱位类型(1为公布运价舱位，0为特价舱位)
@property (nonatomic, copy) NSString *status;       // 最低舱的舱位可售状态, 值A: >9个仓位可售, 1-9: 可售仓位个数, 其他字母： S,Q等，我们系统视作不可售
@property (nonatomic, copy) NSString *price;        // 最低舱的票价
@property (nonatomic, copy) NSString *rebate;       // 最低舱的折扣
@property (nonatomic, copy) NSString *scgd;         // 最低舱的升舱规定
@property (nonatomic, copy) NSString *tpgd;         // 最低舱的退票规定
@property (nonatomic, copy) NSString *qzgd;         // 最低舱的签转规定
@property (nonatomic, copy) NSString *bz;           // 最低舱的备注
@property (nonatomic, copy) NSString *ucaiPrice;    // 最低舱的油菜价
@property (nonatomic, copy) NSString *save;         // 使用油菜价时所节省的金钱数额

@end

@interface FLightListInfoModel : NSObject 

@property (nonatomic, copy) NSString *flightID;         // 航班ID
@property (nonatomic, copy) NSString *flightCode;       // 航班号(字符串)航班号(字符串)
@property (nonatomic, copy) NSString *companyCode;      // 航空公司代码(大写2字码)
@property (nonatomic, copy) NSString *companyName;      // 航空公司名称
@property (nonatomic, copy) NSString *fromTime;         // 出发时间(hhmm)
@property (nonatomic, copy) NSString *toTime;           // 到达时间(hhmm)
@property (nonatomic, copy) NSString *fromAirportCode;  // 出发机场编码(大写3字码)
@property (nonatomic, copy) NSString *fromAirportName;  // 出发机场名字
@property (nonatomic, copy) NSString *toAirportCode;    // 到达机场编码(大写3字码)
@property (nonatomic, copy) NSString *toAirportName;    // 到达机场名字
@property (nonatomic, copy) NSString *plantype;         // 机型
@property (nonatomic, copy) NSString *stopNum;          // 经停次数（0为直达，一般为0,1,2）
@property (nonatomic, copy) NSString *meal;             // 有无餐食(true/false)
@property (nonatomic, copy) NSString *tax;              // 燃油税
@property (nonatomic, copy) NSString *airTax;           // 基建
@property (nonatomic, copy) NSString *yPrice;           // Y舱价格
@property (nonatomic, copy) NSString *eTicket;          // 有无电子客票(true/flase)
@property (nonatomic, retain) CheapestFlight *cheapest;  // 本航班最便宜的舱位信息

@end

@interface FlightListSearchResponseModel : NSObject

@property (nonatomic, copy) NSString *resultCode;       // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;    // 返回结果信息

@property (nonatomic, copy) NSString *currentPage;      // 数字,当前请求页,需大于0
@property (nonatomic, copy) NSString *pageSize;         // 数字,每页显示记录数
@property (nonatomic, copy) NSString *count;            // 总记录数
@property (nonatomic, retain) NSMutableArray *flights;  // 航班数据

@end

//
//  TrainDetailResponseModel.h
//  UCAI
//
//  Created by  on 12-1-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrainStationData : NSObject 

@property (nonatomic, copy) NSString *ID;			//排序编号
@property (nonatomic, copy) NSString *TrainCode;	//列车车次
@property (nonatomic, copy) NSString *SNo;		// 站序号
@property (nonatomic, copy) NSString *SName;	//站名
@property (nonatomic, copy) NSString *ArrTime;	//到达时间，时间格式为“HH:mm”
@property (nonatomic, copy) NSString *GoTime;	//发车时间，时间格式为“HH:mm”
@property (nonatomic, copy) NSString *Distance;	//站站距离
@property (nonatomic, copy) NSString *CostTime;	//运行时间，时间格式为“HH:mm”，HH表示小时数，mm表示分钟数
@property (nonatomic, copy) NSString *YZ;		//硬座票价
@property (nonatomic, copy) NSString *RZ;		//软座票价
@property (nonatomic, copy) NSString *RZ1;		//一等软座票价
@property (nonatomic, copy) NSString *RZ2;		//二等软座票价
@property (nonatomic, copy) NSString *YWS;		//硬卧上铺票价
@property (nonatomic, copy) NSString *YWZ;		//硬卧中铺票价
@property (nonatomic, copy) NSString *YWX;		//硬卧下铺票价
@property (nonatomic, copy) NSString *RWS;		//软卧上铺票价
@property (nonatomic, copy) NSString *RWX;		//软卧下铺票价
@property (nonatomic, copy) NSString *GWS;		//高级软卧上铺票价
@property (nonatomic, copy) NSString *GWX;		//高级软卧下铺票价

@end


@interface TrainDetailResponseModel : NSObject

@property (nonatomic, copy) NSString *sDate;    //搜索的日期, YYYY-MM-DD
@property (nonatomic, copy) NSString *sType;    //返回结果类型，这里固定为“InfoTrain”
@property (nonatomic, copy) NSString *searchCode;   //查询结果代码，“0”为失败，“1”为成功
@property (nonatomic, copy) NSString *errInfo;  //查询失败提示信息
@property (nonatomic, copy) NSString *iCount;   //查询成功时返回的结果数量 1..N
@property (nonatomic, retain) NSMutableArray *data; //(TrainData)

@end

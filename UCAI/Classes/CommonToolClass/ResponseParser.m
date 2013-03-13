//
//  TrainDetailResponseParser.m
//  JingDuTianXia
//
//  Created by Chen Menglin on 4/20/11.
//  Copyright 2011 __JingDuTianXia__. All rights reserved.
//

#import "ResponseParser.h"
#import "GDataXMLNode.h"

#import "TrainSearchResponseModel.h"
#import "TrainDetailResponseModel.h"

#import "FlightReserveResponseModel.h"
#import "FlightListSearchResponseModel.h"
#import "FlightDetailSearchResponseModel.h"
#import "FlightOrderListSearchResponseModel.h"
#import "FlightOrderListInfoModel.h"
#import "FlightOrderInfoSearchResponseModel.h"
#import "FlightBookResponseModel.h"

#import "MemberLoginResponse.h"
#import "MemberRegisterResponse.h"
#import "MemberPasswordBackResponse.h"
#import "MemberInfoQueryResponse.h"
#import "MemberPhoneVerifySendResponse.h"
#import "MemberInfoModifyResponse.h"
#import "MemberPasswordModifyResponse.h"
#import "MemberFlightHistoryCustomerQueryResponse.h"
#import "MemberFlightHistoryCustomerDeleteResponse.h"

#import "HotelListSearchResponse.h"
#import "HotelListInfo.h"
#import "HotelSingleSearchResponse.h"
#import "HotelRoomInfo.h"
#import "HotelBookResponse.h"
#import "HotelOrderListSearchResponseModel.h"
#import "HotelOrderListInfoModel.h"
#import "HotelOrderInfoSearchResponseModel.h"

#import "CouponListSearchResponseModel.h"
#import "CouponListInfoModel.h"
#import "CouponInfoSearchResponseModel.h"
#import "CouponBookingResponseModel.h"
#import "CouponOrderListSearchResponseModel.h"
#import "CouponOrderInfoSearchResponseModel.h"
#import "CouponSendResponseModel.h"
#import "CouponValidQueryResponseModel.h"

#import "AllinTelPayResponseModel.h"

#import "PhoneBillRechargeResponseModel.h"

#import "WeatherSearchResponseModel.h"

#import "FeedbackSearchResponseModel.h"
#import "FeedbackCommitResponseModel.h"

@implementation ResponseParser

+ (FlightReserveResponseModel *)loadFlightReserveResponseModelResponse:(NSData *)xmlData{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
    
    FlightReserveResponseModel * flightReserveResponseModel = [[[FlightReserveResponseModel alloc] init] autorelease];
    flightReserveResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
    flightReserveResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
    
    [doc release];
    return flightReserveResponseModel;
}


#pragma mark 火车查询业务数据解析

// 从字串中得到XML DOM 对象，生成对应的 TrainResponse对象
+ (TrainSearchResponseModel *)loadTrainSearchResponse:(NSData *)xmlData
{
	NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}

	TrainSearchResponseModel * trainResponse = [[[TrainSearchResponseModel alloc] init] autorelease];
	
	trainResponse.sDate = [(GDataXMLElement *)[[doc nodesForXPath:@"//OTResponse/Sdate[1]" error:nil] objectAtIndex:0] stringValue];
	trainResponse.sType = [(GDataXMLElement *)[[doc nodesForXPath:@"//OTResponse/SType[1]" error:nil] objectAtIndex:0] stringValue];
	trainResponse.searchCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//OTResponse/Code[1]" error:nil] objectAtIndex:0] stringValue];
	trainResponse.errInfo = [(GDataXMLElement *)[[doc nodesForXPath:@"//OTResponse/ErrInfo[1]" error:nil] objectAtIndex:0] stringValue];
	trainResponse.iCount = [(GDataXMLElement *)[[doc nodesForXPath:@"//OTResponse/iCount[1]" error:nil] objectAtIndex:0] stringValue];	
	
	NSMutableArray * trainArray = [[NSMutableArray alloc] init];
	NSInteger count = [trainResponse.iCount intValue];
	if (count > 0) { // 目前可能取 -1
		for (NSInteger idx = 1; idx <= count; ++idx) {
			TrainData *trainData = [[TrainData alloc] init];
			
			trainData.ID = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/ID", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.TrainCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/TrainCode", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.TrainType = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/TrainType", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.StartCity = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/StartCity", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.StartTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/StartTime", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.EndCity = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/EndCity", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.EndTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/EndTime", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.Distance = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/Distance", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.CostTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/CostTime", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.YZ = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/YZ", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.RZ = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/RZ", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.RZ1 = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/RZ1", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.RZ2 = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/RZ2", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.YWS = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/YWS", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.YWZ = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/YWZ", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.YWX = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/YWX", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.RWS = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/RWS", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.RWX = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/RWX", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.GWS = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/GWS", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.GWX = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/GWX", idx] error:nil] objectAtIndex:0] stringValue];
			
			[trainArray addObject:trainData];
            [trainData release];
		}
	}
    
    trainResponse.data = trainArray;
    [trainArray release];
	
	[doc release];
	return trainResponse;
}

// 从字串中得到XML DOM 对象，生成对应的 TrainDetailResponse对象
+ (TrainDetailResponseModel *)loadTrainDetailResponse:(NSData *)xmlData
{
	NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}

	TrainDetailResponseModel * trainDetailResponse = [[[TrainDetailResponseModel alloc] init] autorelease];
	
	trainDetailResponse.sDate = [(GDataXMLElement *)[[doc nodesForXPath:@"//OTResponse/Sdate[1]" error:nil] objectAtIndex:0] stringValue];
	trainDetailResponse.sType = [(GDataXMLElement *)[[doc nodesForXPath:@"//OTResponse/SType[1]" error:nil] objectAtIndex:0] stringValue];
	trainDetailResponse.searchCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//OTResponse/Code[1]" error:nil] objectAtIndex:0] stringValue];
	trainDetailResponse.errInfo = [(GDataXMLElement *)[[doc nodesForXPath:@"//OTResponse/ErrInfo[1]" error:nil] objectAtIndex:0] stringValue];
	trainDetailResponse.iCount = [(GDataXMLElement *)[[doc nodesForXPath:@"//OTResponse/iCount[1]" error:nil] objectAtIndex:0] stringValue];	
	
    NSMutableArray * stationArray = [[NSMutableArray alloc] init];
	NSInteger count = [trainDetailResponse.iCount intValue];
	if (count > 0) { // 目前可能取 -1
		for (NSInteger idx = 1; idx <= count; ++idx) {
			TrainStationData *trainData = [[TrainStationData alloc] init];
			
			trainData.ID = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/ID", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.TrainCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/TrainCode", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.SNo = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/SNo", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.SName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/SName", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.ArrTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/ArrTime", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.GoTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/GoTime", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.Distance = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/Distance", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.CostTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/CostTime", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.YZ = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/YZ", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.RZ = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/RZ", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.RZ1 = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/RZ1", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.RZ2 = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/RZ2", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.YWS = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/YWS", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.YWZ = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/YWZ", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.YWX = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/YWX", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.RWS = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/RWS", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.RWX = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/RWX", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.GWS = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/GWS", idx] error:nil] objectAtIndex:0] stringValue];
			trainData.GWX = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//OTResponse/Data[%d]/GWX", idx] error:nil] objectAtIndex:0] stringValue];

			[stationArray addObject:trainData];
            [trainData release];
		}
	}
    
    trainDetailResponse.data = stationArray;
    [stationArray release];

	[doc release];
	return trainDetailResponse;
}

#pragma mark 航班查询业务数据解析

+ (FlightListSearchResponseModel *)loadFlightListSearchResponse:(NSData *)xmlData oldFlightList:(FlightListSearchResponseModel *)flightList{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
    
    if (flightList == nil) {
        FlightListSearchResponseModel * flightListSearchResponseModel = [[[FlightListSearchResponseModel alloc] init] autorelease];
        
        flightListSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
        flightListSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
        flightListSearchResponseModel.currentPage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/currentPage" error:nil] objectAtIndex:0] stringValue];
        flightListSearchResponseModel.pageSize = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/pageSize" error:nil] objectAtIndex:0] stringValue];
        flightListSearchResponseModel.count = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/count" error:nil] objectAtIndex:0] stringValue];
        
        NSArray *arr = [doc nodesForXPath:@"//response/result-body/result/flights/flight" error:nil];
        NSInteger num = [arr count];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (NSInteger idx = 1; idx <= num; ++idx) 
        {
            FLightListInfoModel *fLightListInfoModel = [[[FLightListInfoModel alloc] init] autorelease];
            
            fLightListInfoModel.flightID = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/id", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.flightCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/code", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.companyCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/companyCode", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.companyName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/companyName", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.fromTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/fromTime", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.toTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/toTime", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.fromAirportCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/fromAirportCode", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.fromAirportName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/fromAirportName", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.toAirportCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/toAirportCode", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.toAirportName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/toAirportName", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.plantype = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/plantype", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.stopNum = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/stopNum", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.meal = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/meal", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.tax = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/tax", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.airTax = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/airTax", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.yPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/yPrice", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.eTicket = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/eTicket", idx] error:nil] objectAtIndex:0] stringValue];
            
            CheapestFlight *cheapestClass = [[CheapestFlight alloc] init];
            cheapestClass.classCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/classCode", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.classType = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/classType", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.status = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/status", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.price = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/price", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.rebate = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/rebate", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.scgd = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/scgd", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.tpgd = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/tpgd", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.qzgd = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/qzgd", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.bz = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/bz", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.ucaiPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/ucaiPrice", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.save = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/save", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.cheapest = cheapestClass;
            [cheapestClass release];
            
            [array addObject:fLightListInfoModel];
        }
        
        flightListSearchResponseModel.flights = array;
        [array release];
        
        [doc release];
        return flightListSearchResponseModel;
    } else {
        FlightListSearchResponseModel * flightListSearchResponseModel = [[[FlightListSearchResponseModel alloc] init] autorelease];
        
        flightListSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
        flightListSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
        flightListSearchResponseModel.currentPage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/currentPage" error:nil] objectAtIndex:0] stringValue];
        flightListSearchResponseModel.pageSize = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/pageSize" error:nil] objectAtIndex:0] stringValue];
        flightListSearchResponseModel.count = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/count" error:nil] objectAtIndex:0] stringValue];
        
        NSArray *arr = [doc nodesForXPath:@"//response/result-body/result/flights/flight" error:nil];
        NSInteger num = [arr count];
        
        for (NSInteger idx = 1; idx <= num; ++idx) 
        {
            FLightListInfoModel *fLightListInfoModel = [[[FLightListInfoModel alloc] init] autorelease];
            
            fLightListInfoModel.flightID = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/id", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.flightCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/code", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.companyCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/companyCode", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.companyName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/companyName", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.fromTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/fromTime", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.toTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/toTime", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.fromAirportCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/fromAirportCode", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.fromAirportName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/fromAirportName", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.toAirportCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/toAirportCode", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.toAirportName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/toAirportName", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.plantype = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/plantype", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.stopNum = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/stopNum", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.meal = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/meal", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.tax = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/tax", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.airTax = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/airTax", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.yPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/yPrice", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.eTicket = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/eTicket", idx] error:nil] objectAtIndex:0] stringValue];
            
            CheapestFlight *cheapestClass = [[CheapestFlight alloc] init];
            cheapestClass.classCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/classCode", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.classType = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/classType", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.status = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/status", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.price = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/price", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.rebate = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/rebate", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.scgd = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/scgd", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.tpgd = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/tpgd", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.qzgd = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/qzgd", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.bz = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/bz", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.ucaiPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/ucaiPrice", idx] error:nil] objectAtIndex:0] stringValue];
            cheapestClass.save = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flights/flight[%d]/cheapestClass/save", idx] error:nil] objectAtIndex:0] stringValue];
            fLightListInfoModel.cheapest = cheapestClass;
            [cheapestClass release];
            
            [flightList.flights addObject:fLightListInfoModel];
        }
        
        flightListSearchResponseModel.flights = flightList.flights;
        
        [doc release];
        return flightListSearchResponseModel;
    }
}

+ (FlightDetailSearchResponseModel *)loadFlightDetailSearchResponse:(NSData *)xmlData{

    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	FlightDetailSearchResponseModel * flightDetailSearchResponseModel = [[[FlightDetailSearchResponseModel alloc] init] autorelease];
	flightDetailSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
	flightDetailSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
    
	flightDetailSearchResponseModel.flightID = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/id" error:nil] objectAtIndex:0] stringValue];
	flightDetailSearchResponseModel.flightCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/code" error:nil] objectAtIndex:0] stringValue];	
	flightDetailSearchResponseModel.companyCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/companyCode" error:nil] objectAtIndex:0] stringValue];
	flightDetailSearchResponseModel.companyName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/companyName" error:nil] objectAtIndex:0] stringValue];
	flightDetailSearchResponseModel.fromTime = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/fromTime" error:nil] objectAtIndex:0] stringValue];
	flightDetailSearchResponseModel.toTime = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/toTime" error:nil] objectAtIndex:0] stringValue];	
	flightDetailSearchResponseModel.fromAirportCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/fromAirportCode" error:nil] objectAtIndex:0] stringValue];
	flightDetailSearchResponseModel.toAirportCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/toAirportCode" error:nil] objectAtIndex:0] stringValue];
	flightDetailSearchResponseModel.fromAirportName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/fromAirportName" error:nil] objectAtIndex:0] stringValue];
	flightDetailSearchResponseModel.toAirportName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/toAirportName" error:nil] objectAtIndex:0] stringValue];
	flightDetailSearchResponseModel.plantype = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/plantype" error:nil] objectAtIndex:0] stringValue];	
	flightDetailSearchResponseModel.stopNum = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/stopNum" error:nil] objectAtIndex:0] stringValue];
	flightDetailSearchResponseModel.meal = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/meal" error:nil] objectAtIndex:0] stringValue];
	flightDetailSearchResponseModel.tax = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/tax" error:nil] objectAtIndex:0] stringValue];	
	flightDetailSearchResponseModel.airTax = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/airTax" error:nil] objectAtIndex:0] stringValue];
	flightDetailSearchResponseModel.yPrice = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/yPrice" error:nil] objectAtIndex:0] stringValue];
	flightDetailSearchResponseModel.eTicket = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/flight/eTicket" error:nil] objectAtIndex:0] stringValue];
	
	// 如何得知classSeats里面有几个classSeat
	NSArray *arr = [doc nodesForXPath:@"//response/result-body/result/flight/classSeats/classSeat" error:nil];
	NSInteger num = [arr count];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
	
	for (NSInteger idx = 1; idx <= num; ++idx) 
	{
		FlightClassSeat *seat = [[[FlightClassSeat alloc] init] autorelease];
		seat.price = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flight/classSeats/classSeat[%d]/price", idx] error:nil] objectAtIndex:0] stringValue];
		seat.rebate = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flight/classSeats/classSeat[%d]/rebate", idx] error:nil] objectAtIndex:0] stringValue];
		seat.classType = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flight/classSeats/classSeat[%d]/classType", idx] error:nil] objectAtIndex:0] stringValue];
		seat.classCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flight/classSeats/classSeat[%d]/classCode", idx] error:nil] objectAtIndex:0] stringValue];
		seat.status = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flight/classSeats/classSeat[%d]/status", idx] error:nil] objectAtIndex:0] stringValue];			
		seat.scgd = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flight/classSeats/classSeat[%d]/scgd", idx] error:nil] objectAtIndex:0] stringValue];			
		seat.tpgd = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flight/classSeats/classSeat[%d]/tpgd", idx] error:nil] objectAtIndex:0] stringValue];			
		seat.qzgd = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flight/classSeats/classSeat[%d]/qzgd", idx] error:nil] objectAtIndex:0] stringValue];			
		seat.bz = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flight/classSeats/classSeat[%d]/bz", idx] error:nil] objectAtIndex:0] stringValue];			
		seat.ucaiPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flight/classSeats/classSeat[%d]/ucaiPrice", idx] error:nil] objectAtIndex:0] stringValue];			
		seat.save = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/flight/classSeats/classSeat[%d]/save", idx] error:nil] objectAtIndex:0] stringValue];			
		
		[array addObject:seat];
	}
    
    flightDetailSearchResponseModel.classSeats = array;
    [array release];
	
	[doc release];
	return flightDetailSearchResponseModel;
}

// 解析机票订购响应xml数据(new)
+ (FlightBookResponseModel *)loadFlightBookResponse:(NSData *)xmlData{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	FlightBookResponseModel * flightBookResponseModel = [[[FlightBookResponseModel alloc] init] autorelease];
	
	flightBookResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
	flightBookResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
	
	
	if ([flightBookResponseModel.resultCode intValue] == 0) {
		flightBookResponseModel.orderNo = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/orderNo" error:nil] objectAtIndex:0] stringValue];
		flightBookResponseModel.orderTime = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/orderTime" error:nil] objectAtIndex:0] stringValue];
		flightBookResponseModel.orderPrice = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/orderPrice" error:nil] objectAtIndex:0] stringValue];		
	}
    
    [doc release];
	return flightBookResponseModel;
}

#pragma mark 机票订单查询业务数据解析

+ (FlightOrderListSearchResponseModel *)loadFlightOrderListSearchResponse:(NSData *)xmlData oldFlightOrderList:(FlightOrderListSearchResponseModel *)flightOrderList{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
    
    if (flightOrderList == nil) {
        FlightOrderListSearchResponseModel * flightOrderListSearchResponseModel = [[[FlightOrderListSearchResponseModel alloc] init] autorelease];
        
        flightOrderListSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
        flightOrderListSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
        
		
        if ([flightOrderListSearchResponseModel.resultCode intValue] == 0) {
            NSArray *orders = [doc nodesForXPath:@"//response/result-body/result/orders/order" error:nil];
            NSInteger num = [orders count];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (NSInteger idx = 1; idx <= num; idx++) 
            {
                FlightOrderListInfoModel *flightOrderListInfoModel = [[FlightOrderListInfoModel alloc] init];
                flightOrderListInfoModel.orderID = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/orderID", idx] error:nil] objectAtIndex:0] stringValue];
                flightOrderListInfoModel.orderStatus = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/orderPayStatus", idx] error:nil] objectAtIndex:0] stringValue];
                flightOrderListInfoModel.orderTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/time", idx] error:nil] objectAtIndex:0] stringValue];
                flightOrderListInfoModel.orderPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/price", idx] error:nil] objectAtIndex:0] stringValue];
                flightOrderListInfoModel.orderType = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/type", idx] error:nil] objectAtIndex:0] stringValue];
                flightOrderListInfoModel.fromCity = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/fromCity", idx] error:nil] objectAtIndex:0] stringValue];
                flightOrderListInfoModel.toCity = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/toCity", idx] error:nil] objectAtIndex:0] stringValue];
                [array addObject:flightOrderListInfoModel];
                [flightOrderListInfoModel release];
            }
            
            flightOrderListSearchResponseModel.orders = array;
            [array release];
            
            flightOrderListSearchResponseModel.currentPage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/currentPage" error:nil] objectAtIndex:0] stringValue];
            flightOrderListSearchResponseModel.pageSize = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/pageSize" error:nil] objectAtIndex:0] stringValue];
            flightOrderListSearchResponseModel.count = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/count" error:nil] objectAtIndex:0] stringValue];
        }
        
        [doc release];
        return flightOrderListSearchResponseModel;
    } else {
        FlightOrderListSearchResponseModel * flightOrderListSearchResponseModel = [[[FlightOrderListSearchResponseModel alloc] init] autorelease];
        
        flightOrderListSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
        flightOrderListSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
        
		
        if ([flightOrderListSearchResponseModel.resultCode intValue] == 0) {
            NSArray *orders = [doc nodesForXPath:@"//response/result-body/result/orders/order" error:nil];
            NSInteger num = [orders count];
            for (NSInteger idx = 1; idx <= num; idx++) 
            {
                FlightOrderListInfoModel *flightOrderListInfoModel = [[FlightOrderListInfoModel alloc] init];
                flightOrderListInfoModel.orderID = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/orderID", idx] error:nil] objectAtIndex:0] stringValue];
                flightOrderListInfoModel.orderStatus = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/orderPayStatus", idx] error:nil] objectAtIndex:0] stringValue];
                flightOrderListInfoModel.orderTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/time", idx] error:nil] objectAtIndex:0] stringValue];
                flightOrderListInfoModel.orderPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/price", idx] error:nil] objectAtIndex:0] stringValue];
                flightOrderListInfoModel.orderType = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/type", idx] error:nil] objectAtIndex:0] stringValue];
                flightOrderListInfoModel.fromCity = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/fromCity", idx] error:nil] objectAtIndex:0] stringValue];
                flightOrderListInfoModel.toCity = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/toCity", idx] error:nil] objectAtIndex:0] stringValue];
                [flightOrderList.orders addObject:flightOrderListInfoModel];
                [flightOrderListInfoModel release];
            }
            
            flightOrderListSearchResponseModel.currentPage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/currentPage" error:nil] objectAtIndex:0] stringValue];
            flightOrderListSearchResponseModel.pageSize = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/pageSize" error:nil] objectAtIndex:0] stringValue];
            flightOrderListSearchResponseModel.count = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/count" error:nil] objectAtIndex:0] stringValue];
        }
        
        flightOrderListSearchResponseModel.orders = flightOrderList.orders;
        [doc release];
        return flightOrderListSearchResponseModel;
    }
}

+ (FlightOrderInfoSearchResponseModel *)loadFlightOrderInfoSearchResponse:(NSData *)xmlData{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	FlightOrderInfoSearchResponseModel * flightOrderInfoSearchResponseModel = [[[FlightOrderInfoSearchResponseModel alloc] init] autorelease];
	
	flightOrderInfoSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
	flightOrderInfoSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
	
	if ([flightOrderInfoSearchResponseModel.resultCode intValue] == 0) {
		flightOrderInfoSearchResponseModel.orderTime = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/orderTime" error:nil] objectAtIndex:0] stringValue];
		flightOrderInfoSearchResponseModel.orderPayStatus = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/orderPayStatus" error:nil] objectAtIndex:0] stringValue];
		flightOrderInfoSearchResponseModel.orderPayPrice = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/orderPayPrice" error:nil] objectAtIndex:0] stringValue];
		
		flightOrderInfoSearchResponseModel.linkmanName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/linkman/name" error:nil] objectAtIndex:0] stringValue];
		flightOrderInfoSearchResponseModel.linkmanMobile = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/linkman/mobile" error:nil] objectAtIndex:0] stringValue];
		
		NSArray *flights = [doc nodesForXPath:@"//response/result-body/flights/flight" error:nil];
		
		NSInteger num_flights = [flights count];
        NSMutableArray * tempFlights = [[NSMutableArray alloc] init];
		for (NSInteger idx = 1; idx <= num_flights; ++idx) 
		{
			FlightOrderFlightingInfo *flightOrderFlightingInfo = [[FlightOrderFlightingInfo alloc] init];
			
			flightOrderFlightingInfo.dptCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/dptCode", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderFlightingInfo.dptName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/dptName", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderFlightingInfo.arrCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/arrCode", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderFlightingInfo.arrName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/arrName", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderFlightingInfo.fromDate = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/fromDate", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderFlightingInfo.fromTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/fromTime", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderFlightingInfo.toTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/toTime", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderFlightingInfo.companyCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/companyCode", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderFlightingInfo.companyName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/companyName", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderFlightingInfo.flightNo = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/flightNo", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderFlightingInfo.classCode = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/classCode", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderFlightingInfo.flightType = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/flightType", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderFlightingInfo.price = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/price", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderFlightingInfo.tax = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/tax", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderFlightingInfo.airTax = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/flights/flight[%d]/airTax", idx] error:nil] objectAtIndex:0] stringValue];
			
			[tempFlights addObject:flightOrderFlightingInfo];
            [flightOrderFlightingInfo release];
		}
        flightOrderInfoSearchResponseModel.flights = tempFlights;
        [tempFlights release];
		
		NSArray *customers = [doc nodesForXPath:@"//response/result-body/customers/customer" error:nil];
		NSInteger num_customers = [customers count];
        NSMutableArray * tempUsers = [[NSMutableArray alloc] init];
		for (NSInteger idx = 1; idx <= num_customers; ++idx) 
		{
			FlightOrderCustomerInfo *flightOrderCustomerInfo = [[FlightOrderCustomerInfo alloc] init];
			flightOrderCustomerInfo.name = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/customers/customer[%d]/name", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderCustomerInfo.certificateNo = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/customers/customer[%d]/certificateNo", idx] error:nil] objectAtIndex:0] stringValue];
			flightOrderCustomerInfo.type = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/customers/customer[%d]/type", idx] error:nil] objectAtIndex:0] stringValue];
			[tempUsers addObject:flightOrderCustomerInfo];
            [flightOrderCustomerInfo release];
		}
        flightOrderInfoSearchResponseModel.customers = tempUsers;
        [tempUsers release];
	}
	
    [doc release];
	return flightOrderInfoSearchResponseModel;

}

#pragma mark -
#pragma mark 会员业务数据解析

+ (MemberLoginResponse *)loadMemberLoginResponse:(NSData *)xmlData{
	NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	MemberLoginResponse * memberLoginResponse = [[[MemberLoginResponse alloc] init] autorelease];
	
	memberLoginResponse.result_code = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
	memberLoginResponse.result_message = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
	
	if ([memberLoginResponse.result_code intValue] == 0) {
		memberLoginResponse.memberID = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/id" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.registerName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/registerName" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.cardNO = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/cardNO" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.realName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/realName" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.sex = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/sex" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.phone = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/phone" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.phoneVerifyStatus = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/phoneVerifyStatus" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.eMail = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/eMail" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.contactTel = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/contactTel" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.contactAddress = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/contactAddress" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.idNumber = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/idNumber" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.accPoints = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/accPoints" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.usablePoints = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/usablePoints" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.eCardNO = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/eCard/eCardNO" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.eCardUserName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/eCard/eCardUserName" error:nil] objectAtIndex:0] stringValue];
		memberLoginResponse.eCardStatus = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/eCard/eCardStatus" error:nil] objectAtIndex:0] stringValue];
	}
	
	[doc release];
	return memberLoginResponse;
}


+ (MemberRegisterResponse *)loadMemberRegisterResponse:(NSData *)xmlData{
	NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	MemberRegisterResponse * memberRegisterResponse = [[[MemberRegisterResponse alloc] init] autorelease];
	
	memberRegisterResponse.result_code = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
	memberRegisterResponse.result_message = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
	
	if ([memberRegisterResponse.result_code intValue] == 0) {
		memberRegisterResponse.memberName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/name" error:nil] objectAtIndex:0] stringValue];
		memberRegisterResponse.memberID = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/id" error:nil] objectAtIndex:0] stringValue];
		memberRegisterResponse.cardNO = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/cardNO" error:nil] objectAtIndex:0] stringValue];
	}
	
	[doc release];
	return memberRegisterResponse;
}

+ (MemberPasswordBackResponse *)loadMemberPasswordBackResponse:(NSData *)xmlData{
	NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	MemberPasswordBackResponse * memberPasswordBackResponse = [[[MemberPasswordBackResponse alloc] init] autorelease];
	
	memberPasswordBackResponse.result_code = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
	memberPasswordBackResponse.result_message = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
	
	[doc release];
	return memberPasswordBackResponse;
}

+ (MemberInfoQueryResponse *)loadMemberInfoQueryResponse:(NSData *)xmlData{
	NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	MemberInfoQueryResponse * memberInfoQueryResponse = [[[MemberInfoQueryResponse alloc] init] autorelease];
	
	memberInfoQueryResponse.result_code = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
	memberInfoQueryResponse.result_message = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
	
	if ([memberInfoQueryResponse.result_code intValue] == 0) {
		memberInfoQueryResponse.registerName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/registerName" error:nil] objectAtIndex:0] stringValue];
		memberInfoQueryResponse.cardNO = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/cardNO" error:nil] objectAtIndex:0] stringValue];
		memberInfoQueryResponse.realName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/realName" error:nil] objectAtIndex:0] stringValue];
		memberInfoQueryResponse.sex = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/sex" error:nil] objectAtIndex:0] stringValue];
		memberInfoQueryResponse.phone = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/phone" error:nil] objectAtIndex:0] stringValue];
		memberInfoQueryResponse.phoneVerifyStatus = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/phoneVerifyStatus" error:nil] objectAtIndex:0] stringValue];
		memberInfoQueryResponse.eMail = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/eMail" error:nil] objectAtIndex:0] stringValue];
		memberInfoQueryResponse.contactTel = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/contactTel" error:nil] objectAtIndex:0] stringValue];
		memberInfoQueryResponse.idNumber = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/idNumber" error:nil] objectAtIndex:0] stringValue];
		memberInfoQueryResponse.rapeseedAmount = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/rapeseedAmount" error:nil] objectAtIndex:0] stringValue];
		memberInfoQueryResponse.exchangeRapeseedAmount = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/exchangeRapeseedAmount" error:nil] objectAtIndex:0] stringValue];
	}
	
	[doc release];
	return memberInfoQueryResponse;
}

+ (MemberPhoneVerifySendResponse *)loadMemberPhoneVerifySendResponse:(NSData *)xmlData{
	NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	MemberPhoneVerifySendResponse *memberPhoneVerifySendResponse = [[[MemberPhoneVerifySendResponse alloc] init] autorelease];
	memberPhoneVerifySendResponse.result_code = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
	memberPhoneVerifySendResponse.result_message = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
	
	if ([memberPhoneVerifySendResponse.result_code intValue] == 0) {
		memberPhoneVerifySendResponse.loseEffTime = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/loseEffTime" error:nil] objectAtIndex:0] stringValue];
	}	
	[doc release];
	return memberPhoneVerifySendResponse;
}

+ (MemberInfoModifyResponse *)loadMemberInfoModifyResponse:(NSData *)xmlData{
	NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	MemberInfoModifyResponse *memberInfoModifyResponse = [[[MemberInfoModifyResponse alloc] init] autorelease];
	memberInfoModifyResponse.result_code = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
	memberInfoModifyResponse.result_message = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
	
	if ([memberInfoModifyResponse.result_code intValue] == 0) {
		memberInfoModifyResponse.realName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/realName" error:nil] objectAtIndex:0] stringValue];
		memberInfoModifyResponse.sex = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/sex" error:nil] objectAtIndex:0] stringValue];
		memberInfoModifyResponse.phone = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/phone" error:nil] objectAtIndex:0] stringValue];
		memberInfoModifyResponse.eMail = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/eMail" error:nil] objectAtIndex:0] stringValue];
		memberInfoModifyResponse.contactTel = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/contactTel" error:nil] objectAtIndex:0] stringValue];
		memberInfoModifyResponse.idNumber = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/idNumber" error:nil] objectAtIndex:0] stringValue];
		memberInfoModifyResponse.rapeseedAmount = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/rapeseedAmount" error:nil] objectAtIndex:0] stringValue];
		memberInfoModifyResponse.exchangeRapeseedAmount = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/exchangeRapeseedAmount" error:nil] objectAtIndex:0] stringValue];
	}	
	[doc release];
	return memberInfoModifyResponse;
}

+ (MemberPasswordModifyResponse *)loadMemberPasswordModifyResponse:(NSData *)xmlData{
	NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	MemberPasswordModifyResponse *memberPasswordModifyResponse = [[[MemberPasswordModifyResponse alloc] init] autorelease];
	memberPasswordModifyResponse.result_code = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
	memberPasswordModifyResponse.result_message = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
	
	[doc release];
	return memberPasswordModifyResponse;
}


+ (MemberFlightHistoryCustomerQueryResponse *)loadMemberFlightHistoryCustomerQueryResponse:(NSData *)xmlData{
    
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	MemberFlightHistoryCustomerQueryResponse *memberFlightHistoryCustomerQueryResponse = [[[MemberFlightHistoryCustomerQueryResponse alloc] init] autorelease];
	memberFlightHistoryCustomerQueryResponse.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
	memberFlightHistoryCustomerQueryResponse.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
    
    NSArray *customers = [doc nodesForXPath:@"//response/result-body/passengers/passenger" error:nil];
    NSInteger num_customers = [customers count];
    NSMutableArray * tempUsers = [[NSMutableArray alloc] init];
    for (NSInteger idx = 1; idx <= num_customers; ++idx) 
    {
        FlightHistoryCustomer *flightHistoryCustomer = [[FlightHistoryCustomer alloc] init];
        flightHistoryCustomer.customerID = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/passengers/passenger[%d]/p_id", idx] error:nil] objectAtIndex:0] stringValue];
        flightHistoryCustomer.customerName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/passengers/passenger[%d]/p_name", idx] error:nil] objectAtIndex:0] stringValue];
        flightHistoryCustomer.customerType = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/passengers/passenger[%d]/p_typeid", idx] error:nil] objectAtIndex:0] stringValue];
        flightHistoryCustomer.certificateType = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/passengers/passenger[%d]/p_cardtype", idx] error:nil] objectAtIndex:0] stringValue];
        flightHistoryCustomer.certificateNo = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/passengers/passenger[%d]/p_cardno", idx] error:nil] objectAtIndex:0] stringValue];
        flightHistoryCustomer.secureNum = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/passengers/passenger[%d]/p_bxcount", idx] error:nil] objectAtIndex:0] stringValue];
        [tempUsers addObject:flightHistoryCustomer];
        [flightHistoryCustomer release];
    }
    memberFlightHistoryCustomerQueryResponse.historyCustomers = tempUsers;
    [tempUsers release];
	
	[doc release];
	return memberFlightHistoryCustomerQueryResponse;

}


+ (MemberFlightHistoryCustomerDeleteResponse *)loadMemberFlightHistoryCustomerDeleteResponse:(NSData *)xmlData{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	MemberFlightHistoryCustomerDeleteResponse *memberFlightHistoryCustomerDeleteResponse = [[[MemberFlightHistoryCustomerDeleteResponse alloc] init] autorelease];
	memberFlightHistoryCustomerDeleteResponse.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
	memberFlightHistoryCustomerDeleteResponse.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
	
	[doc release];
	return memberFlightHistoryCustomerDeleteResponse;
}

#pragma mark -
#pragma mark 酒店业务数据解析

+ (HotelListSearchResponse *)loadHotelListSearchResponse:(NSData *)xmlData oldHotelList:(HotelListSearchResponse *)hotelList{
	NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	if (hotelList == nil) {
		HotelListSearchResponse *hotelListSearchResponse = [[[HotelListSearchResponse alloc] init] autorelease];
		hotelListSearchResponse.result_code = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Code" error:nil] objectAtIndex:0] stringValue];
		hotelListSearchResponse.result_message = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Msg" error:nil] objectAtIndex:0] stringValue];
		
		if ([hotelListSearchResponse.result_code intValue] == 1 && ![@"查询结果为空" isEqualToString:hotelListSearchResponse.result_message]) {
			hotelListSearchResponse.cityCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/CityCode" error:nil] objectAtIndex:0] stringValue];
			hotelListSearchResponse.checkInDate = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/CheckInDate" error:nil] objectAtIndex:0] stringValue];
			hotelListSearchResponse.checkOutDate = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/CheckOutDate" error:nil] objectAtIndex:0] stringValue];
			hotelListSearchResponse.totalPageNum = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/PageInfo/TotalPageNum" error:nil] objectAtIndex:0] stringValue];
			hotelListSearchResponse.totalNum = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/PageInfo/TotalNum" error:nil] objectAtIndex:0] stringValue];
			hotelListSearchResponse.curPage = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/PageInfo/CurrentPage" error:nil] objectAtIndex:0] stringValue];
			
			NSArray *hotelArray = [doc nodesForXPath:@"//HotelResponse/Hotels/Hotel" error:nil];
			
			NSInteger num_hotels = [hotelArray count];
			NSMutableArray *array = [[NSMutableArray alloc] init];
			for (NSInteger idx = 0; idx < num_hotels; ++idx) 
			{
				HotelListInfo *hotelListInfo = [[HotelListInfo alloc] init];
				hotelListInfo.hotelCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/HotelCode" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelName = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/HotelName" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelMinRate = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/MinRate" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelImage = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/Image" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelRank = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/Rank" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelAddress = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/Address" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelLongDesc = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/LongDesc" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelPor = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/POR" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelDistrict = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/District" error:nil] objectAtIndex:idx] stringValue];
				
				[array addObject:hotelListInfo];
				[hotelListInfo release];
			}
			
			hotelListSearchResponse.hotelArray = array;
			[array release];
		}
		
		[doc release];
		return hotelListSearchResponse;
	} else {
		HotelListSearchResponse *hotelListSearchResponse = [[[HotelListSearchResponse alloc] init] autorelease];
		hotelListSearchResponse.result_code = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Code" error:nil] objectAtIndex:0] stringValue];
		hotelListSearchResponse.result_message = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Msg" error:nil] objectAtIndex:0] stringValue];
		
		if ([hotelListSearchResponse.result_code intValue] == 1 && ![@"查询结果为空" isEqualToString:hotelListSearchResponse.result_message]) {
			hotelListSearchResponse.cityCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/CityCode" error:nil] objectAtIndex:0] stringValue];
			hotelListSearchResponse.checkInDate = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/CheckInDate" error:nil] objectAtIndex:0] stringValue];
			hotelListSearchResponse.checkOutDate = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/CheckOutDate" error:nil] objectAtIndex:0] stringValue];
			hotelListSearchResponse.totalPageNum = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/PageInfo/TotalPageNum" error:nil] objectAtIndex:0] stringValue];
			hotelListSearchResponse.totalNum = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/PageInfo/TotalNum" error:nil] objectAtIndex:0] stringValue];
			hotelListSearchResponse.curPage = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/PageInfo/CurrentPage" error:nil] objectAtIndex:0] stringValue];
			
			NSArray *hotelArray = [doc nodesForXPath:@"//HotelResponse/Hotels/Hotel" error:nil];
			
			NSInteger num_hotels = [hotelArray count];
			for (NSInteger idx = 0; idx < num_hotels; ++idx) 
			{
				HotelListInfo *hotelListInfo = [[HotelListInfo alloc] init];
				hotelListInfo.hotelCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/HotelCode" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelName = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/HotelName" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelMinRate = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/MinRate" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelImage = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/Image" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelRank = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/Rank" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelAddress = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/Address" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelLongDesc = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/LongDesc" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelPor = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/POR" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.hotelDistrict = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotels/Hotel/District" error:nil] objectAtIndex:idx] stringValue];
				
				[hotelList.hotelArray addObject:hotelListInfo];
				[hotelListInfo release];
			}
			
			hotelListSearchResponse.hotelArray = hotelList.hotelArray;
		}
		
		[doc release];
		return hotelListSearchResponse;
	}
}

+ (HotelSingleSearchResponse *)loadHotelSingleSearchResponse:(NSData *)xmlData{
	NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	HotelSingleSearchResponse *hotelSingleSearchResponse = [[[HotelSingleSearchResponse alloc] init] autorelease];
	hotelSingleSearchResponse.result_code = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Code" error:nil] objectAtIndex:0] stringValue];
	hotelSingleSearchResponse.result_message = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Msg" error:nil] objectAtIndex:0] stringValue];
	
	if ([hotelSingleSearchResponse.result_code intValue] == 1 && ![@"查询结果为空" isEqualToString:hotelSingleSearchResponse.result_message]) {
		hotelSingleSearchResponse.hotelName = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/HotelName" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/HotelCode" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelRank = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/Rank" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelAddress = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/Address" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelOpenDate = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/OpenDate" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelFitment = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/Fitment" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelTel = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/Tel" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelFax = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/Fax" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelRoomCount = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/RoomCount" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelLongDesc = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/LongDesc" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelLongitude = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/Longitude" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelLatitude = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/Latitude" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.cityCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/CityCode" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelVicinity = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/Vicinity" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelTraffic = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/Traffic" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelPOR = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/POR" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelSER = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/SER" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelCAT = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/CAT" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelREC = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/REC" error:nil] objectAtIndex:0] stringValue];
		hotelSingleSearchResponse.hotelImage = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Hotel/Images" error:nil] objectAtIndex:0] stringValue];
	
		NSArray *roomArray = [doc nodesForXPath:@"//HotelResponse/Rooms/Room" error:nil];
		NSMutableArray *array = [[NSMutableArray alloc] init];
		NSInteger num_rooms = [roomArray count];
		for (NSInteger idx = 0; idx < num_rooms; ++idx) 
		{
			HotelRoomInfo *hotelRoomInfo = [[HotelRoomInfo alloc] init];
			hotelRoomInfo.roomTypeName = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Rooms/Room/RoomType/RoomTypeName" error:nil] objectAtIndex:idx] stringValue];
			hotelRoomInfo.roomTypeCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Rooms/Room/RoomType/RoomTypeCode" error:nil] objectAtIndex:idx] stringValue];
			hotelRoomInfo.roomBedType = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Rooms/Room/RoomType/BedType" error:nil] objectAtIndex:idx] stringValue];
			hotelRoomInfo.roomVendorCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Rooms/Room/RoomType/VendorCode" error:nil] objectAtIndex:idx] stringValue];
			hotelRoomInfo.roomDescription = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Rooms/Room/RoomType/RoomDescription" error:nil] objectAtIndex:idx] stringValue];
			hotelRoomInfo.roomInternet = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Rooms/Room/RoomType/Internet" error:nil] objectAtIndex:idx] stringValue];
			hotelRoomInfo.roomTotalPrice = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Rooms/Room/RoomType/Total" error:nil] objectAtIndex:idx] stringValue];
			hotelRoomInfo.roomPayment = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Rooms/Room/RoomRates/RoomRate/@payment" error:nil] objectAtIndex:idx] stringValue];
			hotelRoomInfo.roomRatePlanCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Rooms/Room/RoomRates/RoomRate/@RatePlanCode" error:nil] objectAtIndex:idx] stringValue];
			hotelRoomInfo.roomAmountPrice = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Rooms/Room/Rate/@AmountPrice" error:nil] objectAtIndex:idx] stringValue];
			hotelRoomInfo.roomDisplayPrice = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Rooms/Room/Rate/@DisplayPrice" error:nil] objectAtIndex:idx] stringValue];
			hotelRoomInfo.roomFreeMealCount = [(GDataXMLElement *)[[doc nodesForXPath:@"//HotelResponse/Rooms/Room/Rate/FreeMeal" error:nil] objectAtIndex:idx] stringValue];
			
			[array addObject:hotelRoomInfo];
			[hotelRoomInfo release];
		}
		
		hotelSingleSearchResponse.hotelRoomArray = array;
	}
	
	[doc release];
	return hotelSingleSearchResponse;
}

+ (HotelBookResponse *)loadHotelBookResponse:(NSData *)xmlData{
	NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	HotelBookResponse *hotelBookResponse = [[[HotelBookResponse alloc] init] autorelease];
	hotelBookResponse.result_code = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/Code" error:nil] objectAtIndex:0] stringValue];
	hotelBookResponse.result_message = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/Msg" error:nil] objectAtIndex:0] stringValue];
	
	if ([hotelBookResponse.result_code intValue] == 1) {
		hotelBookResponse.orderNo = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orderNo" error:nil] objectAtIndex:0] stringValue];
		hotelBookResponse.amount = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/amount" error:nil] objectAtIndex:0] stringValue];
		hotelBookResponse.inDate = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/inDate" error:nil] objectAtIndex:0] stringValue];
		hotelBookResponse.outDate = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/outDate" error:nil] objectAtIndex:0] stringValue];
		hotelBookResponse.earlyTime = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/earlyTime" error:nil] objectAtIndex:0] stringValue];
		hotelBookResponse.lateTime = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/lateTime" error:nil] objectAtIndex:0] stringValue];
		hotelBookResponse.hotelName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/hotelName" error:nil] objectAtIndex:0] stringValue];
		hotelBookResponse.roomName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/roomName" error:nil] objectAtIndex:0] stringValue];
		hotelBookResponse.linkman = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/linkman" error:nil] objectAtIndex:0] stringValue];
		hotelBookResponse.linkTel = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/linkTel" error:nil] objectAtIndex:0] stringValue];
		hotelBookResponse.mobile = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/mobile" error:nil] objectAtIndex:0] stringValue];
		hotelBookResponse.email = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/email" error:nil] objectAtIndex:0] stringValue];
	}
	
	[doc release];
	return hotelBookResponse;
}


+ (HotelOrderListSearchResponseModel *)loadHotelOrderListSearchResponse:(NSData *)xmlData oldHotelOrderList:(HotelOrderListSearchResponseModel *)hotelOrderList{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	if (hotelOrderList == nil) {
		HotelOrderListSearchResponseModel *hotelOrderListSearchResponseModel = [[[HotelOrderListSearchResponseModel alloc] init] autorelease];
		
        hotelOrderListSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/Code" error:nil] objectAtIndex:0] stringValue];
        hotelOrderListSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/Msg" error:nil] objectAtIndex:0] stringValue];
		
		if ([hotelOrderListSearchResponseModel.resultCode intValue] == 1 && ![@"没有订单" isEqualToString:hotelOrderListSearchResponseModel.resultMessage]) {
			hotelOrderListSearchResponseModel.orderNum = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orderNum" error:nil] objectAtIndex:0] stringValue];
			hotelOrderListSearchResponseModel.pageIndex = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/pageIndex" error:nil] objectAtIndex:0] stringValue];
			hotelOrderListSearchResponseModel.pageSize = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/pageSize" error:nil] objectAtIndex:0] stringValue];
			
			NSArray *hotelOrderArray = [doc nodesForXPath:@"//response/orders/order" error:nil];
			
			NSMutableArray *array = [[NSMutableArray alloc] init];
			for (NSInteger idx = 0; idx < [hotelOrderArray count]; ++idx) 
			{
				HotelOrderListInfoModel *hotelListInfo = [[HotelOrderListInfoModel alloc] init];
				hotelListInfo.orderId = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orders/order/orderId" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.tpsOrderId = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orders/order/tpsOrderId" error:nil] objectAtIndex:idx] stringValue];
                hotelListInfo.hotelName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orders/order/hotelName" error:nil] objectAtIndex:idx] stringValue];
                hotelListInfo.amount = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orders/order/amount" error:nil] objectAtIndex:idx] stringValue];
                hotelListInfo.resStatus = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orders/order/resStatus" error:nil] objectAtIndex:idx] stringValue];
                hotelListInfo.payStatus = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orders/order/payStatus" error:nil] objectAtIndex:idx] stringValue];
                hotelListInfo.bookTime = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orders/order/bookingTime" error:nil] objectAtIndex:idx] stringValue];
				
				[array addObject:hotelListInfo];
				[hotelListInfo release];
			}
			
			hotelOrderListSearchResponseModel.hotelOrderArray = array;
			[array release];
		}
		
		[doc release];
		return hotelOrderListSearchResponseModel;
	} else {
		HotelOrderListSearchResponseModel *hotelOrderListSearchResponseModel = [[[HotelOrderListSearchResponseModel alloc] init] autorelease];
        
        hotelOrderListSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/Code" error:nil] objectAtIndex:0] stringValue];
        hotelOrderListSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/Msg" error:nil] objectAtIndex:0] stringValue];
		
		if ([hotelOrderListSearchResponseModel.resultCode intValue] == 1 && ![@"没有订单" isEqualToString:hotelOrderListSearchResponseModel.resultMessage]) {
			hotelOrderListSearchResponseModel.orderNum = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orderNum" error:nil] objectAtIndex:0] stringValue];
			hotelOrderListSearchResponseModel.pageIndex = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/pageIndex" error:nil] objectAtIndex:0] stringValue];
			hotelOrderListSearchResponseModel.pageSize = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/pageSize" error:nil] objectAtIndex:0] stringValue];
			
			NSArray *hotelOrderArray = [doc nodesForXPath:@"//response/orders/order" error:nil];
			
			for (NSInteger idx = 0; idx < [hotelOrderArray count]; ++idx) 
			{
				HotelOrderListInfoModel *hotelListInfo = [[HotelOrderListInfoModel alloc] init];
				hotelListInfo.orderId = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orders/order/orderId" error:nil] objectAtIndex:idx] stringValue];
				hotelListInfo.tpsOrderId = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orders/order/tpsOrderId" error:nil] objectAtIndex:idx] stringValue];
                hotelListInfo.hotelName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orders/order/hotelName" error:nil] objectAtIndex:idx] stringValue];
                hotelListInfo.amount = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orders/order/amount" error:nil] objectAtIndex:idx] stringValue];
                hotelListInfo.resStatus = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orders/order/resStatus" error:nil] objectAtIndex:idx] stringValue];
                hotelListInfo.payStatus = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/orders/order/payStatus" error:nil] objectAtIndex:idx] stringValue];
				
				[hotelOrderList.hotelOrderArray addObject:hotelListInfo];
				[hotelListInfo release];
			}
			
			hotelOrderListSearchResponseModel.hotelOrderArray = hotelOrderList.hotelOrderArray;
		}
		
		[doc release];
		return hotelOrderListSearchResponseModel;
	}
}

+ (HotelOrderInfoSearchResponseModel *)loadHotelOrderInfoSearchResponse:(NSData *)xmlData{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	HotelOrderInfoSearchResponseModel *hotelOrderInfoSearchResponseModel = [[[HotelOrderInfoSearchResponseModel alloc] init] autorelease];
    hotelOrderInfoSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/Code" error:nil] objectAtIndex:0] stringValue];
    hotelOrderInfoSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/Msg" error:nil] objectAtIndex:0] stringValue];
	
	if ([hotelOrderInfoSearchResponseModel.resultCode intValue] == 1) {
		hotelOrderInfoSearchResponseModel.amount = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/amount" error:nil] objectAtIndex:0] stringValue];
		hotelOrderInfoSearchResponseModel.hotelName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/hotelName" error:nil] objectAtIndex:0] stringValue];
		hotelOrderInfoSearchResponseModel.bookingTime = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/bookingTime" error:nil] objectAtIndex:0] stringValue];
        hotelOrderInfoSearchResponseModel.inDate = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/inDate" error:nil] objectAtIndex:0] stringValue];
        hotelOrderInfoSearchResponseModel.outDate = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/outDate" error:nil] objectAtIndex:0] stringValue];
        //hotelOrderInfoSearchResponseModel.stayDay = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result/order/stayDay" error:nil] objectAtIndex:0] stringValue];
        hotelOrderInfoSearchResponseModel.earlyTime = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/earlyTime" error:nil] objectAtIndex:0] stringValue];
        hotelOrderInfoSearchResponseModel.lateTime = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/lateTime" error:nil] objectAtIndex:0] stringValue];
        hotelOrderInfoSearchResponseModel.roomName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/roomName" error:nil] objectAtIndex:0] stringValue];
        hotelOrderInfoSearchResponseModel.roomNum = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/roomNum" error:nil] objectAtIndex:0] stringValue];
        //hotelOrderInfoSearchResponseModel.tel = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result/order/tel" error:nil] objectAtIndex:0] stringValue];
        hotelOrderInfoSearchResponseModel.guests = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/guests" error:nil] objectAtIndex:0] stringValue];
        hotelOrderInfoSearchResponseModel.linkName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/linkName" error:nil] objectAtIndex:0] stringValue];
        hotelOrderInfoSearchResponseModel.linkTel = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/linkTel" error:nil] objectAtIndex:0] stringValue];
        hotelOrderInfoSearchResponseModel.linkMobile = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/linkMobile" error:nil] objectAtIndex:0] stringValue];
        hotelOrderInfoSearchResponseModel.linkEmail = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/linkEmail" error:nil] objectAtIndex:0] stringValue];
        hotelOrderInfoSearchResponseModel.resStatus = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/resStatus" error:nil] objectAtIndex:0] stringValue];
        hotelOrderInfoSearchResponseModel.payStatus = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/payStatus" error:nil] objectAtIndex:0] stringValue];
        hotelOrderInfoSearchResponseModel.payment = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/order/Payment" error:nil] objectAtIndex:0] stringValue];
	}
	
	[doc release];
	return hotelOrderInfoSearchResponseModel;

}

#pragma mark -
#pragma mark 优惠劵业务数据解析

+ (CouponListSearchResponseModel *)loadCouponListSearchResponse:(NSData *)xmlData oldCouponList:(CouponListSearchResponseModel *)couponList{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
    
    if (couponList == nil) {
        CouponListSearchResponseModel * couponListSearchResponseModel = [[[CouponListSearchResponseModel alloc] init] autorelease];
        
        couponListSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
        couponListSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
        
        if ([couponListSearchResponseModel.resultCode intValue] == 0) {
            NSArray *orders = [doc nodesForXPath:@"//response/result-body/result/coupons/coupon" error:nil];
            NSInteger num = [orders count];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (NSInteger idx = 1; idx <= num; idx++) 
            {
                CouponListInfoModel *couponListInfoModel = [[CouponListInfoModel alloc] init];
                couponListInfoModel.couponID = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/id", idx] error:nil] objectAtIndex:0] stringValue];
                couponListInfoModel.couponName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/name", idx] error:nil] objectAtIndex:0] stringValue];
                couponListInfoModel.couponType = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/type", idx] error:nil] objectAtIndex:0] stringValue];
                couponListInfoModel.couponPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/price", idx] error:nil] objectAtIndex:0] stringValue];
                couponListInfoModel.couponEndTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/endTime", idx] error:nil] objectAtIndex:0] stringValue];
                couponListInfoModel.couponSellPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/sellPrice", idx] error:nil] objectAtIndex:0] stringValue];
                couponListInfoModel.couponPopularity = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/popularity", idx] error:nil] objectAtIndex:0] stringValue];
                couponListInfoModel.couponImage = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/image", idx] error:nil] objectAtIndex:0] stringValue];
                [array addObject:couponListInfoModel];
                [couponListInfoModel release];
            }
            
            couponListSearchResponseModel.couponArray = array;
            [array release];
            
            couponListSearchResponseModel.currentPage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/currentPage" error:nil] objectAtIndex:0] stringValue];
            couponListSearchResponseModel.pageSize = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/pageSize" error:nil] objectAtIndex:0] stringValue];
            couponListSearchResponseModel.count = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/count" error:nil] objectAtIndex:0] stringValue];
        }
        
        [doc release];
        return couponListSearchResponseModel;
    } else {
        CouponListSearchResponseModel * couponListSearchResponseModel = [[[CouponListSearchResponseModel alloc] init] autorelease];
        
        couponListSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
        couponListSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
        
        if ([couponListSearchResponseModel.resultCode intValue] == 0) {
            NSArray *orders = [doc nodesForXPath:@"//response/result-body/result/coupons/coupon" error:nil];
            NSInteger num = [orders count];
            
            for (NSInteger idx = 1; idx <= num; idx++) 
            {
                CouponListInfoModel *couponListInfoModel = [[CouponListInfoModel alloc] init];
                couponListInfoModel.couponID = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/id", idx] error:nil] objectAtIndex:0] stringValue];
                couponListInfoModel.couponName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/name", idx] error:nil] objectAtIndex:0] stringValue];
                couponListInfoModel.couponType = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/type", idx] error:nil] objectAtIndex:0] stringValue];
                couponListInfoModel.couponPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/price", idx] error:nil] objectAtIndex:0] stringValue];
                couponListInfoModel.couponEndTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/endTime", idx] error:nil] objectAtIndex:0] stringValue];
                couponListInfoModel.couponSellPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/sellPrice", idx] error:nil] objectAtIndex:0] stringValue];
                couponListInfoModel.couponPopularity = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/popularity", idx] error:nil] objectAtIndex:0] stringValue];
                couponListInfoModel.couponImage = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/image", idx] error:nil] objectAtIndex:0] stringValue];
                [couponList.couponArray addObject:couponListInfoModel];
                [couponListInfoModel release];
            }
            
            couponListSearchResponseModel.currentPage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/currentPage" error:nil] objectAtIndex:0] stringValue];
            couponListSearchResponseModel.pageSize = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/pageSize" error:nil] objectAtIndex:0] stringValue];
            couponListSearchResponseModel.count = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/count" error:nil] objectAtIndex:0] stringValue];
        }
        
        couponListSearchResponseModel.couponArray = couponList.couponArray;
        [doc release];
        return couponListSearchResponseModel;
    }
}

+ (CouponInfoSearchResponseModel *)loadCouponInfoSearchResponse:(NSData *)xmlData{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
    
    CouponInfoSearchResponseModel * couponInfoSearchResponseModel = [[[CouponInfoSearchResponseModel alloc] init] autorelease];
    
    couponInfoSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
    couponInfoSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
    
    if ([couponInfoSearchResponseModel.resultCode intValue] == 0) {
        couponInfoSearchResponseModel.couponID = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/id" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.couponName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/name" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.couponType = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/typeName" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.couponPrice = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/price" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.couponEndTime = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/endTime" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.couponSellPrice = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/sellPrice" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.couponPopularity = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/popularity" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.couponImage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/image" error:nil] objectAtIndex:0] stringValue];
        
        couponInfoSearchResponseModel.couponPeriod = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/period" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.couponCondition = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/condition" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.couponMethod = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/method" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.couponDetail = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/detail" error:nil] objectAtIndex:0] stringValue];
        
        couponInfoSearchResponseModel.businessName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/business/businessName" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.cityName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/business/cityName" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.businessWebsite = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/business/businessWebsite" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.businessTel = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/business/businessTel" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.businessContact = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/business/businessContact" error:nil] objectAtIndex:0] stringValue];
        couponInfoSearchResponseModel.businessAddress = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/coupon/business/businessAddress" error:nil] objectAtIndex:0] stringValue];
        
    }
    
    [doc release];
    return couponInfoSearchResponseModel;
}

+ (CouponBookingResponseModel *)loadCouponBookingResponse:(NSData *)xmlData{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
    
    CouponBookingResponseModel * couponBookingResponseModel = [[[CouponBookingResponseModel alloc] init] autorelease];
    
    couponBookingResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
    couponBookingResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
    
    if ([couponBookingResponseModel.resultCode intValue] == 0) {
        couponBookingResponseModel.orderID = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/orderID" error:nil] objectAtIndex:0] stringValue];
        couponBookingResponseModel.payPrice = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/payPrice" error:nil] objectAtIndex:0] stringValue];   
    }
    
    [doc release];
    return couponBookingResponseModel;
}

//解析优惠劵订单列表查询返回信息
+ (CouponOrderListSearchResponseModel *)loadCouponOrderListSearchResponse:(NSData *)xmlData oldCouponList:(CouponOrderListSearchResponseModel *)couponOrderList{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
    
    if (couponOrderList == nil) {
        CouponOrderListSearchResponseModel * couponOrderListSearchResponseModel = [[[CouponOrderListSearchResponseModel alloc] init] autorelease];
        
        couponOrderListSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
        couponOrderListSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
        
        if ([couponOrderListSearchResponseModel.resultCode intValue] == 0) {
            NSArray *orders = [doc nodesForXPath:@"//response/result-body/result/orders/order" error:nil];
            NSInteger num = [orders count];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (NSInteger idx = 1; idx <= num; idx++) 
            {
                CouponOrderListInfoModel *couponOrderListInfoModel = [[CouponOrderListInfoModel alloc] init];
                couponOrderListInfoModel.orderID = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/orderID", idx] error:nil] objectAtIndex:0] stringValue];
                couponOrderListInfoModel.couponName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/couponName", idx] error:nil] objectAtIndex:0] stringValue];
                couponOrderListInfoModel.couponPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/couponPrice", idx] error:nil] objectAtIndex:0] stringValue];
                couponOrderListInfoModel.couponAmount = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/couponAmount", idx] error:nil] objectAtIndex:0] stringValue];
                couponOrderListInfoModel.payPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/payPrice", idx] error:nil] objectAtIndex:0] stringValue];
                couponOrderListInfoModel.isPay = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/isPay", idx] error:nil] objectAtIndex:0] stringValue];
                [array addObject:couponOrderListInfoModel];
                [couponOrderListInfoModel release];
            }
            
            couponOrderListSearchResponseModel.couponOrderArray = array;
            [array release];
            
            couponOrderListSearchResponseModel.currentPage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/currentPage" error:nil] objectAtIndex:0] stringValue];
            couponOrderListSearchResponseModel.pageSize = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/pageSize" error:nil] objectAtIndex:0] stringValue];
            couponOrderListSearchResponseModel.count = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/count" error:nil] objectAtIndex:0] stringValue];
        }
        
        [doc release];
        return couponOrderListSearchResponseModel;
    } else {
        CouponOrderListSearchResponseModel * couponOrderListSearchResponseModel = [[[CouponOrderListSearchResponseModel alloc] init] autorelease];
        
        couponOrderListSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
        couponOrderListSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
        
        if ([couponOrderListSearchResponseModel.resultCode intValue] == 0) {
            NSArray *orders = [doc nodesForXPath:@"//response/result-body/result/orders/order" error:nil];
            NSInteger num = [orders count];
            
            for (NSInteger idx = 1; idx <= num; idx++) 
            {
                CouponOrderListInfoModel *couponOrderListInfoModel = [[CouponOrderListInfoModel alloc] init];
                couponOrderListInfoModel.orderID = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/orderID", idx] error:nil] objectAtIndex:0] stringValue];
                couponOrderListInfoModel.couponName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/couponName", idx] error:nil] objectAtIndex:0] stringValue];
                couponOrderListInfoModel.couponPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/couponPrice", idx] error:nil] objectAtIndex:0] stringValue];
                couponOrderListInfoModel.couponAmount = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/couponAmount", idx] error:nil] objectAtIndex:0] stringValue];
                couponOrderListInfoModel.payPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/payPrice", idx] error:nil] objectAtIndex:0] stringValue];
                couponOrderListInfoModel.isPay = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/orders/order[%d]/isPay", idx] error:nil] objectAtIndex:0] stringValue];
                [couponOrderList.couponOrderArray addObject:couponOrderListInfoModel];
                [couponOrderListInfoModel release];
            }
            
            couponOrderListSearchResponseModel.currentPage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/currentPage" error:nil] objectAtIndex:0] stringValue];
            couponOrderListSearchResponseModel.pageSize = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/pageSize" error:nil] objectAtIndex:0] stringValue];
            couponOrderListSearchResponseModel.count = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/count" error:nil] objectAtIndex:0] stringValue];
        }
        
        couponOrderListSearchResponseModel.couponOrderArray = couponOrderList.couponOrderArray;
        [doc release];
        return couponOrderListSearchResponseModel;
    }

}


+ (CouponOrderInfoSearchResponseModel *)loadCouponOrderInfoSearchResponse:(NSData *)xmlData{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
    
    CouponOrderInfoSearchResponseModel * couponOrderInfoSearchResponseModel = [[[CouponOrderInfoSearchResponseModel alloc] init] autorelease];
    
    couponOrderInfoSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
    couponOrderInfoSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
    
    if ([couponOrderInfoSearchResponseModel.resultCode intValue] == 0) {
        couponOrderInfoSearchResponseModel.orderID = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/order/orderID" error:nil] objectAtIndex:0] stringValue];
        couponOrderInfoSearchResponseModel.couponName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/order/couponName" error:nil] objectAtIndex:0] stringValue];
        couponOrderInfoSearchResponseModel.typeID = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/order/typeID" error:nil] objectAtIndex:0] stringValue];
        couponOrderInfoSearchResponseModel.typeName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/order/typeName" error:nil] objectAtIndex:0] stringValue];
        couponOrderInfoSearchResponseModel.price = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/order/price" error:nil] objectAtIndex:0] stringValue];
        couponOrderInfoSearchResponseModel.couponPrice = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/order/couponPrice" error:nil] objectAtIndex:0] stringValue];
        couponOrderInfoSearchResponseModel.couponAmount = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/order/couponAmount" error:nil] objectAtIndex:0] stringValue];
        couponOrderInfoSearchResponseModel.payPrice = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/order/payPrice" error:nil] objectAtIndex:0] stringValue];
        couponOrderInfoSearchResponseModel.isPay = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/order/isPay" error:nil] objectAtIndex:0] stringValue];
        couponOrderInfoSearchResponseModel.expirationTime = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/order/expirationTime" error:nil] objectAtIndex:0] stringValue];
        
        couponOrderInfoSearchResponseModel.businessName = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/order/business/businessName" error:nil] objectAtIndex:0] stringValue];
        couponOrderInfoSearchResponseModel.businessTel = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/order/business/businessTel" error:nil] objectAtIndex:0] stringValue];
        couponOrderInfoSearchResponseModel.businessAddress = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/order/business/businessAddress" error:nil] objectAtIndex:0] stringValue];
        
        NSArray *coupons = [doc nodesForXPath:@"//response/result-body/result/order/coupons/coupon" error:nil];
        NSInteger num = [coupons count];
        
        NSMutableArray *couponArray = [[NSMutableArray alloc] init];
        for (NSInteger idx = 1; idx <= num; idx++) 
        {
            CouponInfo *couponInfo = [[CouponInfo alloc] init];
            couponInfo.couponNO = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/order/coupons/coupon[%d]/couponNO", idx] error:nil] objectAtIndex:0] stringValue];
            couponInfo.status = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/order/coupons/coupon[%d]/status", idx] error:nil] objectAtIndex:0] stringValue];
            [couponArray addObject:couponInfo];
            [couponInfo release];
        }
        
        couponOrderInfoSearchResponseModel.couponArray = couponArray;
        [couponArray release];
    }
       
    [doc release];
    return couponOrderInfoSearchResponseModel;
}

//解析优惠劵订单发送返回信息
+ (CouponSendResponseModel *)loadCouponSendResponse:(NSData *)xmlData{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
    
    CouponSendResponseModel * couponSendResponseModel = [[[CouponSendResponseModel alloc] init] autorelease];
    
    couponSendResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
    couponSendResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
    
    if ([couponSendResponseModel.resultCode intValue] == 0) {
        couponSendResponseModel.remainingCount = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result/count" error:nil] objectAtIndex:0] stringValue];
    }
    
    [doc release];
    return couponSendResponseModel;
}

+ (CouponValidQueryResponseModel *)loadCouponValidQueryResponse:(NSData *)xmlData oldCouponList:(CouponValidQueryResponseModel *)couponList{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
    
    if (couponList == nil) {
        CouponValidQueryResponseModel * couponValidQueryResponseModel = [[[CouponValidQueryResponseModel alloc] init] autorelease];
        
        couponValidQueryResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
        couponValidQueryResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
        
        if ([couponValidQueryResponseModel.resultCode intValue] == 0) {
            
            NSArray *coupons = [doc nodesForXPath:@"//response/result-body/result/coupons/coupon" error:nil];
            NSInteger num = [coupons count];
            
            NSMutableArray *couponArray = [[NSMutableArray alloc] init];
            for (NSInteger idx = 1; idx <= num; idx++) 
            {
                ValidCoupon *validCoupon = [[ValidCoupon alloc] init];
                validCoupon.couponId = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/id", idx] error:nil] objectAtIndex:0] stringValue];
                validCoupon.couponName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/name", idx] error:nil] objectAtIndex:0] stringValue];
                validCoupon.couponPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/price", idx] error:nil] objectAtIndex:0] stringValue];
                validCoupon.couponNO = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/couponNO", idx] error:nil] objectAtIndex:0] stringValue];
                [couponArray addObject:validCoupon];
                [validCoupon release];
            }
            
            couponValidQueryResponseModel.validCouponArray = couponArray;
            [couponArray release];
            
            couponValidQueryResponseModel.currentPage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/currentPage" error:nil] objectAtIndex:0] stringValue];
            couponValidQueryResponseModel.pageSize = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/pageSize" error:nil] objectAtIndex:0] stringValue];
            couponValidQueryResponseModel.count = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/count" error:nil] objectAtIndex:0] stringValue];
        }
        
        [doc release];
        return couponValidQueryResponseModel;
    } else {
        CouponValidQueryResponseModel * couponValidQueryResponseModel = [[[CouponValidQueryResponseModel alloc] init] autorelease];
        
        couponValidQueryResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
        couponValidQueryResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
        
        if ([couponValidQueryResponseModel.resultCode intValue] == 0) {
            
            NSArray *coupons = [doc nodesForXPath:@"//response/result-body/result/coupons/coupon" error:nil];
            NSInteger num = [coupons count];
            
            
            for (NSInteger idx = 1; idx <= num; idx++) 
            {
                ValidCoupon *validCoupon = [[ValidCoupon alloc] init];
                validCoupon.couponId = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/id", idx] error:nil] objectAtIndex:0] stringValue];
                validCoupon.couponName = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/name", idx] error:nil] objectAtIndex:0] stringValue];
                validCoupon.couponPrice = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/price", idx] error:nil] objectAtIndex:0] stringValue];
                validCoupon.couponNO = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/coupons/coupon[%d]/couponNO", idx] error:nil] objectAtIndex:0] stringValue];
                [couponList.validCouponArray addObject:validCoupon];
                [validCoupon release];
            }
            couponValidQueryResponseModel.validCouponArray = couponList.validCouponArray;
            
            
            couponValidQueryResponseModel.currentPage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/currentPage" error:nil] objectAtIndex:0] stringValue];
            couponValidQueryResponseModel.pageSize = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/pageSize" error:nil] objectAtIndex:0] stringValue];
            couponValidQueryResponseModel.count = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/count" error:nil] objectAtIndex:0] stringValue];
        }
        
        [doc release];
        return couponValidQueryResponseModel;
    }
}

#pragma mark -
#pragma mark 手机充值业务数据解析

+ (PhoneBillRechargeResponseModel *)loadPhoneBillRechargeResponse:(NSData *)xmlData{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
    
    PhoneBillRechargeResponseModel * phoneBillRechargeResponseModel = [[[PhoneBillRechargeResponseModel alloc] init] autorelease];
    
    phoneBillRechargeResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
    phoneBillRechargeResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
    
    if ([phoneBillRechargeResponseModel.resultCode intValue] == 0) {
        phoneBillRechargeResponseModel.orderID = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/orderID" error:nil] objectAtIndex:0] stringValue];
        phoneBillRechargeResponseModel.orderCharge = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/orderCharge" error:nil] objectAtIndex:0] stringValue];   
        phoneBillRechargeResponseModel.cardType = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/cardType" error:nil] objectAtIndex:0] stringValue];
        phoneBillRechargeResponseModel.cardAttribution = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/cardAttribution" error:nil] objectAtIndex:0] stringValue]; 
    }
    
    [doc release];
    return phoneBillRechargeResponseModel;
}

#pragma mark -
#pragma mark 通联支付业务数据解析

+ (AllinTelPayResponseModel *)loadAllinTelPayResponse:(NSData *)xmlData{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
    
    AllinTelPayResponseModel * allinTelPayResponseModel = [[[AllinTelPayResponseModel alloc] init] autorelease];
    
    allinTelPayResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
    allinTelPayResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
    
    if ([allinTelPayResponseModel.resultCode intValue] == 0) {
        allinTelPayResponseModel.allinID = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/id" error:nil] objectAtIndex:0] stringValue];
        allinTelPayResponseModel.allinCreatetime = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/result/createtime" error:nil] objectAtIndex:0] stringValue];   
    }
    
    [doc release];
    return allinTelPayResponseModel;
}

#pragma mark -
#pragma mark 天气业务数据解析

+ (WeatherSearchResponseModel *)loadWeatherSearchResponse:(NSString *)xmlData{
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
    
    if ([[doc nodesForXPath:@"//xml_api_reply/weather/forecast_information" error:nil] count] == 0) {
        [doc release];
        return nil;
    }
    
    WeatherSearchResponseModel * weatherSearchResponseModel = [[[WeatherSearchResponseModel alloc] init] autorelease];
    
    weatherSearchResponseModel.weatherCondition = [(GDataXMLElement *)[[doc nodesForXPath:@"//xml_api_reply/weather/current_conditions/condition/@data" error:nil] objectAtIndex:0] stringValue];
    weatherSearchResponseModel.weatherTemperature = [(GDataXMLElement *)[[doc nodesForXPath:@"//xml_api_reply/weather/current_conditions/temp_c/@data" error:nil] objectAtIndex:0] stringValue];
    weatherSearchResponseModel.weatherHumidity = [(GDataXMLElement *)[[doc nodesForXPath:@"//xml_api_reply/weather/current_conditions/humidity/@data" error:nil] objectAtIndex:0] stringValue];
    NSArray *elementArray = [doc nodesForXPath:@"//xml_api_reply/weather/current_conditions/wind_condition/@data" error:nil];
    if (elementArray==nil || [elementArray count]==0) {
        weatherSearchResponseModel.weatherWind = @"";
    } else {
        weatherSearchResponseModel.weatherWind = [(GDataXMLElement *)[[doc nodesForXPath:@"//xml_api_reply/weather/current_conditions/wind_condition/@data" error:nil] objectAtIndex:0] stringValue];
    }
    weatherSearchResponseModel.weatherIcon = [(GDataXMLElement *)[[doc nodesForXPath:@"//xml_api_reply/weather/current_conditions/icon/@data" error:nil] objectAtIndex:0] stringValue];
            
    NSArray *coupons = [doc nodesForXPath:@"//xml_api_reply/weather/forecast_conditions" error:nil];
    NSInteger num = [coupons count];
    
    NSMutableArray *weatherArray = [[NSMutableArray alloc] init];
    for (NSInteger idx = 1; idx <= num; idx++) 
    {
        WeatherPreviewModel *preview = [[WeatherPreviewModel alloc] init];
        preview.weatherCondition = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//xml_api_reply/weather/forecast_conditions[%d]/condition/@data", idx] error:nil] objectAtIndex:0] stringValue];
        preview.weatherLowTemperature = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//xml_api_reply/weather/forecast_conditions[%d]/low/@data", idx] error:nil] objectAtIndex:0] stringValue];
        preview.weatherHighTemperature = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//xml_api_reply/weather/forecast_conditions[%d]/high/@data", idx] error:nil] objectAtIndex:0] stringValue];
        preview.weatherDayOfWeek = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//xml_api_reply/weather/forecast_conditions[%d]/day_of_week/@data", idx] error:nil] objectAtIndex:0] stringValue];
        preview.weatherIcon = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//xml_api_reply/weather/forecast_conditions[%d]/icon/@data", idx] error:nil] objectAtIndex:0] stringValue];
        [weatherArray addObject:preview];
        [preview release];
    }
    
    weatherSearchResponseModel.weatherPreviewConditions = weatherArray;
    [weatherArray release];
        
    [doc release];
    return weatherSearchResponseModel;
}

#pragma mark -
#pragma mark 用户反馈业务数据解析

+ (FeedbackSearchResponseModel *)loadFeedbackSearchResponse:(NSData *)xmlData  oldSuggestionList:(FeedbackSearchResponseModel *)suggestionList{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
    
    if (suggestionList == nil) {
        FeedbackSearchResponseModel * feedbackSearchResponseModel = [[[FeedbackSearchResponseModel alloc] init] autorelease];
        
        feedbackSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
        feedbackSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
        
        if ([feedbackSearchResponseModel.resultCode intValue] == 0) {
            
            NSArray *coupons = [doc nodesForXPath:@"//response/result-body/result/suggestions/suggestion" error:nil];
            NSInteger num = [coupons count];
            
            NSMutableArray *suggestionArray = [[NSMutableArray alloc] init];
            for (NSInteger idx = 1; idx <= num; idx++) 
            {
                FeedbackSuggestion *feedbackSuggestion = [[FeedbackSuggestion alloc] init];
                feedbackSuggestion.suggestionType = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/suggestions/suggestion[%d]/type", idx] error:nil] objectAtIndex:0] stringValue];
                feedbackSuggestion.suggestionCommitContent = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/suggestions/suggestion[%d]/commitContent", idx] error:nil] objectAtIndex:0] stringValue];
                feedbackSuggestion.suggestionCommitTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/suggestions/suggestion[%d]/commitTime", idx] error:nil] objectAtIndex:0] stringValue];
                feedbackSuggestion.suggestionReplyContent = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/suggestions/suggestion[%d]/replyContent", idx] error:nil] objectAtIndex:0] stringValue];
                [suggestionArray addObject:feedbackSuggestion];
                [feedbackSuggestion release];
            }
            
            feedbackSearchResponseModel.suggestions = suggestionArray;
            [suggestionArray release];
            
            feedbackSearchResponseModel.currentPage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/currentPage" error:nil] objectAtIndex:0] stringValue];
            feedbackSearchResponseModel.pageSize = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/pageSize" error:nil] objectAtIndex:0] stringValue];
            feedbackSearchResponseModel.count = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/count" error:nil] objectAtIndex:0] stringValue];
        }
        
        [doc release];
        return feedbackSearchResponseModel;
    } else {
        FeedbackSearchResponseModel * feedbackSearchResponseModel = [[[FeedbackSearchResponseModel alloc] init] autorelease];
        
        feedbackSearchResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
        feedbackSearchResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
        
        if ([feedbackSearchResponseModel.resultCode intValue] == 0) {
            
            NSArray *coupons = [doc nodesForXPath:@"//response/result-body/result/suggestions/suggestion" error:nil];
            NSInteger num = [coupons count];
            
            
            for (NSInteger idx = 1; idx <= num; idx++) 
            {
                FeedbackSuggestion *feedbackSuggestion = [[FeedbackSuggestion alloc] init];
                feedbackSuggestion.suggestionType = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/suggestions/suggestion[%d]/type", idx] error:nil] objectAtIndex:0] stringValue];
                feedbackSuggestion.suggestionCommitContent = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/suggestions/suggestion[%d]/commitContent", idx] error:nil] objectAtIndex:0] stringValue];
                feedbackSuggestion.suggestionCommitTime = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/suggestions/suggestion[%d]/commitTime", idx] error:nil] objectAtIndex:0] stringValue];
                feedbackSuggestion.suggestionReplyContent = [(GDataXMLElement *)[[doc nodesForXPath:[NSString stringWithFormat:@"//response/result-body/result/suggestions/suggestion[%d]/replyContent", idx] error:nil] objectAtIndex:0] stringValue];
                [suggestionList.suggestions addObject:feedbackSuggestion];
                [feedbackSuggestion release];
            }
            feedbackSearchResponseModel.suggestions = suggestionList.suggestions;
            
            feedbackSearchResponseModel.currentPage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/currentPage" error:nil] objectAtIndex:0] stringValue];
            feedbackSearchResponseModel.pageSize = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/pageSize" error:nil] objectAtIndex:0] stringValue];
            feedbackSearchResponseModel.count = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-body/pageInfo/count" error:nil] objectAtIndex:0] stringValue];
        }
        
        [doc release];
        return feedbackSearchResponseModel;
    }
}


+ (FeedbackCommitResponseModel *)loadFeedbackCommitResponse:(NSData *)xmlData{
    NSError *error;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
	if (doc == nil) 
	{ 
		return nil;
	}
	
	FeedbackCommitResponseModel * feedbackCommitResponseModel = [[[FeedbackCommitResponseModel alloc] init] autorelease];
	
	feedbackCommitResponseModel.resultCode = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-code" error:nil] objectAtIndex:0] stringValue];
	feedbackCommitResponseModel.resultMessage = [(GDataXMLElement *)[[doc nodesForXPath:@"//response/result-message" error:nil] objectAtIndex:0] stringValue];
    
    [doc release];
    return feedbackCommitResponseModel;
}

@end
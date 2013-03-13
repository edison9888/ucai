//
//  FeedbackSearchResponseModel.h
//  UCAI
//
//  Created by  on 12-1-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedbackSuggestion : NSObject 

@property(nonatomic,copy) NSString *suggestionType;           //类型:”1”-投诉,”2”-建议
@property(nonatomic,copy) NSString *suggestionCommitContent;  //会员提交的内容
@property(nonatomic,copy) NSString *suggestionCommitTime;     //会员提交的时间
@property(nonatomic,copy) NSString *suggestionReplyContent;   //回复内容

@end


@interface FeedbackSearchResponseModel : NSObject

@property (nonatomic, copy) NSString *resultCode;      // 返回结果编码:0-成功,1-失败
@property (nonatomic, copy) NSString *resultMessage;   // 返回结果信息
@property (nonatomic,retain) NSMutableArray *suggestions; //建议或投诉

@property (nonatomic, copy) NSString * currentPage;     //当前请求页,从1开始
@property (nonatomic, copy) NSString * pageSize;     //每页显示记录数
@property (nonatomic, copy) NSString * count;     //总记录数

@end

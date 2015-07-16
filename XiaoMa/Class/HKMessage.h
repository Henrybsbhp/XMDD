//
//  HKMessage.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKMessage : NSObject
@property (nonatomic, strong) NSNumber *msgid;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) long long msgtime;
///消息类型(1：系统消息；2：洗车订单；3：保险订单；4：推送消息)
@property (nonatomic, assign) NSInteger msgtype;
///扩展信息(根据msgtype不同，存不同的id)
@property (nonatomic, strong) NSString *ext1;
///描述消息跳转的url
@property (nonatomic, strong) NSString *url;

+ (instancetype)messageWithJSONResponse:(NSDictionary *)rsp;
@end

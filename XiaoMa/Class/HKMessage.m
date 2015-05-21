//
//  HKMessage.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKMessage.h"

@implementation HKMessage

+ (instancetype)messageWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    HKMessage *msg = [HKMessage new];
    msg.msgid = rsp[@"msgid"];
    msg.content = rsp[@"message"];
    msg.msgtime = [rsp[@"msgtime"] longLongValue];
    msg.msgtype = [rsp[@"msgtype"] integerValue];
    msg.ext1 = rsp[@"ext1"];

    return msg;
}


@end

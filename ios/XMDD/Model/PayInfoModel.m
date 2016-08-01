//
//  PayInfoModel.m
//  XiaoMa
//
//  Created by fuqi on 16/6/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "PayInfoModel.h"

@implementation WechatPayInfo

//+ (WechatPayInfo *)parseObject:(NSDictionary *)dict
//{
//    WechatPayInfo * info = [[WechatPayInfo alloc] init];
//    info.appid = [dict stringParamForName:@"appid"];
//    info.appid = [dict stringParamForName:@"appid"];
//    info.appid = [dict stringParamForName:@"appid"];
//    info.appid = [dict stringParamForName:@"appid"];
//    info.appid = [dict stringParamForName:@"appid"];
//    info.appid = [dict stringParamForName:@"appid"];
//    info.appid = [dict stringParamForName:@"appid"];
//}

@end

@implementation PayInfoModel

+ (instancetype)payInfoWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    
    PayInfoModel * info = [[PayInfoModel alloc] init];
    info.alipayInfo = rsp[@"alipayinfo"];
    
    WechatPayInfo * wxPayInfo = [[WechatPayInfo alloc] init];
    wxPayInfo.payInfo = rsp[@"wechatpayinfo"];
    info.wechatInfo = wxPayInfo;
    return info;
}

@end

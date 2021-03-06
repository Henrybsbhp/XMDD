//
//  PayInfoModel.m
//  XiaoMa
//
//  Created by fuqi on 16/6/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "PayInfoModel.h"

@implementation WechatPayInfo

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
    
    NSMutableArray *bankList = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dic in (NSArray *)rsp[@"unionpayinfo"])
    {
        MyBankCard *bankCard = [MyBankCard bankInfoWithJSONResponse:dic];
        [bankList addObject:bankCard];
    }
    info.unionPayDesc = rsp[@"unionpaydesc"];
    info.bankListInfo = bankList;
    
    return info;
}

@end

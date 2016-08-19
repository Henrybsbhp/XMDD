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
    
//    @YZC 要改
    NSMutableArray *bankList = [[NSMutableArray alloc]init];
   
    for (NSDictionary *dic in [(NSDictionary *)rsp[@"unionpayinfo"] objectForKey:@"cards"])
    {
        UnionBankCard *bankCard = [[UnionBankCard alloc] init];
        bankCard.cardno = dic[@"cardno"];
        bankCard.issuebank = dic[@"issuebank"];
        bankCard.tokenid = dic[@"tokenid"];
        bankCard.cardtypename = dic[@"cardtypename"];
        bankCard.cardtype = dic[@"cardtype"];
        bankCard.bindphone = dic[@"bindphone"];
        bankCard.changephoneurl = dic[@"changephoneurl"];
        bankCard.banklogo = dic[@"changephoneurl"];
        bankCard.banktip = dic[@"banktip"];
        [bankList addObject:bankCard];
    }
    info.unionPayDesc = rsp[@"unionpaydesc"];
    info.bankListInfo = bankList;
    
    return info;
}

@end

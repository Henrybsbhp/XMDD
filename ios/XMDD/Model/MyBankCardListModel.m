//
//  MyBankCardListModel.m
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MyBankCardListModel.h"

@implementation MyBankCardListModel

+ (instancetype)listWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp) {
        return nil;
    }
    
    MyBankCardListModel *list = [[MyBankCardListModel alloc] init];
    list.cardNo = rsp[@"cardno"];
    list.issueBank = rsp[@"issuebank"];
    list.tokenID = rsp[@"tokenid"];
    list.cardType = rsp[@"cardtype"];
    list.czbFlag = [rsp[@"czbflag"] integerValue];
    list.bindPhone = rsp[@"bindphone"];
    list.bankLogo = rsp[@"banklogo"];
    list.bankTips = rsp[@"banktip"];
    
    return list;
}

@end

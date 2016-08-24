//
//  MyBankCardListModel.m
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MyBankCard.h"

@implementation MyBankCard

- (id)copyWithZone:(NSZone *)zone
{
    MyBankCard * bankCard = [MyBankCard allocWithZone:zone];
    
    bankCard.cardNo = [self.cardNo copy];
    bankCard.issueBank = [self.issueBank copy];
    bankCard.tokenID = [self.tokenID copy];
    bankCard.cardTypeName = [self.cardTypeName copy];;
    bankCard.cardType = self.cardType;
    bankCard.bindPhone = [self.bindPhone copy];
    bankCard.bankLogo = [self.bankLogo copy];
    bankCard.bankTips = [self.bankTips copy];
    bankCard.changephoneurl = [self.changephoneurl copy];
    bankCard.couponIds = [self.couponIds copy];
    return bankCard;
}

+ (instancetype)bankInfoWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp) {
        return nil;
    }
    
    MyBankCard *bankCard = [[MyBankCard alloc] init];
    bankCard.cardNo = rsp[@"cardno"];
    bankCard.issueBank = rsp[@"issuebank"];
    bankCard.tokenID = rsp[@"tokenid"];
    bankCard.cardTypeName = rsp[@"cardtypename"];
    bankCard.cardType = [rsp integerParamForName:@"cardtype"];
    bankCard.bindPhone = rsp[@"bindphone"];
    bankCard.bankLogo = rsp[@"banklogo"];
    bankCard.bankTips = rsp[@"banktip"];
    bankCard.changephoneurl = [rsp stringParamForName:@"changephoneurl"];
    
    NSString * cids = rsp[@"cids"];
    NSMutableArray * tCids = [NSMutableArray array];
    for (NSString * cid in [cids componentsSeparatedByString:@","])
    {
        NSNumber * number = [NSNumber numberWithInteger:[cid integerValue]];
        [tCids safetyAddObject:number];
    }
    bankCard.couponIds = [NSArray arrayWithArray:tCids];
    return bankCard;
}

@end

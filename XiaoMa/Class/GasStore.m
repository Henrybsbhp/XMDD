//
//  GasStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GasStore.h"
#import "GetGascardListOp.h"
#import "GetGaschargeInfoOp.h"
#import "NSString+Format.h"
#import "BankStore.h"
#import "AddGascardOp.h"
#import "DeleteGascardOp.h"

#define kGasCardTimetagKey  @"GasCardTimetag"

@interface GasStore ()
@property (nonatomic, strong) NSMutableDictionary *timetagDict;
@property (nonatomic, strong) RACSignal *getGaschargeConfigSignal;
@property (nonatomic, strong) RACSignal *getCZBChargeConfigSignal;
@property (nonatomic, strong) BankStore *bankStore;
@end
@implementation GasStore

- (void)reloadForUserChanged:(JTUser *)user
{
    self.gasCards = nil;
    self.bankStore = nil;
    [self triggerEvent:[[RACSignal return:nil] eventWithName:@"reloadUser"] forDomain:kDomainGasCards];
}

#pragma mark - Util
- (CKQueue *)createGasCardsIfNeeded
{
    if (!self.gasCards) {
        self.gasCards = [CKQueue queue];
    }
    return self.gasCards;
}

#pragma mark - Event
///获取当前用户所有油卡信息
- (CKEvent *)getAllGasCards
{
    CKEvent *event = [[self rac_getAllGasCards] eventWithName:@"getAllGasCards"];
    return [self inlineEvent:event forDomain:kDomainGasCards];
}

///添加油卡
- (CKEvent *)addGasCard:(GasCard *)card
{
    CKEvent *event = [[self rac_addGasCard:card] eventWithName:@"addGasCard"];
    return [self inlineEvent:event forDomain:kDomainGasCards];
}

///删除油卡
- (CKEvent *)deleteGasCard:(GasCard *)card
{
    CKEvent *event = [[self rac_deleteCardByGID:card.gid] eventWithName:@"deleteGasCard"];
    return [self inlineEvent:event forDomain:kDomainGasCards];
}

- (CKEvent *)updateCardInfoByGID:(NSNumber *)gid
{
    CKEvent *event = [[self rac_getGasCardNormalInfoByGID:gid] eventWithName:@"updateCardInfoByGID"];
    return [self inlineEvent:event forDomain:kDomainUpadteGasCardInfo];
}

- (CKEvent *)getChargeConfig
{
    CKEvent *event = [[self rac_getChargeConfig] eventWithName:@"getChargeConfig"];
    return [self inlineEvent:event forDomain:kDomainChargeConfig];
}

///更新浙商卡加油信息
- (CKEvent *)updateCZBCardInfoByCID:(NSNumber *)cid
{
    CKEvent *event = [[self rac_updateCZBCardInfoByCID:cid] eventWithName:@"updateCZBCardInfoByCID"];
    return [self inlineEvent:event forDomain:kDomainUpdateCZBCardInfo];
}

///获取浙商充值配置信息
- (CKEvent *)getCZBChargeConfig
{
    CKEvent *event = [[self rac_getCZBChargeConfig] eventWithName:@"getCZBChargeConfig"];
    return [self inlineEvent:event forDomain:kDomainCZBChargeConfig];
}


#pragma mark - Signal
- (RACSignal *)rac_getAllGasCards
{
    GetGascardListOp *op = [GetGascardListOp operation];
    @weakify(self);
    RACSignal *sig = [[[op rac_postRequest] map:^id(GetGascardListOp *rsp) {
        
        @strongify(self);
        CKQueue *gasCards = [self createGasCardsIfNeeded];
        for (GasCard *card in rsp.rsp_gascards) {
            GasCard *oldCard = [gasCards objectForKey:card.gid];
            if (oldCard) {
                [oldCard mergeSimpleGasCard:card];
            }
            else {
                [gasCards addObject:card forKey:card.gid];
            }
        }

        [self updateTimetagForKey:kGasCardTimetagKey];
        return gasCards;
    }] replayLast];
    
    return sig;
}

- (RACSignal *)rac_addGasCard:(GasCard *)card
{
    AddGascardOp *op = [AddGascardOp operation];
    op.req_cardtype = card.cardtype;
    op.req_gascardno = card.gascardno;
    return [[[op rac_postRequest] map:^id(AddGascardOp *op) {
        card.availablechargeamt = op.rsp_availablechargeamt;
        card.couponedmoney = op.rsp_couponedmoney;
        card.gid = op.rsp_gid;
        [[self createGasCardsIfNeeded] addObject:card forKey:card.gid];
        return card;
    }] replayLast];
}

- (RACSignal *)rac_deleteCardByGID:(NSNumber *)gid
{
    DeleteGascardOp *op = [DeleteGascardOp operation];
    op.req_gid = gid;
    return [[[op rac_postRequest] map:^id(DeleteGascardOp *op) {
        GasCard *card = [self.gasCards objectForKey:gid];
        [self.gasCards removeObjectForKey:gid];
        return card;
    }] replayLast];
}

- (RACSignal *)rac_getChargeConfig
{
    RACSignal *cfgSig = self.getGaschargeConfigSignal;
    if (!cfgSig) {
        
        GetGaschargeConfigOp *op = [GetGaschargeConfigOp operation];
        @weakify(self);
        cfgSig = [[[[op rac_postRequest] catch:^RACSignal *(NSError *error) {
            @strongify(self);
            self.getGaschargeConfigSignal = nil;
            return [RACSignal return:nil];
        }] doNext:^(GetGaschargeConfigOp *rspOp) {
            
            @strongify(self);
            self.config = rspOp;
            CKQueue *chargePackages = [CKQueue queue];
            for (GasChargePackage *pkg in [rspOp generateAllChargePackages]) {
                [chargePackages addObject:pkg forKey:pkg.pkgid];
            }
            self.chargePackages = chargePackages;
        }] replayLast];
        
        self.getGaschargeConfigSignal = cfgSig;
    }
    return cfgSig;
}

- (RACSignal *)rac_getGasCardNormalInfoByGID:(NSNumber *)gid
{
    GetGaschargeInfoOp *op = [GetGaschargeInfoOp operation];
    op.req_gid = gid;
    @weakify(self);
    RACSignal *sig = [[[op rac_postRequest] map:^id(GetGaschargeInfoOp *op) {
        @strongify(self);
        GasCard *card = [self.gasCards objectForKey:op.req_gid];
        if (!card) {
            card = [[GasCard alloc] init];
            card.gid = op.req_gid;
            [self.gasCards addObject:card forKey:op.req_gid];
        }
        card.availablechargeamt = op.rsp_availablechargeamt;
        card.couponedmoney = op.rsp_couponedmoney;
        card.desc = op.rsp_desc;
        return card;
    }] replayLast];
    return sig;
}

- (RACSignal *)rac_updateCZBCardInfoByCID:(NSNumber *)cid
{
    GetCZBGaschargeInfoOp *op = [GetCZBGaschargeInfoOp operation];
    op.req_cardid = cid;

    RACSignal *sig = [[[op rac_postRequest] map:^id(GetCZBGaschargeInfoOp *op) {

        BankStore *store = [BankStore fetchExistsStore];
        HKBankCard *card = [store.bankCards objectForKey:cid];
        card.gasInfo = op;
        return card;
    }] replay];
    return sig;
}

- (RACSignal *)rac_getCZBChargeConfig
{
    if (self.getCZBChargeConfigSignal) {
        return self.getCZBChargeConfigSignal;
    }
    GetCZBCouponDefInfoOp *op = [GetCZBCouponDefInfoOp operation];
    @weakify(self);
    RACSignal *sig = [[[[op rac_postRequest] catch:^RACSignal *(NSError *error) {
        
        @strongify(self);
        self.getCZBChargeConfigSignal = nil;
        return [RACSignal return:nil];
    }] doNext:^(GetCZBCouponDefInfoOp *op) {
        
        @strongify(self);
        self.czbConfig = op;
    }] replayLast];
    self.getCZBChargeConfigSignal = sig;
    return sig;
}
#pragma mark - Other
///分期加油充值说明
- (NSString *)rechargeDescriptionForFqjy:(GasChargePackage *)pkg
{
    int amount = [[self.config.rsp_supportamt lastObject] intValue];
    float coupon = amount * pkg.month * (1-[pkg.discount floatValue]/100.0);
    return [NSString stringWithFormat:
            @"<font size=13 color='#888888'>充值即享<font color='#ff0000'>%@折</font>，每月充值%d元，能省%@元</font>",
            pkg.discount, amount, [NSString formatForFloorPrice:coupon]];
}

///普通加油充值说明
- (NSString *)rechargeDescriptionForNormal:(GasCard *)card
{
    if (card && card.desc) {
        return card.desc;
    }
    return @"<font size=13 color='#888888'>充值即享<font color='#ff0000'>98折</font>，\
        每月优惠限额1000元，超出部分不予奖励。每月最多充值2000元。</font>";
}

///浙商卡加油充值说明
- (NSString *)rechargeDescriptionForCZB:(HKBankCard *)bank
{
    if (bank && bank.gasInfo.rsp_desc) {
        return bank.gasInfo.rsp_desc;
    }
    if (self.czbConfig.rsp_desc) {
        return self.czbConfig.rsp_desc;
    }
    return @"添加浙商银行汽车卡后，既可享受金卡返利8%，每月最高返50元；白金卡返利15%，每月最高返100元。";
}

///充值提醒
- (NSString *)gasRemainder
{
    NSString *text = @"<font size=12 color='#888888'>充值成功后，须至相应加油站圈存后方能使用。</font>";
    NSString *link = kAddGasNoticeUrl;
    NSString *agreement = @"《充值服务说明》";
    text = [NSString stringWithFormat:@"%@<font size=12 color='#888888'>更多充值说明，\
            点击查看<font color='#20ab2a'><a href='%@'>%@</a></font></font>",
            text, link, agreement];
    return text;
}

@end

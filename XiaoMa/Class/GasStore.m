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
    [[self getAllGasCards] send];
}

#pragma mark - Util
- (JTQueue *)createGasCardsIfNeeded
{
    if (!self.gasCards) {
        self.gasCards = [[JTQueue alloc] init];
    }
    return self.gasCards;
}

#pragma mark - Event

///获取当前用户所有油卡信息
- (CKEvent *)getAllGasCards
{
    CKEvent *event;
    if (!gAppMgr.myUser) {
        event = [[RACSignal return:nil] eventWithName:@"reloadUser"];
    }
    else {
        event = [[self rac_getAllGasCards] eventWithName:@"getAllGasCards"];
    }
    return [self inlineEvent:event forDomain:kDomainGasCards];
}

- (CKEvent *)getAllGasCardsIfNeeded
{
    if ([self needUpdateTimetagForKey:kGasCardTimetagKey]) {
        return [self getAllGasCards];
    }
    return [CKEvent eventWithName:@"getAllGasCards" signal:nil];
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
        JTQueue *gasCards = [self createGasCardsIfNeeded];
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
        NSInteger index = [self.gasCards indexOfObjectForKey:gid];
        GasCard *card = [self.gasCards objectAtIndex:index];
        if (card) {
            [self.gasCards removeObjectAtIndex:index];
            return [RACTuple tupleWithObjects:card, @(index), nil];
        }
        return nil;
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
- (NSString *)recentlyUsedGasCardKey
{
    if (!gAppMgr.myUser) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@.%@", gAppMgr.myUser.userID, @"recentlyUsedGasCard"];
}

- (void)saverecentlyUsedGasCardID:(NSNumber *)gid
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *key = [self recentlyUsedGasCardKey];
    if (key) {
        [def setObject:gid forKey:key];
    }
}

@end

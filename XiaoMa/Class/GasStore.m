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

#define kGasCardTimetagKey  @"GasCardTimetag"

@interface GasStore ()
@property (nonatomic, strong) NSMutableDictionary *timetagDict;
@property (nonatomic, strong) RACSignal *getGaschargeConfigSignal;
@end
@implementation GasStore

- (void)reloadForUserChanged:(JTUser *)user
{
    self.gasCards = nil;
    self.curNormalGasCard = nil;
}

#pragma mark - Event
///获取当前用户所有油卡信息
- (CKEvent *)getAllGasCards {
    CKEvent *event = [[[self rac_getAllGasCards] replayLast] eventWithName:@"getAllGasCards"];
    return [self inlineEvent:event forDomain:kDomainGasCards];
}

- (CKEvent *)updateCardInfoByGID:(NSNumber *)gid
{
    CKEvent *event = [[[self rac_getGasCardNormalInfoByGID:gid] replayLast] eventWithName:@"updateCardInfoByGID"];
    return [self inlineEvent:event forDomain:kDomainUpadteGasCardInfo];
}

- (CKEvent *)getChargeConfig
{
    CKEvent *event = [[[self rac_getChargeConfig] replayLast] eventWithName:@"getChargeConfig"];
    return [self inlineEvent:event forDomain:kDomainChargeConfig];
}
#pragma mark - Signal
- (RACSignal *)rac_getAllGasCards
{
    GetGascardListOp *op = [GetGascardListOp operation];
    @weakify(self);
    RACSignal *sig = [[op rac_postRequest] map:^id(GetGascardListOp *rsp) {
        
        @strongify(self);
        if (!self.gasCards) {
            self.gasCards = [CKQueue queue];
            for (GasCard *card in rsp.rsp_gascards) {
                [self.gasCards addObject:card forKey:card.gid];
            }
        }
        else {
            for (GasCard *card in rsp.rsp_gascards) {
                GasCard *oldCard = [self.gasCards objectForKey:card.gid];
                if (oldCard) {
                    [oldCard mergeSimpleGasCard:card];
                }
                else {
                    [self.gasCards addObject:card forKey:card.gid];
                }
            }
        }
        [self updateTimetagForKey:kGasCardTimetagKey];
        return self.gasCards;
    }];
    
    return sig;
}

- (RACSignal *)rac_getChargeConfig
{
    RACSignal *cfgSig = self.getGaschargeConfigSignal;
    if (!cfgSig) {
        
        GetGaschargeConfigOp *op = [GetGaschargeConfigOp operation];
        @weakify(self);
        cfgSig = [[[op rac_postRequest] catch:^RACSignal *(NSError *error) {
            @strongify(self);
            self.getGaschargeConfigSignal = nil;
            return [RACSignal return:nil];
        }] doNext:^(GetGaschargeConfigOp *rspOp) {
            
            @strongify(self);
            self.config = rspOp;
            self.chargePackages = [rspOp generateAllChargePackages];
        }];
        
        self.getGaschargeConfigSignal = cfgSig;
    }
    return cfgSig;
}

- (RACSignal *)rac_getGasCardNormalInfoByGID:(NSNumber *)gid
{
    GetGaschargeInfoOp *op = [GetGaschargeInfoOp operation];
    op.req_gid = gid;
    @weakify(self);
    RACSignal *sig = [[op rac_postRequest] map:^id(GetGaschargeInfoOp *op) {
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
        self.curNormalGasCard = card;
        return card;
    }];
    return sig;
}


@end

//
//  GasStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GasStore.h"
#import "GetGascardListOp.h"

#define kGasCardTimetagKey  @"GasCardTimetag"

@interface GasStore ()
@property (nonatomic, strong) NSMutableDictionary *timetagDict;
@property (nonatomic, strong) RACSignal *getGaschargeConfigSignal;
@end
@implementation GasStore

- (void)reloadForUserChanged:(JTUser *)user
{
    self.gasCards = nil;
}

#pragma mark - Event
///获取当前用户所有油卡信息
- (CKEvent *)getAllGasCards {
    GetGascardListOp *op = [GetGascardListOp operation];
    @weakify(self);
    CKEvent *event = [[[[op rac_postRequest] map:^id(GetGascardListOp *rsp) {
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
        return rsp.rsp_gascards;
    }] replayLast] eventWithName:@"getAllGasCards"];

    [self inlineEvent:event handler:^(CKEvent *event) {
        @strongify(self);
        //触发油卡刷新
        [self triggerEvent:event forDomain:kDomainGasCards];
        //获取普通加油配置信息
        [[self getChargeConfigFrom:event.signal] send];
    }];
    
    return event;
}

///获取普通加油配置信息
- (CKEvent *)getChargeConfigFrom:(RACSignal *)signal {
    
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
            self.chargePackages = [rspOp generateAllChargePackages];
        }] replayLast];
        
        self.getGaschargeConfigSignal = cfgSig;
    }
    
    CKEvent *event = [[RACSignal combineLatest:@[signal, cfgSig]] eventWithName:@"getChargeConfig"];
    return [self inlineEvent:event forDomainList:@[kDomainReloadNormalGas]];
}

@end

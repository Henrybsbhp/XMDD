//
//  GasCZBVM.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasCZBVM.h"
#import "BankCardStore.h"
#import "CancelGaschargeOp.h"
#import "GascardChargeOp.h"

@interface GasCZBVM ()
@property (nonatomic, strong) BankCardStore *bankStore;
@property (nonatomic, strong) NSArray *bankList;
@property (nonatomic, strong) RACSignal *getCZBCouponDefInfoSignal;
@end

@implementation GasCZBVM

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupBankStore];
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)setupBankStore
{
    self.bankStore = [BankCardStore fetchOrCreateStore];
    @weakify(self);
    [self.bankStore subscribeEventsWithTarget:self receiver:^(CKStore *store, CKStoreEvent *evt) {

        @strongify(self);
        //选择银行卡
        [evt callIfNeededForCode:kCKStoreEventSelect object:self target:self selector:@selector(reloadBankCardsWithEvent:)];
        //其他
        NSArray *exceptCodes = @[@(kCKStoreEventSelect), @(kCKStoreEventUnknow)];
        [evt callIfNeededExceptCodeList:exceptCodes object:nil target:self selector:@selector(reloadBankCardsWithEvent:)];
    }];
}

- (void)setupCardStore
{
    @weakify(self);
    [self.cardStore subscribeEventsWithTarget:self receiver:^(CKStore *store, CKStoreEvent *evt) {
        @strongify(self);
        //选择油卡
        [evt callIfNeededForCode:kCKStoreEventSelect object:self handler:^(CKStoreEvent *evt) {

            RACSignal *sig = [[evt signal] doNext:^(GasCard *card) {
                @strongify(self);
                self.curGasCard = card;
            }];
            [self reloadWithEvent:[CKStoreEvent eventWithSignal:sig code:evt.code object:evt.object]];
        }];
        
        //自定义
        [evt callIfNeededForCode:kCKStoreEventUnknow object:self target:self selector:@selector(reloadWithEvent:)];

        //其他
        NSArray *otherCodes = @[@(kCKStoreEventAdd),@(kCKStoreEventDelete),@(kCKStoreEventGet),@(kCKStoreEventReload)];
        [evt callIfNeededForCodeList:otherCodes object:nil target:self selector:@selector(reloadWithEvent:)];
    }];
}

#pragma mark - Reload
- (void)reloadBankCardsWithEvent:(CKStoreEvent *)event
{
    NSInteger code = event.code;
    @weakify(self);
    RACSignal *sig = [[event signal] flattenMap:^RACStream *(id value) {
        
        @strongify(self);
        if (code == kCKStoreEventSelect) {
            self.curBankCard = value;
        }
        self.bankList = self.bankStore.cache.allObjects;
        if (!self.bankList) {
            self.bankList = [NSArray array];
        }
        HKBankCard *bankCard = [self.bankStore.cache objectForKey:self.curBankCard.cardID];
        if (!bankCard && self.bankStore.cache.count > 0) {
            bankCard = [self.bankStore.cache objectAtIndex:0];
            self.curBankCard = bankCard;
            return [self.bankStore rac_getCardCZBInfoByCID:bankCard.cardID];
        }
        if (!bankCard) {
            self.curBankCard = nil;
        }
        else if (code == kCKStoreEventReload || code == kCKStoreEventSelect) {
            return [self.bankStore rac_getCardCZBInfoByCID:bankCard.cardID];
        }
        return [RACSignal return:value];
    }];
    //通知加油数据中心去更新其他加油数据
    [self.cardStore sendEvent:[CKStoreEvent eventWithSignal:sig code:kCKStoreEventUnknow object:self]];
}

- (BOOL)reloadWithForce:(BOOL)force
{
    if (force && gAppMgr.myUser) {
        [self.bankStore sendEvent:[self.bankStore getAllBankCards]];
        [self.cardStore sendEvent:[self.cardStore getAllCards]];
        return YES;
    }
    if (gAppMgr.myUser && (!self.bankList || [self.bankStore needUpdateTimetagForKey:nil])) {
        [self.bankStore sendEvent:[self.bankStore getAllBankCards]];
        return YES;
    }
    if (self.cachedEvent) {
        [self.cardStore sendEvent:self.cachedEvent];
        return YES;
    }
    return NO;
}

- (void)reloadWithEvent:(CKStoreEvent *)event
{
    @weakify(self);
    RACSignal *sig = [[event signal] doNext:^(id x) {
        @strongify(self);
        GasCard *card = [self.cardStore.cache objectForKey:self.curGasCard.gid];
        if (!card) {
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            NSString *key = [self recentlyUsedGasCardKey];
            if (key) {
                card = [self.cardStore.cache objectForKey:[def objectForKey:[self recentlyUsedGasCardKey]]];
            }
            self.curGasCard = card ? card : [self.cardStore.cache objectAtIndex:0];
        }
    }];
    CKStoreEvent *evt = [CKStoreEvent eventWithSignal:sig code:kGasConsumeEventForModel object:self];
    self.cachedEvent = evt;
    [self.cardStore sendEvent:evt];
}

- (void)consumeEvent:(CKStoreEvent *)event
{
    if ([self.cachedEvent isEqual:event]) {
        self.cachedEvent = nil;
    }
    RACSignal *sig = [RACSignal combineLatest:@[[self rac_getCZBCouponDefInfo], event.signal]];
    [self.cardStore sendEvent:[CKStoreEvent eventWithSignal:sig code:kGasVCReloadWithEvent object:self]];
}

- (RACSignal *)rac_getCZBCouponDefInfo
{
    if (self.getCZBCouponDefInfoSignal) {
        return self.getCZBCouponDefInfoSignal;
    }
    GetCZBCouponDefInfoOp *op = [GetCZBCouponDefInfoOp operation];
    @weakify(self);
    RACSignal *sig = [[[[op rac_postRequest] catch:^RACSignal *(NSError *error) {
        
        @strongify(self);
        self.getCZBCouponDefInfoSignal = nil;
        return [RACSignal return:nil];
    }] doNext:^(GetCZBCouponDefInfoOp *op) {
        
        @strongify(self);
        self.defCouponInfo = op;
    }] replayLast];
    self.getCZBCouponDefInfoSignal = sig;
    return sig;
}

- (NSArray *)datasource
{
    if (!self.isLoadSuccess || self.isLoading) {
        return @[@[@"1"]];
    }
    NSString *row1 = self.curBankCard ? @"10005" : @"10006";
    NSString *row2 = self.curGasCard ? @"10001" : @"10002";
    return @[@[row1,row2,@"10003",@"10004",@"30001"]];
}

- (NSString *)bankFavorableDesc
{
    if (self.curBankCard && self.curBankCard.gasInfo.rsp_desc) {
        return self.curBankCard.gasInfo.rsp_desc;
    }
    if (self.defCouponInfo.rsp_desc) {
        return self.defCouponInfo.rsp_desc;
    }
    return @"添加浙商银行汽车卡后，既可享受金卡返利8%，最高返50元；白金卡返利15%，最高返100元。";
}

- (void)cancelOrderWithTradeNumber:(NSString *)tdno bankCardID:(NSNumber *)gid
{
    CancelGaschargeOp *op = [CancelGaschargeOp operation];
    op.req_tradeid = tdno;
    @weakify(self);
    RACSignal *sig = [[op rac_postRequest] flattenMap:^RACStream *(id value) {
        
        @strongify(self);
        return [self.cardStore rac_getCardNormalInfoByGID:gid];
    }];
    [self.bankStore sendEvent:[CKStoreEvent eventWithSignal:sig code:kCKStoreEventUpdate object:nil]];
}


@end

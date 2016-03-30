//
//  GasVM.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasNormalVM.h"
#import "GetGaschargeConfigOp.h"
#import "GetGaschargeInfoOp.h"
#import "GascardChargeByStagesOp.h"
#import "OrderPaidSuccessOp.h"
#import "CancelGaschargeOp.h"
#import "PaymentHelper.h"
#import "CKDatasource.h"
#import "NSString+Format.h"

@interface GasNormalVM ()
@property (nonatomic, strong) RACSignal *getGaschargeConfigSignal;
@end
@implementation GasNormalVM

- (void)dealloc
{
}

- (void)setupCardStore
{
    @weakify(self);
    [self.cardStore subscribeEventsWithTarget:self receiver:^(HKStore *store, HKStoreEvent *evt) {
        @strongify(self);
        //切换当前油卡
        [evt callIfNeededForCode:kHKStoreEventSelect object:self handler:^(HKStoreEvent *evt) {
            RACSignal *sig = [[evt signal] doNext:^(GasCard *card) {
                self.curGasCard = card;
            }];
            [self reloadWithEvent:[HKStoreEvent eventWithSignal:sig code:evt.code object:evt.object]];
        }];
        
        NSArray *codes = @[@(kHKStoreEventAdd),@(kHKStoreEventDelete),@(kHKStoreEventGet),
                           @(kHKStoreEventReload),@(kHKStoreEventUpdate)];
        [evt callIfNeededForCodeList:codes object:nil target:self selector:@selector(reloadWithEvent:)];
    }];
}

#pragma mark - Reload
- (BOOL)reloadWithForce:(BOOL)force
{
    if (force && gAppMgr.myUser) {
        [self.cardStore sendEvent:[self.cardStore getAllCards]];
        return YES;
    }
    else if (force) {
        [self reloadWithEvent:[HKStoreEvent eventWithSignal:[RACSignal return:nil] code:kHKStoreEventNone object:nil]];
    }
    else if (self.cachedEvent) {
        [self.cardStore sendEvent:self.cachedEvent];
        return YES;
    }
    return NO;
}

- (void)reloadWithEvent:(HKStoreEvent *)event
{
    NSInteger code = event.code;
    @weakify(self);
    RACSignal *sig = [[event signal] flattenMap:^RACStream *(id value) {
        @strongify(self);
        GasCard *card = [self.cardStore.cache objectForKey:self.curGasCard.gid];
        if (!card && self.cardStore.cache.count > 0) {
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            NSString *key = [self recentlyUsedGasCardKey];
            if (key) {
                card = [self.cardStore.cache objectForKey:[def objectForKey:key]];
            }
            self.curGasCard = card ? card : [self.cardStore.cache objectAtIndex:0];
            if (code == kHKStoreEventUpdate) {
                return [RACSignal return:value];
            }
            return [self.cardStore rac_getCardNormalInfoByGID:self.curGasCard.gid];
        }
        else if (!card) {
            self.curGasCard = nil;
        }
        if (self.curGasCard &&
            (code==kHKStoreEventReload || code == kHKStoreEventSelect||
             !self.curGasCard.availablechargeamt || !self.curGasCard.couponedmoney)){
            return [self.cardStore rac_getCardNormalInfoByGID:self.curGasCard.gid];
        }
        return [RACSignal return:value];
    }];
    self.cachedEvent = [HKStoreEvent eventWithSignal:sig code:kGasConsumeEventForModel object:self];
    [GasCardStore sendEvent:self.cachedEvent];
}


- (void)consumeEvent:(HKStoreEvent *)event
{
    if ([self.cachedEvent isEqual:event]) {
        self.cachedEvent = nil;
    }
    RACSignal *sig = [RACSignal combineLatest:@[[self rac_getChargeConfig], event.signal]];
    [self.cardStore sendEvent:[HKStoreEvent eventWithSignal:sig code:kGasVCReloadWithEvent object:self]];
}

- (RACSignal *)rac_getChargeConfig
{
    if (self.getGaschargeConfigSignal) {
        return self.getGaschargeConfigSignal;
    }
    GetGaschargeConfigOp *op = [GetGaschargeConfigOp operation];
    @weakify(self);
    RACSignal *sig = [[[[op rac_postRequest] catch:^RACSignal *(NSError *error) {
        @strongify(self);
        self.getGaschargeConfigSignal = nil;
        return [RACSignal return:nil];
    }] doNext:^(GetGaschargeConfigOp *rspOp) {
        
        @strongify(self);
        self.configOp = rspOp;
        self.chargePackages = [rspOp generateAllChargePackages];
        self.curChargePackage = [self.chargePackages safetyObjectAtIndex:0];
    }] replayLast];
    
    self.getGaschargeConfigSignal = sig;
    
    return sig;
}

- (RACSignal *)rac_getChargeInfoWithCard:(GasCard *)card
{
    if (!card) {
        card = [[self.cardStore cache] objectAtIndex:0];
        self.curGasCard = card;
    }
    if (card) {
        return [self.cardStore rac_getCardNormalInfoByGID:card.gid];
    }
    return [RACSignal return:nil];
}

- (NSArray *)datasource
{
    //如果加载失败或者正在加载
    if (!self.isLoadSuccess || self.isLoading) {
        return @[@[@"1"]];
    }
    NSString *row1 = self.curGasCard ? @"10001" : @"10002";
//    NSArray *section2 = gPhoneHelper.exsitWechat ? @[@"20001",@"20002",@"20003",@"30001"] : @[@"20001",@"20003",@"30001"];
    NSArray *section2 = @[@"20001",@"30001"];
    return @[@[row1,@"100031",@"10003",@"10004"],section2];
}

- (NSString *)rechargeFavorableDesc
{
    //分期加油
    if (self.curChargePackage.pkgid) {
        GasChargePackage *pkg = self.curChargePackage;
        int amount = (int)self.rechargeAmount;
        float coupon = amount * pkg.month * (1-[pkg.discount floatValue]/100.0);
        return [NSString stringWithFormat:@"<font size=13 color='#888888'>充值即享<font color='#ff0000'>%@折</font>，每月充值%d元，能省%@元</font>",
                pkg.discount, amount, [NSString formatForFloorPrice:coupon]];
    }
    //普通加油
    else if (self.curGasCard && self.curGasCard) {
        return self.curGasCard.desc;
    }
    if (self.configOp.rsp_desc) {
        return self.configOp.rsp_desc;
    }
    return @"<font size=13 color='#888888'>充值即享<font color='#ff0000'>98折</font>，每月优惠限额1000元，超出部分不予奖励。每月最多充值2000元。</font>";
}

- (void)startPayInTargetVC:(UIViewController *)vc
                   success:(void(^)(GasCard *card, GascardChargeOp *paidop))success
                    failed:(void(^)(NSError *error, GascardChargeOp *op))fail
{
    GasCard *card = self.curGasCard;
    GascardChargeOp *op;

    //分期支付
    if (self.curChargePackage.pkgid) {
        GascardChargeByStagesOp *fqop = [GascardChargeByStagesOp operation];
        fqop.req_cardid = card.gid;
        fqop.req_pkgid = self.curChargePackage.pkgid;
        fqop.req_permonthamt = (int)self.rechargeAmount;
        op = fqop;
    }
    else {
        op = [GascardChargeOp operation];
        op.req_gid = card.gid;
        op.req_amount = (int)self.rechargeAmount;
    }
    op.req_gid = card.gid;
    op.req_paychannel = self.paymentPlatform;
    op.req_bill = self.needInvoice;
    op.req_cid = self.coupon.couponId ? self.coupon.couponId : @0;
    @weakify(self, op);
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"订单生成中..."];
    }] subscribeNext:^(GascardChargeOp *op) {
        
        @strongify(self);
        if (![self callPaymentHelperWithPayOp:op gasCard:card targetVC:vc completed:success]) {
            [gToast dismiss];
            [self cancelOrderWithTradeNumber:op.rsp_tradeid cardID:card.gid];
            if (success) {
                success(card, op);
            }
        }
    } error:^(NSError *error) {
        
        @strongify(self, op);
        [gToast showError:error.domain];
        //加油到达上限（如果遇到该错误，客户端提醒用户后，需再调用一次查询卡的充值信息）
        if (error.code == 618602) {
            [self.cardStore sendEvent:[self.cardStore updateCardInfoByGID:card.gid]];
        }
        if (fail) {
            fail(error, op);
        }
    }];
}

- (BOOL)callPaymentHelperWithPayOp:(GascardChargeOp *)paidop gasCard:(GasCard *)card
                          targetVC:(UIViewController *)vc completed:(void(^)(GasCard *card, GascardChargeOp *paidop))completed
{
    if (paidop.rsp_total == 0) {
        return NO;
    }
    PaymentHelper *helper = [[PaymentHelper alloc] init];
    NSString * info = [NSString stringWithFormat:@"%@充值－%@油卡充值",
                       self.curChargePackage.pkgid ? @"分期" : @"普通",
                       card.cardtype == 2 ? @"中石油" : @"中石化"];
    NSString *text;
    switch (paidop.req_paychannel) {
        case PaymentChannelAlipay: {
            text = @"订单生成成功,正在跳转到支付宝平台进行支付";
            [helper resetForAlipayWithTradeNumber:paidop.rsp_tradeid productName:info productDescription:info price:paidop.rsp_total];
        } break;
        case PaymentChannelWechat: {
            text = @"订单生成成功,正在跳转到微信平台进行支付";
            [helper resetForWeChatWithTradeNumber:paidop.rsp_tradeid productName:info price:paidop.rsp_total];
        } break;
        case PaymentChannelUPpay: {
            text = @"订单生成成功,正在跳转到银联平台进行支付";
            [helper resetForUPPayWithTradeNumber:paidop.rsp_tradeid targetVC:vc];
        } break;
        default:
            return NO;
    }
    [gToast showText:text];
    __block BOOL paidSuccess = NO;
    @weakify(self);
    [[helper rac_startPay] subscribeNext:^(id x) {
        
        @strongify(self);
        OrderPaidSuccessOp *op = [OrderPaidSuccessOp operation];
        op.req_notifytype = 3;
        op.req_tradeno = paidop.rsp_tradeid;
        [[op rac_postRequest] subscribeNext:^(id x) {
            DebugLog(@"已通知服务器支付成功!");
        }];
        paidSuccess = YES;
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSString *key = [self recentlyUsedGasCardKey];
        if (key) {
            [def setObject:paidop.req_gid forKey:key];
        }
        if (completed) {
            completed(card, paidop);
        }
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        [self cancelOrderWithTradeNumber:paidop.rsp_tradeid cardID:card.gid];
    } completed:^{
        
        if (!paidSuccess) {
            @strongify(self);
            [self cancelOrderWithTradeNumber:paidop.rsp_tradeid cardID:card.gid];
        }
    }];
    return YES;
}

- (void)cancelOrderWithTradeNumber:(NSString *)tdno cardID:(NSNumber *)gid
{
    CancelGaschargeOp *op = [CancelGaschargeOp operation];
    op.req_tradeid = tdno;
    @weakify(self);
    RACSignal *sig = [[op rac_postRequest] flattenMap:^RACStream *(id value) {
        
        @strongify(self);
        DebugLog(@"Canceled gas order : %@", tdno);
        return [self.cardStore rac_getCardNormalInfoByGID:gid];
    }];
    [self.cardStore sendEvent:[HKStoreEvent eventWithSignal:sig code:kHKStoreEventUpdate object:nil]];
}


@end

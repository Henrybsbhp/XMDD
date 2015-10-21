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
#import "OrderPaidSuccessOp.h"
#import "CancelGaschargeOp.h"
#import "PaymentHelper.h"

@interface GasNormalVM ()
@property (nonatomic, strong) CKStoreEvent *cachedEvent;
@end
@implementation GasNormalVM

- (void)dealloc
{
    
}

- (void)setupCardStore
{
    @weakify(self);
    [self.cardStore subscribeEventsWithTarget:self receiver:^(CKStore *store, CKStoreEvent *evt) {
        @strongify(self);
        [evt callIfNeededForCode:kCKStoreEventSelect object:nil target:self selector:@selector(reloadIfNeeded:)];
        [evt callIfNeededForCode:kCKStoreEventAdd object:nil target:self selector:@selector(reloadIfNeeded:)];
        [evt callIfNeededForCode:kCKStoreEventDelete object:nil target:self selector:@selector(reloadIfNeeded:)];
        [evt callIfNeededForCode:kCKStoreEventGet object:nil target:self selector:@selector(reloadIfNeeded:)];
        [evt callIfNeededForCode:kCKStoreEventReload object:nil target:self selector:@selector(reload:)];
    }];
}

- (void)reloadData
{
    [self.cardStore sendEvent:[self.cardStore getAllCards]];
}

- (void)reload:(CKStoreEvent *)event
{
    RACSignal *sig = [RACSignal empty];
    @weakify(self);
    if (gAppMgr.myUser) {
        sig = [sig merge:[[event signal] flattenMap:^RACStream *(id value) {
            @strongify(self);
            GasCard *card = [self.cardStore.cache objectForKey:self.curGasCard.gid];
            return [self rac_getChargeInfoWithCard:card];
        }]];
    }
    if (!self.configOp) {
        sig = [sig merge:[self rac_getChargeConfig]];
    }
    self.cachedEvent = [CKStoreEvent eventWithSignal:sig code:kGasConsumeEventForModel object:self];
    [GasCardStore sendEvent:self.cachedEvent];
}


- (BOOL)reloadIfNeeded:(CKStoreEvent *)event
{
    @weakify(self);
    if (event) {
        CKStoreEvent *evt = event;
        RACSignal *sig = [RACSignal empty];
        if (gAppMgr.myUser) {
            sig = [sig merge:[[evt signal] flattenMap:^RACStream *(id value) {
                @strongify(self);
                GasCard *card;
                if (event.code == kCKStoreEventSelect) {
                    card = value;
                    self.curGasCard = card;
                }
                else {
                    GasCard *card = [self.cardStore.cache objectForKey:self.curGasCard.gid];
                    if (card) {
                        return [RACSignal return:value];
                    }
                }
                return [self rac_getChargeInfoWithCard:card];
            }]];
        }
        if (!self.configOp) {
            sig = [sig merge:[self rac_getChargeConfig]];
        }
        self.cachedEvent = [CKStoreEvent eventWithSignal:sig code:kGasConsumeEventForModel object:self];
        [GasCardStore sendEvent:self.cachedEvent];
        return YES;
    }
    if (!gAppMgr.myUser && !self.configOp) {
        CKStoreEvent *evt = [CKStoreEvent eventWithSignal:[self rac_getChargeConfig] code:kGasConsumeEventForModel object:self];
        [self.cardStore sendEvent:evt];
        return YES;
    }
    if (gAppMgr.myUser && (!self.gasCardList || [self.cardStore needUpdateTimetagForKey:kGasCardTimetagKey])) {
        [self.cardStore sendEvent:[self.cardStore getAllCards]];
        return YES;
    }
    if (self.cachedEvent) {
        [GasCardStore sendEvent:self.cachedEvent];
        return YES;
    }
    return NO;
}

- (void)consumeEvent:(CKStoreEvent *)event
{
    if ([self.cachedEvent isEqual:event]) {
        self.cachedEvent = nil;
    }
    @weakify(self);
    RACSignal *sig = [event.signal doNext:^(id x) {
        @strongify(self);
        self.gasCardList = [[self.cardStore cache] allObjects];
    }];
    [self.cardStore sendEvent:[CKStoreEvent eventWithSignal:sig code:kGasVCReloadWithEvent object:self]];
}

- (RACSignal *)rac_getChargeConfig
{
    GetGaschargeConfigOp *configOp = [GetGaschargeConfigOp operation];
    RACSignal *sig = [configOp rac_postRequest];
    self.configOp = configOp;
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
    if (!self.isLoadSuccess) {
        return @[@[@"1"]];
    }
    NSString *row1 = self.curGasCard ? @"10001" : @"10002";
    return @[@[row1,@"10003",@"10004"],@[@"20001",@"20002",@"20003"]];
}

- (NSString *)rechargeFavorableDesc
{
    if (self.configOp) {
        return self.configOp.rsp_desc;
    }
    return @"<font size=13 color='#888888'>充值即享<font color='#ff0000'>98折</font>，每月优惠限额1000元，超出部分不予奖励。每月最多充值2000元。</font>";
}

- (void)startPayInTargetVC:(UIViewController *)vc completed:(void(^)(GasCard *card, GascardChargeOp *paidop))completed
{
    GasCard *card = self.curGasCard;
    GascardChargeOp *op = [GascardChargeOp operation];
    op.req_gid = card.gid;
    op.req_amount = (int)self.rechargeAmount;
    op.req_paychannel = [PaymentHelper paymentChannelForPlatformType:self.paymentPlatform];
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"订单生成中..."];
    }] subscribeNext:^(GascardChargeOp *op) {
        
        @strongify(self);
        if (![self callPaymentHelperWithPayOp:op gasCard:card targetVC:vc completed:completed]) {
            [gToast dismiss];
            if (completed) {
                completed(card, op);
            }
        }
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

- (BOOL)callPaymentHelperWithPayOp:(GascardChargeOp *)paidop gasCard:(GasCard *)card
                          targetVC:(UIViewController *)vc completed:(void(^)(GasCard *card, GascardChargeOp *paidop))completed
{
    if (paidop.rsp_total == 0) {
        return NO;
    }
    PaymentHelper *helper = [[PaymentHelper alloc] init];
    NSString * info = @"小马达达加油卡充值";
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
        
        OrderPaidSuccessOp *op = [OrderPaidSuccessOp operation];
        op.req_notifytype = 3;
        op.req_tradeno = paidop.rsp_tradeid;
        [[op rac_postRequest] subscribeNext:^(id x) {
            DebugLog(@"已通知服务器支付成功!");
        }];
        paidSuccess = YES;
        if (completed) {
            completed(card, paidop);
        }
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        [self cancelOrderWithTradeNumber:paidop.rsp_tradeid];
    } completed:^{
        
        if (!paidSuccess) {
            @strongify(self);
            [self cancelOrderWithTradeNumber:paidop.rsp_tradeid];
        }
    }];
    return YES;
}

- (void)cancelOrderWithTradeNumber:(NSString *)tdno
{
    CancelGaschargeOp *op = [CancelGaschargeOp operation];
    op.req_tradeid = tdno;
    [[op rac_postRequest] subscribeNext:^(id x) {
        DebugLog(@"Canceled gas order : %@", tdno);
    }];
}


@end

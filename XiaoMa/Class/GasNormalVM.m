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
@property (nonatomic, strong) RACSignal *getGaschargeConfigSignal;
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
        //切换当前油卡
        [evt callIfNeededForCode:kCKStoreEventSelect object:self handler:^(CKStoreEvent *evt) {
            RACSignal *sig = [[evt signal] doNext:^(GasCard *card) {
                self.curGasCard = card;
            }];
            [self reloadWithEvent:[CKStoreEvent eventWithSignal:sig code:evt.code object:evt.object]];
        }];
        
        NSArray *codes = @[@(kCKStoreEventAdd),@(kCKStoreEventDelete),@(kCKStoreEventGet),
                           @(kCKStoreEventReload),@(kCKStoreEventUpdate)];
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
    else if (self.cachedEvent) {
        [self.cardStore sendEvent:self.cachedEvent];
        return YES;
    }
    return NO;
}

- (void)reloadWithEvent:(CKStoreEvent *)event
{
    NSInteger code = event.code;
    @weakify(self);
    RACSignal *sig = [[event signal] flattenMap:^RACStream *(id value) {
        @strongify(self);
        GasCard *card = [self.cardStore.cache objectForKey:self.curGasCard.gid];
        if (!card && self.cardStore.cache.count > 0) {
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            card = [self.cardStore.cache objectForKey:[def objectForKey:[self recentlyUsedGasCardKey]]];
            self.curGasCard = card ? card : [self.cardStore.cache objectAtIndex:0];
            if (code == kCKStoreEventUpdate) {
                return [RACSignal return:value];
            }
            return [self.cardStore rac_getCardNormalInfoByGID:self.curGasCard.gid];
        }
        else if (!card) {
            self.curGasCard = nil;
        }
        if (self.curGasCard && (code==kCKStoreEventReload||!self.curGasCard.availablechargeamt||!self.curGasCard.couponedmoney)){
            return [self.cardStore rac_getCardNormalInfoByGID:self.curGasCard.gid];
        }
        return [RACSignal return:value];
    }];
    self.cachedEvent = [CKStoreEvent eventWithSignal:sig code:kGasConsumeEventForModel object:self];
    [GasCardStore sendEvent:self.cachedEvent];
}


- (void)consumeEvent:(CKStoreEvent *)event
{
    if ([self.cachedEvent isEqual:event]) {
        self.cachedEvent = nil;
    }
    RACSignal *sig = [RACSignal combineLatest:@[[self rac_getChargeConfig], event.signal]];
    [self.cardStore sendEvent:[CKStoreEvent eventWithSignal:sig code:kGasVCReloadWithEvent object:self]];
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
    if (!self.isLoadSuccess || self.isLoading) {
        return @[@[@"1"]];
    }
    NSString *row1 = self.curGasCard ? @"10001" : @"10002";
    NSArray *section2 = gPhoneHelper.exsitWechat ? @[@"20001",@"20002",@"20003",@"30001"] : @[@"20001",@"20003",@"30001"];
    return @[@[row1,@"10003",@"10004"],section2];
}

- (NSString *)rechargeFavorableDesc
{
    if (self.curGasCard && self.curGasCard) {
        return self.curGasCard.desc;
    }
    if (self.configOp.rsp_desc) {
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
            [self cancelOrderWithTradeNumber:op.rsp_tradeid cardID:card.gid];
            if (completed) {
                completed(card, op);
            }
        }
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        //加油到达上限（如果遇到该错误，客户端提醒用户后，需再调用一次查询卡的充值信息）
        if (error.code == 618602) {
            [self.cardStore sendEvent:[self.cardStore updateCardInfoByGID:card.gid]];
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
    NSString * info = [NSString stringWithFormat:@"普通充值－%@油卡充值", card.cardtype == 2 ? @"中石油" : @"中石化"];
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
        RACSignal *sig = [[[op rac_postRequest] flattenMap:^RACStream *(id value) {
          
            @strongify(self);
            DebugLog(@"已通知服务器支付成功!");
            return [self.cardStore rac_getCardNormalInfoByGID:card.gid];
        }] doNext:^(id x) {
            
            @strongify(self);
            self.rechargeAmount = 100;
        }];
        [self.cardStore sendEvent:[CKStoreEvent eventWithSignal:sig code:kCKStoreEventUpdate object:nil]];
        paidSuccess = YES;
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setObject:paidop.req_gid forKey:[self recentlyUsedGasCardKey]];
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
    [self.cardStore sendEvent:[CKStoreEvent eventWithSignal:sig code:kCKStoreEventUpdate object:nil]];
}


@end

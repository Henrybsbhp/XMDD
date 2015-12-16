//
//  GasBaseVM.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasBaseVM.h"

@implementation GasBaseVM

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isLoadSuccess = YES;
        _segHelper = [[CKSegmentHelper alloc] init];
        _paymentPlatform = PaymentPlatformTypeAlipay;
        _cardStore = [GasCardStore fetchOrCreateStore];
        _rechargeAmount = 500;
        [self setupCardStore];
    }
    return self;
}

- (void)dealloc
{
    [self.segHelper removeAllItemGroups];
}
- (NSArray *)datasource
{
    return nil;
}

///充值提醒
- (NSString *)gasRemainder
{
    NSString *text = @"<font size=12 color='#888888'>充值成功后，须至相应加油站圈存后方能使用。</font>";
    if (self.curGasCard) {
        NSString *link;
        NSString *agreement;
        if (self.curGasCard.cardtype == 1 || self.curGasCard.cardtype == 2) {
            link = kAddGasNoticeUrl;
            agreement = @"《充值服务说明》";
        }
        if (link.length > 0) {
            text = [NSString stringWithFormat:@"%@<font size=12 color='#888888'>更多充值说明，点击查看<font color='#20ab2a'><a href='%@'>%@</a></font></font>",
                    text, link, agreement];
        }
    }
    return text;
}

#pragma mark - Override
///充值优惠
- (NSString *)rechargeFavorableDesc
{
    return nil;
}

- (NSString *)bankFavorableDesc
{
    return nil;
}

- (BOOL)reloadWithForce:(BOOL)force
{
    return NO;
}

- (void)setupCardStore
{
}

- (void)consumeEvent:(HKStoreEvent *)event
{
}

- (NSString *)recentlyUsedGasCardKey
{
    if (!gAppMgr.myUser) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@.%@", gAppMgr.myUser.userID, @"recentlyUsedGasCard"];
}

@end

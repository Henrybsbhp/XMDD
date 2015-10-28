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
        _isAcceptedAgreement = YES;
        _isLoadSuccess = YES;
        _segHelper = [[CKSegmentHelper alloc] init];
        _paymentPlatform = PaymentPlatformTypeAlipay;
        _cardStore = [GasCardStore fetchOrCreateStore];
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
    NSString *text = @"<font size=13 color='#454545'>充值成功后，须至相应加油站圈存后方能使用；如需开发票，请在营业厅圈存后向工作人员索要。</font>";
    if (self.curGasCard) {
        NSString *link;
        NSString *agreement;
        if (self.curGasCard.cardtype == 1 || self.curGasCard.cardtype == 2) {
            link = @"http://xiaomadada.com/apphtml/chongzhishuoming.html";
            agreement = @"《服务说明》";
        }
        if (link.length > 0) {
            text = [NSString stringWithFormat:@"%@<font size=13 color='#9a9a9a'><p>更多充值说明，点击查看<font color='#20ab2a'><a href='%@'>%@</a></font></p></font>",
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

- (void)consumeEvent:(CKStoreEvent *)event
{
}

@end

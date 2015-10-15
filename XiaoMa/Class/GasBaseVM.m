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
        _isLoadSuccess = NO;
        _gasRemainder = @"充值成功后，须至相应加油站圈存后方能使用；如需开发票，请在营业厅圈存后向工作人员索要。";
        _segHelper = [[CKSegmentHelper alloc] init];
        _paymentPlatform = PaymentPlatformTypeAlipay;
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

@end

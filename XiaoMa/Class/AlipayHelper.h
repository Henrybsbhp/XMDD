//
//  AlipayHelper.h
//  HappyTrain
//
//  Created by jt on 14-10-23.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
#import "alipayConfig.h"
//#import "AlixLibService.h"
#import "DataSigner.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"
#import "AlixPayOrder.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "AlixPayOrder.h"
#import "XiaoMa.h"
#import "AlipayHelper.h"
#import "AlixPayResult.h"

@interface AlipayHelper : NSObject
{
    SEL _result;
}

@property (nonatomic,assign) SEL result;//这里声明为属性方便在于外部传入。
///// 支付宝支付结果信号
@property (nonatomic,strong)RACSubject * rac_alipayResultSignal;

+ (instancetype)sharedHelper;

- (void)payOrdWithTradeNo:(NSString *)TradeNO andProductName:(NSString *)pName
    andProductDescription:(NSString *)pDescription andPrice:(float_t)price;
@end

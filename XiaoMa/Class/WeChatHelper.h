//
//  WeChatHelper.h
//  XiaoMa
//
//  Created by jt on 15-4-23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WXApiObject.h"


@interface WeChatHelper : NSObject

/// 微信支付结果信号 9000,dismiss,
@property (nonatomic,strong)RACSubject * rac_wechatResultSignal;

+ (instancetype)sharedHelper;

- (void)payOrdWithTradeNo:(NSString *)TradeNO andProductName:(NSString *)pName andPrice:(float_t)price;

@end

//
//  WeChatHelper.h
//  XiaoMa
//
//  Created by jt on 15-4-23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
#import "PaymentHelper.h"

@interface WeChatHelper : NSObject

/// 判断支付完成后，是否通过左上角。微信如果通过左上角，收不到微信的回调
@property (nonatomic)BOOL isBackFromUpperLeftCorner;
/// 交易类型，用于订单状态查询
@property (nonatomic)TradeType tradeType;

- (RACSignal *)rac_payWithTradeNumber:(NSString *)tn productName:(NSString *)pn price:(CGFloat)price;

@end

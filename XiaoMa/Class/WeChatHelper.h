//
//  WeChatHelper.h
//  XiaoMa
//
//  Created by jt on 15-4-23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface WeChatHelper : NSObject

- (RACSignal *)rac_payWithTradeNumber:(NSString *)tn productName:(NSString *)pn price:(CGFloat)price;

@end

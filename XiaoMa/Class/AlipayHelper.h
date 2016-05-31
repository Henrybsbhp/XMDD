//
//  AlipayHelper.h
//  HappyTrain
//
//  Created by jt on 14-10-23.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface AlipayHelper : NSObject
- (RACSignal *)rac_payWithTradeNumber:(NSString *)tn productName:(NSString *)pn
                   productDescription:(NSString *)pd price:(CGFloat)price
                         notifyStrUrl:(NSString *)notifyUrlStr;

@end

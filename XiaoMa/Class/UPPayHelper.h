//
//  UPPayHelper.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPPayHelper : NSObject

- (RACSignal *)rac_payWithTradeNumber:(NSString *)tn targetVC:(UIViewController *)tvc;

@end

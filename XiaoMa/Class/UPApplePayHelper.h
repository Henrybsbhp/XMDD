//
//  UPApplePayHelper.h
//  XiaoMa
//
//  Created by St.Jimmy on 7/19/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPApplePayHelper : NSObject

- (RACSignal *)rac_applePayWithTradeNumber:(NSString *)tn targetVC:(UIViewController *)tvc;

@end

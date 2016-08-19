//
//  UPayVerifyVC.h
//  XMDD
//
//  Created by RockyYe on 16/8/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPayVerifyVC : UIViewController

@property (strong, nonatomic) NSString *tradeNo;
@property (assign, nonatomic) CGFloat orderFee;
@property (strong, nonatomic) NSString *serviceName;
@property (strong, nonatomic) NSArray *bankCardInfo;
@property (strong, nonatomic) RACSubject *subject;

@end

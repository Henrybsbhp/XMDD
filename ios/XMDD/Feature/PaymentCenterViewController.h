//
//  PaymentCenterViewController.h
//  XiaoMa
//
//  Created by jt on 15/11/16.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentCenterViewController : HKViewController

@property (nonatomic,copy)NSString * tradeNo;
@property (nonatomic,copy)NSString * tradeType;

@property (nonatomic,strong)UIViewController * originVc;

@end

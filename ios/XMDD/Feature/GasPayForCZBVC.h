//
//  GasPayForCZBVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GasCard.h"
#import "MyBankCard.h"

@interface GasPayForCZBVC : HKViewController

@property (nonatomic, strong) MyBankCard *bankCard;
@property (nonatomic, strong) GasCard *gasCard;
@property (nonatomic, strong) NSString *payTitle;
@property (nonatomic, assign) float rechargeAmount;
@property (nonatomic, assign) float discountAmount;
@property (nonatomic, assign) BOOL needInvoice;
@property (nonatomic, weak) UIViewController *originVC;
@property (nonatomic, copy) void(^didPaidSuccessBlock)();

@end

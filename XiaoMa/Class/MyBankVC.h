//
//  MyBankVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GasCZBVM.h"
#import "HKBankCard.h"

@interface MyBankVC : HKViewController

@property (nonatomic, copy) void(^didSelectedBlock)(HKBankCard *card);

@end

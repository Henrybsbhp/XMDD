//
//  MyBankVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyBankCard.h"

/// 我的浙商卡页面
@interface MyBankVC : HKViewController

@property (nonatomic, copy) void(^didSelectedBlock)(MyBankCard *card);

@end

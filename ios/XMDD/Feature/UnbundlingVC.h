//
//  UnbundlingVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyBankCard.h"

@interface UnbundlingVC : HKViewController
@property (nonatomic, copy)NSString *cardId;
@property (nonatomic, copy)NSString *cardNumber;
@property (nonatomic, weak) UIViewController *originVC;
@end

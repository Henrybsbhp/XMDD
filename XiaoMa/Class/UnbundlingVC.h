//
//  UnbundlingVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKBankCard.h"

@interface UnbundlingVC : UIViewController
@property (nonatomic, strong) HKBankCard *card;
@property (nonatomic, weak) UIViewController *originVC;
@end

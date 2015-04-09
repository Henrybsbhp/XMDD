//
//  PayForWashCarVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTShop.h"

@interface PayForWashCarVC : UIViewController
@property (nonatomic, strong) JTShopService *service;
@property (nonatomic, strong) JTShop *shop;
@property (nonatomic, weak) UIViewController *originVC;
@end

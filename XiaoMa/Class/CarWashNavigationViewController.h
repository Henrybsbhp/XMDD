//
//  CarWashNavigationViewController.h
//  XiaoMa
//
//  Created by jt on 15-4-16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseMapViewController.h"
#import "JTShop.h"

@interface CarWashNavigationViewController : BaseMapViewController

@property (nonatomic,strong)JTShop * shop;

/// 是否已收藏标签
@property (nonatomic)BOOL favorite;

@end

//
//  ChooseWashCarTicketVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseCarwashTicketVC : UIViewController

@property (nonatomic, weak) UIViewController *originVC;

@property (nonatomic,strong)NSNumber * couponId;

@property (nonatomic,strong)NSArray * couponArray;

@end

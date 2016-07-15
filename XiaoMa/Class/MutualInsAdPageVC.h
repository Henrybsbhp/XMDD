//
//  MutualInsAdPageVC.h
//  XiaoMa
//
//  Created by RockyYe on 16/7/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MutualInsAdPageVC : UIViewController

@property (strong, nonatomic) UIViewController *targetVC;

+ (instancetype)presentInTargetVC:(UIViewController *)targetVC;

@end

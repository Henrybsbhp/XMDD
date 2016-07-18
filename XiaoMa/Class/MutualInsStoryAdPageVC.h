//
//  MutualInsStoryAdPageVC.h
//  XiaoMa
//
//  Created by RockyYe on 16/7/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MutualInsAdModel.h"

@interface MutualInsStoryAdPageVC : UIViewController

@property (strong, nonatomic) UIViewController *targetVC;

+ (instancetype)presentWithModel:(MutualInsAdModel *)model;

@end

//
//  MutInsCalculateVC.h
//  XiaoMa
//
//  Created by RockyYe on 16/7/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MutInsCalculateVC : UIViewController

/// 渠道，用于神策统计
@property (nonatomic, copy) NSString *channel;

@property (nonatomic, strong) HKMyCar *car;
@property (nonatomic, strong) NSArray *carArray;

@end

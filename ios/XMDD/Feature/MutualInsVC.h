//
//  MutualInsVC.h
//  XiaoMa
//
//  Created by St.Jimmy on 7/11/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MutualInsVC : UIViewController

/// 渠道，用于神策统计
@property (nonatomic,copy)NSString * sensorChannel;

- (void)presentAdPageVC;

@end

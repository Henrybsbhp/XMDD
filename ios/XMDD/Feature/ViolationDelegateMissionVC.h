//
//  ViolationDelegateMissionVC.h
//  XMDD
//
//  Created by RockyYe on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViolationViewController.h"

@interface ViolationDelegateMissionVC : UIViewController

/**
 *  请求代办列表所需参数
 */
@property (strong, nonatomic) NSString *licenceNumber;
/**
 *  传值给完善信息页面所需参数
 */
@property (strong, nonatomic) NSNumber *userCarID;
/**
 *  设置代理实现反向传值
 */
@property (strong, nonatomic) ViolationViewController *delegate;


@end

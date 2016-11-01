//
//  RescuePaymentStatusVC.h
//  XMDD
//
//  Created by St.Jimmy on 18/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKTableViewController.h"

typedef enum : NSInteger
{
    RescueVCTypePay = 1, // 救援支付
    RescueVCTypeControl = 2, // 救援调度
    RescueVCTypeRescuing = 3, // 救援中
    RescueVCTypeRating = 4 // 救援完成评价
} RescueVCType;

@interface RescuePaymentStatusVC : UIViewController

/// 是否已评论，1: 已评论， 2: 未评论
@property (nonatomic, assign) NSInteger commentStatus;

/// VC 的类型，1: 救援支付， 2: 救援调度， 3: 救援中， 4: 救援完成评价
@property (nonatomic, assign) NSInteger vcType;

/// 记录 ID，请求数据的输入参数
@property (nonatomic, strong) NSNumber *applyID;

/// 判断是否从推送主页面进入
@property (nonatomic) BOOL isEnterFromHomePage;

@end

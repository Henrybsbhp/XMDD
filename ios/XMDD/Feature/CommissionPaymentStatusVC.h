//
//  CommissionPaymentStatusVC.h
//  XMDD
//
//  Created by St.Jimmy on 19/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommissionPaymentStatusVC : UIViewController

/// 是否已评论，1: 已评论， 2: 未评论
@property (nonatomic, assign) NSInteger commentStatus;

/// VC 的类型，1: 待支付， 2: 已支付， 3: 已完成， 4: 已取消
@property (nonatomic, assign) NSInteger vcType;

/// 记录 ID，请求数据的输入参数
@property (nonatomic, strong) NSNumber *applyID;

/// 判断是否从推送主页面进入
@property (nonatomic) BOOL isEnterFromHomePage;

@end

//
//  CouponDetailsVC.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/9/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponDetailsVC : UIViewController

///优惠劵Id
@property (nonatomic, strong)NSNumber * couponId;

///是否可分享
@property (nonatomic, assign)BOOL isShareble;

///优惠券颜色
@property (nonatomic, strong)NSString * rgbStr;

@end

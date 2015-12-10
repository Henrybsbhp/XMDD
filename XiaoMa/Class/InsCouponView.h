//
//  InsCouponView.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/10.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InsCouponView : UIView
@property (nonatomic, strong) NSArray *coupons;
@property (nonatomic, strong) UIColor *buttonTitleColor;
@property (nonatomic, strong) UIColor *buttonBorderColor;
@property (nonatomic, assign) CGFloat buttonHeight;

- (void)setup;
+ (CGFloat)heightWithCouponCount:(NSUInteger)count buttonHeight:(CGFloat)height;

@end

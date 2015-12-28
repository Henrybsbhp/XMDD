//
//  CarListSubView.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKMyCar.h"

@interface CarListSubView : UIView
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UILabel *licenceNumberLabel;
///表示是否为“默认”车辆的标记
@property (nonatomic, strong) UIView *markView;
@property (nonatomic, copy) void(^valuationClickBlock)(void);
@property (nonatomic, copy) void(^bottomButtonClickBlock)(UIButton *btn, CarListSubView* view);
@property (nonatomic, copy) void(^backgroundClickBlock)(CarListSubView *view);

- (void)setCellTitle:(NSString *)title withValue:(NSString *)value atIndex:(NSInteger)index;
- (void)setCarTintColorType:(HKCarTintColorType)colorType;
- (void)setShowBottomButton:(BOOL)show withText:(NSString *)text;

@end

//
//  CarValuationSubView.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarValuationSubView : UIView

@property (nonatomic, strong)UIViewController * originVC;

@property (nonatomic, copy) void(^selectTypeClickBlock)(void);
@property (nonatomic, copy) void(^selectDateClickBlock)(void);
@property (nonatomic, copy) void(^addCarClickBlock)(void);

- (id)initWithFrame:(CGRect)frame andCarModel:(HKMyCar *)carModel;

@end

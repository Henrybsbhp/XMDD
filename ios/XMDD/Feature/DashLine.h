//
//  DashLine.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/3.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashLine : UIView
///(default is grayColor)
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat* dashLengths;
///(default is NO)
@property (nonatomic, assign) BOOL vertical;

@end

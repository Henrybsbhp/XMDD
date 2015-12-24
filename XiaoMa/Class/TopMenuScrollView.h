//
//  TopMenuScrollView.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/24.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopMenuScrollView : UIScrollView

//stroryboard中直接继承的初始化方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

//代码添加的初始化方法
- (instancetype)initWithFrame:(CGRect)frame;

@end
//
//  OEButtonView.h
//  XiaoMa
//
//  Created by RockyYe on 16/7/20.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OEButton.h"

/// 仿系统键盘点击后的悬浮窗
@interface OEButtonView : UIView

- (instancetype)initWithKeyboardButton:(OEButton *)button;

@end

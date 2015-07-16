//
//  PwdInputField.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCodeInputField : UITextField

@property (nonatomic, strong) UIButton *rightButton;

- (void)showRightViewAfterInterval:(NSTimeInterval)interval;
- (void)hideRightView;

@end

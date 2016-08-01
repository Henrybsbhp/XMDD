//
//  KeyboardHelper.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KeyboardHelperDelegate;

@interface KeyboardHelper : NSObject
@property (nonatomic, weak) id<KeyboardHelperDelegate> delegate;
@end

@protocol KeyboardHelperDelegate <NSObject>

/// 键盘高度是否改变
- (void)keyboardChangeWithHeight:(CGFloat)height duration:(CGFloat)dur
                           curve:(UIViewAnimationOptions)curve forHiden:(BOOL)hiden;

@end


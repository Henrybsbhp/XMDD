//
//  UIView+DefaultEmptyView.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/26.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DefaultEmptyView)

- (void)showDefaultEmptyViewWithText:(NSString *)text;
- (void)showDefaultEmptyViewWithText:(NSString *)text tapBlock:(void(^)(void))tapBlock;
- (void)showDefaultEmptyViewWithText:(NSString *)text centerOffset:(CGFloat)offset tapBlock:(void(^)(void))tapBlock;
- (void)showDefaultEmptyViewWithImageName:(NSString *)imgName text:(NSString *)text
                             centerOffset:(CGFloat)offset tapBlock:(void(^)(void))tapBlock;
- (void)hideDefaultEmptyView;

@end

//
//  UIView+DefaultEmptyView.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/26.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DefaultEmptyView)

/**
 *  显示默认空页面
 *
 *  @param text 提示文案
 */
- (void)showDefaultEmptyViewWithText:(NSString *)text;
/**
 *  显示带点击事件的默认空页面
 *
 *  @param text     提示文案
 *  @param tapBlock 点击事件
 */
- (void)showDefaultEmptyViewWithText:(NSString *)text tapBlock:(void(^)(void))tapBlock;
/**
 *  显示带点击事件的默认空页面（可以修改图片位置）
 *
 *  @param text     提示文案
 *  @param offset   图片偏移量
 *  @param tapBlock 点击事件
 */
- (void)showDefaultEmptyViewWithText:(NSString *)text centerOffset:(CGFloat)offset tapBlock:(void(^)(void))tapBlock;

/**
 *  显示自定义图片的空页面
 *
 *  @param imgName 图片名
 *  @param text    提示文案
 */
- (void)showImageEmptyViewWithImageName:(NSString *)imgName text:(NSString *)text;
/**
 *  显示带点击事件的自定义图片的空页面
 *
 *  @param imgName  图片名
 *  @param text     提示文案
 *  @param tapBlock 点击事件
 */
- (void)showImageEmptyViewWithImageName:(NSString *)imgName text:(NSString *)text tapBlock:(void(^)(void))tapBlock;
/**
 *  显示带点击事件的自定义图片的空页面（可以修改图片位置）
 *
 *  @param imgName  图片名
 *  @param text     提示文案
 *  @param offset   图片偏移量
 *  @param tapBlock 点击事件
 */
- (void)showImageEmptyViewWithImageName:(NSString *)imgName text:(NSString *)text
                           centerOffset:(CGFloat)offset tapBlock:(void(^)(void))tapBlock;
/**
 *  显示带点击事件的自定义图片的空页面（可以修改图片位置）
 *
 *  @param imgName  图片名
 *  @param text     提示文案
 *  @param offset   图片偏移量
 *  @param tapBlock 点击事件
 */
- (void)showEmptyViewWithImageName:(NSString *)imgName text:(NSString *)text
                      centerOffset:(CGFloat)offset tapBlock:(void(^)(void))tapBlock;

/**
 *  显示带点击事件的自定义图片的空页面（可以修改图片位置）
 *
 *  @param imgName  图片名
 *  @param text     提示文案
 *  @param textColor 文本颜色
 *  @param offset   图片偏移量
 *  @param tapBlock 点击事件
 */
- (void)showEmptyViewWithImageName:(NSString *)imgName text:(NSString *)text textColor:(UIColor *)textColor
                      centerOffset:(CGFloat)offset tapBlock:(void(^)(void))tapBlock;

/**
 *  隐藏空页面
 */
- (void)hideDefaultEmptyView;
/**
 *  是否展示空页面
 *
 *  @return YES展示。NO不展示。
 */
- (BOOL)isShowDefaultEmptyView;

@end

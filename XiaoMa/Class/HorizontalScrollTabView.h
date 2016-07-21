//
//  HorizontalScrollTabView.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HorizontalScrollTabItem;


@interface HorizontalScrollTabView : UIView
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign, readonly) NSInteger selectedIndex;
@property (nonatomic, strong) UIColor *scrollTipBarColor;
@property (nonatomic, copy) void (^tabBlock)(NSInteger index);

- (void)reloadDataWithBoundsSize:(CGSize)size andSelectedIndex:(NSInteger)index;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;
- (void)setDotHidden:(BOOL)hidden atIndex:(NSInteger)index;
- (BOOL)dotIsHiddenAtIndex:(NSInteger)index;

@end

@interface HorizontalScrollTabItem : NSObject
@property (nonatomic, strong, readonly) UIColor *normalColor;
@property (nonatomic, strong, readonly) UIColor *selectedColor;
@property (nonatomic, strong, readonly) NSString *title;

+ (instancetype)itemWithTitle:(NSString *)title normalColor:(UIColor *)normalColor selectedColor:(UIColor *)selectedColor;

@end

@interface HorizontalScrollTabItemView : UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *dotView;
@end
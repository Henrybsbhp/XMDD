//
//  HorizontalScrollTabView.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HorizontalScrollTabView.h"

#define kScrollTipBarHeight         1.5

@interface HorizontalScrollTabView ()
@property (nonatomic, strong) UIView *scrollTabBar;
@end

@implementation HorizontalScrollTabView

#pragma mark - Reload
- (void)reloadDataWithBoundsSize:(CGSize)size andSelectedIndex:(NSInteger)index {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat itemWidth = size.width/MAX(1, self.items.count);
    CGRect rect = CGRectMake(0, 0, itemWidth, size.height - kScrollTipBarHeight);
    for (NSInteger i=0; i<self.items.count; i++) {
        HorizontalScrollTabItem *item = self.items[i];
        UIView *tab = [self createTabViewWithTabItem:item];
        rect.origin.x = i*itemWidth;
        tab.frame = rect;
        tab.tag = 1000+i;
        [self addSubview:tab];
    }
    self.scrollTabBar = [[UIView alloc] initWithFrame:CGRectMake(0, size.height-kScrollTipBarHeight, itemWidth, kScrollTipBarHeight)];
    self.scrollTabBar.backgroundColor = self.scrollTipBarColor;
    [self addSubview:self.scrollTabBar];
    [self setSelectedIndex:index animated:NO];
}

#pragma mark - Animate
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    _selectedIndex = selectedIndex;
    CGRect rect = self.scrollTabBar.frame;
    rect.origin.x = selectedIndex*rect.size.width;
    if (animated) {
        
        [UIView animateWithDuration:0.24 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollTabBar.frame = rect;
        } completion:nil];
    }
    else {
        self.scrollTabBar.frame = rect;
    }
    for (NSInteger i=0; i<self.items.count; i++) {
        HorizontalScrollTabItem *item = self.items[i];
        UILabel *label = [self viewWithTag:i+1000];
        label.textColor = i == selectedIndex ? item.selectedColor : item.normalColor;
    }
}

#pragma mark - Private
- (UILabel *)createTabViewWithTabItem:(HorizontalScrollTabItem *)item {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16];
    label.text = item.title;
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
    [label addGestureRecognizer:tap];
    
    return label;
}

#pragma mark - Action
- (void)actionTap:(UITapGestureRecognizer *)tap {
    NSInteger index = tap.view.tag - 1000;
    if (index != self.selectedIndex) {
        [self setSelectedIndex:index animated:YES];
        if (self.tabBlock) {
            self.tabBlock(index);
        }
    }
}


@end

@implementation HorizontalScrollTabItem

+ (instancetype)itemWithTitle:(NSString *)title normalColor:(UIColor *)normalColor selectedColor:(UIColor *)selectedColor
{
    HorizontalScrollTabItem *item = [[HorizontalScrollTabItem alloc] init];
    item->_normalColor = normalColor;
    item->_selectedColor = selectedColor;
    item->_title = title;
    return item;
}

@end
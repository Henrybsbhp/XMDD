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

#pragma mark - Public
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

#pragma mark - DotView
- (BOOL)dotIsHiddenAtIndex:(NSInteger)index {
    HorizontalScrollTabItemView *itemView = [self viewWithTag:index + 1000];
    return itemView.dotView.hidden;
}

- (void)setDotHidden:(BOOL)hidden atIndex:(NSInteger)index {
    if (index == NSNotFound) {
        return;
    }
    HorizontalScrollTabItemView *itemView = [self viewWithTag:index + 1000];
    itemView.dotView.hidden = hidden;
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
        HorizontalScrollTabItemView *itemView = [self viewWithTag:i+1000];
        itemView.titleLabel.textColor = i == selectedIndex ? item.selectedColor : item.normalColor;
    }
}

#pragma mark - Private
- (UIView *)createTabViewWithTabItem:(HorizontalScrollTabItem *)item {

    HorizontalScrollTabItemView *view = [[HorizontalScrollTabItemView alloc] initWithFrame:CGRectZero];
    view.titleLabel.text = item.title;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
    [view addGestureRecognizer:tap];
    return view;
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

@implementation HorizontalScrollTabItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self __commonInit];
    return self;
}

- (void)__commonInit {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    [self addSubview:label];
    self.titleLabel = label;
    
    UIImageView *dotView = [[UIImageView alloc] initWithFrame:CGRectZero];
    dotView.hidden = YES;
    dotView.image = [UIImage imageNamed:@"cm_dot_300"];
    [self addSubview:dotView];
    self.dotView = dotView;
    
    @weakify(self);
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.center.equalTo(self).centerOffset(CGPointZero);
    }];
    
    [dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(label.mas_top).offset(-3);
        make.left.equalTo(label.mas_right).offset(3);
    }];
}
@end
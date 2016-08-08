//
//  ShopDetailNavigationBar.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailNavigationBar.h"

@interface ShopDetailNavigationBar ()
@property (nonatomic, strong) UIButton *greenStarButton;
@property (nonatomic, strong) UIButton *whiteStarButton;
@property (nonatomic, strong) UIButton *greenBackButton;
@property (nonatomic, strong) UIView *titleContainerView;
@end

@implementation ShopDetailNavigationBar

- (instancetype)initScrollView:(UIScrollView *)scrollView {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _scrollView = scrollView;
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit {
    self.backgroundColor = [UIColor clearColor];
    [self setupTitleView];

    UIImage *backImage = [UIImage imageNamed:@"nav_back_300"];
    UIButton *whiteBackButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [whiteBackButton setImage:[backImage imageByFilledWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self addSubview:whiteBackButton];
    
    _greenBackButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_greenBackButton setImage:backImage forState:UIControlStateNormal];
    [self addSubview:_greenBackButton];
    
    _whiteStarButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self addSubview:_whiteStarButton];

    _greenStarButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self addSubview:_greenBackButton];
    
    [self setIsCollected:NO];

    @weakify(self);
    [whiteBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20);
        make.left.equalTo(self).offset(6);
        make.size.mas_equalTo(CGSizeMake(70, 42));
    }];
    
    [_greenBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self).offset(20);
        make.left.equalTo(self).offset(6);
        make.size.mas_equalTo(CGSizeMake(70, 42));
    }];
    
    [_whiteStarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-6);
        make.size.mas_equalTo(CGSizeMake(70, 42));
    }];
    
    [_greenBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-6);
        make.size.mas_equalTo(CGSizeMake(70, 42));
    }];

    [self observeScrollView];
}

- (void)setupTitleView {
    _titleContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    _titleContainerView.backgroundColor = [UIColor clearColor];
    [self addSubview:_titleContainerView];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor whiteColor];
    [_titleContainerView addSubview:bgView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [UIFont boldSystemFontOfSize:17];
    _titleLabel.textColor = kBlackTextColor;
    [_titleContainerView addSubview:_titleLabel];
    
    UIImageView *shadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cm_nav_shadow"]];
    [_titleContainerView addSubview:shadowView];
    
    @weakify(self);
    [_titleContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self);
    }];
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleContainerView);
        make.right.equalTo(_titleContainerView);
        make.top.equalTo(_titleContainerView);
    }];
    
    [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleContainerView);
        make.right.equalTo(_titleContainerView);
        make.bottom.equalTo(_titleContainerView);
        make.height.mas_equalTo(3);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_titleContainerView);
        make.centerY.equalTo(_titleContainerView).offset(10);
    }];
}

- (void)observeScrollView {
    [[RACObserve(self.scrollView, contentOffset) distinctUntilChanged] subscribeNext:^(id x) {
        
    }];
}

#pragma mark - Setter
- (void)setIsCollected:(BOOL)isCollected {
    _isCollected = isCollected;
    [_whiteStarButton setImage:[self imageForStarButtonWithCollected:isCollected andWhite:YES]
                      forState:UIControlStateNormal];
    [_greenStarButton setImage:[self imageForStarButtonWithCollected:isCollected andWhite:NO]
                      forState:UIControlStateNormal];
}
#pragma mark - Util
- (UIImage *)imageForStarButtonWithCollected:(BOOL)collected andWhite:(BOOL)white {
    if (collected) {
        return white ? [UIImage imageNamed:@"shop_white_fillstar_300"] : [UIImage imageNamed:@"shop_green_fillstar_300"];
    }
    return white ? [UIImage imageNamed:@"shop_white_star_300"] : [UIImage imageNamed:@"shop_green_star_300"];
}

@end

//
//  SearchShopListBar.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "SearchShopListBar.h"

@interface SearchShopListBar ()
@end
@implementation SearchShopListBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __commonInitWithFrame:frame];
    }
    return self;
}

- (void)__commonInitWithFrame:(CGRect)frame {
    CGFloat width = CGRectGetWidth(frame);
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, width - 77, frame.size.height)];
    _searchBar.barStyle = UIBarStyleDefault;
    [_searchBar setPlaceholder:@"找商户"];
    [_searchBar setBackgroundColor:[UIColor clearColor]];
    [_searchBar setBackgroundImage:[UIImage new]];
//    [_searchBar setSearchFieldBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    _searchBar.layer.cornerRadius = 4;
    _searchBar.layer.borderWidth = 1;
    _searchBar.layer.borderColor = kDefLineColor.CGColor;
    _searchBar.layer.masksToBounds = YES;
    [self addSubview:_searchBar];
    
    _searchButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 72, 0, 52, frame.size.height)];
    [_searchButton setBackgroundColor:kDefTintColor];
    [_searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_searchButton setTitle:@"搜索" forState:UIControlStateNormal];
    _searchButton.titleLabel.font = [UIFont systemFontOfSize:13];
    _searchButton.layer.cornerRadius = 5;
    _searchButton.layer.masksToBounds = YES;
    [self addSubview:_searchButton];
}

@end

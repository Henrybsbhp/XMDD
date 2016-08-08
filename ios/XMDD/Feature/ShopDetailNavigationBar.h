//
//  ShopDetailNavigationBar.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopDetailNavigationBar : UIView
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) BOOL isCollected;

@end

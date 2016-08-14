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
@property (nonatomic, copy) void(^shouldUpdateStatusBar)(void);
@property (nonatomic, copy) void(^actionDidBack)(void);
@property (nonatomic, copy) void(^actionDidCollect)(void);
@property (nonatomic, assign) BOOL titleDidShowed;

- (instancetype)initWithFrame:(CGRect)frame andScrollView:(UIScrollView *)scrollView;
@end

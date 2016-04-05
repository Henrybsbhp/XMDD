//
//  HKPageSliderView.h
//  HKPageSliderView
//
//  Created by 刘亚威 on 16/3/28.
//  Copyright © 2016年 lyw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HKTabBarStyle) {
    HKTabBarStyleUnderline       = 0,   //订单优惠券等下划线风格
    HKTabBarStyleUnderCorner     = 1,   //我的爱车白色三角光标风格
    HKTabBarStyleCleanMenu       = 2    //
};

@protocol PageSliderDelegate <NSObject>

- (void)pageClickAtIndex:(NSInteger)index;

@optional

- (void)addContentVCAtIndex:(NSInteger)index;

@end

@interface HKPageSliderView : UIView

@property (nonatomic, weak) id <PageSliderDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame andTitleArray:(NSArray *)titleArray andStyle:(HKTabBarStyle)style atIndex:(NSInteger)index;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) UIScrollView *contentScrollView;

- (void)selectAtIndex:(NSInteger)index;

@end


@interface TabBarMenuStyleModel : NSObject

@property (nonatomic, assign) CGFloat menuHeight;
@property (nonatomic, strong) UIColor *menuBackgroundColor;
@property (nonatomic, assign) CGFloat buttonSpacing;
@property (nonatomic, strong) UIColor *menuNormalColor;
@property (nonatomic, strong) UIColor *menuSelectedColor;
@property (nonatomic, strong) UIView *bottomView;

@end
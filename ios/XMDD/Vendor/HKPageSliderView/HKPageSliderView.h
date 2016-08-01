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

@optional

- (void)pageClickAtIndex:(NSInteger)index;

/// 委托中是否监控scrollview的offset属性 。 会通知菜单栏进行动画。如果响应的话，菜单栏的点击事件的光标动画就不需要了。 。
- (BOOL)observeScrollViewOffset;



- (void)addContentVCAtIndex:(NSInteger)index;

@end

@interface HKPageSliderView : UIView

@property (nonatomic, weak) id <PageSliderDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame andTitleArray:(NSArray *)titleArray andStyle:(HKTabBarStyle)style atIndex:(NSInteger)index;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) UIScrollView *contentScrollView;

- (void)selectAtIndex:(NSInteger)index;

// 光标移动方向，pecent百分比，direction方向（-1左，1右）
- (void)slideOffsetX:(CGFloat)offsetX andTotleW:(CGFloat)totalWidth andPageW:(CGFloat)pageWidth;

@end


@interface TabBarMenuStyleModel : NSObject

@property (nonatomic, assign) CGFloat menuHeight;
@property (nonatomic, strong) UIColor *menuBackgroundColor;
@property (nonatomic, assign) CGFloat buttonSpacing;
@property (nonatomic, strong) UIColor *menuNormalColor;
@property (nonatomic, strong) UIColor *menuSelectedColor;
@property (nonatomic, strong) UIView *bottomView;


/// 如下颜色需要和menuNormalColor对应
@property (nonatomic)CGFloat menuNormalColorR;
@property (nonatomic)CGFloat menuNormalColorG;
@property (nonatomic)CGFloat menuNormalColorB;

@property (nonatomic)CGFloat menuSelectColorR;
@property (nonatomic)CGFloat menuSelectColorG;
@property (nonatomic)CGFloat menuSelectColorB;

@end
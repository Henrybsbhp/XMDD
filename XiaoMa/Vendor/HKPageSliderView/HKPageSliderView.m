//
//  YWTabBarView.m
//  YWPageSliderControl
//
//  Created by 刘亚威 on 16/3/28.
//  Copyright © 2016年 lyw. All rights reserved.
//

#import "HKPageSliderView.h"

#define HKTabBarStyleCleanMenuScale 0.7f
#define HKTabBarStyleUnderCornerScale 0.8f

@interface HKPageSliderView()

@property (nonatomic, assign) HKTabBarStyle style;
@property (nonatomic, strong) TabBarMenuStyleModel *styleModel;

@property (nonatomic, strong) UIScrollView *menuScrollView;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSArray<NSString*> *titles;
@property (nonatomic, strong) UIView *cursorView;

@property (nonatomic, assign) BOOL isAnimation;

@end

@implementation HKPageSliderView


- (void)dealloc
{
    DebugLog(@"HKPageSliderView dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame andTitleArray:(NSArray *)titles andStyle:(HKTabBarStyle)style atIndex:(NSInteger)index;
{
    if (self = [super init]) {
        self.frame = frame;
        self.titles = titles;
        self.style = style;
        self.currentIndex = index;
        [self setupStyleModel];
        [self setupMenu];
        [self setupContent];
    }
    return self;
}

- (void)setupStyleModel
{
    self.styleModel = [TabBarMenuStyleModel new];
    if (self.style == HKTabBarStyleUnderline) {
        self.styleModel.menuHeight = 46;
        self.styleModel.buttonSpacing = 10;
        self.styleModel.menuNormalColor = HEXCOLOR(@"#888888"); //todo
        self.styleModel.menuSelectedColor = HEXCOLOR(@"#18D06A"); //todo
        self.styleModel.menuNormalColorR = 0.53125f;
        self.styleModel.menuNormalColorG = 0.53125f;
        self.styleModel.menuNormalColorB = 0.53125f;
        self.styleModel.menuSelectColorR = 0.09375f;
        self.styleModel.menuSelectColorG = 0.8125f;
        self.styleModel.menuSelectColorB = 0.4140625f;
    }
    else if (self.style == HKTabBarStyleUnderCorner) {
        self.styleModel.menuHeight = self.titles.count > 1 ? 38 : 0;
        self.styleModel.buttonSpacing = 8;
        self.styleModel.menuNormalColor = HEXCOLOR(@"#dbdbdb");
        self.styleModel.menuSelectedColor = HEXCOLOR(@"#ffffff");
        self.styleModel.menuBackgroundColor = HEXCOLOR(@"#12c461");
        self.styleModel.menuNormalColorR = 0.85546875f;
        self.styleModel.menuNormalColorG = 0.85546875f;
        self.styleModel.menuNormalColorB = 0.85546875f;
        self.styleModel.menuSelectColorR = 1.0f;
        self.styleModel.menuSelectColorG = 1.0f;
        self.styleModel.menuSelectColorB = 1.0f;
    }
    else if (self.style == HKTabBarStyleCleanMenu) {
        self.styleModel.menuHeight = 50;
        self.styleModel.buttonSpacing = 5;
        self.styleModel.menuNormalColor = HEXCOLOR(@"#888888");
        self.styleModel.menuSelectedColor = HEXCOLOR(@"#18D06A");
        self.styleModel.menuBackgroundColor = [UIColor clearColor];
        
        self.styleModel.menuNormalColorR = 0.53125f;
        self.styleModel.menuNormalColorG = 0.53125f;
        self.styleModel.menuNormalColorB = 0.53125f;
        self.styleModel.menuSelectColorR = 0.09375f;
        self.styleModel.menuSelectColorG = 0.8125f;
        self.styleModel.menuSelectColorB = 0.4140625f;
    }
}

- (void)setupMenu
{
    self.menuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.styleModel.menuHeight)];
    self.menuScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.menuScrollView];
    if (self.style == HKTabBarStyleCleanMenu) {
        UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 49.5, self.bounds.size.width, 0.5)];
        lineView.image = [UIImage imageNamed:@"cm_greenline"];
        [self insertSubview:lineView atIndex:0];
    }
    
    //设置按钮
    self.buttons = [NSMutableArray array];
    for (int i = 0; i < self.titles.count; i ++) {
        UIButton * button = [UIButton new];
        button.tag = i;
        [button setTitle:self.titles[i] forState:UIControlStateNormal];
        //当前所选按钮设置为选择色
        [button setTitleColor:self.currentIndex == i ? self.styleModel.menuSelectedColor  : self.styleModel.menuNormalColor forState:UIControlStateNormal];
        
        //先按照最大的字体设置大小
        if (self.style == HKTabBarStyleUnderline) {
            button.titleLabel.font = [UIFont systemFontOfSize:15];
        }
        else if (self.style == HKTabBarStyleUnderCorner) {
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [button sizeToFit];
            [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            CGFloat r = self.currentIndex == i ? 1.0f : HKTabBarStyleUnderCornerScale;
            button.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, r, r);
        }
        else if (self.style == HKTabBarStyleCleanMenu) {
            button.titleLabel.font = [UIFont systemFontOfSize:21];
            [button sizeToFit];
            [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
            CGFloat r = self.currentIndex == i ? 1.0f : HKTabBarStyleCleanMenuScale;
            button.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, r, r);
        }
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuScrollView addSubview:button];
        [self.buttons addObject:button];
    }
    
    //设置光标视图
    [self setupCursor];
}

- (void)setupContent
{
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.styleModel.menuHeight, self.bounds.size.width, self.bounds.size.height - self.styleModel.menuHeight)];
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.pagingEnabled = YES;
    [self.contentScrollView setContentSize:CGSizeMake(self.bounds.size.width * self.buttons.count, self.bounds.size.height - self.styleModel.menuHeight)];
    [self.contentScrollView setContentOffset:CGPointMake(self.currentIndex * self.contentScrollView.bounds.size.width, 0)];
    [self addSubview:self.contentScrollView];
}

-(void)setupCursor
{
    self.cursorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.menuScrollView.frame.size.width, 0)];
    //插入到最底层防止遮挡按钮
    [self.menuScrollView insertSubview:self.cursorView atIndex:0];
    
    //根据风格设置光标类型
    if (self.style == HKTabBarStyleUnderline) {
        UIView *underLine = [[UIView alloc] init];
        underLine.backgroundColor = [UIColor greenColor]; //todo
        [self.cursorView addSubview:underLine];
        
        [underLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.cursorView);
            make.right.equalTo(self.cursorView);
            make.height.mas_equalTo(2);
            make.bottom.equalTo(self.cursorView);
        }];
    }
    else if (self.style == HKTabBarStyleUnderCorner){
        self.menuScrollView.backgroundColor = self.styleModel.menuBackgroundColor;
        UIImageView *underTriangle = [[UIImageView alloc] init];
        underTriangle.image = [UIImage imageNamed:@"mec_cursor"];
        underTriangle.translatesAutoresizingMaskIntoConstraints = NO;
        [self.cursorView addSubview:underTriangle];
        
        [underTriangle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.cursorView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(11, 6));
            make.bottom.equalTo(self.cursorView);
        }];
    }
    else if (self.style == HKTabBarStyleCleanMenu) {
        self.menuScrollView.backgroundColor = self.styleModel.menuBackgroundColor;
        UIImageView *underTriangle = [[UIImageView alloc] init];
        underTriangle.image = [UIImage imageNamed:@"mec_greencursor"];
        underTriangle.translatesAutoresizingMaskIntoConstraints = NO;
        [self.cursorView addSubview:underTriangle];
        
        [underTriangle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.cursorView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(16, 7));
            make.bottom.equalTo(self.cursorView).offset(0.5);
        }];
    }
}

#pragma - mark Relayout Buttons After AddSubviews

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat itemTotalWidth = 0;
    CGFloat itemSingleWidth = 0;
    
    for (UIButton * button in self.buttons) {
        itemTotalWidth += button.bounds.size.width;
        if (itemSingleWidth < button.bounds.size.width) {
            itemSingleWidth = button.bounds.size.width;
        }
    }
    
    CGFloat totalWidth = itemTotalWidth + (self.buttons.count + 1) * 2 * self.styleModel.buttonSpacing;
    
    //总长度（含间距）小于屏幕宽，重绘按钮，间距为0
    if (totalWidth <= self.menuScrollView.bounds.size.width) {
        self.styleModel.buttonSpacing = 0;
        CGFloat averageWidth = self.menuScrollView.bounds.size.width / self.buttons.count;
        for (int i = 0; i < self.buttons.count; i ++)
        {
            UIButton * button = self.buttons[i];
            button.frame = CGRectMake(averageWidth * i, 0, averageWidth, self.menuScrollView.bounds.size.height);
            
            CGFloat r = 1.0f;
            if (self.style != HKTabBarStyleUnderline)
            {
                if (self.style == HKTabBarStyleUnderCorner)
                {
                    r = self.currentIndex == i ? 1.0f : HKTabBarStyleUnderCornerScale;
                    button.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, r, r);
                }
                else if (self.style == HKTabBarStyleCleanMenu)
                {
                    r = self.currentIndex == i ? 1.0f : HKTabBarStyleCleanMenuScale;
                    button.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, r, r);
                }
            }

            [button setTitleColor:self.currentIndex == i ? self.styleModel.menuSelectedColor  : self.styleModel.menuNormalColor forState:UIControlStateNormal];
        }
        [self.menuScrollView setContentSize:CGSizeMake(self.menuScrollView.bounds.size.width, self.styleModel.menuHeight)];
        
        if (!self.isAnimation) {
            //若无需滚动，则选中标识view绘制不含按钮间隔
            UIButton * selectButton = [self.buttons safetyObjectAtIndex:self.currentIndex];
            self.cursorView.frame = CGRectMake(selectButton.center.x - selectButton.bounds.size.width / 2, 0, selectButton.bounds.size.width, self.styleModel.menuHeight);
        }
    }
    else {
        CGFloat left = 2 * self.styleModel.buttonSpacing;
        for (UIButton *button in self.buttons) {
            button.frame = CGRectMake(left, 0, button.bounds.size.width, self.menuScrollView.bounds.size.height);
            left += button.bounds.size.width + 2 * self.styleModel.buttonSpacing;
        }
        [self.menuScrollView setContentSize:CGSizeMake(totalWidth, self.styleModel.menuHeight)];
        
        if (!self.isAnimation) {
            UIButton * selectButton = [self.buttons objectAtIndex:self.currentIndex];
            self.cursorView.frame = CGRectMake(selectButton.frame.origin.x - self.styleModel.buttonSpacing, 0, selectButton.bounds.size.width + self.styleModel.buttonSpacing * 2, self.styleModel.menuHeight);
            [self makeButtonCenter:selectButton];
        }
    }
}

- (void)buttonEvent:(UIButton *)sender {
    if (self.isAnimation) {
        return;
    }
    NSInteger index = sender.tag;
    [self selectAtIndex:index];
    
    if ([self.delegate respondsToSelector:@selector(pageClickAtIndex:)])
    {
        [self.delegate pageClickAtIndex:index];
    }
    //设置滚动
    [self.contentScrollView setContentOffset:CGPointMake(index * self.contentScrollView.bounds.size.width, 0) animated:YES];
}

- (void)selectAtIndex:(NSInteger)index {
    if (index == self.currentIndex || self.isAnimation) {
        return;
    }
    
    self.isAnimation = YES;
    //self.contentScrollView.scrollEnabled = NO;
    
    //上一个按钮的恢复
    UIButton *lastButton = [self.buttons objectAtIndex:self.currentIndex];
    [lastButton setTitleColor:self.styleModel.menuNormalColor forState:UIControlStateNormal];
    
    //点击按钮状态变化
    UIButton *clickButton = [self.buttons objectAtIndex:index];
    [clickButton setTitleColor:self.styleModel.menuSelectedColor forState:UIControlStateNormal];
    
    //字体放大缩小
    if (self.style == HKTabBarStyleUnderCorner) {
        
        if (![self.delegate respondsToSelector:@selector(observeScrollViewOffset)]){
            [UIView animateWithDuration:0.3 animations:^{
                lastButton.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, HKTabBarStyleUnderCornerScale, HKTabBarStyleUnderCornerScale);
            }];
            [UIView animateWithDuration:0.3 animations:^{
                clickButton.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            }];
        }
    }
    else if (self.style == HKTabBarStyleCleanMenu) {
        
        if (![self.delegate respondsToSelector:@selector(observeScrollViewOffset)]){
            [UIView animateWithDuration:0.3 animations:^{
                lastButton.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, HKTabBarStyleCleanMenuScale, HKTabBarStyleCleanMenuScale);
            }];
            [UIView animateWithDuration:0.3 animations:^{
                clickButton.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            }];
        }
    }
    
    //动画完成前，设置上一个按钮后设置新的index
    self.currentIndex = index;
    
    //光标移动动画
    if (![self.delegate respondsToSelector:@selector(observeScrollViewOffset)])
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.cursorView.frame = CGRectMake(
                                               clickButton.center.x - (clickButton.bounds.size.width / 2 + self.styleModel.buttonSpacing),
                                               0,
                                               clickButton.bounds.size.width + 2 * self.styleModel.buttonSpacing,
                                               self.styleModel.menuHeight);
        } completion:^(BOOL finished) {
            self.isAnimation = NO;
            //self.contentScrollView.scrollEnabled = YES;
        }];
    }
    else
    {
        self.isAnimation = NO;
    }
    
    //当选中按钮的位置>中心点时，自动居中
    if (self.menuScrollView.contentSize.width > self.menuScrollView.bounds.size.width) {
        [self makeButtonCenter:clickButton];
    }
    
    //以下委托用于动态添加子内容视图
//    if ([self.delegate respondsToSelector:@selector(addContentVCAtIndex:)]) {
//        [self.delegate addContentVCAtIndex:index];
//        [self.contentScrollView setContentOffset:CGPointMake(index * self.contentScrollView.bounds.size.width, 0) animated:YES]; //此处动画应可选是否需要
//    }
//    else {
//        NSAssert(0, @"添加子视图的委托未实现");
//    }
}

- (void)slideOffsetX:(CGFloat)offsetX andTotleW:(CGFloat)totalWidth andPageW:(CGFloat)pageWidth
{
    if (offsetX < 0 || offsetX > totalWidth)
        return;
    CGFloat remainder;
    CGFloat remainderOffsetX = offsetX;
    NSInteger index = 0;
    for (;;)
    {
        if (remainderOffsetX - pageWidth < 0)
        {
            remainder = remainderOffsetX;
            break;
        }
        remainderOffsetX = remainderOffsetX - pageWidth;
        index = index + 1;
    }
    
    UIButton * btn = [self.buttons safetyObjectAtIndex:index];
    UIButton * nextBtn = [self.buttons safetyObjectAtIndex:index + 1];
    if (!nextBtn)
    {
        /// 说明移到最后一栏
//        return;
    }
    CGFloat space = ABS(nextBtn.center.x - btn.center.x);
    CGFloat percent = 1.0 * remainder / pageWidth;
    CGFloat offset = 1.0 * space * percent;
    
    CGFloat x = btn.center.x + offset - (btn.bounds.size.width / 2 + self.styleModel.buttonSpacing);
    self.cursorView.frame = CGRectMake(x,0,
                                       btn.bounds.size.width + 2 * self.styleModel.buttonSpacing,
                                       self.styleModel.menuHeight);
    
    //字体放大缩小
    if (self.style == HKTabBarStyleUnderCorner) {
        
        CGFloat bigScale = 1 - ((1 - HKTabBarStyleUnderCornerScale) * percent);
        CGFloat smallScale = HKTabBarStyleUnderCornerScale + ((1 - HKTabBarStyleUnderCornerScale) * percent);
        btn.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, bigScale, bigScale);
        nextBtn.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, smallScale, smallScale);
        [btn setTitleColor:[self getBigGradualColor:percent] forState:UIControlStateNormal];
        [nextBtn setTitleColor:[self getSmallGradualColor:percent] forState:UIControlStateNormal];
    }
    else if (self.style == HKTabBarStyleCleanMenu) {
        
        CGFloat bigScale = 1 - ((1 - HKTabBarStyleCleanMenuScale) * percent);
        CGFloat smallScale = HKTabBarStyleCleanMenuScale + ((1 - HKTabBarStyleCleanMenuScale) * percent);
        btn.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, bigScale, bigScale);
        nextBtn.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, smallScale, smallScale);
        [btn setTitleColor:[self getBigGradualColor:percent] forState:UIControlStateNormal];
        [nextBtn setTitleColor:[self getSmallGradualColor:percent] forState:UIControlStateNormal];
        
        // 违章页面，会出现先刷到第一栏，然后刷到第x（默认爱车）栏（导致第一栏缩放为1）
        for (UIButton * item in self.buttons)
        {
            if ((item != btn) && (item != nextBtn))
            {
                item.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, HKTabBarStyleCleanMenuScale, HKTabBarStyleCleanMenuScale);
                [item setTitleColor:self.styleModel.menuNormalColor forState:UIControlStateNormal];
            }
        }
//        UIButton * firstBtn = [self.buttons safetyObjectAtIndex:0];
//        if ((firstBtn != btn) && (firstBtn != nextBtn))
//        {
//            firstBtn.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, HKTabBarStyleCleanMenuScale, HKTabBarStyleCleanMenuScale);
//            [firstBtn setTitleColor:self.styleModel.menuNormalColor forState:UIControlStateNormal];
//        }
    }
}

- (void)makeButtonCenter:(UIButton *)clickButton
{
    if (clickButton.center.x + self.menuScrollView.bounds.size.width / 2 > self.menuScrollView.contentSize.width) {
        [self.menuScrollView setContentOffset:CGPointMake(self.menuScrollView.contentSize.width - self.bounds.size.width,self.menuScrollView.contentOffset.y)animated:YES];
    }
    else if (clickButton.center.x - self.bounds.size.width / 2 < 0) {
        [self.menuScrollView setContentOffset:CGPointMake(0, self.menuScrollView.contentOffset.y) animated:YES];
    } else {
        [self.menuScrollView setContentOffset:CGPointMake(clickButton.center.x - self.menuScrollView.bounds.size.width / 2, self.menuScrollView.contentOffset.y) animated:YES];
    }
}


- (UIColor *)getBigGradualColor:(CGFloat)percent
{
    CGFloat r = (self.styleModel.menuNormalColorR - self.styleModel.menuSelectColorR) * percent  + self.styleModel.menuSelectColorR;
    CGFloat g = (self.styleModel.menuNormalColorG - self.styleModel.menuSelectColorG) * percent + self.styleModel.menuSelectColorG;
    CGFloat b = (self.styleModel.menuNormalColorB - self.styleModel.menuSelectColorB) * percent + self.styleModel.menuSelectColorB;
    
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
    return color;
}

- (UIColor *)getSmallGradualColor:(CGFloat)percent
{
    CGFloat r = (self.styleModel.menuSelectColorR - self.styleModel.menuNormalColorR)* percent + self.styleModel.menuNormalColorR;
    CGFloat g = (self.styleModel.menuSelectColorG - self.styleModel.menuNormalColorG) * percent + self.styleModel.menuNormalColorG;
    CGFloat b = (self.styleModel.menuSelectColorB - self.styleModel.menuNormalColorB) * percent + self.styleModel.menuNormalColorB;
    
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
    return color;
}


@end


@implementation TabBarMenuStyleModel


@end

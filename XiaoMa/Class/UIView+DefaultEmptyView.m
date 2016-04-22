//
//  UIView+DefaultEmptyView.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/26.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UIView+DefaultEmptyView.h"
#import <Masonry.h>

#define kEmptyView  @"$DefaultEmptyView"
#define kImgView    @"$DefaultEmptyView_ImgView"
#define kLabelView  @"$DefaultEmptyView_LabelView"
#define kTapGesture @"$DefaultEmptyView_TapGesture"

@implementation UIView (DefaultEmptyView)

- (void)showDefaultEmptyViewWithText:(NSString *)text
{
    [self showDefaultEmptyViewWithText:text tapBlock:nil];
}

- (void)showDefaultEmptyViewWithText:(NSString *)text tapBlock:(void(^)(void))tapBlock
{
    [self showDefaultEmptyViewWithText:text centerOffset:-20 tapBlock:tapBlock];
}

- (void)showDefaultEmptyViewWithText:(NSString *)text centerOffset:(CGFloat)offset tapBlock:(void(^)(void))tapBlock
{
    [self showEmptyViewWithImageName:@"cm_blank" text:text centerOffset:offset tapBlock:tapBlock];
}

- (void)showImageEmptyViewWithImageName:(NSString *)imgName text:(NSString *)text
{
    if (imgName.length && [UIImage imageNamed:imgName])
    {
        [self showEmptyViewWithImageName:imgName text:text centerOffset:-20 tapBlock:nil];
    }
    else
    {
        [self showEmptyViewWithImageName:@"cm_blank" text:text centerOffset:-20 tapBlock:nil];
    }
}
- (void)showImageEmptyViewWithImageName:(NSString *)imgName text:(NSString *)text tapBlock:(void(^)(void))tapBlock
{
    if (imgName.length && [UIImage imageNamed:imgName])
    {
        [self showEmptyViewWithImageName:imgName text:text centerOffset:-20 tapBlock:tapBlock];
    }
    else
    {
        [self showEmptyViewWithImageName:@"cm_blank" text:text centerOffset:-20 tapBlock:tapBlock];
    }
}

- (void)showImageEmptyViewWithImageName:(NSString *)imgName text:(NSString *)text
                           centerOffset:(CGFloat)offset tapBlock:(void(^)(void))tapBlock
{
    if (imgName.length && [UIImage imageNamed:imgName])
    {
        [self showEmptyViewWithImageName:imgName text:text centerOffset:offset tapBlock:tapBlock];
    }
    else
    {
        [self showEmptyViewWithImageName:@"cm_blank" text:text centerOffset:offset tapBlock:tapBlock];
    }
}

- (void)showEmptyViewWithImageName:(NSString *)imgName text:(NSString *)text
                      centerOffset:(CGFloat)offset tapBlock:(void(^)(void))tapBlock
{
    UIView *view = self.customInfo[kEmptyView];
    self.backgroundColor = kBackgroundColor;
    if (!view) {
        //        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        view = [[UIView alloc]initWithFrame:self.bounds];
        view.backgroundColor = [UIColor clearColor];
        //        view.userInteractionEnabled = NO;
        UIImageView *imgView =  [[UIImageView alloc] initWithFrame:CGRectZero];
        [view addSubview:imgView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor lightGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:17];
        label.numberOfLines = 0;
        [view addSubview:label];
        [self addSubview:view];
        
        //添加点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionDefaultEmptyViewTaped:)];
        [view addGestureRecognizer:tap];
        
        self.customInfo[kEmptyView] = view;
        self.customInfo[kImgView] = imgView;;
        self.customInfo[kLabelView] = label;
        self.customInfo[kTapGesture] = tap;
    }
    
    CKAsyncMainQueue(^{
        view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)+offset);
    });
    
    UIImageView *imgView = self.customInfo[kImgView];
    UILabel *label = self.customInfo[kLabelView];
    UITapGestureRecognizer *tap = self.customInfo[kTapGesture];
    
    [tap setAssociatedObject:tapBlock forKey:kTapGesture policy:OBJC_ASSOCIATION_COPY_NONATOMIC];
    
    imgView.image = [UIImage imageNamed:imgName];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    label.text = text;
    
    [imgView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).offset(-40);
    }];
    
    [label mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(view).offset(14);
        make.right.equalTo(view).offset(-14);
        make.top.equalTo(imgView.mas_bottom).offset(17);
    }];
    
    view.hidden = NO;
    [self bringSubviewToFront:view];
}

- (void)hideDefaultEmptyView
{
    UIView *view = self.customInfo[kEmptyView];
    view.hidden = YES;
}

- (BOOL)isShowDefaultEmptyView
{
    UIView *view = self.customInfo[kEmptyView];
    if (view && !view.hidden) {
        return YES;
    }
    return NO;
}

- (void)actionDefaultEmptyViewTaped:(UITapGestureRecognizer *)tap
{
    void (^block)(void) = [tap associatedObjectForKey:kTapGesture];
    if (block) {
        block();
    }
}
@end

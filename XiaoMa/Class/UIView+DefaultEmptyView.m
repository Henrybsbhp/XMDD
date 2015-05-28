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

@implementation UIView (DefaultEmptyView)

- (void)showDefaultEmptyViewWithText:(NSString *)text boundsView:(UIView *)boundsView
{
    [self showDefaultEmptyViewWithImageName:@"cm_blank" text:text boundsView:boundsView centerOffset:-20];
}

- (void)showDefaultEmptyViewWithText:(NSString *)text boundsView:(UIView *)boundsView centerOffset:(CGFloat)offset
{
    [self showDefaultEmptyViewWithImageName:@"cm_blank" text:text boundsView:boundsView centerOffset:offset];
}

- (void)showDefaultEmptyViewWithImageName:(NSString *)imgName text:(NSString *)text
                               boundsView:(UIView *)boundsView centerOffset:(CGFloat)offset
{
    UIView *view = self.customInfo[kEmptyView];
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor clearColor];
        view.userInteractionEnabled = NO;
        UIImageView *imgView =  [[UIImageView alloc] initWithFrame:CGRectZero];
        [view addSubview:imgView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textColor = [UIColor lightGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:17];
        [view addSubview:label];
        [self addSubview:view];
        self.customInfo[kEmptyView] = view;
        self.customInfo[kImgView] = imgView;;
        self.customInfo[kLabelView] = label;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(320, 320));
        }];
    }
    UIImageView *imgView = self.customInfo[kImgView];
    UILabel *label = self.customInfo[kLabelView];
    
    imgView.image = [UIImage imageNamed:imgName];
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
    
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(boundsView.mas_centerX);
        make.centerY.equalTo(self.mas_centerY).offset(offset);
    }];
    
    view.hidden = NO;
    [self bringSubviewToFront:view];
}

- (void)hideDefaultEmptyView
{
    UIView *view = self.customInfo[kEmptyView];
    view.hidden = YES;
}

@end

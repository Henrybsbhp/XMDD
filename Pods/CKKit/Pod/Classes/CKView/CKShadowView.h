//
//  CKShadowView.h
//  JTReader
//
//  Created by jiangjunchen on 13-11-15.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKShadowView : UIView

@property (nonatomic, assign) UIEdgeInsets shadowInsets;
@property (nonatomic, strong) UIImage *shadowImage;
@property (nonatomic, strong) UIView *contentView;

- (id)initWithShadowImage:(UIImage *)image shadowInsets:(UIEdgeInsets)insets;

@end

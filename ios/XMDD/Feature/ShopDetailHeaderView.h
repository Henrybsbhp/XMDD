//
//  ShopDetailHeaderView.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBAutoScrollLabel.h"

@interface ShopDetailHeaderView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *trottingContainerView;
@property (nonatomic, strong) CBAutoScrollLabel *trottingView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) NSArray *picURLArray;
@end

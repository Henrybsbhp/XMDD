//
//  UIView+TagView.h
//  HappyTrain
//
//  Created by jt on 14-11-11.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Base)

- (UIView *)searchViewWithTag:(NSInteger)tag;

- (void)removeSubviews;

@end

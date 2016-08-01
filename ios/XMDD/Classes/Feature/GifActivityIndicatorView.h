//
//  GifActivityIndicatorView.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GifActivityIndicatorView : UIView

- (void)stopAnimating;
- (void)startAnimating;
- (BOOL)isAnimating;

@end

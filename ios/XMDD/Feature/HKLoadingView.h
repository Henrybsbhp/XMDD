//
//  HKLoadingView.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/31.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKLoadingView : UIView

@property (nonatomic, assign, readonly) BOOL isAnimating;

- (void)startMONAnimating;
- (void)startGifAnimating;
- (void)startTYMAnimating;
- (void)startUIAnimating;

- (void)stopAnimating;

@end

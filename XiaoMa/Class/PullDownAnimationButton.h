//
//  PullDownAnimationButton.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullDownAnimationButton : UIButton

@property (nonatomic, readonly) BOOL pulled;

- (void)setPulled:(BOOL)pulled withAnimation:(BOOL)animate;

@end

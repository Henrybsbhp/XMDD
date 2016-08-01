//
//  AddCloseAnimationButton.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCloseAnimationButton : UIButton
@property (nonatomic, readonly) BOOL closing;

- (void)setClosing:(BOOL)closing WithAnimation:(BOOL)animate;



@end

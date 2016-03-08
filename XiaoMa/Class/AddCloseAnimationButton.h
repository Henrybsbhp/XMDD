//
//  AddCloseAnimationButton.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCloseAnimationButton : UIButton
@property (nonatomic, readonly) BOOL closed;

- (void)setClosed:(BOOL)closed WithAnimation:(BOOL)animate;



@end

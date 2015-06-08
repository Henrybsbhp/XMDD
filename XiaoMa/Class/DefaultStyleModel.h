//
//  DefaultStyleModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MZFormSheetController.h>
@interface DefaultStyleModel : NSObject

+ (void)setupDefaultStyle;
///弹出视图（默认样式是从底部弹出）
+ (MZFormSheetController *)bottomAppearSheetCtrlWithSize:(CGSize)size
                                          viewController:(UIViewController *)vc
                                              targetView:(UIView *)targetView;
+ (MZFormSheetController *)presentSheetCtrlFromBottomWithSize:(CGSize)size
                                               viewController:(UIViewController *)vc
                                                   targetView:(UIView *)view;

@end

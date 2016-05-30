//
//  UIViewController+CKNavigator.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/23.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKRouter.h"

@interface UIViewController (CKNavigator)

@property (nonatomic, strong, readonly) CKRouter *router;

@end

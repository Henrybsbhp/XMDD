//
//  JTNavigationController.h
//  EasyPay
//
//  Created by jiangjunchen on 14/10/27.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBarButtonItem+CustomStyle.h"

@interface JTNavigationController : UINavigationController
@property (nonatomic, assign) BOOL shouldAllowInteractivePopGestureRecognizer;
@end

@interface UIViewController (NavigationController)

- (void)actionBack:(id)sender;

@end

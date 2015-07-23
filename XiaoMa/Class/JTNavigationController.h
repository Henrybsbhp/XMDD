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

@end

@interface UIViewController (NavigationController)

- (void)actionBack:(id)sender;

@end

//
//  HKNavigationController.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKNavigator.h"
#import "UIBarButtonItem+CustomStyle.h"

@interface HKNavigationController : CKNavigationController

@end

@interface UIViewController (HKNavigationController)
- (void)actionBack:(id)sender;
@end


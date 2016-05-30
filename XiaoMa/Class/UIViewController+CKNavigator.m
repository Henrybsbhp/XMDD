//
//  UIViewController+CKNavigator.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/23.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UIViewController+CKNavigator.h"
#import <objc/runtime.h>

static char s_routerKey;

@implementation UIViewController (CKNavigator)
@dynamic router;

- (CKRouter *)router {
    CKRouter *routerObj = objc_getAssociatedObject(self, &s_routerKey);
    if (!routerObj) {
        routerObj = [CKRouter routerWithTargetViewController:self];
        objc_setAssociatedObject(self, &s_routerKey, routerObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return routerObj;
}

@end


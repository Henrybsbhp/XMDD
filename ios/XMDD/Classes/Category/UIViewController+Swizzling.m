//
//  UIViewController+Swizzling.m
//  XiaoMa
//
//  Created by jt on 16/1/28.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UIViewController+Swizzling.h"
#import "UMLogHelper.h"

#define SelfClassName NSStringFromClass([self class])

@implementation UIViewController (Swizzling)

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // 如果这个类没有实现 originalSelector ，但其父类实现了，那 class_getInstanceMethod 会返回父类的方法
    // class_addMethod will fail if original method already exists
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    // 如果已经方法已经加进去了了
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)patchForViewController
{
    Method ori_viewDidLoad= class_getInstanceMethod([UIViewController class], @selector(viewDidLoad));
    Method my_viewDidLoad = class_getInstanceMethod([UIViewController class], @selector(sw_viewDidLoad));
    swizzleMethod([self class], method_getName(ori_viewDidLoad), method_getName(my_viewDidLoad));
    
    Method ori_viewDidAppear = class_getInstanceMethod([UIViewController class], @selector(viewDidAppear:));
    Method my_viewDidAppear = class_getInstanceMethod([UIViewController class], @selector(sw_viewDidAppear:));
    swizzleMethod([self class], method_getName(ori_viewDidAppear), method_getName(my_viewDidAppear));
    
    Method ori_viewDidDisappear = class_getInstanceMethod([UIViewController class], @selector(viewDidDisappear:));
    Method my_viewDidDisappear = class_getInstanceMethod([UIViewController class], @selector(sw_viewDidDisappear:));
    swizzleMethod([self class], method_getName(ori_viewDidDisappear), method_getName(my_viewDidDisappear));
}


#pragma mark - swizzleMethod
- (void)sw_viewDidLoad
{
    [self sw_viewDidLoad];
    
    NSString * className = SelfClassName;
    
    NSDictionary * dict = [[UMLogHelper getPagesUMLogInfo] objectForKey:className];
    if (dict)
    {
        HKCLSLog(@"%@ viewDidLoad",className);
    }
}

- (void)sw_viewDidAppear:(BOOL)animated
{
    [self sw_viewDidAppear:animated];
    
    NSString * className = SelfClassName;
    
    //友盟，aop打点方式
    NSDictionary * dict = [[UMLogHelper getPagesUMLogInfo] objectForKey:className];
    if (dict)
    {
        //crashlytics日志信息
        HKCLSLog(@"%@ viewDidAppear",className);
        
        NSString * pageTag = [dict objectForKey:@"pagetag"];
        NSAssert([pageTag isKindOfClass:[NSString class]] && pageTag.length, @"UIViewController+Swizzling : pageTag is not NSString class or length is zero");
        [MobClick beginLogPageView:pageTag];
    }
}

- (void)sw_viewDidDisappear:(BOOL)animated
{
    [self sw_viewDidDisappear:animated];
    
    NSString * className = SelfClassName;
    
    //友盟，aop打点方式
    NSDictionary * dict = [[UMLogHelper getPagesUMLogInfo] objectForKey:className];
    if (dict)
    {
        //crashlytics日志信息
        HKCLSLog(@"%@ viewDidDisappear",className);
        
        NSString * pageTag = [dict objectForKey:@"pagetag"];
        NSAssert([pageTag isKindOfClass:[NSString class]] && pageTag.length, @"UIViewController+Swizzling : pageTag is not NSString class or length is zero");
        [MobClick endLogPageView:pageTag];
    }
}



@end

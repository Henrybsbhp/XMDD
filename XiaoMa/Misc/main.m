//
//  main.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/1.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "UIView+CustomForXIB.h"
#import <UI7Kit/UI7Kit.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
        [UIView patchForCustomXIB];
        [UI7Kit patchIfNeeded];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

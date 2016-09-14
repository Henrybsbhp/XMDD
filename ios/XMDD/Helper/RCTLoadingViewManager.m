//
//  RCTLoadingViewManager.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/31.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "RCTLoadingViewManager.h"
#import "RCTLoadingView.h"

@implementation RCTLoadingViewManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [[RCTLoadingView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
}

RCT_EXPORT_VIEW_PROPERTY(animate, BOOL);
RCT_EXPORT_VIEW_PROPERTY(animationType, NSInteger);

@end

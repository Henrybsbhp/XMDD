//
//  HKMapView.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKMapView.h"

@implementation HKMapView

///重载该方法是为了修复ios6中ui7kit崩溃的bug
+ (instancetype)appearance
{
    return nil;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
}

@end

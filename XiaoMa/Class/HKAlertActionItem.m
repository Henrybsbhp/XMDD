//
//  HKAlertActionItem.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKAlertActionItem.h"

@implementation HKAlertActionItem

+ (instancetype)item {
    return [[self alloc] init];
}

+ (instancetype)itemWithTitle:(NSString *)title
{
    return [self itemWithTitle:title color:HEXCOLOR(@"#18d06a") clickBlock:nil];
}

+ (instancetype)itemWithTitle:(NSString *)title color:(UIColor *)color clickBlock:(void(^)(id alertVC))block {
    HKAlertActionItem *item = [[self alloc] init];
    item.title = title;
    item.color  =color;
    item.clickBlock = block;
    return item;
}

@end



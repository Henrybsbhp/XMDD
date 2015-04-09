//
//  UIStoryboard+Expansion.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/3.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UIStoryboard+Expansion.h"

@implementation UIStoryboard (Expansion)

+ (id)vcWithId:(NSString *)ide inStoryboard:(NSString *)sbname
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:sbname bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:ide];
}

@end

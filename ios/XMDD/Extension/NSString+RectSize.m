//
//  NSString+RectSize.m
//  ECP4iPhone
//
//  Created by jtang on 12-6-1.
//  wcw made it
//  Copyright (c) 2012年 jtang.com.cn. All rights reserved.
//

#import "NSString+RectSize.h"

@implementation NSString (RectSize)

// 计算显示文字需要的矩形尺寸
- (CGSize)labelSizeWithWidth:(int)width font:(UIFont *)font
{
    CGSize maxSize = CGSizeMake(width, 9999);
    CGSize expectedSize;
    
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
        NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        expectedSize = [self boundingRectWithSize:maxSize options:options attributes:attribute context:nil].size;
    }
    else
    {
//用于去掉xcode5下面的警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        expectedSize = [self sizeWithFont:font
                        constrainedToSize:maxSize
                            lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    }

    return expectedSize;
}

@end

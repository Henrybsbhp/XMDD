//
//  CKLine.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger
{
    CKLineAlignmentHorizontalTop = 1,
    CKLineAlignmentHorizontalBottom = 2,
    CKLineAlignmentVerticalLeft = -1,
    CKLineAlignmentVerticalRight = -2
}CKLineAlignment;

typedef enum : NSUInteger
{
    CKLineOptionNone = 0,
    CKLineOptionPixel = 1 << 0,
    CKLineOptionDash = 1 << 1,
}CKLineOptionMask;

@interface CKLine : UIView
///(default is HEXCOLOR(@"#E3E3E3"))
@property (nonatomic, strong) UIColor *lineColor;
///(线的像素宽度 default is 1px)
@property (nonatomic, assign) CGFloat linePixelWidth;
///(线的点宽度 default is 1)
@property (nonatomic, assign) CGFloat linePointWidth;
///(default is CKLineOptionPixel)
@property (nonatomic, assign) CKLineOptionMask lineOptions;
///(default is CKLineAlignmentHorizontalTop)
@property (nonatomic, assign) CKLineAlignment lineAlignment;
///虚线的线段长短
@property (nonatomic, strong) NSArray *dashLengths;

@end

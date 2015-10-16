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

@interface CKLine : UIView
///(default is grayColor)
@property (nonatomic, strong) UIColor *lineColor;
///(线的像素宽度 default is 1px)
@property (nonatomic, assign) CGFloat linePixelWidth;
///(线的点宽度 default is 1)
@property (nonatomic, assign) CGFloat linePointWidth;
///(default is NO)
@property (nonatomic, assign) BOOL pixelMode;
///(default is CKLineAlignmentHorizontalTop)
@property (nonatomic, assign) CKLineAlignment lineAlignment;
@end

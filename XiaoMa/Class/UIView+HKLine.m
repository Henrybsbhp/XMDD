//
//  UIView+HKLine.m
//  XiaoMa
//
//  Created by fuqi on 16/3/29.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UIView+HKLine.h"

@implementation UIView (HKLine)

- (void)drawLineWithDirection:(CKViewBorderDirection)d
             withEdge:(UIEdgeInsets)edge
{
    UIImageView *topline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Horizontaline"]];
    UIImageView *bottomline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Horizontaline2"]];
    UIImageView *leftline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Verticalline"]];
    UIImageView *rightline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Verticalline2"]];
    
    switch (d) {
        case CKViewBorderDirectionLeft:
        {
            
            [self addSubview:leftline];
            [leftline mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(self).offset(edge.top);
                make.bottom.equalTo(self).offset(-edge.bottom);
                make.width.mas_equalTo(@1);
                make.left.equalTo(self).offset(edge.left);
            }];
            break;
        }
        case CKViewBorderDirectionRight:
        {
            [self addSubview:rightline];
            [rightline mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(self).offset(edge.top);
                make.bottom.equalTo(self).offset(-edge.bottom);
                make.width.mas_equalTo(@1);
                make.right.equalTo(self).offset(-edge.right);
            }];
            break;
        }
        case CKViewBorderDirectionTop:
        {
            [self addSubview:topline];
            [topline mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(self).offset(edge.left);
                make.right.equalTo(self).offset(-edge.right);
                make.height.mas_equalTo(@1);
                make.top.equalTo(self).offset(edge.top);
            }];
            break;
        }
        case CKViewBorderDirectionBottom:
        {
            [self addSubview:bottomline];
            [bottomline mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(self).offset(edge.left);
                make.right.equalTo(self).offset(-edge.right);
                make.height.mas_equalTo(@1);
                make.bottom.equalTo(self).offset(-edge.bottom);
            }];
            break;
        }
            
        default:
            break;
    }
}

@end

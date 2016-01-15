//
//  OETextField.m
//  XiaoMa
//
//  Created by RockyYe on 15/12/29.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "OETextField.h"
#import "NSString+CKExpansion.h"
@implementation OETextField

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        
    }
    return self;
}

-(void)setNormalInputAccessoryViewWithDataArr:(NSArray *)dataArr
{
    if (dataArr.count > 0)
    {
        CGFloat screenWidth = [[UIScreen mainScreen]bounds].size.width;
        CGFloat equalWidth = screenWidth / dataArr.count;
        CGFloat leftContraint = 0;
        
        UIView *inputAccessoryView = [UIView new];
        inputAccessoryView.frame = CGRectMake(0, 0, screenWidth, 40);
        inputAccessoryView.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
        
        for (id obj in dataArr)
        {
            UIButton *btn;
            if ([obj isKindOfClass:[UIButton class]])
            {
                btn = (UIButton *)obj;
            }
            else
            {
                btn = [UIButton new];
                [btn setTitle:[NSString stringWithFormat:@"%@",obj] forState:UIControlStateNormal];
            }
            [inputAccessoryView addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(leftContraint);
                make.width.mas_equalTo(equalWidth);
                make.height.mas_equalTo(40);
            }];
            btn.backgroundColor = [UIColor colorWithRed:187/255.0 green:194/255.0 blue:201/255.0 alpha:1.0];
            leftContraint += equalWidth;
            leftContraint++;
            [[btn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
                [self insertText:btn.titleLabel.text];
            }];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        self.inputAccessoryView = inputAccessoryView;
    }
}

-(void)setScrollInputAccessoryViewWithContentSize:(CGSize)size DataArr:(NSArray *)dataArr;
{
    if (dataArr.count > 0)
    {
        CGFloat screenWidth = [[UIScreen mainScreen]bounds].size.width;
        CGFloat equalWidth = size.width / dataArr.count;
        CGFloat leftContraint = 0;
        
        UIScrollView *inputAccessoryView = [UIScrollView new];
        inputAccessoryView.frame = CGRectMake(0, 0, screenWidth, 30);
        inputAccessoryView.contentSize = CGSizeMake(size.width, 0);
        inputAccessoryView.scrollEnabled = YES;
        inputAccessoryView.showsHorizontalScrollIndicator = NO;
        inputAccessoryView.bounces = YES;
        inputAccessoryView.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
        
        for (id obj in dataArr)
        {
            UIButton *btn;
            if ([obj isKindOfClass:[UIButton class]])
            {
                btn = (UIButton *)obj;
                
            }
            else
            {
                btn = [UIButton new];
                [btn setTitle:[NSString stringWithFormat:@"%@",obj] forState:UIControlStateNormal];
            }
            [inputAccessoryView addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(leftContraint);
                make.width.mas_equalTo(equalWidth);
                make.height.mas_equalTo(30);
            }];
            btn.backgroundColor = [UIColor colorWithRed:187/255.0 green:194/255.0 blue:201/255.0 alpha:1.0];
            leftContraint += equalWidth;
            leftContraint++;
            [[btn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
                self.text = [self.text append:[NSString stringWithFormat:@"%@",btn.titleLabel.text]];
            }];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        self.inputAccessoryView = inputAccessoryView;
    }
}


@end

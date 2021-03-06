//
//  OETextField.m
//  XiaoMa
//
//  Created by RockyYe on 15/12/29.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "OETextField.h"
#import "NSString+CKExpansion.h"

/// 可以在顶部增加数字的textfeild

@interface OETextField()

@end

@implementation OETextField

-(void)setNormalInputAccessoryViewWithDataArr:(NSArray *)dataArr
{
    if (dataArr.count > 0)
    {
        CGFloat screenWidth = [[UIScreen mainScreen]bounds].size.width;
        CGFloat equalWidth = screenWidth / dataArr.count - 5;
        CGFloat leftContraint = 2.5;
        
        OEView *inputAccessoryView = [[OEView alloc] init];
        inputAccessoryView.frame = CGRectMake(0, 0, screenWidth, OEHeight);
        inputAccessoryView.backgroundColor = [UIColor colorWithRed:210/255.0 green:213/255.0 blue:220/255.0 alpha:1.0];
        
        for (id obj in dataArr)
        {
            OEButton *btn;
            if ([obj isKindOfClass:[OEButton class]])
            {
                btn = (OEButton *)obj;
            }
            else
            {
                btn = [OEButton new];
                [btn setTitle:[NSString stringWithFormat:@"%@",obj] forState:UIControlStateNormal];
            }
            
            [inputAccessoryView addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(2);
                make.left.mas_equalTo(leftContraint);
                make.width.mas_equalTo(equalWidth);
                make.bottom.mas_equalTo(-4);
            }];
            btn.backgroundColor = [UIColor colorWithRed:187/255.0 green:194/255.0 blue:201/255.0 alpha:1.0];
            leftContraint += (equalWidth + 5);
            [[btn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
                [self insertText:btn.titleLabel.text];
            }];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        
        self.customAccessoryView = inputAccessoryView;
        self.customAccessoryView.tag = OEAccessTag;
    }
}

@end


/// OEView

@interface OEView()

@end

@implementation OEView

@end



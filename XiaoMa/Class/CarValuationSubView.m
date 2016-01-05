//
//  CarValuationSubView.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "CarValuationSubView.h"
#import "DashLine.h"
#import "HKSubscriptInputField.h"
#import "NSDate+DateForText.h"

@implementation CarValuationSubView

- (id)initWithFrame:(CGRect)frame andCarModel:(HKMyCar *)carModel
{
    self = [super initWithFrame:frame];
    [self subviewsInit:carModel];
    
    return self;
}

- (void)subviewsInit:(HKMyCar *)carModel
{
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat spacing = 0.0;
    CGFloat bottomSpacing = 0.0;
    NSString * backgroundImgStr = @"val_car_bgimg";
    if (self.frame.size.height == 280) {
        spacing = 16;
        bottomSpacing = 12;
    }
    else if (self.frame.size.height < 280) {
        spacing = 8;
        bottomSpacing = 7;
        backgroundImgStr = @"val_car_smallbgimg";
    }
    else {
        spacing = 20;
        bottomSpacing = 16;
    }
    @weakify(self);
    //背景
    UIImage * bgImg = [UIImage imageNamed:backgroundImgStr];
    UIImageView * bgV = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:bgV];
    [bgV mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self);
    }];
    bgV.image = [bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(55, 10, 85, 10)];
    
    if ([carModel isKindOfClass:[HKMyCar class]]) {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.font = [UIFont systemFontOfSize:18];
        headerLabel.textColor = HEXCOLOR(@"#20AB2A");
        [self addSubview:headerLabel];
        headerLabel.text = carModel.licencenumber;
        [headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(bgV);
            make.top.equalTo(self).offset(14);
        }];
        
        DashLine *line = [[DashLine alloc] initWithFrame:CGRectZero];
        CGFloat* lengths = malloc(sizeof(CGFloat)*2);
        lengths[0] = 5;
        lengths[1] = 2;
        line.dashLengths = lengths;
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongify(self);
            make.top.equalTo(self).offset(47);
            make.height.mas_equalTo(1);
            make.left.equalTo(self).offset(7);
            make.right.equalTo(self).offset(-7);
        }];
        
        for (int i = 0; i < 3; i++) {
            
            UILabel * titleL = [[UILabel alloc] initWithFrame:CGRectZero];
            titleL.tag = 101 + i;
            titleL.font = [UIFont systemFontOfSize:15];
            titleL.textColor = HEXCOLOR(@"#20AB2A");
            
            HKSubscriptInputField * textField = [[HKSubscriptInputField alloc] initWithFrame:CGRectZero];
            textField.tag = 201 + i;
            
            [self addSubview:titleL];
            [self addSubview:textField];
            
            UIButton * btn = [[UIButton alloc] initWithFrame:CGRectZero];
            btn.tag = 301 + i;
            
            if (i == 0) {
                NSDictionary *attrDic = @{NSFontAttributeName:[UIFont systemFontOfSize:13],
                                          NSForegroundColorAttributeName:HEXCOLOR(@"#868686")};
                NSString * p = @"行驶里程（万公里）";
                NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:p];
                [attrStr setAttributes:attrDic range:NSMakeRange(4, 5)];
                titleL.attributedText = attrStr;
                textField.inputField.placeholder = @"请输入行驶里程";
                textField.inputField.keyboardType = UIKeyboardTypeDecimalPad;
                if (carModel.odo > 0) {
                    textField.inputField.text = [NSString formatForPrice:carModel.odo / 10000.00];
                }
            }
            else if (i == 1) {
                titleL.text = @"爱车车型";
                textField.userInteractionEnabled = NO;
                textField.subscriptImageName = @"val_textfield_car";
                textField.inputField.placeholder = @"请选择爱车车型";
                textField.inputField.text = carModel.detailModel.modelname.length ? [NSString stringWithFormat:@"%@", carModel.detailModel.modelname] : @"";
                
                [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                    [self endEditing:YES];
                    if (self.selectTypeClickBlock) {
                        self.selectTypeClickBlock();
                    }
                }];
                [self addSubview:btn];
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(textField.mas_top);
                    make.left.equalTo(self).offset(15);
                    make.right.equalTo(self).offset(-25);
                    make.height.mas_equalTo(25);
                }];
            }
            else {
                titleL.text = @"购车时间";
                textField.userInteractionEnabled = NO;
                textField.subscriptImageName = @"ins_arrow_time";
                textField.inputField.placeholder = @"请选择购车时间";
                
                NSString * dataStr = [carModel.purchasedate dateFormatForYYMM];
                textField.inputField.text = dataStr;
                [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                    [self endEditing:YES];
                    if (self.selectDateClickBlock) {
                        self.selectDateClickBlock();
                    }
                }];
                [self addSubview:btn];
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(textField.mas_top);
                    make.left.equalTo(self).offset(15);
                    make.right.equalTo(self).offset(-25);
                    make.height.mas_equalTo(25);
                }];
            }
            
            [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
                if (i == 0) {
                    make.top.equalTo(line).offset(spacing);
                }
                else {
                    HKSubscriptInputField * textfield = [self viewWithTag:200 + i];
                    make.top.equalTo(textfield.mas_bottom).offset(spacing);
                }
                make.left.equalTo(self).offset(25);
            }];
            
            [textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(titleL.mas_bottom).offset(spacing - 10);
                make.left.equalTo(self).offset(15);
                make.right.equalTo(self).offset(-25);
                make.height.mas_equalTo(25);
            }];
        }
        
        UIImageView * tipImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        tipImg.image = [UIImage imageNamed:@"val_prompt"];
        [self addSubview:tipImg];
        [tipImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(- bottomSpacing - 1);
            make.left.equalTo(self).offset(25);
            make.height.mas_equalTo(14);
            make.width.mas_equalTo(14);
        }];
        
        UILabel * tipL = [[UILabel alloc] initWithFrame:CGRectZero];
        tipL.font = [UIFont systemFontOfSize:13];
        tipL.textColor = HEXCOLOR(@"#20AB2A");
        tipL.text = @"爱车信息如果有误，请点击修改";
        [self addSubview:tipL];
        [tipL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(- bottomSpacing);
            make.left.equalTo(tipImg.mas_right).offset(5);
            make.right.equalTo(self).offset(-10);
        }];
    }
    else {
        UIButton * addBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [addBtn setBackgroundImage:[UIImage imageNamed:@"val_addcar"] forState:UIControlStateNormal];
        [[addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            if (self.addCarClickBlock) {
                self.addCarClickBlock();
            }
        }];
        
        UILabel * addLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        addLabel.textColor = HEXCOLOR(@"#868686");
        addLabel.text = @"点击添加您需要评估的车辆";
        
        [self addSubview:addBtn];
        [self addSubview:addLabel];
        
        [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(60 + spacing);
            make.centerX.equalTo(self.mas_centerX);
            make.height.mas_equalTo(50);
            make.width.mas_equalTo(50);
        }];
        
        [addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(addBtn.mas_bottom).offset(25);
            make.centerX.equalTo(self.mas_centerX);
        }];
    }
}
@end

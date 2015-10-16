//
//  HKPickerVCViewController.h
//  XiaoMa
//
//  Created by jt on 15/9/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKPickerVC : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sureBtn;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

- (void)setupWithTintColor:(UIColor *)tintColor;

+ (RACSignal *)rac_presentPickerVCInView:(UIView *)view withDatasource:(NSArray *)datasource andCurrentValue:(NSArray *)value;
- (RACSignal *)rac_presentPickerVCInView:(UIView *)view withDatasource:(NSArray *)datasource andCurrentValue:(NSArray *)value;

@end

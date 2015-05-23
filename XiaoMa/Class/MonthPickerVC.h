//
//  CommonPackerVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/27.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRMonthPicker.h"

@interface MonthPickerVC : UIViewController
@property (weak, nonatomic) IBOutlet SRMonthPicker *pickerView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ensureItem;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionEnsure:(id)sender;
- (void)setupWithTintColor:(UIColor *)tintColor;
- (void)resetForDT8Picker;

///弹出日期选择器
+ (RACSignal *)rac_presentPickerVCInView:(UIView *)view withSelectedDate:(NSDate *)date;
+ (MonthPickerVC *)monthPickerVC;
- (RACSignal *)rac_presentPickerVCInView:(UIView *)view withSelectedDate:(NSDate *)date;

@end

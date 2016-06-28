//
//  DatePackerVC.h
//  LiverApp
//
//  Created by jiangjunchen on 15/2/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PickerTypeTime,
    PickerTypeDate,
} PickerType;

@interface DatePickerVC : HKViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ensureItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleItem;
@property (weak, nonatomic) IBOutlet UIButton *titleItemBtn;
@property (nonatomic, strong) NSDate *maximumDate;
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, copy) NSString *datePickerTitle;
- (IBAction)actionCancel:(id)sender;
- (IBAction)actionEnsure:(id)sender;
- (void)setupWithTintColor:(UIColor *)tintColor;

///弹出日期选择器
+ (RACSignal *)rac_presentPickerVCInView:(UIView *)view withSelectedDate:(NSDate *)date;
+ (DatePickerVC *)datePickerVCWithMaximumDate:(NSDate *)date;
- (RACSignal *)rac_presentPickerVCInView:(UIView *)view withSelectedDate:(NSDate *)date;

@end

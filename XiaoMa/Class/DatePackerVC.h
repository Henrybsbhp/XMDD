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

@interface DatePackerVC : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ensureItem;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionEnsure:(id)sender;
- (void)setupWithTintColor:(UIColor *)tintColor;

@end

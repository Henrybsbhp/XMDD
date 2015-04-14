//
//  DatePackerVC.m
//  LiverApp
//
//  Created by jiangjunchen on 15/2/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "DatePackerVC.h"
#import "XiaoMa.h"

@interface DatePackerVC ()

@end

@implementation DatePackerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文
    self.datePicker.locale = locale;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionCancel:(id)sender
{
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
}
- (IBAction)actionEnsure:(id)sender
{
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
}

- (void)setupWithTintColor:(UIColor *)tintColor
{
    self.cancelItem.tintColor = tintColor;
    self.ensureItem.tintColor = tintColor;
}

@end

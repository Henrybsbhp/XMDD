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

///弹出日期选择器(next:NSData* error:【表示取消选取】)
+ (RACSignal *)rac_presentPackerVCInView:(UIView *)view withSelectedDate:(NSDate *)date
{
    DatePackerVC *vc = [UIStoryboard vcWithId:@"DatePackerVC" inStoryboard:@"Common"];
    CGSize size = CGSizeMake(CGRectGetWidth(view.frame), 280);
    MZFormSheetController *sheet = [DefaultStyleModel bottomAppearSheetCtrlWithSize:size
                                                                     viewController:vc
                                                                         targetView:view];
    sheet.shouldDismissOnBackgroundViewTap = NO;
    [sheet presentAnimated:YES completionHandler:nil];
    vc.datePicker.date = date;
    vc.datePicker.maximumDate = [NSDate date];
    [vc setupWithTintColor:kDefTintColor];
    
    RACSubject *subject = [RACSubject subject];
    @weakify(vc);
    [[[vc rac_signalForSelector:@selector(actionEnsure:)] take:1] subscribeNext:^(id x) {
        @strongify(vc);
        [subject sendNext:vc.datePicker.date];
        [subject sendCompleted];
    }];

    [[[vc rac_signalForSelector:@selector(actionCancel:)] take:1] subscribeNext:^(id x) {
        [subject sendError:[NSError errorWithDomain:@"cancel" code:0 userInfo:nil]];
    }];
    return subject;
}

@end

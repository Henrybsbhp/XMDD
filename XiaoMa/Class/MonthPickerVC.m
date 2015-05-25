//
//  CommonPackerVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/27.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MonthPickerVC.h"

@interface MonthPickerVC ()

@end

@implementation MonthPickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetForDT8Picker
{
}

- (void)setupWithTintColor:(UIColor *)tintColor
{
    self.cancelItem.tintColor = tintColor;
    self.ensureItem.tintColor = tintColor;
}

+ (MonthPickerVC *)monthPickerVC
{
    MonthPickerVC *vc = [UIStoryboard vcWithId:@"MonthPickerVC" inStoryboard:@"Common"];
    return vc;
}

+ (RACSignal *)rac_presentPickerVCInView:(UIView *)view withSelectedDate:(NSDate *)date
{
    MonthPickerVC *vc = [self monthPickerVC];
    return [vc rac_presentPickerVCInView:view withSelectedDate:date];
}
///弹出日期选择器(next:NSData* error:【表示取消选取】)
- (RACSignal *)rac_presentPickerVCInView:(UIView *)view withSelectedDate:(NSDate *)date
{
    
    CGSize size = CGSizeMake(CGRectGetWidth(view.frame), 280);
    MZFormSheetController *sheet = [DefaultStyleModel bottomAppearSheetCtrlWithSize:size
                                                                     viewController:self
                                                                         targetView:view];
    sheet.shouldDismissOnBackgroundViewTap = NO;
    [sheet presentAnimated:YES completionHandler:nil];
    self.pickerView.maximumYear = @2100;
    self.pickerView.minimumYear = @1900;
    self.pickerView.yearFirst = YES;
    if (date) {
        self.pickerView.date = date;
    }
    [self setupWithTintColor:kDefTintColor];
    
    RACSubject *subject = [RACSubject subject];
    @weakify(self);
    [[[self rac_signalForSelector:@selector(actionEnsure:)] take:1] subscribeNext:^(id x) {
        @strongify(self);
        [subject sendNext:self.pickerView.date];
        [subject sendCompleted];
    }];
    
    [[[self rac_signalForSelector:@selector(actionCancel:)] take:1] subscribeNext:^(id x) {
        [subject sendError:[NSError errorWithDomain:@"cancel" code:0 userInfo:nil]];
    }];
    return subject;
}
#pragma mark - Action
- (IBAction)actionCancel:(id)sender
{
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
}
- (IBAction)actionEnsure:(id)sender
{
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
}

@end

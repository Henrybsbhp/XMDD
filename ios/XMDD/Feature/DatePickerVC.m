//
//  DatePackerVC.m
//  LiverApp
//
//  Created by jiangjunchen on 15/2/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "DatePickerVC.h"
#import "Xmdd.h"
#import "NSString+RectSize.h"

@interface DatePickerVC ()
@end

@implementation DatePickerVC

+ (DatePickerVC *)datePickerVCWithMaximumDate:(NSDate *)date
{
    DatePickerVC *vc = [UIStoryboard vcWithId:@"DatePickerVC" inStoryboard:@"Common"];
    vc.maximumDate = date;
    return vc;
}

+ (RACSignal *)rac_presentPickerVCInView:(UIView *)view withSelectedDate:(NSDate *)date
{
    DatePickerVC *vc = [self datePickerVCWithMaximumDate:[NSDate date]];
    return [vc rac_presentPickerVCInView:view withSelectedDate:date];
}


- (void)dealloc
{
    DebugLog(@"DatePickerVC delloc ~");
}

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
    [self.titleItemBtn setTitle:self.datePickerTitle forState:UIControlStateNormal];
    [self.titleItemBtn setTitleColor:tintColor forState:UIControlStateNormal];
    [self.titleItemBtn setTitleColor:tintColor forState:UIControlStateHighlighted];
    self.titleItemBtn.showsTouchWhenHighlighted = NO;
    self.titleItemBtn.enabled = NO;
    
    CGSize size = [self.datePickerTitle labelSizeWithWidth:9999 font:[UIFont systemFontOfSize:15]];
    CGRect rect = self.titleItemBtn.frame;
    rect.size.width = size.width;
    self.titleItemBtn.frame = rect;
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
    
    self.datePicker.maximumDate = self.maximumDate;
    self.datePicker.minimumDate = self.minimumDate;
    
    self.titleItem.title = self.datePickerTitle;
    
    if (date) {
        self.datePicker.date = date;
    }

    [self setupWithTintColor:kDefTintColor];
    
    RACSubject *subject = [RACSubject subject];
    @weakify(self);
    [[[self rac_signalForSelector:@selector(actionEnsure:)] take:1] subscribeNext:^(id x) {
        @strongify(self);
        [subject sendNext:self.datePicker.date];
        [subject sendCompleted];
    }];

    [[[self rac_signalForSelector:@selector(actionCancel:)] take:1] subscribeNext:^(id x) {
        [subject sendError:[NSError errorWithDomain:@"cancel" code:0 userInfo:nil]];
    }];
    return subject;
}

@end

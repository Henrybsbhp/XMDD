//
//  HKPickerVCViewController.m
//  XiaoMa
//
//  Created by jt on 15/9/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKPickerVC.h"

@interface HKPickerVC ()

@property (nonatomic,strong)NSArray * datasource;

@end

@implementation HKPickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc
{
    DebugLog(@"HKPickerVC dealloc ~");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelAction:(id)sender {
    
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
}
- (IBAction)sureAction:(id)sender {
    
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
}

- (void)setupWithTintColor:(UIColor *)tintColor
{
    self.cancelBtn.tintColor = tintColor;
    self.sureBtn.tintColor = tintColor;
}


+ (RACSignal *)rac_presentPickerVCInView:(UIView *)view withDatasource:(NSArray *)datasource andCurrentValue:(NSArray *)value
{
    HKPickerVC *vc = [UIStoryboard vcWithId:@"HKPickerVC" inStoryboard:@"Common"];
    return [vc rac_presentPickerVCInView:view withDatasource:datasource andCurrentValue:value];
}

- (RACSignal *)rac_presentPickerVCInView:(UIView *)view withDatasource:(NSArray *)datasource andCurrentValue:(NSArray *)value
{
    self.datasource = datasource;
    CGSize size = CGSizeMake(CGRectGetWidth(view.frame), 280);
    CGRect rect = view.frame;
    rect.size.height += 40;
    MZFormSheetController *sheet = [DefaultStyleModel presentSheetCtrlFromBottomWithSize:size viewController:self targetViewFrame:rect];
    sheet.shouldDismissOnBackgroundViewTap = NO;
    [self setupWithTintColor:kDefTintColor];
    
    RACSubject *subject = [RACSubject subject];
    @weakify(self);
    [[[self rac_signalForSelector:@selector(sureAction:)] take:1] subscribeNext:^(id x) {
        @strongify(self);
        [subject sendNext:self.datasource];
        [subject sendCompleted];
    }];
    
    [[[self rac_signalForSelector:@selector(cancelAction:)] take:1] subscribeNext:^(id x) {
        [subject sendError:[NSError errorWithDomain:@"cancel" code:0 userInfo:nil]];
    }];
    
    for (NSInteger component = 0; component< self.datasource.count;component++)
    {
        NSArray * array = [self.datasource safetyObjectAtIndex:component];
        for (NSInteger row = 0; row < array.count;row++)
        {
            NSObject * obj = [array safetyObjectAtIndex:row];
            if (obj.customTag)
            {
                [self.pickerView selectRow:row inComponent:component animated:YES];
 
            }
        }
    }
    return subject;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.datasource.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray * array = [self.datasource safetyObjectAtIndex:component];
    return array.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray * array = [self.datasource safetyObjectAtIndex:component];
    NSDictionary * dict = [array safetyObjectAtIndex:row];
    return dict[@"key"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSArray * array = [self.datasource safetyObjectAtIndex:component];
    row = row >= array.count ? array.count - 1 : row;
    for (NSInteger i = 0;i < array.count;i++)
    {
        NSDictionary * dict = [array safetyObjectAtIndex:i];
        dict.customTag = i == row;
    }
}



@end

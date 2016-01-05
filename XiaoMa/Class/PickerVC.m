//
//  PickerVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "PickerVC.h"

@interface PickerVC ()
@property (nonatomic,strong)NSArray * datasource;
@property (nonatomic, strong) NSMutableArray *curRows;
@end

@implementation PickerVC

- (void)dealloc
{
    DebugLog(@"PickerVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (instancetype)pickerVC
{
    PickerVC *vc = [UIStoryboard vcWithId:@"PickerVC" inStoryboard:@"Common"];
    [vc setupWithTintColor:kDefTintColor];
    return vc;
}

#pragma mark - Action
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

#pragma mark - Present
- (RACSignal *)rac_presentInView:(UIView *)view datasource:(NSArray *)datasource curRows:(NSArray *)rows
{
    self.datasource = datasource;
    if (!rows) {
        rows = [datasource arrayByMappingOperator:^id(NSArray *datas) {
            return [datas objectAtIndex:0];
        }];
    }
    self.curRows = [NSMutableArray arrayWithArray:rows];
    
    CGSize size = CGSizeMake(CGRectGetWidth(view.frame), 280);
    CGRect rect = view.frame;
    rect.size.height += 40;
    MZFormSheetController *sheet = [DefaultStyleModel presentSheetCtrlFromBottomWithSize:size viewController:self targetViewFrame:rect];
    sheet.shouldDismissOnBackgroundViewTap = NO;
    
    RACSubject *subject = [RACSubject subject];
    
    @weakify(self);
    [[[self rac_signalForSelector:@selector(sureAction:)] take:1] subscribeNext:^(id x) {
        @strongify(self);
        NSMutableArray *datas = [NSMutableArray array];
        for (NSInteger component = 0; component < self.curRows.count; component++) {
            NSInteger row = [self.curRows[component] integerValue];
            NSArray *array = [self.datasource safetyObjectAtIndex:component];
            [datas safetyAddObject:[array safetyObjectAtIndex:row]];
        }
        [subject sendNext:datas];
        [subject sendCompleted];
    }];
    
    [[[self rac_signalForSelector:@selector(cancelAction:)] take:1] subscribeNext:^(id x) {
        [subject sendError:[NSError errorWithDomain:@"cancel" code:0 userInfo:nil]];
    }];
    
    for (NSInteger component = 0; component < rows.count; component++) {
        NSInteger row = [rows[component] integerValue];
        [self.pickerView selectRow:row inComponent:component animated:YES];
    }
    return subject;
}
#pragma mark - UIPickerViewDelegate And Dataousrce
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
    if (self.getTitleBlock) {
        return self.getTitleBlock(row, component);
    }
    return [[self.datasource safetyObjectAtIndex:component] safetyObjectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.curRows safetyReplaceObjectAtIndex:component withObject:@(row)];
}

@end

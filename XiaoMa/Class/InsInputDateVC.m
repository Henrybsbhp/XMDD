//
//  InsInputDateVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/6.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "InsInputDateVC.h"
#import "HKCellData.h"
#import "HKSubscriptInputField.h"
#import "DatePickerVC.h"

#import "InsCoverageSelectVC.h"

@interface InsInputDateVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) DatePickerVC *datePicker;

@end

@implementation InsInputDateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupDatePicker];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置日期选择控件（主要是为了事先加载，优化性能）
- (void)setupDatePicker {
    self.datePicker = [DatePickerVC datePickerVCWithMaximumDate:nil];
}
#pragma mark - Datasource
- (void)reloadData
{
    HKCellData *cell1 = [HKCellData dataWithCellID:@"Input" tag:@0];
    cell1.customInfo[@"title"] = @"商业险起保日";
    cell1.customInfo[@"placehold"] = @"请输入商业险日期";
    cell1.customInfo[@"lock"] = @NO;
    cell1.object = self.insModel.startDate;
    
    HKCellData *cell2 = [HKCellData dataWithCellID:@"Input" tag:@1];
    cell2.customInfo[@"title"] = @"交强险起保日";
    cell2.customInfo[@"placehold"] = @"请输入交强险日期";
    cell2.customInfo[@"lock"] = @(self.insModel.forceStartDate.length > 0);
    cell2.object = self.insModel.forceStartDate;
    
    self.datasource = @[cell1, cell2];
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionNext:(id)sender
{
    HKCellData *cell1 = self.datasource[0];
    HKCellData *cell2 = self.datasource[1];
    if ([cell1.object length] == 0) {
        [gToast showText:@"商业险起保日不能为空"];
    }
    else if ([cell2.object length] == 0) {
        [gToast showText:@"交强险起保日不能为空"];
    }
    else {
        self.insModel.startDate = cell1.object;
        self.insModel.forceStartDate = cell2.object;
        InsCoverageSelectVC *vc = [UIStoryboard vcWithId:@"InsCoverageSelectVC" inStoryboard:@"Insurance"];
        vc.insModel = self.insModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDelegate and datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    [self resetInputCell:cell data:data];
    
    return cell;
}

- (void)resetInputCell:(UITableViewCell *)cell data:(HKCellData *)data
{
    UILabel *titleL = [cell viewWithTag:10011];
    HKSubscriptInputField *inputF = [cell viewWithTag:10012];
    UIButton *bgB = [cell viewWithTag:10013];
    
    titleL.text = data.customInfo[@"title"];
    inputF.subscriptImageName = @"ins_arrow_time";
    inputF.inputField.placeholder = data.customInfo[@"placehold"];
    bgB.userInteractionEnabled = ![data.customInfo[@"lock"] boolValue];
    @weakify(self);
    [[[[bgB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     flattenMap:^RACStream *(id value) {
         @strongify(self);
         return [self rac_pickDateWithNow:data.object];
    }] subscribeNext:^(NSString *datetext) {
        data.object = datetext;
        inputF.inputField.text = datetext;
    }];
}


#pragma mark - Utility
- (RACSignal *)rac_pickDateWithNow:(NSString *)nowtext
{
    NSDate *date = [NSDate dateWithD10Text:nowtext];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    [components setDay:components.day+1];
    self.datePicker.minimumDate = [calendar dateFromComponents:components];
    return [[[self.datePicker rac_presentPickerVCInView:self.navigationController.view withSelectedDate:date] ignoreError] map:^id(NSDate *date) {
        return [date dateFormatForD10];
    }];
}

@end

//
//  InsInputDateVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/6.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "InsInputDateVC.h"
#import "HKSubscriptInputField.h"
#import "DatePickerVC.h"
#import "CKDatasource.h"
#import "HKTableViewCell.h"
#import "UpdateCalculatePremiumOp.h"

#import "InsCoverageSelectVC.h"

@interface InsInputDateVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CKList *datasource;
@property (nonatomic, strong) DatePickerVC *datePicker;
@property (nonatomic, assign) BOOL isDateDifferent;
@property (nonatomic, strong) NSDictionary *selectedCarInfo;

@end

@implementation InsInputDateVC

- (void)dealloc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupDatePicker];
    [self reloadData];
    [self setupSignals];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置日期选择控件（主要是为了事先加载，优化性能）
- (void)setupDatePicker
{
    self.datePicker = [DatePickerVC datePickerVCWithMaximumDate:nil];
}

- (void)setupSignals
{
    @weakify(self);
    [[RACObserve(self, isDateDifferent) distinctUntilChanged] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if ([x boolValue]) {
            [self showHelpCell];
        }
        else {
            [self hideHelpCell];
        }
    }];
}
#pragma mark - Action
- (IBAction)actionNext:(id)sender
{
    NSString *date1 = self.datasource[@"StartDate"][@"date"];
    NSString *date2 = self.datasource[@"ForceDate"][@"date"];
    if ([date1 length] == 0) {
        [gToast showText:@"商业险起保日不能为空"];
    }
    else if ([date2 length] == 0) {
        [gToast showText:@"交强险起保日不能为空"];
    }
    else if (self.selectedCarInfo) {
        //更新核保信息
        [self requestUpdateCalculatePremium];
    }
    else {
        //跳转到选择险种页面
        [self gotoCoverageSelectVC];
    }
}

- (void)gotoCoverageSelectVC
{
    self.insModel.startDate = self.datasource[@"StartDate"][@"date"];
    self.insModel.forceStartDate = self.datasource[@"ForceDate"][@"date"];
    InsCoverageSelectVC *vc = [UIStoryboard vcWithId:@"InsCoverageSelectVC" inStoryboard:@"Insurance"];
    vc.insModel = self.insModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showHelp
{
    
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        [MobClick event:@"rp1013_4"];
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:^(id alertVC) {
        [MobClick event:@"rp1013_5"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"交强险与商业险起保日不一致时，默认按照交强险起保日投保。如需不同起保日期投保，请拨打客服电话。是否立即拨打电话咨询？" ActionItems:@[cancel,confirm]];
    [alert show];
}

- (void)showHelpCell
{
    CKDict *data = self.datasource[@"Help"];
    if (!data) {
        data = [self helpItem];
        NSInteger index = [self.datasource indexOfObjectForKey:@"ForceDate"] + 1;
        [self.datasource insertObject:data withKey:nil atIndex:index];
        [self.tableView beginUpdates];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)hideHelpCell
{
    NSInteger index = [self.datasource indexOfObjectForKey:@"Help"];
    if (index != NSNotFound) {
        [self.datasource removeObjectAtIndex:index];
        [self.tableView beginUpdates];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

#pragma mark - Request
///更新核保信息
- (void)requestUpdateCalculatePremium
{
    UpdateCalculatePremiumOp *op = [UpdateCalculatePremiumOp operation];
    op.req_brand = [self.selectedCarInfo jsonEncodedString];
    op.req_carpremiumid = self.insModel.simpleCar.carpremiumid;
    op.req_fstartdate = self.datasource[@"ForceDate"][@"date"];
    op.req_mstartdate = self.datasource[@"StartDate"][@"date"];

    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"正在提交..."];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast dismiss];
        [self gotoCoverageSelectVC];
    } error:^(NSError *error) {
    
        [gToast showError:error.domain];
    }];
}

#pragma mark - Request
- (void)reloadData
{
    _isDateDifferent = self.insModel.forceStartDate && self.insModel.startDate &&
                       ![self.insModel.forceStartDate isEqualToString:self.insModel.startDate];
    CKList *datasource = [CKList list];
    
    CKDict *dateTitle = [self titleItemWithDict:@{kCKCellID:@"Title", @"title":@"选择起保日"}];
    CKDict *date1 = [self inputItemWithDict:@{kCKCellID:@"Input", @"title":@"商业险起保日", @"event":@"rp1013_1",
                                              @"placehold":@"请输入商业险日期", @"lock":@NO, @"date":self.insModel.startDate}];
    CKDict *data2 = [self inputItemWithDict:@{kCKCellID:@"Input", @"title":@"交强险起保日", @"event":@"rp1013_2",
                                              @"placehold":@"请输入交强险日期", @"lock":@(self.insModel.forceStartDate.length > 0),
                                              @"date":self.insModel.forceStartDate}];

    [datasource addObject:dateTitle forKey:@"DateTitle"];
    [datasource addObject:date1 forKey:@"StartDate"];
    [datasource addObject:data2 forKey:@"ForceDate"];
    
    if (self.isDateDifferent) {
        [datasource addObject:[self helpItem] forKey:nil];
    }
    
    if (self.insCarInfo.rsp_brandlist.count > 0) {
        _selectedCarInfo = self.insCarInfo.rsp_brandlist[0];
        
        CKDict *carTitle = [self titleItemWithDict:@{kCKCellID:@"Title", @"title":@"选择爱车车型"}];
        [datasource addObject:carTitle forKey:@"CarTitle"];
        
        for (NSDictionary *info in self.insCarInfo.rsp_brandlist) {
            [datasource addObject:[self carItemWithCarInfo:info] forKey:nil];
        }
    }
 
    self.datasource = datasource;
    [self.tableView reloadData];
}

#pragma mark - About Cell
- (CKDict *)inputItemWithDict:(NSDictionary *)dict
{
    CKDict *data = [CKDict dictWith:dict];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 60;
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        [MobClick event:data[@"event"]];
    });
    
    @weakify(self);
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UILabel *titleL = [cell viewWithTag:10011];
        HKSubscriptInputField *inputF = [cell viewWithTag:10012];
        UIButton *bgB = [cell viewWithTag:10013];
        
        titleL.text = data[@"title"];
        inputF.subscriptImageName = @"ins_arrow_time";
        inputF.inputField.placeholder = data[@"placehold"];
        inputF.inputField.text = data[@"date"];
        bgB.userInteractionEnabled = ![data.customInfo[@"lock"] boolValue];
        
        [[[[bgB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
          flattenMap:^RACStream *(id value) {
              
              @strongify(self);
              return [self rac_pickDateWithNow:data[@"date"]];
          }] subscribeNext:^(NSString *datetext) {
              
              @strongify(self);
              data[@"date"] = datetext;
              inputF.inputField.text = datetext;
              //判断商业险和交强险日期是否相等
              NSString *data1 = self.datasource[@"StartDate"][@"date"];
              NSString *data2 = self.datasource[@"ForceDate"][@"date"];
              self.isDateDifferent = [data1 length] && [data2 length] && ![data1 isEqualToString:data2];
          }];
    });
    return data;
}

- (CKDict *)titleItemWithDict:(NSDictionary *)dict
{
    CKDict *data = [CKDict dictWith:dict];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 42;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *titleL = [cell viewWithTag:1001];
        titleL.text = data[@"title"];
    });
    return data;
}

- (CKDict *)helpItem
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"Help", kCKItemKey:@"Help"}];
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 51;
    });

    @weakify(self);
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"rp1013_3"];
        if (self.isDateDifferent) {
            [self showHelp];
        }
    });
    return data;
}

- (CKDict *)carItemWithCarInfo:(NSDictionary *)info
{
    CKDict *data = [CKDict dictWith:@{kCKCellID:@"Car"}];
    data[kCKItemKey] = [NSString stringWithFormat:@"%p", (__bridge void *)(info)];
    data[@"info"] = info;
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 44;
    });
    
    @weakify(self);
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UILabel *titleL = [cell viewWithTag:1001];
        UIImageView *boxV = [cell viewWithTag:1002];
        
        titleL.text = data[@"info"][@"displaycarname"];
        
        [[RACObserve(self, selectedCarInfo) takeUntilForCell:cell] subscribeNext:^(NSDictionary *x) {
            boxV.hidden = ![data[@"info"] isEqual:x];
        }];
        HKTableViewCell *hkcell = (HKTableViewCell *)cell;
        [hkcell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 22, 0, 22)];
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        self.selectedCarInfo = data[@"info"];
    });
    return data;
}

#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CKDict *data = self.datasource[indexPath.row];
    if (data[kCKCellSelected]) {
        CKCellSelectedBlock block = data[kCKCellSelected];
        block(data, indexPath);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.datasource[indexPath.row];
    if (data[kCKCellGetHeight]) {
        CKCellGetHeightBlock block = data[kCKCellGetHeight];
        return block(data, indexPath);
    }
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.datasource[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = data[kCKCellPrepare];
    if (block) {
        block(data, cell, indexPath);
    }
    return cell;
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

//
//  enquiryInsuranceVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "EnquiryInsuranceVC.h"
#import "XiaoMa.h"
#import <Masonry.h>
#import "DatePackerVC.h"
#import "UIView+Shake.h"
#import "EnquiryResultVC.h"
#import "GetInsuranceCalculatorOp.h"
#import "NSDate+DateForText.h"

@interface EnquiryInsuranceVC ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
///新车未上牌的一个标志
@property (nonatomic, assign) BOOL noPlateNumber;
///车牌号
@property (nonatomic, strong) NSString *plateNumber;
///城市
@property (nonatomic, strong) NSString *city;
///价格
@property (nonatomic, assign) NSUInteger price;
///提车时间
@property (nonatomic, strong) NSString *strCarryTime;
@property (nonatomic, strong) NSDate *carryTime;

@end

@implementation EnquiryInsuranceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadDatasource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadDatasource
{
    //提车时间
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月"];
    self.carryTime = date;
    self.strCarryTime = [dateFormatter stringFromDate:date];
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionEnquiry:(id)sender
{
    if ([self shakeIfNeededAtRow:0]) {
        return;
    }
    if ([self shakeIfNeededAtRow:1]) {
        return;
    }
    if ([self shakeIfNeededAtRow:2]) {
        return;
    }
    if ([self shakeIfNeededAtRow:3]) {
        return;
    }
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        GetInsuranceCalculatorOp * op = [GetInsuranceCalculatorOp operation];
        op.req_city = self.city;
        op.req_licencenumber = self.plateNumber;
        op.req_registered = self.noPlateNumber ? 2 : 1;
        op.req_purchaseprice = self.price;
        op.req_purchasedate = self.carryTime;
        @weakify(self);
        [[[op rac_postRequest] initially:^{
            [gToast showingWithText:@"正在查询..."];
        }] subscribeNext:^(GetInsuranceCalculatorOp *rspOp) {
            @strongify(self);
            EnquiryResultVC *vc = [UIStoryboard vcWithId:@"EnquiryResultVC" inStoryboard:@"Insurance"];
            [self.navigationController pushViewController:vc animated:YES];
            [vc reloadWithInsurance:rspOp.rsp_insuraceArray calculatorID:rspOp.rsp_calculatorID];
            [gToast dismiss];
        } error:^(NSError *error) {
            [gToast showError:error.domain];
        }];
    }
}

#pragma mark - UITableViewDelegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = [NSString stringWithFormat:@"Cell%d", (int)indexPath.row+1];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (indexPath.row == 0) {
        [self setupCityCell:cell];
    }
    else if (indexPath.row == 1) {
        [self setupPlateNumberCell:cell];
    }
    else if (indexPath.row == 2) {
        [self setupPriceCell:cell];
    }
    else if (indexPath.row == 3) {
        [self setupCarryTimeCell:cell];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *jtcell = (JTTableViewCell *)cell;
    jtcell.customSeparatorInset = UIEdgeInsetsMake(-1, 0, 0, 0);
    [jtcell prepareCellForTableView:tableView atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //修改提车时间
    if (indexPath.row == 3) {
        [self.view endEditing:YES];
        [self pickDate];
    }
}

#pragma mark - TableCell
- (void)setupCityCell:(UITableViewCell *)cell
{
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    field.text = self.city;
    @weakify(self);
    [[[field rac_textSignal] distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        self.city = x;
    }];
}

- (void)setupPriceCell:(UITableViewCell *)cell
{
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    field.text = self.price > 0 ? [NSString stringWithFormat:@"%d", (int)self.price] : @"";
    @weakify(self);
    [[[field rac_textSignal] distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        self.price = [x floatValue];
    }];
}

- (void)setupPlateNumberCell:(UITableViewCell *)cell
{
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    UIButton *button = (UIButton *)[cell.contentView viewWithTag:1003];
    button.selected = self.noPlateNumber;
    @weakify(self);
    [[[button rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(UIButton *btn) {
         @strongify(self);
         btn.selected = !btn.selected;
         field.userInteractionEnabled = !btn.selected;
         self.noPlateNumber = btn.selected;
    }];
    
    [[RACObserve(self, noPlateNumber) takeUntilForCell:cell] subscribeNext:^(id x) {
        
        field.text = [x boolValue] ? [NSString stringWithFormat:@"新车未上牌"] : nil;
    }];
    
    [[[field rac_textSignal] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        self.plateNumber = x;
    }];
}

- (void)setupCarryTimeCell:(UITableViewCell *)cell
{
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    [[RACObserve(self, strCarryTime) takeUntilForCell:cell] subscribeNext:^(id x) {
        field.text = x;
    }];
}

#pragma mark - Private
- (BOOL)shakeIfNeededAtRow:(NSInteger)row
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    if (field.text.length == 0) {
        [field shake];
        return YES;
    }
    return NO;
}

- (void)pickDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月"];
    NSDate *date = [dateFormatter dateFromString:self.strCarryTime];
    DatePackerVC *vc = [UIStoryboard vcWithId:@"DatePackerVC" inStoryboard:@"Common"];
    CGSize size = CGSizeMake(CGRectGetWidth(self.view.frame), 280);
    MZFormSheetController *sheet = [DefaultStyleModel bottomAppearSheetCtrlWithSize:size
                                                                     viewController:vc
                                                                         targetView:self.navigationController.view];
    sheet.shouldDismissOnBackgroundViewTap = NO;
    [sheet presentAnimated:YES completionHandler:nil];
    vc.datePicker.date = date;
    vc.datePicker.maximumDate = [NSDate date];

    [vc setupWithTintColor:kDefTintColor];
    
    @weakify(vc);
     [[[vc rac_signalForSelector:@selector(actionEnsure:)] take:1] subscribeNext:^(id x) {
 
        @strongify(vc);
         self.carryTime = vc.datePicker.date;
        self.strCarryTime = [dateFormatter stringFromDate:vc.datePicker.date];
    }];
}

@end

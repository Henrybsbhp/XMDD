//
//  InsCoverageSelectVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/23.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsCoverageSelectVC.h"
#import "CCSegmentedControl.h"
#import "CKLine.h"
#import "HKInsurance.h"
#import "HKCoverage.h"
#import "HKCellData.h"
#import "HKTableViewCell.h"
#import "InsuranceStore.h"

#import "GetInsuranceCalculatorOpV3.h"
#import "CalculatePremiumOp.h"

#import "PickerVC.h"
#import "InsActivityIndicatorVC.h"
#import "InsCheckResultsVC.h"
#import "InsCheckFailVC.h"
#import "InsAppointmentSuccessVC.h"

@interface InsCoverageSelectVC ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet CCSegmentedControl *segctrl;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *planList;
@property (nonatomic, strong) NSMutableDictionary *datasourceCache;
@property (nonatomic, strong) NSArray *datasource;

@end

@implementation InsCoverageSelectVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"InsCoverageSelectVC dealloc ~");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //init data
    self.datasourceCache = [NSMutableDictionary dictionary];
    // init UI
    self.navigationItem.title = @"选择车险";
    [self setupHeaderView];
    [self setupBottomView];
    CKAsyncMainQueue(^{
        [self requestInsurancePlans];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Setup
- (void)setupHeaderView
{
    CCSegmentedControl *segctrl = [self.headerView viewWithTag:1001];
    CKLine *line = [self.headerView viewWithTag:1002];
    
    line.lineAlignment = CKLineAlignmentHorizontalBottom;
    
    segctrl.backgroundColor = [UIColor whiteColor];
    UIView * v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor colorWithHex:@"#20ab2a" alpha:1.0f];
    segctrl.selectedStainView = v;
    segctrl.selectedSegmentTextColor = [UIColor whiteColor];
    segctrl.segmentTextColor = [UIColor darkGrayColor];
    [segctrl addTarget:self action:@selector(actionSegmentChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)setupBottomView
{
    UIButton *button = [self.bottomView viewWithTag:1001];
    [button setTitle:self.selectMode == InsuranceSelectModeBuy ? @"立即核保" : @"预约核保" forState:UIControlStateNormal];
}

#pragma mark - Reload
- (void)reloadTableDataWithCurPlan:(HKInsurance *)curPlan
{
    NSMutableArray *datasource = [self.datasourceCache objectForKey:curPlan.insuranceName];
    if (!datasource) {
        datasource = [NSMutableArray array];
        NSArray *coveragesList = [self.insModel createCoveragesList];
        for (NSArray *coverages in coveragesList) {
            [datasource addObject:[self generateRowsForCoverages:coverages andCurPlan:curPlan]];
        }
        [self.datasourceCache safetySetObject:datasource forKey:curPlan.insuranceName];
    }
    self.datasource = datasource;
    [self.tableView reloadData];
}

- (void)reloadSegmentView
{
    CCSegmentedControl *segctrl = [self.headerView viewWithTag:1001];
    [segctrl removeAllSegments];
    [self.planList enumerateObjectsUsingBlock:^(HKInsurance *ins, NSUInteger idx, BOOL * _Nonnull stop) {
        [segctrl insertSegmentWithTitle:ins.insuranceName atIndex:idx animated:NO];
    }];
}
#pragma mark - Request
- (void)requestInsurancePlans
{
    GetInsuranceCalculatorOpV3 * op = [GetInsuranceCalculatorOpV3 operation];
    @weakify(self);
    [[[[op rac_postRequest] deliverOn:[RACScheduler mainThreadScheduler]] initially:^{
       
        @strongify(self);
        self.containerView.hidden = YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(GetInsuranceCalculatorOpV3 *op) {

        @strongify(self);
        self.containerView.hidden = NO;
        [self.view stopActivityAnimation];
        
        NSMutableArray * array = [NSMutableArray arrayWithArray:op.rsp_insuraceArray];
        [array addObject:[self generateCustomPlan]];
        self.planList = array;
        [self reloadSegmentView];
        [self reloadTableDataWithCurPlan:[array safetyObjectAtIndex:0]];
    } error:^(NSError *error) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"保险方案获取失败，点击重试" tapBlock:^{
            @strongify(self);
            [self requestInsurancePlans];
        }];
    }];
}

- (void)requestCalculatePremium:(NSArray *)inslist
{
    CalculatePremiumOp * op = [CalculatePremiumOp operation];
    op.req_carpremiumid = self.insModel.simpleCar.carpremiumid;
    op.req_inslist = [inslist componentsJoinedByString:@"|"];
    op.req_fstartdate = self.insModel.forceStartDate;
    op.req_mstartdate = self.insModel.startDate;
    
    InsActivityIndicatorVC *indicator = [[InsActivityIndicatorVC alloc] init];
    
    //当页面释放的时候，直接断开连接
    @weakify(op);
    @weakify(self);
    [[[[[[op rac_postRequest] takeUntil:[self rac_willDeallocSignal]] delay:0.3] initially:^{
        
        @strongify(self);
        [indicator showInViewController:self];
    }] finally:^{
        
        @strongify(op);
        [indicator dismiss];
        [op cancel];
    }] subscribeNext:^(CalculatePremiumOp *op) {
        
        @strongify(self);
        //核保成功，刷新保险车辆列表
        [[[InsuranceStore fetchExistsStore] getInsSimpleCars] sendAndIgnoreError];
        if ([self.navigationController.topViewController isEqual:self]) {
            //跳到核保结果页
            InsCheckResultsVC *vc = [UIStoryboard vcWithId:@"InsCheckResultsVC" inStoryboard:@"Insurance"];
            vc.insModel = self.insModel;
            vc.premiumList = op.rsp_premiumlist;
            vc.headerTip = op.rsp_tip;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } error:^(NSError *error) {
        
        @strongify(self);
        if ([self.navigationController.topViewController isEqual:self]) {
            //跳到核保失败页面
            InsCheckFailVC *vc = [UIStoryboard vcWithId:@"InsCheckFailVC" inStoryboard:@"Insurance"];
            vc.insModel = self.insModel;
            vc.errmsg = error.domain;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (void)requestAppointment:(NSArray *)inslist
{
    self.appointmentOp.req_inslist = [inslist componentsJoinedByString:@"|"];
    @weakify(self);
    [[[self.appointmentOp rac_postRequest] initially:^{
        
        [gToast showingWithText:@"正在预约..."];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast dismiss];
        InsAppointmentSuccessVC *vc = [UIStoryboard vcWithId:@"InsAppointmentSuccessVC" inStoryboard:@"Insurance"];
        vc.insModel = self.insModel;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma mark - Action
- (void)actionBack:(id)sender
{
    [MobClick event:@"rp1003_1"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionNext:(id)sender
{
    [MobClick event:@"rp1003_6"];
    NSArray *inslist = [self generateInsList];
    if (inslist.count < 3) {
        [gToast showError:@"请至少选择一个商业险种"];
    }
    else if (self.selectMode == InsuranceSelectModeBuy) {
        [self requestCalculatePremium:inslist];
    }
    else {
        [self requestAppointment:inslist];
    }
}

- (void)actionSegmentChanged:(id)sender
{
    [MobClick event:[NSString stringWithFormat:@"rp1003_%ld", self.segctrl.selectedSegmentIndex+2]];
    [self reloadTableDataWithCurPlan:[self.planList safetyObjectAtIndex:self.segctrl.selectedSegmentIndex]];
}

#pragma mark - Utlity
- (HKCellData *)dataForInsID:(NSNumber *)insid inArray:(NSArray *)array
{
    if (!insid || !array) {
        return nil;
    }
    HKCellData *data = [array firstObjectByFilteringOperator:^BOOL(HKCellData *data) {
        HKCoverage *cov = data.object;
        return [cov.insId isEqual:insid];
    }];
    return data;
}

- (HKInsurance *)generateCustomPlan
{
    HKInsurance * ins = [[HKInsurance alloc] init];
    ins.insuranceName = @"自选";
    
    SubInsurance *sub1 = [[SubInsurance alloc] init];
    sub1.coveragerId = @14;
    SubInsurance *sub2 = [[SubInsurance alloc] init];
    sub2.coveragerId = @15;
    
    ins.subInsuranceArray = @[sub1, sub2];
    
    return ins;
}

- (NSMutableArray *)generateRowsForCoverages:(NSArray *)coverages andCurPlan:(HKInsurance *)curPlan
{
    NSMutableArray *rows = [NSMutableArray array];
    for (HKCoverage *cov in coverages) {
        HKCellData *data = [HKCellData dataWithCellID:@"Ins" tag:nil];
        data.object = cov;
        data.customInfo[@"detail"] = [cov.params safetyObjectAtIndex:cov.defParamIndex];
        [curPlan.subInsuranceArray enumerateObjectsUsingBlock:^(SubInsurance *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj.coveragerId isEqual:cov.insId]) {
                data.customInfo[@"select"] = @YES;
                *stop = YES;
            }
        }];
        [rows addObject:data];
        
        if (cov.excludingDeductibleCoverage) {
            [curPlan.subInsuranceArray enumerateObjectsUsingBlock:^(SubInsurance *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.coveragerId isEqual:cov.excludingDeductibleCoverage.insId]) {
                    HKCellData *data2 = [HKCellData dataWithCellID:@"SubIns" tag:nil];
                    data2.object = cov.excludingDeductibleCoverage;
                    data2.customInfo[@"select"] = @YES;
                    data2.customInfo[@"nested"] = @YES;
                    [rows addObject:data2];
                    *stop = YES;
                }
            }];
        }
    }
    
    return rows;
}

- (NSArray *)generateInsList
{
    NSMutableArray *inslist = [NSMutableArray array];
    for (NSArray *datas in self.datasource) {
        for (HKCellData *data in datas) {
            HKCoverage *cov = data.object;
            if ([data.customInfo[@"select"] boolValue]) {
                NSNumber *value = [data.customInfo[@"detail"] objectForKey:@"value"];
                [inslist addObject:[NSString stringWithFormat:@"%@@%@", cov.insId, value ? value : @0]];
            }
        }
    }
    return inslist;
}

- (RACSignal *)pickCoverageParamWithData:(HKCellData *)data
{
    HKCoverage *coverage = data.object;
    PickerVC *vc = [PickerVC pickerVC];
    [vc setGetTitleBlock:^NSString *(NSInteger row, NSInteger component) {
        return [[coverage.params safetyObjectAtIndex:row] objectForKey:@"key"];
    }];
    
    NSArray *curRows = @[@([coverage.params indexOfObject:data.customInfo[@"detail"]])];
    RACSignal *sig = [[vc rac_presentInView:self.navigationController.view datasource:@[coverage.params]
                          curRows:curRows] map:^id(NSArray *result) {
        return [result safetyObjectAtIndex:0];
    }];

    [vc setupWithTintColor:HEXCOLOR(@"#20ab2a")];
    
    return sig;
}

#pragma mark - UITableViewDelegate and Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.datasource safetyObjectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * v = [[UIView alloc] init];
    v.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 30);
    UILabel * l = [[UILabel alloc] init];
    l.frame = CGRectMake(10,6,100,18);
    l.font = [UIFont systemFontOfSize:12];
    l.backgroundColor = [UIColor clearColor];
    l.text = section == 0 ? @"基本险" : @"附加险";
    [v addSubview:l];
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    HKCellData *data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    HKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    
    [self resetCell:cell forData:data atIndexPath:indexPath];

    cell.customSeparatorInset = UIEdgeInsetsZero;
    [cell prepareCellForTableView:tableView atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Cell
- (void)resetCell:(UITableViewCell *)cell forData:(HKCellData *)data atIndexPath:(NSIndexPath *)indexPath
{
    UIButton *checkB = [cell viewWithTag:101];
    UILabel *titleL = [cell viewWithTag:102];
    UIView *rightV = [cell viewWithTag:103];
    UILabel *rightL = [cell viewWithTag:1031];
    UIButton *rightB = [cell viewWithTag:1033];

    HKCoverage *coverage = data.object;
    [[RACObserve(data, forceReload) takeUntilForCell:cell] subscribeNext:^(id x) {
        titleL.text = coverage.insName;
        rightV.hidden = coverage.params.count == 0 || data.customInfo[@"nested"];
        rightL.text = [data.customInfo[@"detail"] objectForKey:@"key"];
        checkB.selected = [data.customInfo[@"select"] boolValue];
    }];
    
    @weakify(self);
    [[[checkB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         
         @strongify(self);
         //交强险和车船税无法取消
         if ([coverage.insId isEqual:@14] || [coverage.insId isEqual:@15]) {
             
             HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                 [alertVC dismiss];
             }];
             HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"在线无法单独购买商业险,请拨打4007-111-111, 小马达达车险专员为您服务" ActionItems:@[cancel]];
             [alert show];
             
             return ;
         }
         NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
         BOOL selected = ![data.customInfo[@"select"] boolValue];
         data.customInfo[@"select"] = @(selected);
         data.forceReload = !data.forceReload;
         NSArray *array = [self.datasource safetyObjectAtIndex:indexPath.section];
         //移除行
         if (!selected) {
             [self.tableView beginUpdates];

             if ([coverage.insId isEqual:@3]) {
                 HKCellData *data2 = [self dataForInsID:@4 inArray:array];
                 data2.customInfo[@"select"] = @NO;
                 data2.forceReload = !data2.forceReload;
                 //注意！delete的顺序，index一定要大到小，不然会错乱
                 [self deleteRowsForData:data2 inSection:indexPath.section];
                 [self deleteRowsForData:data inSection:indexPath.section];
             }
             else if ([coverage.insId isEqual:@4]) {
                 HKCellData *data2 = [self dataForInsID:@3 inArray:array];
                 data2.customInfo[@"select"] = @NO;
                 data2.forceReload = !data2.forceReload;
                 [self deleteRowsForData:data inSection:indexPath.section];
                 [self deleteRowsForData:data2 inSection:indexPath.section];
             }
             else {
                 [self deleteRowsForData:data inSection:indexPath.section];
             }
             [self.tableView endUpdates];
          }
         //插入行
         else if (selected && coverage.excludingDeductibleCoverage) {
             [self.tableView beginUpdates];
             
             if ([coverage.insId isEqual:@3]) {
                 HKCellData *data2 = [self dataForInsID:@4 inArray:array];
                 data2.customInfo[@"select"] = @YES;
                 data2.forceReload = !data2.forceReload;
                 //注意！insert的顺序，index一定要从小到大，不然会错乱
                 [self insertRowForData:data inSection:indexPath.section];
                 [self insertRowForData:data2 inSection:indexPath.section];
             }
             else if ([coverage.insId isEqual:@4]) {
                 HKCellData *data2 = [self dataForInsID:@3 inArray:array];
                 data2.customInfo[@"select"] = @YES;
                 data2.forceReload = !data2.forceReload;
                 [self insertRowForData:data2 inSection:indexPath.section];
                 [self insertRowForData:data inSection:indexPath.section];
             }
             else {
                 [self insertRowForData:data inSection:indexPath.section];
             }
             [self.tableView endUpdates];
         }
    }];
    
    [[[[rightB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     flattenMap:^RACStream *(id value) {
         
         @strongify(self);
         return [self pickCoverageParamWithData:data];
    }] subscribeNext:^(id x) {
        
        data.customInfo[@"detail"] = x;
        rightL.text = [x objectForKey:@"key"];
    }];
}

- (void)insertRowForData:(HKCellData *)data inSection:(NSInteger)section
{
    HKCoverage *subcov = [(HKCoverage *)data.object excludingDeductibleCoverage];
    NSMutableArray *array = [self.datasource safetyObjectAtIndex:section];
    
    if (![self dataForInsID:subcov.insId inArray:array]) {
        NSInteger row = [array indexOfObject:data];
        HKCellData *insertingData = [HKCellData dataWithCellID:@"SubIns" tag:nil];
        insertingData.object = [(HKCoverage *)data.object excludingDeductibleCoverage];
        insertingData.customInfo[@"select"] = @YES;
        insertingData.customInfo[@"nested"] = @YES;
        [array safetyInsertObject:insertingData atIndex:row+1];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row+1 inSection:section];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)deleteRowsForData:(HKCellData *)data inSection:(NSInteger)section
{
    NSMutableArray *array = [self.datasource safetyObjectAtIndex:section];
    HKCoverage *subcov = [(HKCoverage *)data.object excludingDeductibleCoverage];
    
    if ([self dataForInsID:subcov.insId inArray:array]) {
        NSInteger row = [array indexOfObject:data];
        [array safetyRemoveObjectAtIndex:row+1];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row+1 inSection:section];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}

@end

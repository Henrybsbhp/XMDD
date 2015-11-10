//
//  InsuranceChooseViewController.m
//  XiaoMa
//
//  Created by jt on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceChooseViewController.h"
#import "HKCoverage.h"
#import "InsuranceResultVC.h"
#import "InsuranceAppointmentOp.h"
#import "HKPickerVC.h"

@interface InsuranceChooseViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@property (nonatomic,strong)NSMutableArray * insuranceArry;
@property (nonatomic,strong)NSMutableArray * insuranceArry2;
@property (nonatomic,strong)CKSegmentHelper *checkBoxHelper;

@end

@implementation InsuranceChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupInsuranceArray];
    
    [self setupUI];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp133"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"rp133"];
}

- (void)actionBack:(id)sender
{
    [MobClick event:@"rp133-4"];
    [super actionBack:sender];
}

- (void)setupUI
{
    [[self.sureBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp133-3"];
        if (![self inslistForVC].count)
        {
            [gToast showError:@"请至少选择一个车险"];
            return ;
        }
        InsuranceAppointmentOp *op = [[InsuranceAppointmentOp alloc] init];
        op.req_idcard = self.idcard;
        op.req_driverpic = self.currentRecord.url;
        op.req_invitecode = self.inviteCode;
        op.req_inslist = [[self inslistForVC] componentsJoinedByString:@"|"];
        @weakify(self);
        [[[op rac_postRequest] initially:^{
            
            [gToast showingWithText:@"正在预约..."];
        }] subscribeNext:^(id x) {
            
            @strongify(self);
            [gToast dismiss];
            InsuranceResultVC *vc = [UIStoryboard vcWithId:@"InsuranceResultVC" inStoryboard:@"Insurance"];
            vc.title = @"预约结果";
            [self.navigationController pushViewController:vc animated:YES];
        } error:^(NSError *error) {
            
            [gToast showError:error.domain];
        }];
    }];
}

- (void)setupInsuranceArray
{
    HKCoverage * coverage1 = [[HKCoverage alloc] initWithCategory:InsuranceCompulsory];
    HKCoverage * coverage2 = [[HKCoverage alloc] initWithCategory:InsuranceTravelTax];
    HKCoverage * coverage3 = [[HKCoverage alloc] initWithCategory:InsuranceCarDamage];
    HKCoverage * coverage4 = [[HKCoverage alloc] initWithCategory:InsuranceThirdPartyLiability];
    HKCoverage * coverage5 = [[HKCoverage alloc] initWithCategory:InsuranceCarSeatInsuranceOfDriver];
    HKCoverage * coverage6 = [[HKCoverage alloc] initWithCategory:InsuranceCarSeatInsuranceOfPassenger];
    HKCoverage * coverage7 = [[HKCoverage alloc] initWithCategory:InsuranceWholeCarStolen];
    HKCoverage * coverage8 = [[HKCoverage alloc] initWithCategory:InsuranceSeparateGlassBreakage];
    HKCoverage * coverage9 = [[HKCoverage alloc] initWithCategory:InsuranceSpontaneousLossRisk];
    HKCoverage * coverage10 = [[HKCoverage alloc] initWithCategory:InsuranceWaterLoss];
    self.insuranceArry = [NSMutableArray arrayWithArray:@[coverage1,coverage2,coverage3,coverage4,coverage5,coverage6,
                                                          coverage7]];
    self.insuranceArry2 = [NSMutableArray arrayWithArray:@[coverage8,coverage9,coverage10]];
}


- (void)showActionSheet:(HKCoverage * )c
{
    
    NSMutableArray * array = [NSMutableArray array];
    NSMutableArray * select = [NSMutableArray array];
    if (c.params)
    {
        [array safetyAddObject:c.params];
        NSObject * obj = [c.params firstObjectByFilteringOperator:^BOOL(NSObject * obj) {
            
            return obj.customTag;
        }];
        [select safetyAddObject:obj];
    }
    if (c.params2)
    {
        [array safetyAddObject:c.params2];
        NSObject * obj = [c.params2 firstObjectByFilteringOperator:^BOOL(NSObject * obj) {
            
            return obj.customTag;
        }];
        [select safetyAddObject:obj];
    }

    [[HKPickerVC rac_presentPickerVCInView:self.view withDatasource:array andCurrentValue:select] subscribeNext:^(NSArray * array) {
        
        NSInteger i;
        NSIndexPath *indexPath1;
        
        if ([self.insuranceArry containsObject:c])
        {
            i= [self.insuranceArry indexOfObject:c];
            indexPath1 = [NSIndexPath indexPathForRow:i inSection:0];
        }
        else
        {
            i= [self.insuranceArry2 indexOfObject:c];
            indexPath1 = [NSIndexPath indexPathForRow:i inSection:1];
        }
        
        NSArray * refreshArray ;
        if (c.customTag && c.excludingDeductibleCoverage)
        {
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:i + 1 inSection:0];
            refreshArray = @[indexPath1,indexPath2];
        }
        else
        {
            refreshArray = @[indexPath1];
        }
        [self.tableView reloadRowsAtIndexPaths:refreshArray withRowAnimation:UITableViewRowAnimationNone];
    } error:^(NSError *error) {
        
    }];
}


#pragma mark - TableView data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 45.0f;
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count;
    if (section == 0){
        
        count = self.insuranceArry.count;
    }
    else{
        
        count = self.insuranceArry2.count;
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * v = [[UIView alloc] init];
    v.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 30);
    UILabel * l = [[UILabel alloc] init];
    l.frame = CGRectMake(10,6,100,18);
    l.font = [UIFont systemFontOfSize:12];
    l.backgroundColor = [UIColor clearColor];
    [v addSubview:l];
    if (section == 0){
        
        l.text = @"基本险";
    }
    else{
        
        l.text = @"附加险";
    }
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    HKCoverage * coverage;
    
    if (indexPath.section == 0)
        coverage = [self.insuranceArry safetyObjectAtIndex:indexPath.row];
    else
        coverage = [self.insuranceArry2  safetyObjectAtIndex:indexPath.row];
    
    if (coverage.insCategory == InsuranceCompulsory ||
        coverage.insCategory == InsuranceTravelTax ||
        coverage.insCategory == InsuranceCarDamage ||
        coverage.insCategory == InsuranceWholeCarStolen ||
        coverage.insCategory == InsuranceSpontaneousLossRisk ||
        coverage.insCategory == InsuranceWaterLoss)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"InsuranceTypeA"];
        
        UIButton *boxBtn = (UIButton *)[cell searchViewWithTag:101];
        UILabel *insuranceNameLb = (UILabel *)[cell searchViewWithTag:102];
        
        insuranceNameLb.text = coverage.insName;
        
        boxBtn.selected = coverage.customTag;
        @weakify(boxBtn);
        [[[boxBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            [MobClick event:@"rp133-1"];
            @strongify(boxBtn);
            
            /**
             *  先更新数据源，再刷新
             */
            BOOL flag = boxBtn.selected;
            [boxBtn setSelected:!flag];
            coverage.customTag = !flag;
            
            if (coverage.excludingDeductibleCoverage)
            {
                HKCoverage * subCoverage = coverage.excludingDeductibleCoverage;
                if (coverage.customTag == YES)
                {
                    subCoverage.customTag = [self needSelectExcludingDeductible:subCoverage];
                    NSInteger index = [self.insuranceArry indexOfObject:coverage];
                    [self.insuranceArry safetyInsertObject:coverage.excludingDeductibleCoverage atIndex:index + 1];
                    NSIndexPath * idxPath = [NSIndexPath indexPathForRow:index + 1 inSection:indexPath.section];
                    [self.tableView insertRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationLeft];
                }
                else
                {
                    NSInteger index = [self.insuranceArry indexOfObject:coverage.excludingDeductibleCoverage];
                    [self.insuranceArry safetyRemoveObject:coverage.excludingDeductibleCoverage];
                    NSIndexPath * idxPath = [NSIndexPath indexPathForRow:index inSection:indexPath.section];
                    [self.tableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationRight];
                }
            }
        }];
    }
    else if (coverage.insCategory == InsuranceThirdPartyLiability ||
             coverage.insCategory == InsuranceCarSeatInsuranceOfDriver ||
             coverage.insCategory == InsuranceCarSeatInsuranceOfPassenger ||
             coverage.insCategory == InsuranceSeparateGlassBreakage)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"InsuranceTypeB"];
        
        UIButton *boxBtn = (UIButton *)[cell searchViewWithTag:101];
        UILabel *insuranceNameLb = (UILabel *)[cell searchViewWithTag:102];
        UIView * paramView = (UIView * )[cell searchViewWithTag:105];
        UILabel *paramLb = (UILabel *)[cell searchViewWithTag:20501];
        UITapGestureRecognizer * gesture = paramView.customObject;
        if (!gesture)
        {
            UITapGestureRecognizer *ge = [[UITapGestureRecognizer alloc] init];
            [paramView addGestureRecognizer:ge];
            paramView.userInteractionEnabled = YES;
            paramView.customObject = ge;
        }
        gesture = paramView.customObject;
        [[[gesture rac_gestureSignal] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            [self showActionSheet:coverage];
        }];
        
        insuranceNameLb.text = coverage.insName;
        boxBtn.selected = coverage.customTag;
       
        NSString * paramText = @"";
        for (NSDictionary * obj in coverage.params)
        {
            if (obj.customTag)
            {
                paramText = [paramText append:[obj objectForKey:@"key"]];
                break;
            }
        }
        for (NSDictionary * obj in coverage.params2)
        {
            if (obj.customTag)
            {
                paramText = [paramText append:@" "];
                paramText = [paramText append:[obj objectForKey:@"key"]];
                break;
            }
        }
        
        paramLb.text = paramText;
        
        @weakify(boxBtn);
        [[[boxBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            [MobClick event:@"rp133-1"];
            @strongify(boxBtn);
            BOOL flag = boxBtn.selected;
            [boxBtn setSelected:!flag];
            coverage.customTag = !flag;
            
            if (coverage.excludingDeductibleCoverage)
            {
                HKCoverage * subCoverage = coverage.excludingDeductibleCoverage;
                if (coverage.customTag == YES)
                {
                    subCoverage.customTag = [self needSelectExcludingDeductible:subCoverage];
                    NSInteger index = [self.insuranceArry indexOfObject:coverage];
                    [self.insuranceArry safetyInsertObject:coverage.excludingDeductibleCoverage atIndex:index + 1];
                    NSIndexPath * idxPath = [NSIndexPath indexPathForRow:index + 1 inSection:indexPath.section];
                    [self.tableView insertRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationLeft];
                }
                else
                {
                    NSInteger index = [self.insuranceArry indexOfObject:coverage.excludingDeductibleCoverage];
                    [self.insuranceArry safetyRemoveObject:coverage.excludingDeductibleCoverage];
                    NSIndexPath * idxPath = [NSIndexPath indexPathForRow:index inSection:indexPath.section];
                    [self.tableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationRight];
                }
            }
        }];
    }
    else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"SubInsuranceTypeA"];
        
        UIButton *boxBtn = (UIButton *)[cell searchViewWithTag:101];
        UILabel *insuranceNameLb = (UILabel *)[cell searchViewWithTag:102];
        
        insuranceNameLb.text = coverage.insName;
        
        boxBtn.selected = coverage.customTag;
        @weakify(boxBtn);
        [[[boxBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            [MobClick event:@"rp133-2"];
            @strongify(boxBtn);
            BOOL flag = boxBtn.selected;
            [boxBtn setSelected:!flag];
            coverage.customTag = !flag;
        }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    JTTableViewCell *jtcell = (JTTableViewCell *)cell;
    //    [jtcell prepareCellForTableView:tableView atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Utility
- (NSArray *)inslistForVC
{
    NSMutableArray * array = [NSMutableArray array];
    for (HKCoverage * c in self.insuranceArry)
    {
        if (c.customTag)
        {
            NSString * paramText = @"";
            for (NSDictionary * obj in c.params)
            {
                if (obj.customTag)
                {
                    paramText = [paramText append:[obj objectForKey:@"key"]];
                    break;
                }
            }
            for (NSDictionary * obj in c.params2)
            {
                if (obj.customTag)
                {
                    paramText = [paramText append:@" "];
                    paramText = [paramText append:[obj objectForKey:@"key"]];
                    break;
                }
            }
            paramText = paramText.length ? paramText : @"0";
            NSString * s = [NSString stringWithFormat:@"%@@%@@%@@%.2f",c.insId,c.insName,paramText,0.00];
            [array safetyAddObject:s];
        }
    }
    
    for (HKCoverage * c in self.insuranceArry2)
    {
        if (c.customTag)
        {
            NSString * paramText = @"";
            for (NSDictionary * obj in c.params)
            {
                if (obj.customTag)
                {
                    paramText = [paramText append:[obj objectForKey:@"key"]];
                    break;
                }
            }
            for (NSDictionary * obj in c.params2)
            {
                if (obj.customTag)
                {
                    paramText = [paramText append:@" "];
                    paramText = [paramText append:[obj objectForKey:@"key"]];
                    break;
                }
            }
            paramText = paramText.length ? paramText : @"0";
            NSString * s = [NSString stringWithFormat:@"%@@%@@%@@%.2f",c.insId,c.insName,paramText,0.00];
            [array safetyAddObject:s];
        }
    }
    //    NSString * inslist = [array componentsJoinedByString:@"|"];
    return array;
}

#pragma mark - Utility
- (BOOL)needSelectExcludingDeductible:(HKCoverage *)c
{
    if (c.insCategory == InsuranceExcludingDeductible4CarDamage ||
        c.insCategory == InsuranceExcludingDeductible4ThirdPartyLiability ||
        c.insCategory == InsuranceExcludingDeductible4CarSeatInsuranceOfDriver ||
        c.insCategory == InsuranceExcludingDeductible4CarSeatInsuranceOfPassenger)
    {
        return YES;
    }
    else if (c.insCategory == InsuranceExcludingDeductible4WholeCarStolen)
    {
        return NO;
    }
    return c.customTag;
}
@end

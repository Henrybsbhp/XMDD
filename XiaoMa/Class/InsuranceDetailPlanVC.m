//
//  InsuranceDetailPlanVC.m
//  XiaoMa
//
//  Created by jt on 15/7/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceDetailPlanVC.h"
#import "JDFlipNumberView.h"
#import "HKCoverage.h"
#import "InsuranceCalcHelper.h"
#import "UploadInsuranceInfoVC.h"


#define CheckBoxInsuranceGroup @"CheckBoxInsuranceGroup"

@interface InsuranceDetailPlanVC()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet JDFlipNumberView *flipNumberView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@property (nonatomic,strong)NSMutableArray * insuranceArry;
@property (nonatomic, strong) CKSegmentHelper *checkBoxHelper;
@property (nonatomic)CGFloat totalPrice;
@property (nonatomic)InsuranceCalcHelper * calcHelper;

@end

@implementation InsuranceDetailPlanVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCalcHelper];
    [self setupInsuranceArray];
    [self setupFlipNumberView];
    [self calcTotalPrice];
    [self animateToTargetValue:(NSInteger)(self.totalPrice * 100)];
    
    [self setupUI];
    
    [self.tableView reloadData];
}

- (void)setupUI
{
    [[self.sureBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       
        UploadInsuranceInfoVC * vc = [insuranceStoryboard instantiateViewControllerWithIdentifier:@"UploadInsuranceInfoVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)setupCalcHelper
{
    self.calcHelper = [[InsuranceCalcHelper alloc] init];
    self.calcHelper.carPrice = 250000;
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
                                                          coverage7,coverage8,coverage9,coverage10]];
    
    // 勾选
    for (HKCoverage * c in self.insuranceArry){
        
        NSNumber * cid = c.insId;
        NSNumber * filter = [self.selectInsurance firstObjectByFilteringOperator:^BOOL(NSNumber * num) {
            
            return [cid isEqualToNumber:num];
        }];
        
        if ([filter integerValue]){
            
            c.customFlag = YES;
            continue;
        }
        else{
            
            c.customFlag = NO;
        }
        
        if (c.isContainExcludingDeductible.customObject &&
            [c.isContainExcludingDeductible.customObject isKindOfClass:[HKCoverage class]]){
            
            HKCoverage * subCoverage = c.isContainExcludingDeductible.customObject;
            
            NSNumber * sid = subCoverage.insId;
            NSNumber * sFilter = [self.selectInsurance firstObjectByFilteringOperator:^BOOL(NSNumber * num) {
                
                return [sid isEqualToNumber:num];
            }];
            
            if ([sFilter integerValue]){
                
                subCoverage.customFlag = YES;
            }
            else{
                
                subCoverage.customFlag = NO;
            }
        }
    }
}

- (void)setupFlipNumberView
{
    self.flipNumberView.isDecimal = YES;
    self.flipNumberView.digitCount = 6;
    [self animateToTargetValue:(NSInteger)(self.totalPrice * 100)];
}

- (void)animateToTargetValue:(NSInteger)targetValue;
{
    [self.flipNumberView animateToValue:targetValue duration:1.0 completion:^(BOOL finished) {
        if (finished) {
            
            DebugLog(@"animateToTargetValue finish");
        } else {
            
            DebugLog(@"animateToTargetValue unfinish");
        }
    }];
}

- (void)calcTotalPrice
{
    // customObject 为险种HKCoverage
    // customFlag 为险种是否勾选
    CGFloat total = 0;
    CGFloat price = 0;
    CGFloat excludingDeductible = 0;
    for (HKCoverage * c in self.insuranceArry)
    {
        if (c.customFlag)
        {
            price = [self.calcHelper calcInsurancePrice:c];
            total = total + price;
            
            if (c.isContainExcludingDeductible.customObject &&
                [c.isContainExcludingDeductible.customObject isKindOfClass:[HKCoverage class]] &&
                c.isContainExcludingDeductible.customFlag){
                
                excludingDeductible = [self.calcHelper calcInsurancePrice:c.isContainExcludingDeductible.customObject];
                total = total + excludingDeductible;
            }
        }
    }
    self.totalPrice = total;
}

- (void)showActionSheet:(HKCoverage * )c
{
    UIActionSheet * as = [[UIActionSheet alloc] init];
    as.title = c.insName;
    [as setCancelButtonIndex:c.params.count];
    for (NSDictionary * dict in c.params)
    {
        [as addButtonWithTitle:dict[@"key"]];
    }
    [as addButtonWithTitle:@"取消"];
    [as showInView:self.view];
    [[as rac_buttonClickedSignal] subscribeNext:^(NSNumber * number) {
        
        NSInteger index = [number integerValue];
        for (NSDictionary * dict in c.params)
        {
            dict.customFlag = NO;
        }
        
        
        NSObject * obj = [c.params safetyObjectAtIndex:index];
        obj.customFlag = YES;
        
        //计算金额
        [self calcTotalPrice];
        [self animateToTargetValue:(NSInteger)(self.totalPrice * 100)];
        //刷新cell
        NSInteger i = [self.insuranceArry indexOfObject:c];
        NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:i + 1 inSection:0];
        NSArray * refreshArray ;
        if (c.customFlag && c.isContainExcludingDeductible)
        {
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:i + 2 inSection:0];
            refreshArray = @[indexPath1,indexPath2];
        }
        else
        {
            refreshArray = @[indexPath1];
        }
        [self.tableView reloadRowsAtIndexPaths:refreshArray withRowAnimation:UITableViewRowAnimationNone];
    }];
}


#pragma mark - TableView data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (indexPath.row == 1) {
        
        height = 48.0f;
    }
    else{
        
        height = 45.0f;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = 1 + self.insuranceArry.count;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"StaticInfoCell"];
    }
    else
    {
        NSInteger i = indexPath.row - 1;
        HKCoverage * coverage = [self.insuranceArry safetyObjectAtIndex:i];
        
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
            UILabel *priceLb = (UILabel *)[cell searchViewWithTag:104];
            
            insuranceNameLb.text = coverage.insName;
            CGFloat price = [self.calcHelper calcInsurancePrice:coverage];
            priceLb.text = [NSString stringWithFormat:@"%.2f",price];
            
            boxBtn.selected = coverage.customFlag;
            @weakify(boxBtn);
            [[[boxBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                @strongify(boxBtn);
                
                /**
                 *  先更新数据源，再刷新
                 */
                BOOL flag = boxBtn.selected;
                [boxBtn setSelected:!flag];
                coverage.customFlag = !flag;
                
                if ([coverage.isContainExcludingDeductible integerValue])
                {
                    if (coverage.customFlag == YES)
                    {
                        NSInteger index = [self.insuranceArry indexOfObject:coverage];
                        [self.insuranceArry safetyInsertObject:coverage.customObject atIndex:index + 1];
                        NSIndexPath * idxPath = [NSIndexPath indexPathForRow:1 + index + 1 inSection:indexPath.section];
                        [self.tableView insertRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationLeft];
                    }
                    else
                    {
                        NSInteger index = [self.insuranceArry indexOfObject:coverage.customObject];
                        [self.insuranceArry safetyRemoveObject:coverage.customObject];
                        NSIndexPath * idxPath = [NSIndexPath indexPathForRow: 1 + index inSection:indexPath.section];
                        [self.tableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationRight];
                    }
                }
                
                [self calcTotalPrice];
                [self animateToTargetValue:(NSInteger)(self.totalPrice * 100)];
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
            UILabel *priceLb = (UILabel *)[cell searchViewWithTag:104];
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
            CGFloat price = [self.calcHelper calcInsurancePrice:coverage];
            priceLb.text = [NSString stringWithFormat:@"%.2f",price];
            boxBtn.selected = coverage.customFlag;
            for (NSDictionary * obj in coverage.params)
            {
                if (obj.customFlag)
                    paramLb.text = [obj objectForKey:@"key"];
            }
            
            @weakify(boxBtn);
            [[[boxBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                @strongify(boxBtn);
                BOOL flag = boxBtn.selected;
                [boxBtn setSelected:!flag];
                coverage.customFlag = !flag;
                
                if ([coverage.isContainExcludingDeductible integerValue])
                {
                    if (coverage.customFlag == YES)
                    {
                        NSInteger index = [self.insuranceArry indexOfObject:coverage];
                        [self.insuranceArry safetyInsertObject:coverage.customObject atIndex:index + 1];
                        NSIndexPath * idxPath = [NSIndexPath indexPathForRow:1 + index + 1 inSection:indexPath.section];
                        [self.tableView insertRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationLeft];
                    }
                    else
                    {
                        NSInteger index = [self.insuranceArry indexOfObject:coverage.customObject];
                        [self.insuranceArry safetyRemoveObject:coverage.customObject];
                        NSIndexPath * idxPath = [NSIndexPath indexPathForRow: 1 + index inSection:indexPath.section];
                        [self.tableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationRight];
                    }
                }
                
                [self calcTotalPrice];
                [self animateToTargetValue:(NSInteger)(self.totalPrice * 100)];
            }];
        }
        else
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"SubInsuranceTypeA"];
            
            UIButton *boxBtn = (UIButton *)[cell searchViewWithTag:101];
            UILabel *insuranceNameLb = (UILabel *)[cell searchViewWithTag:102];
            UILabel *priceLb = (UILabel *)[cell searchViewWithTag:104];
            
            insuranceNameLb.text = coverage.insName;
            CGFloat price = [self.calcHelper calcInsurancePrice:coverage];
            priceLb.text = [NSString stringWithFormat:@"%.2f",price];
            
            boxBtn.selected = coverage.customFlag;
            @weakify(boxBtn);
            [[[boxBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                @strongify(boxBtn);
                BOOL flag = boxBtn.selected;
                [boxBtn setSelected:!flag];
                coverage.customFlag = !flag;
                
                [self calcTotalPrice];
                [self animateToTargetValue:(NSInteger)(self.totalPrice * 100)];
            }];
        }
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


@end

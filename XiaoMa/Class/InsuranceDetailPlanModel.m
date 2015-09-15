//
//  InsuranceDetailPlanModel.m
//  XiaoMa
//
//  Created by jt on 15/9/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceDetailPlanModel.h"
#import "HKCoverage.h"

@implementation InsuranceDetailPlanModel

- (instancetype)initWithSelectInsurance:(NSArray *)array andCarPrice:(CGFloat)price
{
    self  = [super init];
    if (self)
    {
        self.selectInsurance = array;
        self.carPrice = price;
        [self setupCalcHelper];
        [self setupInsuranceArray];
        
        [self calcTotalPrice];
        [self animateToTargetValue];
    }
    return self;
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
    for (NSNumber * cid in self.selectInsurance){
        
        HKCoverage * coverage = [self.insuranceArry firstObjectByFilteringOperator:^BOOL(HKCoverage * c) {
            
            return [cid isEqualToNumber:c.insId];
        }];
        
        if (coverage){
            
            coverage.customTag = YES;
            
            if ([coverage.isContainExcludingDeductible integerValue])
            {
                NSInteger index = [self.insuranceArry indexOfObject:coverage];
                [self.insuranceArry safetyInsertObject:coverage.isContainExcludingDeductible.customObject atIndex:index + 1];
            }
            continue;
        }
        else{
            
            coverage.customTag = NO;
        }
        
        if (coverage.isContainExcludingDeductible.customObject &&
            [coverage.isContainExcludingDeductible.customObject isKindOfClass:[HKCoverage class]]){
            
            HKCoverage * subCoverage = coverage.isContainExcludingDeductible.customObject;
            
            NSNumber * sid = subCoverage.insId;
            NSNumber * sFilter = [self.selectInsurance firstObjectByFilteringOperator:^BOOL(NSNumber * num) {
                
                return [sid isEqualToNumber:num];
            }];
            
            if ([sFilter integerValue]){
                
                subCoverage.customTag = YES;
            }
            else{
                
                subCoverage.customTag = NO;
            }
        }
    }
}

- (void)setupCalcHelper
{
    self.calcHelper = [[InsuranceCalcHelper alloc] init];
    self.calcHelper.carPrice = self.carPrice;
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
        if (c.customTag)
        {
            price = [self.calcHelper calcInsurancePrice:c];
            total = total + price;
            
            if (c.isContainExcludingDeductible.customObject &&
                [c.isContainExcludingDeductible.customObject isKindOfClass:[HKCoverage class]] &&
                c.isContainExcludingDeductible.customTag){
                
                excludingDeductible = [self.calcHelper calcInsurancePrice:c.isContainExcludingDeductible.customObject];
                total = total + excludingDeductible;
            }
        }
    }
    self.totalPrice = total;
}

- (void)showActionSheet:(HKCoverage * )c
{
    if (!self.tableView.superview)
        return;
    UIActionSheet * as = [[UIActionSheet alloc] init];
    as.title = c.insName;
    [as setCancelButtonIndex:c.params.count];
    for (NSDictionary * dict in c.params)
    {
        [as addButtonWithTitle:dict[@"key"]];
    }
    [as addButtonWithTitle:@"取消"];
    [as showInView:self.tableView.superview];
    [[as rac_buttonClickedSignal] subscribeNext:^(NSNumber * number) {
        
        NSInteger index = [number integerValue];
        for (NSDictionary * dict in c.params)
        {
            dict.customTag = NO;
        }
        
        
        NSObject * obj = [c.params safetyObjectAtIndex:index];
        obj.customTag = YES;
        
        //计算金额
        [self calcTotalPrice];
        [self animateToTargetValue];
        //刷新cell
        NSInteger i = [self.insuranceArry indexOfObject:c];
        NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:i + 1 inSection:0];
        NSArray * refreshArray ;
        if (c.customTag && c.isContainExcludingDeductible)
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

- (void)animateToTargetValue
{
    [self.flipNumberView animateToValue:(NSInteger)(self.totalPrice * 100) duration:1.0 completion:^(BOOL finished) {
        if (finished) {
            
            DebugLog(@"animateToTargetValue finish");
        } else {
            
            DebugLog(@"animateToTargetValue unfinish");
        }
    }];
}

- (void)noAnimateToTargetValue
{
    [self.flipNumberView setValue:(NSInteger)(self.totalPrice * 100) animated:1.0f];
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
            
            boxBtn.selected = coverage.customTag;
            @weakify(boxBtn);
            [[[boxBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                @strongify(boxBtn);
                
                /**
                 *  先更新数据源，再刷新
                 */
                BOOL flag = boxBtn.selected;
                [boxBtn setSelected:!flag];
                coverage.customTag = !flag;
                
                if ([coverage.isContainExcludingDeductible integerValue])
                {
                    if (coverage.customTag == YES)
                    {
                        NSInteger index = [self.insuranceArry indexOfObject:coverage];
                        [self.insuranceArry safetyInsertObject:coverage.isContainExcludingDeductible.customObject atIndex:index + 1];
                        NSIndexPath * idxPath = [NSIndexPath indexPathForRow:1 + index + 1 inSection:indexPath.section];
                        [self.tableView insertRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationLeft];
                    }
                    else
                    {
                        NSInteger index = [self.insuranceArry indexOfObject:coverage.customObject];
                        [self.insuranceArry safetyRemoveObject:coverage.isContainExcludingDeductible.customObject];
                        NSIndexPath * idxPath = [NSIndexPath indexPathForRow: 1 + index inSection:indexPath.section];
                        [self.tableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationRight];
                    }
                }
                
                [self calcTotalPrice];
                [self animateToTargetValue];
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
            boxBtn.selected = coverage.customTag;
            for (NSDictionary * obj in coverage.params)
            {
                if (obj.customTag)
                    paramLb.text = [obj objectForKey:@"key"];
            }
            
            @weakify(boxBtn);
            [[[boxBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                @strongify(boxBtn);
                BOOL flag = boxBtn.selected;
                [boxBtn setSelected:!flag];
                coverage.customTag = !flag;
                
                if ([coverage.isContainExcludingDeductible integerValue])
                {
                    if (coverage.customTag == YES)
                    {
                        NSInteger index = [self.insuranceArry indexOfObject:coverage];
                        [self.insuranceArry safetyInsertObject:coverage.isContainExcludingDeductible.customObject atIndex:index + 1];
                        NSIndexPath * idxPath = [NSIndexPath indexPathForRow:1 + index + 1 inSection:indexPath.section];
                        [self.tableView insertRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationLeft];
                    }
                    else
                    {
                        NSInteger index = [self.insuranceArry indexOfObject:coverage.isContainExcludingDeductible.customObject];
                        [self.insuranceArry safetyRemoveObject:coverage.isContainExcludingDeductible.customObject];
                        NSIndexPath * idxPath = [NSIndexPath indexPathForRow: 1 + index inSection:indexPath.section];
                        [self.tableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationRight];
                    }
                }
                
                [self calcTotalPrice];
                [self animateToTargetValue];
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
            
            boxBtn.selected = coverage.customTag;
            @weakify(boxBtn);
            [[[boxBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                @strongify(boxBtn);
                BOOL flag = boxBtn.selected;
                [boxBtn setSelected:!flag];
                coverage.customTag = !flag;
                
                [self calcTotalPrice];
                [self animateToTargetValue];
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

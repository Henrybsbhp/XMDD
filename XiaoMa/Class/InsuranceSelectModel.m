//
//  InsuranceSelectModel.m
//  XiaoMa
//
//  Created by jt on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsuranceSelectModel.h"
#import "HKCoverage.h"
#import "HKPickerVC.h"

@interface InsuranceSelectModel()

@property (nonatomic,strong)NSMutableArray * insuranceArry;
@property (nonatomic,strong)NSMutableArray * insuranceArry2;

@end

@implementation InsuranceSelectModel

- (void)dealloc
{
    DebugLog(@"InsuranceSelectModel dealloc");
}


- (void)setupInsuranceArray
{
    HKCoverage * coverage1 = [[HKCoverage alloc] initWithCategory:InsuranceCompulsory];
    HKCoverage * coverage2 = [[HKCoverage alloc] initWithCategory:InsuranceTravelTax];
    HKCoverage * coverage3 = [[HKCoverage alloc] initWithCategory:InsuranceCarDamage];
    HKCoverage * coverage4 = [[HKCoverage alloc] initWithCategory:InsuranceThirdPartyLiability];
    HKCoverage * coverage5 = [[HKCoverage alloc] initWithCategory:InsuranceCarSeatInsuranceOfDriver];
    /// 2.5需求，座位数不是写死
//    HKCoverage * coverage6 = [[HKCoverage alloc] initWithInsuranceCarSeatInsuranceOfPassengerWithNumOfSeat:self.numOfSeat];
    HKCoverage * coverage7 = [[HKCoverage alloc] initWithCategory:InsuranceWholeCarStolen];
    HKCoverage * coverage8 = [[HKCoverage alloc] initWithCategory:InsuranceSeparateGlassBreakage];
    HKCoverage * coverage9 = [[HKCoverage alloc] initWithCategory:InsuranceSpontaneousLossRisk];
    HKCoverage * coverage10 = [[HKCoverage alloc] initWithCategory:InsuranceWaterLoss];
    HKCoverage * coverage11 = [[HKCoverage alloc] initWithCategory:InsuranceCarBodyScratches];
    self.insuranceArry = [NSMutableArray arrayWithArray:@[coverage1,coverage2,coverage3,coverage4,coverage5,coverage7]];
    self.insuranceArry2 = [NSMutableArray arrayWithArray:@[coverage8,coverage9,coverage10,coverage11]];
    
    [self setupSelectIns];
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
//    if (c.params2)
//    {
//        [array safetyAddObject:c.params2];
//        NSObject * obj = [c.params2 firstObjectByFilteringOperator:^BOOL(NSObject * obj) {
//            
//            return obj.customTag;
//        }];
//        [select safetyAddObject:obj];
//    }
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 45.0f;
    return height;
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
    
    ///没选择
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
                
                NSMutableArray * parentArray = [self.insuranceArry containsObject:coverage] ? self.insuranceArry : self.insuranceArry2;
                
                if (coverage.customTag == YES)
                {
                    subCoverage.customTag = [self needSelectExcludingDeductible:subCoverage];
                    NSInteger index = [parentArray indexOfObject:coverage];
                    [parentArray safetyInsertObject:coverage.excludingDeductibleCoverage atIndex:index + 1];
                    NSIndexPath * idxPath = [NSIndexPath indexPathForRow:index + 1 inSection:indexPath.section];
                    [self.tableView insertRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationLeft];
                }
                else
                {
                    NSInteger index = [parentArray indexOfObject:coverage.excludingDeductibleCoverage];
                    [parentArray safetyRemoveObject:coverage.excludingDeductibleCoverage];
                    NSIndexPath * idxPath = [NSIndexPath indexPathForRow:index inSection:indexPath.section];
                    [self.tableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationRight];
                }
            }
        }];
    }
    /// 有选择
    else if (coverage.insCategory == InsuranceThirdPartyLiability ||
             coverage.insCategory == InsuranceCarSeatInsuranceOfDriver ||
             coverage.insCategory == InsuranceCarSeatInsuranceOfPassenger ||
             coverage.insCategory == InsuranceSeparateGlassBreakage||
             coverage.insCategory == InsuranceCarBodyScratches)
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
        paramLb.text = [coverage coverageAmountDesc];
        
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
                
                NSMutableArray * parentArray = [self.insuranceArry containsObject:coverage] ? self.insuranceArry : self.insuranceArry2;
                
                if (coverage.customTag == YES)
                {
                    subCoverage.customTag = [self needSelectExcludingDeductible:subCoverage];
                    NSInteger index = [parentArray indexOfObject:coverage];
                    [parentArray safetyInsertObject:coverage.excludingDeductibleCoverage atIndex:index + 1];
                    NSIndexPath * idxPath = [NSIndexPath indexPathForRow:index + 1 inSection:indexPath.section];
                    [self.tableView insertRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationLeft];
                }
                else
                {
                    NSInteger index = [parentArray indexOfObject:coverage.excludingDeductibleCoverage];
                    [parentArray safetyRemoveObject:coverage.excludingDeductibleCoverage];
                    NSIndexPath * idxPath = [NSIndexPath indexPathForRow:index inSection:indexPath.section];
                    [self.tableView deleteRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationRight];
                }
            }
        }];
    }
    /// 不计免赔
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
- (BOOL)needSelectExcludingDeductible:(HKCoverage *)c
{
    if (c.insCategory == InsuranceExcludingDeductible4CarDamage ||
        c.insCategory == InsuranceExcludingDeductible4ThirdPartyLiability ||
        c.insCategory == InsuranceExcludingDeductible4CarSeatInsuranceOfDriver ||
        c.insCategory == InsuranceExcludingDeductible4CarSeatInsuranceOfPassenger ||
        c.insCategory == InsuranceExcludingDeductible4CarBodyScratches ||
        c.insCategory == InsuranceExcludingDeductible4SpontaneousLossRisk)
    {
        return YES;
    }
    else if (c.insCategory == InsuranceExcludingDeductible4WholeCarStolen)
    {
        return NO;
    }
    return c.customTag;
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
                    paramText = [paramText stringByReplacingOccurrencesOfString:@"/座" withString:@""];
                    break;
                }
            }
//            for (NSDictionary * obj in c.params2)
//            {
//                if (obj.customTag)
//                {
//                    paramText = [paramText append:@" "];
//                    paramText = [paramText append:[obj objectForKey:@"key"]];
//                    break;
//                }
//            }
            paramText = paramText.length ? paramText : @"0";
            NSString * s = [NSString stringWithFormat:@"%@@%@",c.insId,paramText];
            [array safetyAddObject:s];
        }
    }


    return array;
}

- (void)setupSelectIns
{
    // 勾选
    for (NSNumber * cid in self.selectInsurance){
        
        HKCoverage * coverage = [self.insuranceArry firstObjectByFilteringOperator:^BOOL(HKCoverage * c) {
            
            return [cid isEqualToNumber:c.insId];
        }];
        
        if (coverage){
            
            coverage.customTag = YES;
            
            if (coverage.excludingDeductibleCoverage)
            {
                NSInteger index = [self.insuranceArry indexOfObject:coverage];
                [self.insuranceArry safetyInsertObject:coverage.excludingDeductibleCoverage atIndex:index + 1];
            }
            continue;
        }
        else{
            
            coverage.customTag = NO;
        }
        
        if (coverage.excludingDeductibleCoverage){
            
            HKCoverage * subCoverage = coverage.excludingDeductibleCoverage;
            
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

@end

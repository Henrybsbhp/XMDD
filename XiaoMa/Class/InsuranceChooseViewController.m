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
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupUI
{
    [[self.sureBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        InsuranceResultVC *resultVC = [UIStoryboard vcWithId:@"InsuranceResultVC" inStoryboard:@"Insurance"];
        [resultVC setResultType:(arc4random() % 3)];
        [self.navigationController pushViewController:resultVC animated:YES];
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
        
        NSInteger i;
        NSIndexPath *indexPath1;
        //刷新cell
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
        if (c.customFlag && c.isContainExcludingDeductible)
        {
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:i + 1 inSection:0];
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
                    NSIndexPath * idxPath = [NSIndexPath indexPathForRow:index + 1 inSection:indexPath.section];
                    [self.tableView insertRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationLeft];
                }
                else
                {
                    NSInteger index = [self.insuranceArry indexOfObject:coverage.customObject];
                    [self.insuranceArry safetyRemoveObject:coverage.customObject];
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
                    NSIndexPath * idxPath = [NSIndexPath indexPathForRow:index + 1 inSection:indexPath.section];
                    [self.tableView insertRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationLeft];
                }
                else
                {
                    NSInteger index = [self.insuranceArry indexOfObject:coverage.customObject];
                    [self.insuranceArry safetyRemoveObject:coverage.customObject];
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
        
        boxBtn.selected = coverage.customFlag;
        @weakify(boxBtn);
        [[[boxBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(boxBtn);
            BOOL flag = boxBtn.selected;
            [boxBtn setSelected:!flag];
            coverage.customFlag = !flag;
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



@end

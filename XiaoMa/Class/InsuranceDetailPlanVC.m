//
//  InsuranceDetailPlanVC.m
//  XiaoMa
//
//  Created by jt on 15/7/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceDetailPlanVC.h"
#import "JDFlipNumberView.h"
#import "HKInsurance.h"

#define CheckBoxInsuranceGroup @"CheckBoxInsuranceGroup"

@interface InsuranceDetailPlanVC()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)JDFlipNumberView * flipNumberView;

@property (nonatomic,strong)NSArray * insuranceArry;
@property (nonatomic, strong) CKSegmentHelper *checkBoxHelper;
@property (nonatomic)CGFloat totalPrice;

@end

@implementation InsuranceDetailPlanVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SubInsurance * i1 = [[SubInsurance alloc] init];
    i1.coveragerName = @"车损险";
    i1.coveragerPrice = 2900.12;
    i1.customTag = 1;
    i1.type = 1;
    
    SubInsurance * i2 = [[SubInsurance alloc] init];
    i2.coveragerName = @"车船税";
    i2.coveragerPrice = 390.00;
    i2.customTag = 1;
    i2.type = 1;
    
    SubInsurance * i3 = [[SubInsurance alloc] init];
    i3.coveragerName = @"玻璃险";
    i3.coveragerPrice = 300.12;
    i3.customTag = 1;
    i3.type = 1;
    
    SubInsurance * i4 = [[SubInsurance alloc] init];
    i4.coveragerName = @"交强险";
    i4.coveragerPrice = 480.96;
    i4.customTag = 1;
    i4.type = 1;
    
    SubInsurance * i5 = [[SubInsurance alloc] init];
    i5.coveragerName = @"第三方责任险";
    i5.coveragerPrice = 600.67;
    i5.customTag = 1;
    i5.type = 2;

    self.insuranceArry = @[i1,i2,i3,i4,i5];
    
    [self setupCheckBoxHelper];
    
    [self.tableView reloadData];
}

- (void)setupCheckBoxHelper
{
    
}

- (void)calcTotalPrice
{
    self.totalPrice = 0;
    for (SubInsurance * i in  self.insuranceArry)
    {
        BOOL select = i.customTag;
        CGFloat price = i.coveragerPrice;
        if (select)
        {
            self.totalPrice = self.totalPrice + price;
        }
    }
}

- (void)animateToTargetValue:(NSInteger)targetValue;
{
    
    NSDate *startDate = [NSDate date];
    [self.flipNumberView animateToValue:targetValue duration:1.3 completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"Animation needed: %.2f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);
        } else {
            NSLog(@"Animation canceled after: %.2f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);
        }
    }];
}


#pragma mark - TableView data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (indexPath.row == 0) {
        
        height = 80.0f;
    }
    else if (indexPath.row == 1) {
        
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
    
    NSInteger count = self.insuranceArry.count + 2;
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
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TotalPriceCell"];
        
        JDFlipNumberView * numberV = (JDFlipNumberView *)[cell searchViewWithTag:101];
        numberV.digitCount = 5;
        self.flipNumberView = numberV;
        
        [self calcTotalPrice];
        [self animateToTargetValue:(int)self.totalPrice];
    }
    else if (indexPath.row == 1) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"StaticInfoCell"];
    }
    else
    {
        SubInsurance * insurace = [self.insuranceArry safetyObjectAtIndex:indexPath.row - 2];
        if (insurace.type == 1)
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"InsuranceTypeA"];
            
            UIButton *boxBtn = (UIButton *)[cell searchViewWithTag:101];
            UILabel *insuranceNameLb = (UILabel *)[cell searchViewWithTag:102];
            UILabel *priceLb = (UILabel *)[cell searchViewWithTag:104];
            
            insuranceNameLb.text = insurace.coveragerName;
            priceLb.text = [NSString stringWithFormat:@"%.2f",insurace.coveragerPrice];
            
            boxBtn.selected = insurace.customTag;
            @weakify(boxBtn);
            [[[boxBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                @strongify(boxBtn);
                BOOL flag = boxBtn.selected;
                [boxBtn setSelected:!flag];
                insurace.customTag = !flag;
                
                [self calcTotalPrice];
                [self animateToTargetValue:(int)self.totalPrice];
            }];
        }
        else
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"InsuranceTypeB"];
            
            UIButton *boxBtn = (UIButton *)[cell searchViewWithTag:101];
            UILabel *insuranceNameLb = (UILabel *)[cell searchViewWithTag:102];
            UILabel *priceLb = (UILabel *)[cell searchViewWithTag:104];
            
            insuranceNameLb.text = insurace.coveragerName;
            priceLb.text = [NSString stringWithFormat:@"%.2f",insurace.coveragerPrice];
            
            boxBtn.selected = insurace.customTag;
            @weakify(boxBtn);
            [[[boxBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                @strongify(boxBtn);
                BOOL flag = boxBtn.selected;
                [boxBtn setSelected:!flag];
                insurace.customTag = !flag;
                
                [self calcTotalPrice];
                [self animateToTargetValue:(int)self.totalPrice];
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

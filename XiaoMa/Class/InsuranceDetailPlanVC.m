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
#import "InsuranceResultVC.h"
#import "CCSegmentedControl.h"
#import "InsuranceDetailPlanModel.h"
#import "HKInsurance.h"

#define CheckBoxInsuranceGroup @"CheckBoxInsuranceGroup"

@interface InsuranceDetailPlanVC()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet JDFlipNumberView *flipNumberView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet CCSegmentedControl *segmentedControl;
@property (nonatomic,strong)CKSegmentHelper *checkBoxHelper;

@property (strong,nonatomic)NSMutableArray * modelArray;

@property (nonatomic,strong)InsuranceDetailPlanModel * currentModel;
@property (nonatomic)NSInteger selectIndex;

@end

@implementation InsuranceDetailPlanVC

- (void)awakeFromNib
{
     [self setupSegmentControl];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // UI
    [self setupUI];
    [self setupSegmentControl];
    [self setupFlipNumberView];
    
    //处理绑定
    //    RAC(<#TARGET, ...#>)
    //数据
    [self setupModel];
    
    [self.tableView reloadData];
}


- (void)setupSegmentControl
{
    [self.segmentedControl commonInit];
    [self.planArray enumerateObjectsUsingBlock:^(HKInsurance * ins, NSUInteger idx, BOOL *stop) {
        
        [self.segmentedControl insertSegmentWithTitle:ins.insuranceName atIndex:idx animated:NO];
    }];
    
    UIView * v = [[UIView alloc] init];
    v.backgroundColor = [UIColor orangeColor];
    self.segmentedControl.selectedStainView = v;
    
    self.segmentedControl.selectedSegmentTextColor = [UIColor whiteColor];
    self.segmentedControl.segmentTextColor = [UIColor colorWithHex:@"#e2e2e2" alpha:1.0f];
    [self.segmentedControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
}



- (void)setupUI
{
    [[self.sureBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       
        UploadInsuranceInfoVC * vc = [insuranceStoryboard instantiateViewControllerWithIdentifier:@"UploadInsuranceInfoVC"];
        vc.allowSkip = NO;
        [self.navigationController pushViewController:vc animated:YES];
        [vc setFinishBlock:^UIViewController *(BOOL skip, UIViewController *targetvc) {
            InsuranceResultVC *vc = [UIStoryboard vcWithId:@"InsuranceResultVC" inStoryboard:@"Insurance"];
            return vc;
        }];
    }];
}



- (void)setupFlipNumberView
{
    self.flipNumberView.isDecimal = YES;
    self.flipNumberView.digitCount = 6;
}

- (void)setupModel
{
    self.modelArray = [NSMutableArray array];
    for (HKInsurance * ins in self.planArray)
    {
        NSMutableArray * selectIns = [NSMutableArray array];
        for (SubInsurance * subIns in ins.subInsuranceArray)
        {
            [selectIns safetyAddObject:@(subIns.coveragerId)];
        }
        InsuranceDetailPlanModel * model = [[InsuranceDetailPlanModel alloc] initWithSelectInsurance:selectIns andCarPrice:self.carPrice];
        model.tableView = self.tableView;
        model.flipNumberView = self.flipNumberView;
        [self.modelArray safetyAddObject:model];
    }
    InsuranceDetailPlanModel * model = [self.modelArray safetyObjectAtIndex:self.selectIndex];
    self.currentModel = model;
    
    [self switchDatasource:model];
}


#pragma mark - Utility
- (void)segmentValueChanged:(id)sender
{
    CCSegmentedControl* segmentedControl = sender;
    self.selectIndex = segmentedControl.selectedSegmentIndex;
    InsuranceDetailPlanModel * model = [self.modelArray safetyObjectAtIndex:self.selectIndex];
    self.currentModel = model;
    [self switchDatasource:model];
}

- (void)switchDatasource:(InsuranceDetailPlanModel *)model
{
    [model noAnimateToTargetValue];
    
    self.tableView.dataSource = model;
    self.tableView.delegate = model;
    
    [self.tableView reloadData];
}

@end

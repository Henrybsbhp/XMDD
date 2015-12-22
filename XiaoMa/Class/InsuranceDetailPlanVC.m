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
#import "InsuranceInfoSubmitingVC.h"
#import "InsuranceResultVC.h"
#import "CCSegmentedControl.h"
#import "InsuranceDetailPlanModel.h"
#import "HKInsurance.h"

#define CheckBoxInsuranceGroup @"CheckBoxInsuranceGroup"

@interface InsuranceDetailPlanVC()

@property (strong, nonatomic) IBOutlet UIView *vview;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet JDFlipNumberView *flipNumberView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet CCSegmentedControl *segmentedControl;

@property (strong,nonatomic)NSMutableArray * modelArray;

@property (nonatomic,strong)InsuranceDetailPlanModel * currentModel;
@property (nonatomic)NSInteger selectIndex;

@end

@implementation InsuranceDetailPlanVC

- (void)awakeFromNib
{
     [self setupSegmentControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp117"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp117"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // UI
    [self setupUI];
    [self setupSegmentControl];
    [self setupFlipNumberView];
    
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
    self.segmentedControl.segmentTextColor = [UIColor darkGrayColor];
    [self.segmentedControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
}



- (void)setupUI
{
    [[self.sureBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
    
        [MobClick event:@"rp117-7"];
        if (![self.currentModel inslistForVC].count)
        {
            [gToast showError:@"请至少选择一个车险"];
            return ;
        }
        
        InsuranceInfoSubmitingVC * vc = [insuranceStoryboard instantiateViewControllerWithIdentifier:@"InsuranceInfoSubmitingVC"];
//        vc.submitModel = InsuranceInfoSubmitForEnquiry;
//        vc.calculatorOp = self.calculatorOp;
//        vc.insuranceList = [[self.currentModel inslistForVC] componentsJoinedByString:@"|"];
        [self.navigationController pushViewController:vc animated:YES];
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
        InsuranceDetailPlanModel * model = [[InsuranceDetailPlanModel alloc] initWithSelectInsurance:selectIns andCarPrice:[self.calculatorOp.req_purchaseprice floatValue] * 10000];
        model.tableView = self.tableView;
        model.view = self.view;
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
    [MobClick event:@"rp117-6"];
    CCSegmentedControl* segmentedControl = sender;
    self.selectIndex = segmentedControl.selectedSegmentIndex;
    InsuranceDetailPlanModel * model = [self.modelArray safetyObjectAtIndex:self.selectIndex];
    self.currentModel = model;
    [self switchDatasource:model];
}

- (void)switchDatasource:(InsuranceDetailPlanModel *)model
{
    if (self.modelArray.lastObject != model)
    {
        [model setupInsuranceArray];
    }
    [model calcTotalPrice];
    [model noAnimateToTargetValue];
    
    self.tableView.dataSource = model;
    self.tableView.delegate = model;
    
    [self.tableView reloadData];
}

@end

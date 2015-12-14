//
//  InsuranceSelectViewController.m
//  XiaoMa
//
//  Created by jt on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsuranceSelectViewController.h"
#import "CCSegmentedControl.h"
#import "InsuranceSelectModel.h"
#import "GetInsuranceCalculatorOpV3.h"
#import "CalculateInsuranceCarPremiumOp.h"
#import "HKInsurance.h"

@interface InsuranceSelectViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CCSegmentedControl *segmentedView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@property (strong,nonatomic)NSMutableArray * modelArray;

@property (nonatomic,strong)InsuranceSelectModel * currentModel;
@property (nonatomic)NSInteger selectIndex;


@property (nonatomic,strong)NSArray * planArray;

@end

@implementation InsuranceSelectViewController

- (void)dealloc
{
    DebugLog(@"InsuranceSelectViewController dealloc");
}

- (void)awakeFromNib
{
    [self setupSegmentControl];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UI
    [self setupUI];
    
    //数据
    [self requestInsurancePlan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Setup
- (void)setupSegmentControl
{
    self.segmentedView.hidden = YES;
    [self.segmentedView commonInit];
    [self.planArray enumerateObjectsUsingBlock:^(HKInsurance * ins, NSUInteger idx, BOOL *stop) {
        
        [self.segmentedView insertSegmentWithTitle:ins.insuranceName atIndex:idx animated:NO];
    }];
    
    UIView * v = [[UIView alloc] init];
    v.backgroundColor = [UIColor colorWithHex:@"#20ab2a" alpha:1.0f];
    self.segmentedView.selectedStainView = v;
    
    self.segmentedView.selectedSegmentTextColor = [UIColor whiteColor];
    self.segmentedView.segmentTextColor = [UIColor darkGrayColor];
    [self.segmentedView addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.segmentedView.hidden = NO;
}

- (void)setupUI
{
    [[self.sureBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        if (![self.currentModel inslistForVC].count)
        {
            [gToast showError:@"请至少选择一个车险"];
            return;
        }
        [self requestCalculatePremium];
    }];
    
    self.navigationItem.title = @"选择车险";
}

#pragma mark - Network
- (RACSignal *)rac_getInsurance
{
    GetInsuranceCalculatorOpV3 * op = [GetInsuranceCalculatorOpV3 operation];
    op.req_city = @"aaa";
    return [op rac_postRequest];
}



#pragma mark - Utility
- (void)segmentValueChanged:(id)sender
{
    CCSegmentedControl* segmentedControl = sender;
    self.selectIndex = segmentedControl.selectedSegmentIndex;
    InsuranceSelectModel * model = [self.modelArray safetyObjectAtIndex:self.selectIndex];
    self.currentModel = model;
    [self switchDatasource:model];
}

- (void)switchDatasource:(InsuranceSelectModel *)model
{
    self.tableView.dataSource = model;
    self.tableView.delegate = model;
    
    [self.tableView reloadData];
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
        InsuranceSelectModel * model = [[InsuranceSelectModel alloc] init];
        model.tableView = self.tableView;
        model.view = self.view;
        model.selectInsurance = selectIns;
        model.numOfSeat = self.numOfSeat;
        [model setupInsuranceArray];
        [self.modelArray safetyAddObject:model];
    }
    InsuranceSelectModel * model = [self.modelArray safetyObjectAtIndex:self.selectIndex];
    self.currentModel = model;
    
    [self switchDatasource:model];
}

- (void)requestInsurancePlan
{
    RACSignal * signal = [self rac_getInsurance];
    [[signal initially:^{
        
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(GetInsuranceCalculatorOpV3 * rspOp) {
        
        NSMutableArray * array = [NSMutableArray arrayWithArray:rspOp.rsp_insuraceArray];
        HKInsurance * ins = [[HKInsurance alloc] init];
        ins.insuranceName = @"自选";
        [array safetyAddObject:ins];
        
        self.planArray = array;
        [self setupModel];
        
        [self setupSegmentControl];
        
        [self.view stopActivityAnimation];
    } error:^(NSError *error) {
        
        @weakify(self)
        [self.view showDefaultEmptyViewWithText:@"保险方案获取失败，点击重试" tapBlock:^{
            @strongify(self);
            [self requestInsurancePlan];
        }];
        [self.view stopActivityAnimation];
    }];
}

- (void)requestCalculatePremium
{
    CalculateInsuranceCarPremiumOp * op = [[CalculateInsuranceCarPremiumOp alloc] init];
    op.carPremiumId = self.premiumId;
    op.inslist = [[self.currentModel inslistForVC] componentsJoinedByString:@"|"];
    
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        
    }];
}

@end

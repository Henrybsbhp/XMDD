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
#import "HKInsurance.h"
#import "CKLine.h"

#import "GetInsuranceCalculatorOpV3.h"
#import "CalculatePremiumOp.h"

#import "InsActivityIndicatorVC.h"
#import "InsCheckResultsVC.h"
#import "InsAppointmentSuccessVC.h"
#import "InsCheckFailVC.h"

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
    self.segmentedView.backgroundColor = [UIColor whiteColor];
    [self.planArray enumerateObjectsUsingBlock:^(HKInsurance * ins, NSUInteger idx, BOOL *stop) {
        
        [self.segmentedView insertSegmentWithTitle:ins.insuranceName atIndex:idx animated:NO];
    }];
    
    UIView * v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor colorWithHex:@"#20ab2a" alpha:1.0f];
    self.segmentedView.selectedStainView = v;
    self.segmentedView.selectedSegmentTextColor = [UIColor whiteColor];
    self.segmentedView.segmentTextColor = [UIColor darkGrayColor];
    [self.segmentedView addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.segmentedView.hidden = NO;
}

#pragma mark - Action
- (IBAction)actionNext:(id)sender
{
    if (![self.currentModel inslistForVC].count)
    {
        [gToast showError:@"请至少选择一个车险"];
    }
    else if (self.selectMode == InsuranceSelectModeBuy) {
        [self requestCalculatePremium];
    }
    else {
        [self requestAppointment];
    }
}

#pragma mark - Network
- (RACSignal *)rac_getInsurance
{
    GetInsuranceCalculatorOpV3 * op = [GetInsuranceCalculatorOpV3 operation];
    return [op rac_postRequest];
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
    CalculatePremiumOp * op = [CalculatePremiumOp operation];
    op.req_carpremiumid = self.insModel.simpleCar.carpremiumid;
    op.req_inslist = [[self.currentModel inslistForVC] componentsJoinedByString:@"|"];

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
        if ([self.navigationController.topViewController isEqual:self]) {
            InsCheckResultsVC *vc = [UIStoryboard vcWithId:@"InsCheckResultsVC" inStoryboard:@"Insurance"];
            vc.insModel = self.insModel;
            vc.premiumList = op.rsp_premiumlist;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } error:^(NSError *error) {

        @strongify(self);
        if ([self.navigationController.topViewController isEqual:self]) {
            InsCheckFailVC *vc = [UIStoryboard vcWithId:@"InsCheckFailVC" inStoryboard:@"Insurance"];
            vc.insModel = self.insModel;
            vc.errmsg = error.domain;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (void)requestAppointment
{
    self.appointmentOp.req_inslist = [[self.currentModel inslistForVC] componentsJoinedByString:@"|"];
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
            [selectIns safetyAddObject:subIns.coveragerId];
        }
        InsuranceSelectModel * model = [[InsuranceSelectModel alloc] init];
        model.tableView = self.tableView;
        model.view = self.view;
        model.selectInsurance = selectIns;
        model.numOfSeat = self.selectMode==InsuranceSelectModeAppointment ? nil : @(MAX(1, [self.insModel.numOfSeat integerValue] - 1));
        [model setupInsuranceArray];
        [self.modelArray safetyAddObject:model];
    }
    InsuranceSelectModel * model = [self.modelArray safetyObjectAtIndex:self.selectIndex];
    self.currentModel = model;
    
    [self switchDatasource:model];
}




@end

//
//  InsuranceEnquiryVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/18.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceEnquiryVC.h"
#import "UIView+Shake.h"
#import "InsuranceDetailPlanVC.h"
#import "GetInsuranceDiscountOp.h"
#import "GetInsuranceCalculatorOpV2.h"
#import "CKLimitTextField.h"

@interface InsuranceEnquiryVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet CKLimitTextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *placeholdLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation InsuranceEnquiryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp115"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp115"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI
{
    self.textField.textLimit = 7;
    self.textField.regexpPattern = @"^\\d+$|^\\d*\\.\\d{0,2}";
    @weakify(self);
    [self.textField setDidBeginEditingBlock:^(CKLimitTextField *field) {
        [MobClick event:@"rp115-5"];
        @strongify(self);
        [self.placeholdLabel setHidden:YES animated:YES];
    }];
    
    [self.textField setDidEndEditingBlock:^(CKLimitTextField *field) {
        @strongify(self);
        if (field.text.length == 0) {
            [self.placeholdLabel setHidden:NO animated:YES];
        }
    }];
}
#pragma mark - Action
- (IBAction)actionEnquiry:(id)sender
{
    [MobClick event:@"rp115-7"];
    if (self.textField.text.length == 0 || [self.textField.text floatValue] == 0) {
        [self.containerView shake];
        return;
    }
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        
        RACSignal * signal;
        if (gAppMgr.discountRateDict){
            signal = [self rac_getInsurance];
        }
        else{
            signal = [self rac_getDiscountAndInsurance];
        }
        @weakify(self);
        [[signal initially:^{
            
            [gToast showingWithText:@"正在查询..."];
        }] subscribeNext:^(GetInsuranceCalculatorOpV2 *rspOp) {
            
            @strongify(self);
            InsuranceDetailPlanVC * vc = [insuranceStoryboard instantiateViewControllerWithIdentifier:@"InsuranceDetailPlanVC"];
            NSMutableArray * array = [NSMutableArray arrayWithArray:rspOp.rsp_insuraceArray];
            HKInsurance * ins = [[HKInsurance alloc] init];
            ins.insuranceName = @"自选";
            [array safetyAddObject:ins];
            
            vc.calculatorOp = rspOp;
            vc.planArray = array;
            [self.navigationController pushViewController:vc animated:YES];
            [gToast dismiss];
        } error:^(NSError *error) {
            [gToast showError:error.domain];
        }];
    }
}

#pragma mark - LoadData
- (RACSignal *)rac_getDiscountAndInsurance
{
    RACSignal * signal;
    GetInsuranceDiscountOp * op = [GetInsuranceDiscountOp operation];
    
    signal = [[op rac_postRequest] flattenMap:^RACStream *(GetInsuranceDiscountOp * getInsuranceDiscountOp) {
        
        GetInsuranceDiscountOp * op = getInsuranceDiscountOp;
        NSArray * array = op.rsp_dicInsurance;
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        for (InsuranceDiscount * d in array)
        {
            [dict safetySetObject:@(d.discountrate) forKey:@(d.pid)];
        }
        gAppMgr.discountRateDict = [NSDictionary dictionaryWithDictionary:dict];
        
        return [self rac_getInsurance];
    }];
    
    return signal;
}

- (RACSignal *)rac_getInsurance
{
    GetInsuranceCalculatorOpV2 * op = [GetInsuranceCalculatorOpV2 operation];
    op.req_purchaseprice = self.textField.text;
    
    return [op rac_postRequest];
}


@end

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

@interface InsuranceEnquiryVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *placeholdLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation InsuranceEnquiryVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)actionEnquiry:(id)sender
{
    if (self.textField.text.length == 0 || [self.textField.text integerValue] == 0) {
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

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.placeholdLabel setHidden:YES animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0) {
        [self.placeholdLabel setHidden:NO animated:YES];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.text.length > 0) {
        textField.text = [NSString stringWithInteger:[textField.text integerValue]];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger len = range.location + [string length] - range.length;
    if (len > 6) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.placeholdLabel setHidden:NO animated:YES];
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

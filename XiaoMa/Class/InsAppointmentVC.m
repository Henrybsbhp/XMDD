//
//  InsAppointmentVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/11.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsAppointmentVC.h"
#import "HKCellData.h"
#import "HKSubscriptInputField.h"
#import "InsCouponView.h"
#import "NSString+Format.h"
#import "InsuranceAppointmentV2Op.h"
#import "GetPremiumDetailOp.h"

#import "DatePickerVC.h"
#import "InsAlertVC.h"
#import "InsAppointmentSuccessVC.h"

@interface InsAppointmentVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) DatePickerVC *datePicker;
@property (nonatomic, strong) GetPremiumDetailOp *premiumDetail;
@property (nonatomic, strong) InsuranceAppointmentV2Op *appointInfo;
@end

@implementation InsAppointmentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.insModel.inscompname;
    [self setupDatePicker];
    CKAsyncMainQueue(^{
        [self requestDetailPremium];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置日期选择控件（主要是为了事先加载，优化性能）
- (void)setupDatePicker {
    self.datePicker = [DatePickerVC datePickerVCWithMaximumDate:nil];
}
#pragma mark - Request
- (void)requestDetailPremium
{
    GetPremiumDetailOp *op = [GetPremiumDetailOp operation];
    op.req_carpremiumid = self.insModel.simpleCar.carpremiumid;
    op.req_inscomp = self.insModel.inscomp;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        @strongify(self);
        self.containerView.hidden = YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        self.containerView.hidden = NO;
        self.premiumDetail = x;
        [self reloadData];
    } error:^(NSError *error) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        [self.view showDefaultEmptyViewWithText:@"获取详情失败，点击重试" tapBlock:^{
            @strongify(self);
            [self requestDetailPremium];
        }];
    }];
}

#pragma Datasource
- (void)reloadData
{
    self.appointInfo = [InsuranceAppointmentV2Op operation];
    self.appointInfo.req_ownername = self.premiumDetail.rsp_ownername ? self.premiumDetail.rsp_ownername : self.insModel.realName;
    self.appointInfo.req_carpremiumid = self.premiumDetail.req_carpremiumid;
    self.appointInfo.req_startdate = self.premiumDetail.rsp_startdate;
    self.appointInfo.req_forcestartdate = self.premiumDetail.rsp_fstartdate;
    
    HKCellData *infoCell = [HKCellData dataWithCellID:@"Info" tag:nil];
    if (self.premiumDetail.rsp_fstartdate.length > 0) {
        infoCell.customInfo[@"lockfdate"] = @YES;
    }
    [infoCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 310;
    }];
    
    HKCellData *sectionCell = [HKCellData dataWithCellID:@"Title" tag:nil];
    [sectionCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 35;
    }];
    HKCellData *couponsCell = [HKCellData dataWithCellID:@"Coupon" tag:nil];
    couponsCell.object = self.insPremium.couponlist;
    @weakify(self);
    [couponsCell setHeightBlock:^CGFloat(UITableView *tableView) {
        @strongify(self);
        return [InsCouponView heightWithCouponCount:self.insPremium.couponlist.count buttonHeight:30];
    }];
    self.datasource = @[infoCell, sectionCell, couponsCell];
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionAppoint:(id)sender
{
    if (self.appointInfo.req_startdate.length == 0) {
        [gToast showText:@"商业险起保日不能为空"];
    }
    else if (self.appointInfo.req_forcestartdate.length == 0) {
        [gToast showText:@"交强险起保日不能为空"];
    }
    else if (self.appointInfo.req_ownername.length  == 0) {
        [gToast showText:@"投保人姓名不能为空"];
    }
    else if (self.appointInfo.req_idcard.length != 18) {
        [gToast showText:@"身份证号码必须为18位"];
    }
    else {
        @weakify(self);
        [[[self.appointInfo rac_postRequest] initially:^{
            
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
}
#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource objectAtIndex:indexPath.row];
    if (data.heightBlock) {
        return data.heightBlock(tableView);
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Info" tag:nil]) {
        [self resetBaseInfoCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Coupon" tag:nil]){
        [self resetCouponCell:cell forData:data];
    }
    return cell;
}

- (void)resetBaseInfoCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UIImageView *logoV = [cell viewWithTag:1001];
    UILabel *titleL = [cell viewWithTag:1002];
    UILabel *priceL = [cell viewWithTag:1003];
    HKSubscriptInputField *dateLF = [cell viewWithTag:1004];
    UIButton *dateLB = [cell viewWithTag:10041];
    HKSubscriptInputField *dateRF = [cell viewWithTag:1005];
    UIButton *dateRB = [cell viewWithTag:10051];
    HKSubscriptInputField *nameF = [cell viewWithTag:1006];
    HKSubscriptInputField *idF = [cell viewWithTag:1007];
    
    [logoV setImageByUrl:self.insPremium.inslogo withType:ImageURLTypeOrigin defImage:@"ins_comp_def" errorImage:@"ins_comp_def"];
    titleL.text = self.insPremium.inscompname;
    priceL.text = [NSString stringWithFormat:@"参考价:%@", [NSString formatForRoundPrice2:self.insPremium.price]];
    
    dateLF.inputField.placeholder = @"商业险日期";
    dateLF.inputField.text = self.appointInfo.req_startdate;
    dateLF.subscriptImageName = @"ins_arrow_time";
    
    @weakify(self);
    [[[[dateLB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     flattenMap:^RACStream *(id value) {
        
         @strongify(self);
         [self.view endEditing:YES];
         return [self rac_pickDateWithNow:self.appointInfo.req_startdate];
    }] subscribeNext:^(NSString *datetext) {
      
        @strongify(self);
        self.appointInfo.req_startdate = datetext;
        dateLF.inputField.text = datetext;
    }];
    
    dateRF.inputField.placeholder = @"交强险日期";
    dateRF.inputField.text = self.appointInfo.req_forcestartdate;
    dateRF.subscriptImageName = @"ins_arrow_time";
    
    dateRB.userInteractionEnabled = ![data.customInfo[@"lockfdate"] boolValue];
    [[[[dateRB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     flattenMap:^RACStream *(id value) {
         
        @strongify(self);
        [self.view endEditing:YES];
        return [self rac_pickDateWithNow:self.appointInfo.req_forcestartdate];
    }] subscribeNext:^(NSString *datetext) {
        
        @strongify(self);
        self.appointInfo.req_forcestartdate = datetext;
        dateRF.inputField.text = datetext;
    }];
    
    nameF.inputField.placeholder = @"请输入投保人姓名";
    nameF.inputField.text = self.appointInfo.req_ownername;
    nameF.inputField.textLimit = 20;
    [nameF.inputField setTextDidChangedBlock:^(CKLimitTextField *field) {
        @strongify(self);
        self.appointInfo.req_ownername = field.text;
    }];
    
    idF.inputField.placeholder = @"请输入投保人身份证号码";
    idF.inputField.text = self.appointInfo.req_idcard;
    idF.inputField.textLimit = 18;
    idF.inputField.keyboardType = UIKeyboardTypeASCIICapable;
    [idF.inputField setTextDidChangedBlock:^(CKLimitTextField *field) {
        @strongify(self);
        self.appointInfo.req_idcard = field.text;
    }];
}

- (void)resetCouponCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    InsCouponView *couponV = [cell viewWithTag:1001];
    
    couponV.buttonHeight = 30;
    couponV.buttonTitleColor = HEXCOLOR(@"#20ab2a");
    couponV.buttonBorderColor = HEXCOLOR(@"#20ab2a");
    couponV.coupons = data.object;
    
    couponV.coupons = [data.object arrayByMapFilteringOperator:^id(NSDictionary *dict) {
        NSString *name = dict[@"name"];
        NSString *desc = dict[@"desc"];
        name.customObject = desc;
        return name;
    }];
    
    @weakify(self);
    [couponV setButtonClickBlock:^(NSString *name) {
        @strongify(self);
        [InsAlertVC showInView:self.navigationController.view withMessage:name.customObject];
    }];
}

#pragma mark - Utility
- (RACSignal *)rac_pickDateWithNow:(NSString *)nowtext
{
    NSDate *date = [NSDate dateWithD10Text:nowtext];
    return [[[self.datePicker rac_presentPickerVCInView:self.navigationController.view withSelectedDate:date] ignoreError] map:^id(NSDate *date) {
        return [date dateFormatForD10];
    }];
}
@end

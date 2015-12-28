//
//  InsPayResultVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/11.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsPayResultVC.h"
#import "HKCellData.h"
#import "HKSubscriptInputField.h"
#import "InsuranceVM.h"
#import "NSString+Format.h"
#import "UpdateDeliveryInfoOp.h"

#import "CityPickerVC.h"
#import "InsSubmitResultVC.h"

@interface InsPayResultVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) UpdateDeliveryInfoOp *deliveryInfo;
@end

@implementation InsPayResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    /**
     *  支付结果页面返回事件
     */
    [MobClick event:@"rp1007-1"];
}

#pragma mark - Datasource
- (void)reloadData
{
    self.deliveryInfo = [UpdateDeliveryInfoOp operation];
    
    HKCellData *headerCell = [HKCellData dataWithCellID:@"Header" tag:nil];
    [headerCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 66;
    }];
    HKCellData *baseCell = [HKCellData dataWithCellID:@"Base" tag:nil];
    [baseCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 115;
    }];
    HKCellData *contactCell = [HKCellData dataWithCellID:@"Contact" tag:nil];
    self.deliveryInfo.req_contatorname = self.insOrder.policyholder;
    [contactCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 88;
    }];
    HKCellData *addrCell = [HKCellData dataWithCellID:@"Address" tag:nil];
    [addrCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 105;
    }];
    HKCellData *bottomCell = [HKCellData dataWithCellID:@"Bottom" tag:nil];
    [bottomCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 33;
    }];
    
    self.datasource = @[headerCell, baseCell, contactCell, addrCell, bottomCell];
    [self.tableView reloadData];
}

#pragma mark - Action
- (void)actionBack:(id)sender
{
    if (self.insModel.originVC) {
        [self.navigationController popToViewController:self.insModel.originVC animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)actionSubmit:(id)sender
{
    /**
     *  提交资料点击事件
     */
    [MobClick event:@"1007-6"];
    if (self.deliveryInfo.req_contatorname.length == 0) {
        [gToast showText:@"联系人姓名不能为空"];
    }
    else if (self.deliveryInfo.req_contatorphone.length == 0) {
        [gToast showText:@"联系人手机号不能为空"];
    }
    else {
        NSString *baseAddr = [(HKCellData *)self.datasource[3] customInfo][@"base"];
        NSString *detailAddr = [(HKCellData *)self.datasource[3] customInfo][@"detail"];
        if (baseAddr.length == 0) {
            [gToast showText:@"省市区不能为空"];
        }
        else if (detailAddr.length == 0) {
            [gToast showText:@"详细地址不能为空"];
        }
        else {
            self.deliveryInfo.req_address = [baseAddr append:detailAddr];
            self.deliveryInfo.req_orderid = self.insOrder.orderid;
            [self requestUpdateDeliveryInfo];
        }
    }
}

#pragma mark - Request
- (void)requestUpdateDeliveryInfo
{
    @weakify(self);
    [[[self.deliveryInfo rac_postRequest] initially:^{

        [gToast showingWithText:@"正在提交"];
    }] subscribeNext:^(UpdateDeliveryInfoOp *op) {

        @strongify(self);
        [gToast dismiss];
        InsSubmitResultVC *vc = [UIStoryboard vcWithId:@"InsSubmitResultVC" inStoryboard:@"Insurance"];
        vc.couponList = op.rsp_couponlist;
        vc.insOrderID = self.insOrder.orderid;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
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
    if ([data equalByCellID:@"Base" tag:nil]) {
        [self resetBaseCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Contact" tag:nil]) {
        [self resetContactCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Address" tag:nil]) {
        [self resetAddressCell:cell forData:data];
    }
    return cell;
}

- (void)resetBaseCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UIImageView *logoV = [cell viewWithTag:1001];
    UILabel *titleL = [cell viewWithTag:1002];
    UILabel *priceL = [cell viewWithTag:1003];
    UILabel *numberL = [cell viewWithTag:1004];
    
    [logoV setImageByUrl:self.insOrder.picUrl withType:ImageURLTypeOrigin defImage:@"ins_comp_def" errorImage:@"ins_comp_def"];
    titleL.text = self.insOrder.inscomp;
    priceL.text = [NSString formatForRoundPrice2:self.insOrder.fee];
    numberL.text = self.insOrder.licencenumber;
}

- (void)resetContactCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    HKSubscriptInputField *nameF = [cell viewWithTag:1001];
    HKSubscriptInputField *phoneF = [cell viewWithTag:1002];
    
    nameF.inputField.textLimit = 20;
    nameF.inputField.placeholder = @"请输入姓名";
    nameF.inputField.text = self.deliveryInfo.req_contatorname;
    @weakify(self);
    [nameF.inputField setTextDidChangedBlock:^(CKLimitTextField *field) {
        @strongify(self);
        /**
         *  联系人姓名点击事件
         */
        [MobClick event:@"rp1007-2"];
        self.deliveryInfo.req_contatorname = field.text;
    }];
    
    phoneF.inputField.keyboardType = UIKeyboardTypeNumberPad;
    phoneF.inputField.textLimit = 11;
    phoneF.inputField.placeholder = @"请输入手机";
    phoneF.inputField.text = self.deliveryInfo.req_contatorphone;
    [phoneF.inputField setTextDidChangedBlock:^(CKLimitTextField *field) {
        /**
         *  联系人手机号点击事件
         */
        [MobClick event:@"rp1007-3"];
        self.deliveryInfo.req_contatorphone = field.text;
    }];
}

- (void)resetAddressCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UITextField *textF = [cell viewWithTag:10011];
    UIButton *selectB = [cell viewWithTag:10013];
    HKSubscriptInputField *addrF = [cell viewWithTag:1002];
    
    textF.text = data.customInfo[@"base"];
    
    addrF.inputField.placeholder = @"请填写详细地址";
    addrF.inputField.text = data.customInfo[@"detail"];
    [addrF.inputField setTextDidChangedBlock:^(CKLimitTextField *field) {
        /**
         *  保单寄送详细地址点击事件
         */
        [MobClick event:@"rp1007-5"];
        data.customInfo[@"detail"] = field.text;
    }];
    
    @weakify(self);
    [[[selectB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         /**
          *  保单寄送点击事件
          */
         [MobClick event:@"rp1007-4"];
         @strongify(self);
         [self.view endEditing:YES];
         CityPickerVC *picker = [CityPickerVC cityPickerVCWithOriginVC:self];
         picker.options = CityPickerOptionCity | CityPickerOptionProvince | CityPickerOptionDistrict | CityPickerOptionGPS;
         [picker setCompletedBlock:^(CityPickerVC *vc, Area *p, Area *c, Area *d) {
             NSString *base = [NSString stringWithFormat:@"%@%@%@", p.name, c.name, (d.name ? d.name : @"")];
             textF.text = base;
             data.customInfo[@"base"] = base;
         }];
         [self.navigationController pushViewController:picker animated:YES];
    }];
}

@end

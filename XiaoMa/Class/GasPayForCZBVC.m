//
//  GasPayForCZBVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasPayForCZBVC.h"
#import "NSString+RectSize.h"
#import "CKLimitTextField.h"
#import "GetCzbpayVcodeOp.h"
#import "GascardChargeOp.h"
#import "UIView+Shake.h"
#import "HKSMSModel.h"
#import "BankCardStore.h"

#import "GasPaymentResultVC.h"

@interface GasPayForCZBVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (nonatomic, strong) CKLimitTextField *vcodeField;
@property (nonatomic, strong) NSString *vcode;
@property (nonatomic, strong) UIButton *vcodeButton;
@property (nonatomic, strong) HKSMSModel *smsModel;
@property (nonatomic, strong) GetCzbpayVcodeOp *orderInfo;
@end

@implementation GasPayForCZBVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.smsModel = [[HKSMSModel alloc] init];
    [self setupBottomView];
}

- (void)setupBottomView
{
    @weakify(self);
    [[RACObserve(self, vcode) distinctUntilChanged] subscribeNext:^(NSString *vcode) {
        @strongify(self);
        self.bottomBtn.enabled = vcode.length >= 6 && self.orderInfo;
    }];
}

#pragma mark - Action
- (void)actionGetVCode:(id)sender
{
    @weakify(self);
    GetCzbpayVcodeOp *op = [GetCzbpayVcodeOp operation];
    op.req_cardid = self.bankCard.cardID;
    op.req_chargeamt = (int)self.chargeamt;
    op.req_gid = self.gasCard.gid;
    RACSignal *sig = [self.smsModel rac_getVcodeWithType:HKVcodeTypeCZBGasCharge fromSignal:[op rac_postRequest]];
    [[self.smsModel rac_startGetVcodeWithFetchVcodeSignal:sig] subscribeNext:^(id x) {
        
        @strongify(self);
        self.orderInfo = op;
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
    
    //激活输入验证码的输入框
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
    [field becomeFirstResponder];
}

- (IBAction)actionPay:(id)sender
{
    GascardChargeOp *op = [GascardChargeOp operation];
    op.req_amount = self.orderInfo.req_chargeamt;
    op.req_gid = self.orderInfo.req_gid;
    op.req_cardid = self.orderInfo.req_cardid;
    op.req_vcode = self.vcodeField.text;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在支付..."];
    }] subscribeNext:^(GascardChargeOp *op) {
        
        @strongify(self);
        [gToast dismiss];
        GasPaymentResultVC *vc = [UIStoryboard vcWithId:@"GasPaymentResultVC" inStoryboard:@"Gas"];
        vc.drawingStatus = DrawingBoardViewStatusSuccess;
        vc.gasCard = self.gasCard;
        vc.gasPayOp = op;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast dismiss];
        GasPaymentResultVC *vc = [UIStoryboard vcWithId:@"GasPaymentResultVC" inStoryboard:@"Gas"];
        vc.drawingStatus = DrawingBoardViewStatusFail;
        vc.gasCard = self.gasCard;
        vc.gasPayOp = op;
        vc.detailText = error.domain;
        vc.originVC = self.originVC;
        [self.navigationController pushViewController:vc animated:YES];
        [[BankCardStore fetchExistsStore] reloadDataWithCode:kCKStoreEventReload];
    }];
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        CGSize lbsize = [[self paymentTitle] labelSizeWithWidth:tableView.frame.size.width-28 font:[UIFont systemFontOfSize:13]];
        return lbsize.height + 13;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 12;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [self titleCellAtIndexPath:indexPath];
    }
    else if (indexPath.section == 1) {
        cell = [self vcodeCellAtIndexPath:indexPath];
    }
    else if (indexPath.section == 2) {
        cell = [self orderCellAtIndexPath:indexPath];
    }
    return cell;
}

- (UITableViewCell *)titleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TitleCell"];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    NSString *tialno = [self.bankCard.cardNumber substringFromIndex:self.bankCard.cardNumber.length-4 length:4];
    titleL.text = [NSString stringWithFormat:@"您正在用浙商银行汽车卡尾号为%@的卡号充值油卡，点击“获取验证码”，验证码将发至年的银行预留手机号中，请及时输入验证码进行支付。", tialno];
    return cell;
}

- (UITableViewCell *)vcodeCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"VCodeCell" forIndexPath:indexPath];
    CKLimitTextField *field = (CKLimitTextField *)[cell.contentView viewWithTag:1001];
    UIButton *vcodeBtn = (UIButton *)[cell.contentView viewWithTag:1002];
    
    if (!self.vcodeField) {
        self.vcodeField = field;
        field.textLimit = 6;
        @weakify(self);
        [[field rac_newTextChannel] subscribeNext:^(NSString *text) {
            
            @strongify(self);
            self.vcode = text;
        }];
    }
    if (!self.vcodeButton) {
        self.vcodeButton = vcodeBtn;
        self.smsModel.getVcodeButton = vcodeBtn;
        [vcodeBtn addTarget:self action:@selector(actionGetVCode:) forControlEvents:UIControlEventTouchUpInside];
        [self.smsModel countDownIfNeededWithVcodeType:HKVcodeTypeCZBGasCharge];
    }
    
    return cell;
}

- (UITableViewCell *)orderCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OrderCell" forIndexPath:indexPath];
    UIView *containerV = [cell.contentView viewWithTag:100];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    
    [[RACObserve(self, orderInfo) takeUntilForCell:cell] subscribeNext:^(GetCzbpayVcodeOp *info) {
        containerV.hidden = info.rsp_tradeid.length == 0;
    }];
    
    NSString *tradeno = self.orderInfo.rsp_tradeid;
    if (tradeno.length > 6) {
        tradeno = [tradeno substringFromIndex:tradeno.length - 6 length:6];
    }
    titleL.text = [NSString stringWithFormat:@"您本次加油的订单尾号为：%@", tradeno];
    
    return cell;
}

- (NSString *)paymentTitle
{
    NSString *tialno = [self.bankCard.cardNumber substringFromIndex:self.bankCard.cardNumber.length-4 length:4];
    return [NSString stringWithFormat:@"您正在用浙商银行汽车卡尾号为%@的卡号充值油卡，点击“获取验证码”，验证码将发至年的银行预留手机号中，请及时输入验证码进行支付。", tialno];
}

@end


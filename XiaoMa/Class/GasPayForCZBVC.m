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
#import "CancelGaschargeOp.h"
#import "UIView+Shake.h"
#import "HKSMSModel.h"
#import "BankCardStore.h"
#import "PaymentHelper.h"
#import "HKCellData.h"
#import "HKTableViewCell.h"
#import "NSString+Split.h"
#import "CKLimitTextField.h"
#import "IQKeyboardManager.h"
#import "GasStore.h"
#import "HKImageAlertVC.h"

#import "GasPaymentResultVC.h"

@interface GasPayForCZBVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *payButton;

@property (nonatomic, strong) NSString *vcode;
@property (nonatomic, strong) HKSMSModel *smsModel;
@property (nonatomic, strong) GetCzbpayVcodeOp *orderInfo;
@property (nonatomic, strong) NSArray *datasource;

@end

@implementation GasPayForCZBVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"GasPayForCZBVC dealloc ~");
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //隐藏键盘工具条
    self.smsModel = [[HKSMSModel alloc] init];
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 100;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 10;
}

#pragma mark - Datasource
- (void)reloadData
{
    HKCellData *info = [HKCellData dataWithCellID:@"Info" tag:nil];
    [info setHeightBlock:^CGFloat(UITableView *tableView) {
        return 112;
    }];
    
    HKCellData *prompt = [HKCellData dataWithCellID:@"Prompt" tag:nil];
    NSString *cardno = [self.bankCard.cardNumber substringFromIndex:self.bankCard.cardNumber.length-4 length:4];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = 5;
    NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:HEXCOLOR(@"#454545"), NSParagraphStyleAttributeName: ps};
    NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:HEXCOLOR(@"#f9430a"),NSParagraphStyleAttributeName: ps};
    NSMutableAttributedString *attstr = [NSMutableAttributedString attributedString];
    [attstr appendAttributedString:[[NSAttributedString alloc] initWithString:@"您正在使用浙商银行汽车卡尾号" attributes:attr1]];
    [attstr appendAttributedString:[[NSAttributedString alloc] initWithString:cardno attributes:attr2]];
    [attstr appendAttributedString:[[NSAttributedString alloc] initWithString:@"的卡号充值油卡，点击“获取验证码”" attributes:attr1]];
    
    prompt.object = attstr;
    [prompt setHeightBlock:^CGFloat(UITableView *tableView) {
        CGRect rect = [attstr boundingRectWithSize:CGSizeMake(tableView.frame.size.width-28,10000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
        return ceil(rect.size.height+24);
    }];
    
    HKCellData *vcode = [HKCellData dataWithCellID:@"Vcode" tag:nil];
    [vcode setHeightBlock:^CGFloat(UITableView *tableView) {
        return 140;
    }];
    
    HKCellData *bottom = [HKCellData dataWithCellID:@"Bottom" tag:nil];
    [bottom setHeightBlock:^CGFloat(UITableView *tableView) {
        return 64;
    }];
    
    self.datasource = @[@[info], @[prompt, vcode], @[bottom]];
    [self.tableView reloadData];
}

#pragma mark - Action
- (void)actionBack:(id)sender
{
    if (self.orderInfo) {
        HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
        alert.topTitle = @"温馨提示";
        alert.imageName = @"mins_bulb";
        alert.message = @"您还有订单未支付，是否继续支付？";
        @weakify(self);
        HKAlertActionItem *leftItem = [HKAlertActionItem itemWithTitle:@"放弃支付" color:HEXCOLOR(@"#888888") clickBlock:^(id alertVC) {
            @strongify(self);
            [alertVC dismiss];
            [self requestCancelOrderWithTradeNumber:self.orderInfo.rsp_tradeid gasCardID:self.orderInfo.req_gid];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        HKAlertActionItem *rightItem = [HKAlertActionItem itemWithTitle:@"继续支付" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            [alertVC dismiss];
        }];
        alert.actionItems = @[leftItem, rightItem];
        [alert show];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)actionGetVCode:(id)sender
{
    [MobClick event:@"rp507_2"];
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
    [MobClick event:@"rp507_3"];
    GascardChargeOp *op = [GascardChargeOp operation];
    op.req_amount = self.orderInfo.req_chargeamt;
    op.req_gid = self.orderInfo.req_gid;
    op.req_vcode = self.vcode;
    op.req_paychannel = [PaymentHelper paymentChannelForPlatformType:PaymentPlatformTypeCreditCard];
    op.req_orderid = self.orderInfo.rsp_orderid;
    op.req_bill = self.needInvoice ? 1 : 0;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在支付..."];
    }] subscribeNext:^(GascardChargeOp *op) {
        
        @strongify(self);
        [gToast dismiss];
        //标记当前油卡为最近使用的油卡
        [[GasStore fetchOrCreateStore] saverecentlyUsedGasCardID:op.req_gid];
        //跳转到支付成功页面
        GasPaymentResultVC *vc = [UIStoryboard vcWithId:@"GasPaymentResultVC" inStoryboard:@"Gas"];
        vc.originVC = self.originVC;
        vc.drawingStatus = DrawingBoardViewStatusSuccess;
        vc.gasCard = self.gasCard;
        vc.chargeMoney = op.req_amount+op.rsp_couponmoney;
        vc.couponMoney = op.rsp_couponmoney;
        vc.paidMoney = op.rsp_total;
        [vc setDismissBlock:^(DrawingBoardViewStatus status) {
            @strongify(self);
            //更新信息
            if (self.didPaidSuccessBlock) {
                self.didPaidSuccessBlock();
            }
        }];
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        @strongify(self);
        //绑定验证码失效
        if (error.code == 616201) {
            [gToast showError:error.domain];
            self.orderInfo.customInfo[@"Invaild"] = @YES;
            return ;
        }
        //验证码错误
        else if (error.code == 616202) {
            [gToast showError:error.domain];
            return;
        }
        [gToast dismiss];
        //加油到达上限（如果遇到该错误，客户端提醒用户后，需再调用一次查询卡的充值信息）
        if (error.code == 618602) {
            BankCardStore *store = [BankCardStore fetchExistsStore];
            [store sendEvent:[store updateBankCardCZBInfoByCID:self.bankCard.cardID]];
        }
        //跳转到支付失败页面
        GasPaymentResultVC *vc = [UIStoryboard vcWithId:@"GasPaymentResultVC" inStoryboard:@"Gas"];
        vc.drawingStatus = DrawingBoardViewStatusFail;
        vc.gasCard = self.gasCard;
        vc.paidMoney = self.orderInfo.rsp_total;
        vc.couponMoney = self.orderInfo.rsp_couponmoney;
        vc.chargeMoney = self.orderInfo.req_chargeamt+self.orderInfo.rsp_couponmoney;
        vc.detailText = error.domain;
        vc.originVC = self.originVC;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - Request
- (void)requestCancelOrderWithTradeNumber:(NSString *)tdno gasCardID:(NSNumber *)gid
{
    [[[[GasStore fetchExistsStore] updateCardInfoByGID:gid] mapSignal:^RACSignal *(RACSignal *signal) {
        CancelGaschargeOp *op = [CancelGaschargeOp operation];
        op.req_tradeid = tdno;
        return [[op rac_postRequest] flattenMap:^RACStream *(id value) {
            return signal;
        }];
    }] send];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    if (data.heightBlock) {
        return data.heightBlock(tableView);
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.datasource safetyObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];

    if ([data equalByCellID:@"Info" tag:nil]) {
        [self resetInfoCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Prompt" tag:nil]) {
        [self resetPromptCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Vcode" tag:nil]) {
        [self resetVcodeCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Bottom" tag:nil]) {
        [self resetBottomCell:cell forData:data];
    }

    return cell;
}

- (void)resetInfoCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UIImageView *logoV = [cell viewWithTag:1001];
    UILabel *cardnoL = [cell viewWithTag:1002];
    UILabel *priceL = [cell viewWithTag:1007];
    
    logoV.image = [UIImage imageNamed:self.gasCard.cardtype == 2 ? @"gas_icon_cnpc" : @"gas_icon_snpn"];
    cardnoL.text = [self.gasCard.gascardno splitByStep:4 replacement:@" "];
    priceL.text = [NSString stringWithFormat:@"￥%.2f", (float)self.chargeamt];
}

- (void)resetPromptCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UILabel *promptL = [cell viewWithTag:1001];
    promptL.attributedText = data.object;
}

- (void)resetVcodeCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UIButton *vcodeB = [cell viewWithTag:1001];
    CKLimitTextField *vcodeF = [cell viewWithTag:1002];
    
    if (!data.customInfo[@"inited"]) {
        data.customInfo[@"inited"] = @YES;
        self.smsModel.getVcodeButton = vcodeB;
        [vcodeB addTarget:self action:@selector(actionGetVCode:) forControlEvents:UIControlEventTouchUpInside];
        [self.smsModel countDownIfNeededWithVcodeType:HKVcodeTypeCZBGasCharge];
    }
    
    @weakify(self);
    [vcodeF setDidBeginEditingBlock:^(CKLimitTextField *field) {
        
        [MobClick event:@"rp507_1"];
    }];
    
    [vcodeF setTextChangingBlock:^(CKLimitTextField *rTextFeild, NSString *text) {
        
        @strongify(self);
        self.vcode = rTextFeild.text;
    }];
    
    vcodeF.textLimit = 6;
}

- (void)resetBottomCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UIButton *payButton = [cell viewWithTag:1001];
    
    [payButton setTitle:self.payTitle forState:UIControlStateNormal];
    [payButton setTitle:self.payTitle forState:UIControlStateDisabled];

    @weakify(self);
    [[RACObserve(self, vcode) takeUntilForCell:cell] subscribeNext:^(NSString *vcode) {
        @strongify(self);
        BOOL enable = vcode.length >= 6 && self.orderInfo && ![self.orderInfo.customInfo[@"Invaild"] boolValue];
        payButton.enabled = enable;
    }];
}


@end


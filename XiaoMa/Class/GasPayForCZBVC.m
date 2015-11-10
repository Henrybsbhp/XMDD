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
#import "PaymentHelper.h"

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp507"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp507"];
}

- (void)setupBottomView
{
    @weakify(self);
    [[RACObserve(self, vcode) distinctUntilChanged] subscribeNext:^(NSString *vcode) {
        @strongify(self);
        self.bottomBtn.enabled = vcode.length >= 6 && self.orderInfo && ![self.orderInfo.customInfo[@"Invaild"] boolValue];
    }];
}

#pragma mark - Action
- (void)actionBack:(id)sender
{
    if (self.orderInfo) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"您还有订单未支付，是否继续支付？" delegate:nil
                                              cancelButtonTitle:@"放弃支付" otherButtonTitles:@"继续支付", nil];
        [alert show];
        @weakify(self);
        [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
            @strongify(self);
            if ([index integerValue] == 0) {
                [self.navigationController popViewControllerAnimated:YES];
                [self.model cancelOrderWithTradeNumber:self.orderInfo.rsp_tradeid bankCardID:self.orderInfo.req_cardid];
            }
        }];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)actionGetVCode:(id)sender
{
    [MobClick event:@"rp507-2"];
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
    [MobClick event:@"rp507-3"];
    GascardChargeOp *op = [GascardChargeOp operation];
    op.req_amount = self.orderInfo.req_chargeamt;
    op.req_gid = self.orderInfo.req_gid;
    op.req_vcode = self.vcodeField.text;
    op.req_paychannel = [PaymentHelper paymentChannelForPlatformType:PaymentPlatformTypeCreditCard];
    op.req_orderid = self.orderInfo.rsp_orderid;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在支付..."];
    }] subscribeNext:^(GascardChargeOp *op) {
        
        @strongify(self);
        [gToast dismiss];
        //标记当前油卡为最近使用的油卡
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSString *key = [self.model recentlyUsedGasCardKey];
        if (key) {
            [def setObject:op.req_gid forKey:key];
        }
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
            self.model.rechargeAmount = 500;
            BankCardStore *store = [BankCardStore fetchExistsStore];
            [store sendEvent:[store updateBankCardCZBInfoByCID:self.bankCard.cardID]];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        @strongify(self);
        //绑定验证码失效
        if (error.code == 616201) {
            [gToast showError:error.domain];
            self.orderInfo.customInfo[@"Invaild"] = @YES;
            self.bottomBtn.enabled = NO;
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
    titleL.text = [NSString stringWithFormat:@"您正在用浙商银行汽车卡尾号为%@的卡号充值油卡，点击“获取验证码”，验证码将发至您的银行预留手机号中，请及时输入验证码进行支付。", tialno];
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
        [field setDidBeginEditingBlock:^(CKLimitTextField *field) {
            
            [MobClick event:@"rp507-1"];
        }];
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
        NSString *tradeno = info.rsp_tradeid;
        containerV.hidden = tradeno.length == 0;
        
        if (tradeno.length > 6) {
            tradeno = [tradeno substringFromIndex:tradeno.length - 6 length:6];
        }
        titleL.text = [NSString stringWithFormat:@"您本次加油的订单尾号为：%@", tradeno];
    }];

    
    
    return cell;
}

- (NSString *)paymentTitle
{
    NSString *tialno = [self.bankCard.cardNumber substringFromIndex:self.bankCard.cardNumber.length-4 length:4];
    return [NSString stringWithFormat:@"您正在用浙商银行汽车卡尾号为%@的卡号充值油卡，点击“获取验证码”，验证码将发至年的银行预留手机号中，请及时输入验证码进行支付。", tialno];
}

@end


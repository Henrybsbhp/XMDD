//
//  PolicyPaymentVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/24.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PayForPolicyVC.h"
#import "XiaoMa.h"
#import "UIView+Layer.h"
#import "UpdateInsuranceOrderOp.h"
#import "PayResultForInstallmentsVC.h"
#import "AlipayHelper.h"
#import "WeChatHelper.h"
#import "WebVC.h"

@interface PayForPolicyVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, strong) CKSegmentHelper *checkBoxHelper;
@property (nonatomic, strong) UpdateInsuranceOrderOp *payOp;
@end

@implementation PayForPolicyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupCheckBoxHelper];
    [self setupBottomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCheckBoxHelper
{
    self.checkBoxHelper = [CKSegmentHelper new];
}

- (void)setupBottomView
{
    //line
    [self.bottomView setBorderColor:kDefLineColor];
    [self.bottomView showBorderLineWithDirectionMask:CKViewBorderDirectionTop];
    [self.bottomView layoutBorderLineIfNeeded];
    
    //label
    UILabel *label = (UILabel *)[self.bottomView viewWithTag:1001];
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:@"总计："
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                                NSForegroundColorAttributeName:HEXCOLOR(@"#fb4209")}];
    [str appendAttributedString:attrStr1];
    
    NSString *price = [NSString stringWithFormat:@"￥%.2f", self.insuranceOp.rsp_policy.premium];
    NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:price
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],
                                                                                NSForegroundColorAttributeName:HEXCOLOR(@"#fb4209")}];
    [str appendAttributedString:attrStr2];
    label.attributedText = str;
}

- (void)reloadWithInsuranceOp:(GetInsuranceByChannelOp *)op
{
    _insuranceOp = op;
    self.payOp = [UpdateInsuranceOrderOp new];
    self.payOp.req_paychannel = PaymentChannelInstallments;
    self.payOp.req_deliveryaddress = op.rsp_deliveryaddress;
    [self.tableView reloadData];
}
#pragma mark - Action
- (IBAction)actionPay:(id)sender
{
    self.payOp.req_orderid = self.insuranceOp.rsp_orderid;
    if (self.payOp.req_deliveryaddress.length == 0) {
        [gToast showText:@"请填写完整的邮寄地址"];
        return;
    }
    @weakify(self);
    [[[self.payOp rac_postRequest] initially:^{
        [gToast showingWithText:@"选择支付方式..."];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [gToast dismiss];
        if (self.payOp.req_paychannel == PaymentChannelInstallments) {
            WebVC *vc = [UIStoryboard vcWithId:@"WebVC" inStoryboard:@"Common"];
            vc.originVC = [self.navigationController.viewControllers safetyObjectAtIndex:0];
            vc.title = @"分期付款";
//            PayResultForInstallmentsVC *vc = [UIStoryboard vcWithId:@"PayResultForInstallmentsVC" inStoryboard:@"Insurance"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (self.payOp.req_paychannel == PaymentChannelAlipay) {
            [self requestAliPay:self.insuranceOp.rsp_orderid andPrice:self.insuranceOp.rsp_policy.premium];
        }
        else if (self.payOp.req_paychannel == PaymentChannelWechat) {
            [self requestWechatPay:self.insuranceOp.rsp_orderid andPrice:self.insuranceOp.rsp_policy.premium];
        }

    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

#pragma mark - Pay
- (void)requestAliPay:(NSString *)orderId andPrice:(CGFloat)price
{
    @weakify(self);
    [gAlipayHelper payOrdWithTradeNo:orderId andProductName:@"保险" andProductDescription:@"渠道保险购买" andPrice:price];
    [gAlipayHelper.rac_alipayResultSignal subscribeNext:^(id x) {
        @strongify(self);
        [gToast showSuccess:@"支付成功"];
        [self gotoPaySuccessVC];
    } error:^(NSError *error) {
    }];
}

- (void)requestWechatPay:(NSString *)orderId andPrice:(CGFloat)price
{
    @weakify(self);
    [gWechatHelper payOrdWithTradeNo:orderId andProductName:@"保险" andPrice:price];
    [gWechatHelper.rac_wechatResultSignal subscribeNext:^(id x) {
        @strongify(self);
        [gToast showSuccess:@"支付成功"];
        [self gotoPaySuccessVC];
    } error:^(NSError *error) {
    }];
}

- (void)gotoPaySuccessVC
{
    WebVC *vc = [UIStoryboard vcWithId:@"WebVC" inStoryboard:@"Common"];
    vc.originVC = [self.navigationController.viewControllers safetyObjectAtIndex:0];
    vc.title = @"支付成功";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate and datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        return 95;
    }
    if (indexPath.row == 3) {
        return 32;
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    if (row == 0) {
        return [self addressCellAtIndexPath:indexPath];
    }
    if (row == 1) {
        return [self title_1_CellAtIndexPath:indexPath];
    }
    if (row == 3) {
        return [self title_2_CellAtIndexPath:indexPath];
    }
    return [self paymentCellAtIndexPath:indexPath];
}

- (UITableViewCell *)addressCellAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AddressCell" forIndexPath:indexPath];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1001];
    field.text = self.payOp.req_deliveryaddress;
    @weakify(self);
    [[[field rac_newTextChannel] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        self.payOp.req_deliveryaddress = x;
    }];

    cell.customSeparatorInset = UIEdgeInsetsZero;
    return cell;
}

- (UITableViewCell *)title_1_CellAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TitleCell1" forIndexPath:indexPath];
    UIButton *helpBtn = (UIButton *)[cell.contentView viewWithTag:1002];
    NSDictionary *attr = @{NSForegroundColorAttributeName:HEXCOLOR(@"#15AC1F"),
                           NSFontAttributeName:[UIFont systemFontOfSize:14],
                           NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:@"什么是分期付款?" attributes:attr];
    [helpBtn setAttributedTitle:attrStr forState:UIControlStateNormal];
    
    @weakify(self);
    [[[helpBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         @strongify(self);
         WebVC *vc = [UIStoryboard vcWithId:@"WebVC" inStoryboard:@"Common"];
         vc.title = @"什么是分期付款?";
         [self.navigationController pushViewController:vc animated:YES];
    }];
    
    cell.customSeparatorInset = UIEdgeInsetsZero;
    return cell;
}

- (UITableViewCell *)title_2_CellAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TitleCell2" forIndexPath:indexPath];
    cell.customSeparatorInset = UIEdgeInsetsZero;
    return cell;
}

- (UITableViewCell *)paymentCellAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentCell" forIndexPath:indexPath];
    UIImageView *iconV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UIImageView *badgeV = (UIImageView *)[cell.contentView viewWithTag:1003];
    UILabel *subTitleL = (UILabel *)[cell.contentView viewWithTag:1004];
    UIButton *boxBtn = (UIButton *)[cell.contentView viewWithTag:1005];
    
    PaymentChannelType type = [self paymentChannelForCellRow:indexPath.row];
    badgeV.hidden = type != PaymentChannelInstallments;
    if (type == PaymentChannelInstallments) {
        titleL.text = @"分期支付(暂只支持农行卡)";
        subTitleL.text = @"0利息0手续费";
        iconV.image = [UIImage imageNamed:@"ins_instalment"];
    }
    else if (type == PaymentChannelAlipay) {
        titleL.text = @"支付宝";
        subTitleL.text = @"推荐支付宝用户使用";
        iconV.image = [UIImage imageNamed:@"ins_alipay"];
    }
    else if (type == PaymentChannelWechat) {
        titleL.text = @"微信支付";
        subTitleL.text = @"推荐微信用户使用";
        iconV.image = [UIImage imageNamed:@"ins_wechat"];
    }
    
    boxBtn.customTag = type;
    @weakify(self);
    [self.checkBoxHelper addItem:boxBtn forGroupName:@"payment" withChangedBlock:^(UIButton *item, BOOL selected) {
        item.selected = selected;
        if (selected) {
            @strongify(self);
            self.payOp.req_paychannel = (PaymentChannelType)item.customTag;
        }
    }];
    
    [[[boxBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
      takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        [self.checkBoxHelper selectItem:x forGroupName:@"payment"];
    }];
    if (!boxBtn.selected && self.payOp.req_paychannel == type) {
        [self.checkBoxHelper selectItem:boxBtn forGroupName:@"payment"];
    }

    if (indexPath.row == 2) {
        cell.customSeparatorInset = UIEdgeInsetsZero;
    }
    else {
        cell.customSeparatorInset = UIEdgeInsetsMake(0, 11, 0, 11);
    }
    return cell;
}

- (NSInteger)cellRowForPaymentChannel:(PaymentChannelType)type
{
    if (type == PaymentChannelInstallments) {
        return 2;
    }
    if (type == PaymentChannelAlipay) {
        return 4;
    }
    return 5;
}

- (PaymentChannelType)paymentChannelForCellRow:(NSInteger)row
{
    if (row == 2) {
        return PaymentChannelInstallments;
    }
    if (row == 4) {
        return PaymentChannelAlipay;
    }
    return PaymentChannelWechat;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
}

@end

//
//  PayForWashCarVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PayForWashCarVC.h"
#import "XiaoMa.h"
#import "UIView+Layer.h"
#import "PaymentSuccessVC.h"
#import "ChooseCarwashTicketVC.h"
#import "GetUserResourcesOp.h"
#import "GetUserCarOp.h"
#import "HKCoupon.h"
#import "HKMyCar.h"
#import "AlipayHelper.h"
#import "CheckoutServiceOrderOp.h"
#import "NSDate+DateForText.h"



@interface PayForWashCarVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CKSegmentHelper *checkBoxHelper;

@property (nonatomic,strong)HKMyCar *car;

/// 是否添加车辆（请求我的车辆成功，且无车辆）
@property (nonatomic)BOOL needAppendCarFlag;

@property (nonatomic)PaymentChannelType paymentType;
@end

@implementation PayForWashCarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCheckBoxHelper];
    [self setupBottomView];
    
    if (gAppMgr.myUser.carArray.count)
    {
        self.car = [gAppMgr.myUser getDefaultCar];
    }
    else
    {
        [self requestGetUserCar];
    }
    [self requestGetUserResource];
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
    NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%@", self.service.serviceName]
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],
                                                                                NSForegroundColorAttributeName:HEXCOLOR(@"#fb4209")}];
    [str appendAttributedString:attrStr2];
    label.attributedText = str;
}

//- (void)reloadDatasource
//{
//    self.paymentTypeList = [gAppMgr.myUser paymentTypes];
//    [self.tableView reloadData];
//}

#pragma mark - Action
- (IBAction)actionPay:(id)sender
{
    if (self.needAppendCarFlag)
    {
        [SVProgressHUD showWithStatus:@"您没有车辆信息，请添加一辆车"];
        return;
    }
    if (self.paymentType == PaymentChannelCoupon)
    {
        if (gAppMgr.myUser.couponArray.count == 0)
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您目前没有优惠劵，可能导致提交失败，请选择其他方式支付" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:@"继续提交", nil];
            [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * num) {
                
                NSInteger index = [num integerValue];
                if (index == 1)
                {
                    [self checkout];
                }
            }];
            [av show];
        }
    }
    else if (self.paymentType == PaymentChannelABCCarWashAmount)
    {
        if (gAppMgr.myUser.abcCarwashTimesCount == 0)
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您目前没有免费洗车次数，可能导致提交失败，请选择其他方式支付" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:@"继续提交", nil];
            [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * num) {
                
                NSInteger index = [num integerValue];
                if (index == 1)
                {
                    [self checkout];
                }
            }];
            [av show];
        }
    }
   else if (self.paymentType == PaymentChannelABCIntegral)
    {
        if (gAppMgr.myUser.abcIntegral < 1)/// @fq 积分不够
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您目前积分不够，可能导致提交失败，请选择其他方式支付" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:@"继续提交", nil];
            [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * num) {
                
                NSInteger index = [num integerValue];
                if (index == 1)
                {
                    [self checkout];
                }
            }];
            [av show];
        }
    }
    
    else // 支付宝或微信
    {
        [self checkout];
    }
    
}


- (void)checkout
{
    CheckoutServiceOrderOp * op = [CheckoutServiceOrderOp operation];
    op.serviceid = self.service.serviceID;
    op.licencenumber = [gAppMgr.myUser getDefaultCar].licencenumber;
    op.cid = @"";
    op.paychannel = self.paymentType;
    [[[op rac_postRequest] initially:^{
        
        [SVProgressHUD showWithStatus:@"订单生成中..."];
    }] subscribeNext:^(CheckoutServiceOrderOp * op) {
        
        
        if (op.rsp_Code == 0)
        {
            [SVProgressHUD showWithStatus:@"订单生成成功,正在跳转到支付宝平台进行支付" duration:2.0f];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                NSString * submitTime = [[NSDate date] dateFormatForDT8];
                NSString * info = [NSString stringWithFormat:@"%@",self.shop.shopName];
                [self requestPay:op.rsp_orderid andPrice:op.rsp_price
                  andProductName:info andDescription:@"小马达达" andTime:submitTime];
            });
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"订单生成失败"];
        }
    } error:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:@"订单生成失败"];
    }];
}

- (void)requestPay:(NSString *)orderId andPrice:(CGFloat)price
    andProductName:(NSString *)name andDescription:(NSString *)desc andTime:(NSString *)time
{
    [gAlipayHelper payOrdWithTradeNo:orderId andProductName:name andProductDescription:desc andPrice:price];
    
    [gAlipayHelper.rac_alipayResultSignal subscribeNext:^(id x) {
        
        PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
        vc.originVC = self.originVC;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44;
    if (indexPath.section == 0 && indexPath.row == 0) {
        height = 84;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    CGFloat height = CGFLOAT_MIN;
    if (section == 1) {
        height = 33;
    }
    else if (section == 2) {
        height = 33;
    }
    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title;
    if (section == 1) {
        title = @"使用优惠券（各优惠券不得同享）";
    }
    else if (section == 2) {
        title = @"其他支付方式";
    }
    return title;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger count = 0;
    if (section == 0) {
        count = 4;
    }
    else if (section == 1) {
        count = 3;
    }
    else if (section == 2) {
        count = 2;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [self shopTitleCellAtIndexPath:indexPath];
        }
        else {
            cell = [self shopItemCellAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == 1) {
        cell = [self paymentTypeCellAtIndexPath:indexPath];
    }
    else if (indexPath.section == 2) {
        cell = [self paymentModeCellAtIndexPath:indexPath];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *jtcell = (JTTableViewCell *)cell;
    [jtcell prepareCellForTableView:tableView atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        //点击查看优惠券
            ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
            vc.originVC = self.originVC;
            [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - TableViewCell
- (UITableViewCell *)shopTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShopTitleCell"];
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1003];
    
    logoV.image = [UIImage imageNamed:[self.shop.picArray safetyObjectAtIndex:0]];
    titleL.text = self.shop.shopName;
    addrL.text = self.shop.shopAddress;
    
    return cell;
}

- (UITableViewCell *)shopItemCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShopItemCell"];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UIButton *additionB = (UIButton *)[cell.contentView viewWithTag:1002];
    
    if (indexPath.row == 1) {
        titleL.text = [NSString stringWithFormat:@"服务项目：%@", self.service.serviceName];
        additionB.hidden = YES;
    }
    else if (indexPath.row == 2) {
        titleL.text = [NSString stringWithFormat:@"项目价格：%.2f", self.service.contractprice];
        NSArray * rates = self.service.chargeArray;
        ChargeContent * cc;
        for (ChargeContent * tcc in rates)
        {
            if (cc.paymentChannelType == PaymentChannelABCIntegral)
            {
                cc = tcc;
                break;
            }
        }
        additionB.hidden = !cc;
        [additionB setTitle:[NSString stringWithFormat:@" %.0f分", cc.amount]forState:UIControlStateNormal];
    }
    else if (indexPath.row == 3) {
        
        if (self.car.licencenumber.length)
        {
            titleL.text = [NSString stringWithFormat:@"我的车辆：%@", gAppMgr.myUser.numberPlate];
            additionB.hidden = YES;
        }
        else
        {
            titleL.text = [NSString stringWithFormat:@"我的车辆："];
            additionB.hidden = YES;
        }
    }

    return cell;
}

- (UITableViewCell *)paymentTypeCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentTypeCell"];
    UIButton *box = (UIButton *)[cell.contentView viewWithTag:1001];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1002];
    UIImageView *arrow = (UIImageView *)[cell.contentView viewWithTag:1003];
    
    if (indexPath.row == 0) {
        label.text = [NSString stringWithFormat:@"免费洗车券：%ld张", (long)gAppMgr.myUser.carwashTicketsCount];
        arrow.hidden = NO;
    }
    else if (indexPath.row == 1) {
        label.text = [NSString stringWithFormat:@"农行卡免费洗车次数：%ld次", (long)gAppMgr.myUser.abcCarwashTimesCount];
    }
    else
    {
        label.text = [NSString stringWithFormat:@"农行卡积分：%ld分", (long)gAppMgr.myUser.abcIntegral];
    }
    @weakify(self);
    [self.checkBoxHelper addItem:box forGroupName:@"PaymentType" withChangedBlock:^(id item, BOOL selected) {
        box.selected = selected;
    }];
    [[[box rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        [self.checkBoxHelper selectItem:box forGroupName:@"PaymentType"];
        if (indexPath.row == 0)
        {
            self.paymentType = PaymentChannelCoupon;
        }
        else if (indexPath.row == 1)
        {
            self.paymentType = PaymentChannelABCCarWashAmount;
        }
        else
        {
            self.paymentType = PaymentChannelABCIntegral;
        }
    }];

    
    return cell;
}

- (UITableViewCell *)paymentModeCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentModeCell"];
    UIImageView *iconV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UIButton *boxB = (UIButton *)[cell.contentView viewWithTag:1003];
    if (indexPath.row == 0) {
        iconV.image = [UIImage imageNamed:@"cw_alipay"];
        titleL.text = @"支付宝支付";
    }
    else if (indexPath.row == 1) {
        iconV.image = [UIImage imageNamed:@"cw_wechat"];
        titleL.text = @"微信支付";
    }
    @weakify(self);
    [self.checkBoxHelper addItem:boxB forGroupName:@"PaymentType" withChangedBlock:^(id item, BOOL selected) {
        boxB.selected = selected;
    }];

    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        [self.checkBoxHelper selectItem:boxB forGroupName:@"PaymentType"];
        if (indexPath.row == 0)
        {
            self.paymentType = PaymentChannelAlipay;
        }
        else
        {
            self.paymentType = PaymentChannelWechat;
        }
    }];
    
    if (indexPath.row == 0)
    {
        [self.checkBoxHelper selectItem:boxB forGroupName:@"PaymentType"];
    }
    
    return cell;
}

#pragma mark - Utility
- (void)requestGetUserResource
{
    GetUserResourcesOp * op = [GetUserResourcesOp operation];
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetUserResourcesOp * op) {
        
        gAppMgr.myUser.abcCarwashTimesCount = op.rsp_freewashes;
        gAppMgr.myUser.abcIntegral = op.rsp_bankIntegral;
        gAppMgr.myUser.carwashTicketsCount = op.rsp_coupons.count;
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    } error:^(NSError *error) {
        
    }];
}

- (void)requestGetUserCar
{
    GetUserCarOp * op = [GetUserCarOp operation];
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetUserCarOp * op) {
        
        if (op.rsp_Code == 0)
        {
            if (op.rsp_carArray.count)
            {
                gAppMgr.myUser.carArray = op.rsp_carArray;
                self.car = [gAppMgr.myUser getDefaultCar];
                NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[reloadIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            else
            {
                self.needAppendCarFlag = YES;
            }
        }
    } error:^(NSError *error) {
        
    }];
}

@end

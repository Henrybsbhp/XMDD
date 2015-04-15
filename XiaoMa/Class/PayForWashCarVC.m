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


@interface PayForWashCarVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *paymentTypeList;
@property (nonatomic, strong) CKSegmentHelper *checkBoxHelper;
@end

@implementation PayForWashCarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCheckBoxHelper];
    [self setupBottomView];
    [self reloadDatasource];
    
    
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

- (void)reloadDatasource
{
    self.paymentTypeList = [gAppMgr.myUser paymentTypes];
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionPay:(id)sender
{
    PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
    vc.originVC = self.originVC;
    [self.navigationController pushViewController:vc animated:YES];
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
    if (section == 1 && self.paymentTypeList.count > 0) {
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
        count = self.paymentTypeList.count;
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
    if (indexPath.section == 1) {
        //点击查看优惠券
        RACTuple *paymentType = [self.paymentTypeList safetyObjectAtIndex:indexPath.row];
        NSInteger type = [paymentType.first integerValue];
        if (type == PaymentTypeCarwashTicket) {
            ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
            vc.originVC = self.originVC;
            [self.navigationController pushViewController:vc animated:YES];
        }
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
            if (cc.chargeChannelType == ChargeChannelABCIntegral)
            {
                cc = tcc;
                break;
            }
        }
        additionB.hidden = !cc;
        [additionB setTitle:[NSString stringWithFormat:@" %.0f分", cc.amount]forState:UIControlStateNormal];
    }
    else if (indexPath.row == 3) {
        titleL.text = [NSString stringWithFormat:@"我的车辆：%@", gAppMgr.myUser.numberPlate];
        additionB.hidden = YES;
    }

    return cell;
}

- (UITableViewCell *)paymentTypeCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentTypeCell"];
    UIButton *box = (UIButton *)[cell.contentView viewWithTag:1001];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1002];
    UIImageView *arrow = (UIImageView *)[cell.contentView viewWithTag:1003];
    
    RACTuple *paymentType = [self.paymentTypeList safetyObjectAtIndex:indexPath.row];
    NSInteger type = [paymentType.first integerValue];
    NSNumber *value = paymentType.second;
    if (type == PaymentTypeCarwashTicket) {
        label.text = [NSString stringWithFormat:@"免费洗车券：%@张", value];
        arrow.hidden = NO;
    }
    else if (type == PaymentTypeABCBankCarwashTimes) {
        label.text = [NSString stringWithFormat:@"农行卡免费洗车次数：%@次", value];
        arrow.hidden = YES;
    }
    else if (type == PaymentTypeABCBankIntegral) {
        label.text = [NSString stringWithFormat:@"农行卡积分：%@分", value];
        arrow.hidden = YES;
    }
    @weakify(self);
    [self.checkBoxHelper addItem:box forGroupName:@"PaymentType" withChangedBlock:^(id item, BOOL selected) {
        box.selected = selected;
    }];
    [[[box rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        [self.checkBoxHelper selectItem:box forGroupName:@"PaymentType"];
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
    [self.checkBoxHelper addItem:boxB forGroupName:@"PaymentMode" withChangedBlock:^(id item, BOOL selected) {
        boxB.selected = selected;
    }];

    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        [self.checkBoxHelper selectItem:boxB forGroupName:@"PaymentMode"];
    }];
    
    return cell;
}

@end

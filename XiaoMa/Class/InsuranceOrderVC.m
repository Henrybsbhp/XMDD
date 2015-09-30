//
//  InsuranceOrderVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/30.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceOrderVC.h"
#import "UIView+Layer.h"
#import "BorderLineLabel.h"
#import "GetInsuranceOrderDetailsOp.h"
#import "InsuranceOrderPayOp.h"
#import "PayForInsuranceVC.h"
#import "HKLoadingModel.h"

@interface InsuranceOrderVC ()<UITableViewDataSource,UITableViewDelegate,HKLoadingModelDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *coverages;
@property (nonatomic, strong) HKLoadingModel *loadingModel;
@end

@implementation InsuranceOrderVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
    if (self.order) {
        self.orderID = self.order.orderid;
        [self.tableView.refreshView addTarget:self.loadingModel action:@selector(reloadData)
                             forControlEvents:UIControlEventValueChanged];
        [self reloadWithOrderStatus:self.order.status];
    }
    else {
        [self.loadingModel loadDataForTheFirstTime];
    }
    [self setupNotify];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp319"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp319"];
}

- (void)resetBottomButton
{
    UIColor *bgColor;
    SEL action;
    NSString *title;
    if (self.order.status == InsuranceOrderStatusUnpaid) {
        bgColor = HEXCOLOR(@"#ff5a00");
        title = @"去支付";
        action = @selector(actionPay:);
    }
    else {
        bgColor = HEXCOLOR(@"#23ac2d");
        title = @"联系客服";
        action = @selector(actionMakeCall:);
    }
    [self.bottomButton setBackgroundColor:bgColor];
    self.bottomButton.layer.cornerRadius = 5.0;
    self.bottomButton.layer.masksToBounds = YES;
    [self.bottomButton setTitle:title forState:UIControlStateNormal];
    [self.bottomButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.bottomButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupNotify
{
    [self listenNotificationByName:kNotifyRefreshDetailInsuranceOrder withNotifyBlock:^(NSNotification *note, id weakSelf) {
        if ([note.object isKindOfClass:[NSNumber class]] && [self.orderID isEqualToNumber:note.object]) {
            [self.loadingModel reloadData];
        }
    }];
}
#pragma mark - Load
- (void)reloadDatasource
{

}

- (void)reloadWithOrderStatus:(InsuranceOrderStatus)status
{
    self.order.status = status;
    id amount;
    id remark;
    //优惠额度
    int activityAmount = floor(self.order.activityAmount);
    if (activityAmount > 0) {
        NSString *str = [NSString stringWithFormat:@"(已优惠%d) ", activityAmount];
        NSDictionary *attr = @{NSForegroundColorAttributeName:HEXCOLOR(@"#8b9eb3"),
                               NSFontAttributeName:[UIFont systemFontOfSize:12]};
        remark = [[NSAttributedString alloc] initWithString:str attributes:attr];
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
        
        str = [NSString stringWithFormat:@"￥%.2f ", self.order.totoalpay];
        attr = @{NSForegroundColorAttributeName:[UIColor blackColor],
                 NSFontAttributeName:[UIFont systemFontOfSize:12],
                 NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:str attributes:attr]];
        
        str = [NSString stringWithFormat:@"￥%.2f", self.order.totoalpay-self.order.activityAmount];
        attr = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                 NSForegroundColorAttributeName:[UIColor blackColor]};
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:str attributes:attr]];
        amount = attrStr;
    }
    else {
        amount = [NSString stringWithFormat:@"￥%.2f", self.order.totoalpay-self.order.activityAmount];
    }


    NSArray *array = @[RACTuplePack(@"被保险人",_order.policyholder),
                       RACTuplePack(@"保险公司",_order.inscomp),
                       RACTuplePack(@"证件号码",_order.idcard),
                       RACTuplePack(@"投保车辆",_order.licencenumber),
                       RACTuplePack(@"共计保费",amount,remark),
                       RACTuplePack(@"保险期限",_order.validperiod)];
    NSMutableArray *titles = [NSMutableArray arrayWithArray:array];
    if (_order.insordernumber.length > 0) {
        [titles safetyInsertObject:RACTuplePack(@"保单编号",_order.insordernumber) atIndex:0];
    }
    self.titles = titles;
    self.coverages = self.order.policy.subInsuranceArray;
    [self resetBottomButton];
    [self.tableView reloadData];
}

- (NSString *)strValueFrom:(id)value
{
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return @"";
}
#pragma mark - Action
- (void)actionPay:(id)sender {
    [MobClick event:@"rp319-1"];
    PayForInsuranceVC * vc = [insuranceStoryboard instantiateViewControllerWithIdentifier:@"PayForInsuranceVC"];
    vc.insOrder = self.order;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionMakeCall:(id)sender {
    if (self.order.status == InsuranceOrderStatusPaid) {
        [MobClick event:@"rp319-2"];
    }
    else if (self.order.status == InsuranceOrderStatusComplete){
        [MobClick event:@"rp319-3"];
    }
    [gPhoneHelper makePhone:@"4007111111" andInfo:@"咨询电话：4007-111-111"];
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKDatasourceLoadingType)type
{
    return @"该订单已消失";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKDatasourceLoadingType)type error:(NSError *)error
{
    return @"获取订单信息失败，点击重试";
}


- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKDatasourceLoadingType)type
{
    //保险订单详情接口试调
    GetInsuranceOrderDetailsOp * op = [GetInsuranceOrderDetailsOp operation];
    op.req_orderid = self.orderID;
    return [[op rac_postRequest] map:^id(GetInsuranceOrderDetailsOp *rspOp) {
        self.order = rspOp.rsp_order;
        return [NSArray arrayWithObject:rspOp.rsp_order];
    }];
}
- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKDatasourceLoadingType)type
{
    [self reloadWithOrderStatus:self.order.status];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        return 9+22+8+self.titles.count*22;
    }
    else if (indexPath.row == 2) {
        return 20+17+(self.coverages.count+1)*30;
    }
    return 96;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [self headerCellAtIndexPath:indexPath];
    }
    else if (indexPath.row == 1) {
        return [self itemUponCellAtIndexPath:indexPath];
    }
    return [self itemUnderCellAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - About Cell
- (UITableViewCell *)headerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
    UIImageView *line1 = (UIImageView *)[cell.contentView viewWithTag:1002];
    UIImageView *line2 = (UIImageView *)[cell.contentView viewWithTag:1004];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1006];
    
    [self resetStepViewInCell:cell highlight:(self.order.status == InsuranceOrderStatusUnpaid) baseTag:10010];
    [self resetStepViewInCell:cell highlight:(self.order.status == InsuranceOrderStatusPaid) baseTag:10030];
    [self resetStepViewInCell:cell highlight:(self.order.status == InsuranceOrderStatusComplete) baseTag:10050];
    
    line1.highlighted = self.order.status == InsuranceOrderStatusUnpaid || self.order.status == InsuranceOrderStatusPaid;
    line2.highlighted = self.order.status == InsuranceOrderStatusPaid || self.order.status == InsuranceOrderStatusComplete;
    
    switch (self.order.status) {
        case InsuranceOrderStatusUnpaid:
            titleL.text = @"请确认保单";
            break;
        case InsuranceOrderStatusPaid:
            titleL.text = @"保单正在处理中";
            break;
        case InsuranceOrderStatusComplete:
            titleL.text = @"保单将尽快寄出";
            break;
        default:
            titleL.text = [self.order descForCurrentStatus];
            break;
    }
    return cell;
}

- (void)resetStepViewInCell:(UITableViewCell *)cell highlight:(BOOL)highlight baseTag:(NSInteger)tag
{
    UIImageView *leftBg = (UIImageView *)[cell.contentView viewWithTag:tag+1];
    UIImageView *rightBg = (UIImageView *)[cell.contentView viewWithTag:tag+2];
    leftBg.highlighted = highlight;
    rightBg.highlighted = highlight;
}

- (UITableViewCell *)itemUponCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ItemUponCell" forIndexPath:indexPath];
    UIView *containerV = [cell.contentView viewWithTag:1000];
    //清除label
    [containerV.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    id uponV = containerV;
    for (RACTuple *item in self.titles) {
        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        leftLabel.textColor = HEXCOLOR(@"#8b9eb3");
        leftLabel.font = [UIFont systemFontOfSize:14];
        leftLabel.text = item[0];
        [containerV addSubview:leftLabel];
        
        UILabel *midLabel = leftLabel;
        
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        rightLabel.textColor = HEXCOLOR(@"#000000");
        rightLabel.font = [UIFont systemFontOfSize:14];
        id text = item[1];
        if ([text isKindOfClass:[NSString class]]) {
            text = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                                NSForegroundColorAttributeName:[UIColor blackColor]}];
        }
        rightLabel.attributedText = text;
        rightLabel.textAlignment = NSTextAlignmentRight;
        [containerV addSubview:rightLabel];
        
        id remark = [item third];
        if (remark && [remark isKindOfClass:[NSAttributedString class]]) {
            midLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            midLabel.textColor = HEXCOLOR(@"#000000");
            midLabel.font = [UIFont systemFontOfSize:14];
            midLabel.attributedText = remark;
            [containerV addSubview:midLabel];
            [midLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh  forAxis:UILayoutConstraintAxisHorizontal];
            [midLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(leftLabel);
                make.left.equalTo(leftLabel.mas_right);
                make.height.mas_equalTo(22);
            }];
        }
        
        [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(uponV);
            make.left.equalTo(containerV);
            make.height.mas_equalTo(22);
        }];
        
        [rightLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(leftLabel);
            make.left.equalTo(midLabel.mas_right);
            make.right.equalTo(containerV);
            make.height.mas_equalTo(22);
        }];
        
        uponV = leftLabel.mas_bottom;
    }
    return cell;
}

- (UITableViewCell *)itemUnderCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ItemUnderCell" forIndexPath:indexPath];
    UIView *containerV = [cell.contentView viewWithTag:1000];
    //清除label
    [containerV.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //第一行（标题）
    UILabel *leftL;
    UILabel *rightL;
    if (self.coverages.count > 0) {
        leftL = [self baseCoverageLabelForRight:NO uponView:nil leftView:nil containerView:containerV];
        leftL.textColor = HEXCOLOR(@"#444b54");
        leftL.text = @"承保险种";
        leftL.backgroundColor = HEXCOLOR(@"#dae7f7");
        [leftL showBorderLineWithDirectionMask:CKViewBorderDirectionLeft | CKViewBorderDirectionBottom | CKViewBorderDirectionTop];
        rightL = [self baseCoverageLabelForRight:YES uponView:nil leftView:leftL containerView:containerV];
        rightL.textColor = HEXCOLOR(@"#444b54");
        rightL.text = @"保险金额 / 责任限额(元)";
        rightL.backgroundColor = HEXCOLOR(@"#dae7f7");
        [rightL showBorderLineWithDirectionMask:CKViewBorderDirectionAll];
    }
    for (SubInsurance *item in self.coverages) {
        leftL = [self baseCoverageLabelForRight:NO uponView:leftL leftView:nil containerView:containerV];
        leftL.text = item.coveragerName;
        rightL = [self baseCoverageLabelForRight:YES uponView:rightL leftView:leftL containerView:containerV];
        if ([item.coveragerValue isKindOfClass:[NSNumber class]]) {
            rightL.text = [item.coveragerValue description];
        }
        else {
            rightL.text = item.coveragerValue;
        }
    }
    return cell;
}

- (UILabel *)baseCoverageLabelForRight:(BOOL)right uponView:(UIView *)uponV leftView:(UIView *)leftV containerView:(UIView *)containerV
{
    BorderLineLabel *label = [[BorderLineLabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:14];
    label.backgroundColor = HEXCOLOR(@"#f1f7fd");
    label.textColor = HEXCOLOR(@"#8b9eb3");
    [label setBorderLineColor:HEXCOLOR(@"#ccdbef") forDirectionMask:CKViewBorderDirectionAll];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.6;
    [containerV addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(uponV ? uponV.mas_bottom : containerV);
        make.left.equalTo(leftV ? leftV.mas_right : containerV);
        make.height.mas_equalTo(30);
        if (right) {
            make.right.equalTo(containerV);
        }
        if (leftV) {
            make.width.equalTo(leftV.mas_width).multipliedBy(5.0/4.0);
        }
    }];
    NSInteger mask = CKViewBorderDirectionLeft | CKViewBorderDirectionBottom;
    mask |= right ? CKViewBorderDirectionRight : 0;
    [label showBorderLineWithDirectionMask:mask];
    return label;
}

@end


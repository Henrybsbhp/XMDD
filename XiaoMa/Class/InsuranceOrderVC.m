//
//  InsuranceOrderVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/30.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceOrderVC.h"
#import "UIView+Layer.h"

typedef enum : NSInteger
{
    InsuranceOrderStatusWaiting,
    InsuranceOrderStatusPaid,
    InsuranceOrderStatusComplete
}InsuranceOrderStatus;
@interface InsuranceOrderVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (nonatomic, assign) InsuranceOrderStatus orderStatus;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *coverages;
@end

@implementation InsuranceOrderVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadWithOrderStatus:InsuranceOrderStatusWaiting];
}

- (void)resetBottomButton
{
    NSString *bgName;
    if (self.orderStatus == InsuranceOrderStatusWaiting) {
        bgName = @"ins_btn_bg4";
    }
    else {
        bgName = @"ins_btn_bg5";
    }
    UIImage *bg = [[UIImage imageNamed:bgName] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.bottomButton setBackgroundImage:bg forState:UIControlStateNormal];

}
#pragma mark - Load
- (void)reloadWithOrderStatus:(InsuranceOrderStatus)status
{
    self.orderStatus = status;
    self.titles = @[@[@"被保险人",@"李美美"],
                    @[@"保险公司",@"太平保险"],
                    @[@"证件号码",@"330100101001010011"],
                    @[@"投保车辆",@"浙A12345"],
                    @[@"共计保费",@"￥4500.00"],
                    @[@"保险期限",@"2015.06.01-2016.06.01"]];
    self.coverages = @[@[@"机动车损失险",@"359555.00"],
                       @[@"车上乘客责任险",@"1000.00/座*4座"],
                       @[@"第三责任险",@"500000.00"],
                       @[@"不计免赔险",@"1000.00/座*1座"],
                       @[@"交强险",@"950.00"]];
    [self resetBottomButton];
    [self.tableView reloadData];
}
#pragma mark - Action
- (IBAction)actionPay:(id)sender {
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        return 9+22+8+self.titles.count*18;
    }
    else if (indexPath.row == 2) {
        return 10+(self.coverages.count+1)*30;
    }
    return 90;
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

#pragma mark - About Cell
- (UITableViewCell *)headerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
    UIImageView *line1 = (UIImageView *)[cell.contentView viewWithTag:1002];
    UIImageView *line2 = (UIImageView *)[cell.contentView viewWithTag:1004];
    [self resetStepViewInCell:cell highlight:(self.orderStatus == InsuranceOrderStatusWaiting) baseTag:10010];
    [self resetStepViewInCell:cell highlight:(self.orderStatus == InsuranceOrderStatusPaid) baseTag:30010];
    [self resetStepViewInCell:cell highlight:(self.orderStatus == InsuranceOrderStatusComplete) baseTag:50010];
    line1.highlighted = self.orderStatus != InsuranceOrderStatusComplete;
    line2.highlighted = self.orderStatus != InsuranceOrderStatusWaiting;
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
    UIView *uponV;
    for (NSArray *item in self.titles) {
        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        leftLabel.textColor = HEXCOLOR(@"#8b9e83");
        leftLabel.font = [UIFont systemFontOfSize:14];
        leftLabel.text = [item safetyObjectAtIndex:0];
        [containerV addSubview:leftLabel];
        
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        rightLabel.textColor = HEXCOLOR(@"#000000");
        rightLabel.font = [UIFont systemFontOfSize:14];
        rightLabel.text = [item safetyObjectAtIndex:1];
        [containerV addSubview:rightLabel];

        uponV = containerV;
        [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(uponV).offset(4);
            make.left.equalTo(containerV);
        }];
        [rightLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(leftLabel);
            make.left.equalTo(leftLabel);
            make.right.equalTo(containerV);
        }];
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
        leftL = [self baseCoverageLabelForRight:NO uponView:containerV leftView:containerV containerView:containerV];
        leftL.textColor = HEXCOLOR(@"#444b54");
        leftL.text = @"承保险种";
        leftL.backgroundColor = HEXCOLOR(@"#dae7f7");
        rightL = [self baseCoverageLabelForRight:YES uponView:containerV leftView:leftL containerView:containerV];
        rightL.textColor = HEXCOLOR(@"#444b54");
        rightL.text = @"保险金额 / 责任限额(元)";
        rightL.backgroundColor = HEXCOLOR(@"#dae7f7");
    }
    for (NSArray *item in self.coverages) {
        leftL = [self baseCoverageLabelForRight:NO uponView:leftL leftView:containerV containerView:containerV];
        leftL.text = [item safetyObjectAtIndex:0];
        rightL = [self baseCoverageLabelForRight:YES uponView:rightL leftView:leftL containerView:containerV];
        rightL.text = [item safetyObjectAtIndex:1];
    }
    return cell;
}

- (UILabel *)baseCoverageLabelForRight:(BOOL)right uponView:(UIView *)uponV leftView:(UIView *)leftV containerView:(UIView *)containerV
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:14];
    label.backgroundColor = HEXCOLOR(@"#f1f7fd");
    label.textColor = HEXCOLOR(@"#8b9e83");
    [label setBorderLineColor:HEXCOLOR(@"#ccdbef") forDirectionMask:CKViewBorderDirectionAll];
    [containerV addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(uponV);
        make.left.equalTo(leftV);
        make.height.mas_equalTo(30);
        if (right) {
            make.right.equalTo(containerV);
        }
    }];
    
    return label;
}

@end


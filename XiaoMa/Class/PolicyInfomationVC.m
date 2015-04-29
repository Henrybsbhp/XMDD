//
//  PolicyInfomationVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PolicyInfomationVC.h"
#import "XiaoMa.h"
#import "UIView+Layer.h"
#import "PayForPolicyVC.h"
#import <Masonry.h>

@interface PolicyInfomationVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *coveragers;
@end

@implementation PolicyInfomationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadDatasource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadDatasource
{
    SubInsurance *head = [SubInsurance new];
    head.coveragerName = @"承保险种";
    head.coveragerValue = @"保险金额/责任限额（元）";
    NSMutableArray *coveragers = [NSMutableArray arrayWithObject:head];
    
    if (self.insuranceOp) {
        GetInsuranceByChannelOp *op = self.insuranceOp;
        self.titles = @[RACTuplePack(@"被保险人：", op.rsp_policyholder),
                        RACTuplePack(@"车牌号码：", op.rsp_licencenumber),
                        RACTuplePack(@"证件号码：", op.rsp_idnumber),
                        RACTuplePack(@"保险公司：", op.rsp_inscomp),
                        RACTuplePack(@"保险期限：", op.rsp_insperiod),
                        RACTuplePack(@"保费总额：", op.rsp_totalpay)];
        [coveragers safetyAddObjectsFromArray:self.insuranceOp.rsp_policy.subInsuranceArray];
    }
    else {
        [coveragers safetyAddObjectsFromArray:self.policy.subInsuranceArray];
    }
    
    self.coveragers = coveragers;
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionNext:(id)sender
{
    PayForPolicyVC *vc = [UIStoryboard vcWithId:@"PayForPolicyVC" inStoryboard:@"Insurance"];
    vc.insuranceOp = self.insuranceOp;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate and dataoource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 10;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 26;
    }
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.titles.count;
    }
    return self.coveragers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self titleCellAtIndexPath:indexPath];
    }
    return [self gridCellAtIndexPath:indexPath];
}

- (UITableViewCell *)titleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TitleCell" forIndexPath:indexPath];
    RACTuple *tuple = [self.titles safetyObjectAtIndex:indexPath.row];
    UILabel *leftL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *rightL = (UILabel *)[cell.contentView viewWithTag:1002];
    leftL.text = tuple.first;
    rightL.text = tuple.second;
    return cell;
}

- (UITableViewCell *)gridCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GridCell" forIndexPath:indexPath];
    SubInsurance *item = [self.coveragers safetyObjectAtIndex:indexPath.row];
    UILabel *leftL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *rightL = (UILabel *)[cell.contentView viewWithTag:1002];
    leftL.text = item.coveragerName;
    rightL.text = item.coveragerValue;
    NSInteger leftLineMask, rightLineMask;
    if (indexPath.row == 0) {
        leftL.backgroundColor  = HEXCOLOR(@"#eaeaea");
        rightL.backgroundColor = HEXCOLOR(@"#eaeaea");
        leftLineMask = CKViewBorderDirectionTop | CKViewBorderDirectionLeft |
                        CKViewBorderDirectionBottom | CKViewBorderDirectionRight;
        rightLineMask = CKViewBorderDirectionRight | CKViewBorderDirectionBottom | CKViewBorderDirectionTop;
    }
    else {
        leftL.backgroundColor  = HEXCOLOR(@"#f7f7f7");
        rightL.backgroundColor = HEXCOLOR(@"#f7f7f7");
        leftLineMask = CKViewBorderDirectionLeft | CKViewBorderDirectionRight | CKViewBorderDirectionBottom;
        rightLineMask = CKViewBorderDirectionRight | CKViewBorderDirectionBottom;
    }
    [leftL setBorderLineColor:kDefLineColor forDirectionMask:leftLineMask];
    [leftL showBorderLineWithDirectionMask:leftLineMask];
    [rightL setBorderLineColor:kDefLineColor forDirectionMask:rightLineMask];
    [rightL showBorderLineWithDirectionMask:rightLineMask];
    
    return cell;
}

@end

//
//  GasRecordVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/10/16.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GasRecordVC.h"

@interface GasRecordVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UILabel *headLabel;

@end

@implementation GasRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setHeadLabelText];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setHeadLabelText
{
    NSDictionary * dic1 = @{NSFontAttributeName:[UIFont systemFontOfSize:13]};
    NSDictionary * dic2 = @{NSFontAttributeName:[UIFont systemFontOfSize:15]};
    NSInteger recharge = 20000;
    NSInteger discount = 2000;
    NSMutableAttributedString * attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"今年您的油卡充值了%ld元，", (long)recharge] attributes:dic1];
    NSAttributedString * attributedStr2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"总计优惠了%ld元", (long)discount] attributes:dic2];
    [attributedStr appendAttributedString:attributedStr2];
    self.headLabel.attributedText = attributedStr;
    
}

#pragma mark - UITableViewDelegate and datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 137;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RecordCell" forIndexPath:indexPath];
    UILabel * timeLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    UIImage * logoImg = (UIImage *)[cell.contentView viewWithTag:1002];
    UILabel * cardnumLbabel = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel * rechargeLabel = (UILabel *)[cell.contentView viewWithTag:1006];
    UILabel * payLabel = (UILabel *)[cell.contentView viewWithTag:1007];
    UILabel * stateLabel = (UILabel *)[cell.contentView viewWithTag:1008];
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end

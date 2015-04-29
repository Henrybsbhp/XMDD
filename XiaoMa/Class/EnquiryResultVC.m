//
//  EnquiryResultVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "EnquiryResultVC.h"
#import "XiaoMa.h"
#import "UploadInfomationVC.h"
#import "SimplePolicyInfoVC.h"
#import "HKInsurance.h"

@interface EnquiryResultVC ()

@end

@implementation EnquiryResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadWithInsurance:(NSArray *)insurances calculatorID:(NSString *)cid
{
    _insurances = insurances;
    _calculatorID = cid;
    [self.tableView reloadData];
}
#pragma mark - Action
- (IBAction)actionUploadInfomation:(id)sender
{
    UploadInfomationVC *vc = [UIStoryboard vcWithId:@"UploadInfomationVC" inStoryboard:@"Insurance"];
    vc.calculateID = self.calculatorID;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.insurances.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *badgeL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1003];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:1004];
    HKInsurance *ins = [self.insurances safetyObjectAtIndex:indexPath.row];
    
    badgeL.text = ins.insuranceName;
    badgeL.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_2_PI/0.98);
    titleL.text = @"参考价格为：";//[NSString stringWithFormat:@"您的爱车%@保险参考价格为：", ins.insuranceName];
    priceL.text = [NSString stringWithFormat:@"￥%d", (int)ins.premium];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimplePolicyInfoVC *vc = [UIStoryboard vcWithId:@"SimplePolicyInfoVC" inStoryboard:@"Insurance"];
    vc.policy = [self.insurances safetyObjectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

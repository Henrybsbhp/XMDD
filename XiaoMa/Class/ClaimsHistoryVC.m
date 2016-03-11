//
//  ClaimsHistoryVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/3.
//  Copyright © 2016年 huika. All rights reserved.
//
#import "HKInclinedLabel.h"
#import "ClaimsHistoryVC.h"

@interface ClaimsHistoryVC () <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ClaimsHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDelegate,UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 10;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    HKInclinedLabel *hkLabel = [cell viewWithTag:101];
    hkLabel.text = @"理赔中";
    hkLabel.backgroundColor = [UIColor clearColor];
    hkLabel.trapeziumColor = [UIColor colorWithHex:@"#ff7428" alpha:1];
    hkLabel.textColor = [UIColor whiteColor];
    UIView *backView = [cell viewWithTag:1000];
    backView.layer.cornerRadius = 5;
    backView.layer.masksToBounds = YES;
    
    UILabel *detaiLabel = [cell viewWithTag:1002];
    detaiLabel.preferredMaxLayoutWidth = cell.bounds.size.width - 35;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 15;
    }
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

#pragma mark Action

- (IBAction)callAction:(id)sender {
    NSString * number = @"4007111111";
    [gPhoneHelper makePhone:number andInfo:@"投诉建议,商户加盟等\n请拨打客服电话: 4007-111-111"];
}

@end

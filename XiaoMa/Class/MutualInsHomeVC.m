//
//  MutualInsHomeVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/3.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsHomeVC.h"
#import "AutoGroupInfoVC.h"
#import "GroupIntroductionVC.h"
#import "InviteByCodeVC.h"
#import "AskClaimsVC.h"

@interface MutualInsHomeVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MutualInsHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3 + 1 + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 21;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        return 60;
    }
    else if (indexPath.row == 3) {
        return 50;
    }
    else if (indexPath.row > 3) {
        return 150;
    }
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 2) {
        cell = [self btnCellAtIndexPath:indexPath];
    }
    else if (indexPath.row == 3) {
        cell = [self sectionCellAtIndexPath:indexPath];
    }
    else if (indexPath.row == 4) {
        cell = [self myGroupCellCellAtIndexPath:indexPath];
    }
    else {
        cell = [self groupCellAtIndexPath:indexPath];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 1) {
        GroupIntroductionVC * vc = [UIStoryboard vcWithId:@"GroupIntroductionVC" inStoryboard:@"MutualInsJoin"];
        vc.titleStr = @"匹配团介绍";
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row > 3) {
        //我的团详情页面
    }
}

#pragma mark - About Cell
- (UITableViewCell *)groupCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"GroupTypeCell" forIndexPath:indexPath];
    UIView *leftView = (UIView *)[cell.contentView viewWithTag:1001];
    UIImageView *logoImgV = (UIImageView *)[cell.contentView viewWithTag:1002];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1003];
    UILabel *detailLabel = (UILabel *)[cell.contentView viewWithTag:1004];
    
    if (indexPath.row == 0) {
        leftView.backgroundColor = HEXCOLOR(@"#FFBA36");
        logoImgV.image = [UIImage imageNamed:@"mutualIns_home_self"];
        titleLabel.text = @"自组互助团";
        detailLabel.text = @"熟人组团，省钱有保障";
    }
    else {
        leftView.backgroundColor = HEXCOLOR(@"#38B3FF");
        logoImgV.image = [UIImage imageNamed:@"mutualIns_home_match"];
        titleLabel.text = @"平台互助团";
        detailLabel.text = @"好司机参团，方便又省心";
    }
    
    return cell;
}

- (UITableViewCell *)btnCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"BtnCell" forIndexPath:indexPath];
    UIButton *checkBtn = (UIButton *)[cell.contentView viewWithTag:1001];
    UIButton *payBtn = (UIButton *)[cell.contentView viewWithTag:1002];
    
    //我要核价
    [[[checkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
    }];
    //我要理赔
    [[[payBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        AskClaimsVC *test = [UIStoryboard vcWithId:@"AskClaimsVC" inStoryboard:@"MutualInsClaims"];
        [self.navigationController pushViewController:test animated:YES];
        return;
    }];
    
    return cell;
}

- (UITableViewCell *)sectionCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"SectionCell" forIndexPath:indexPath];
    return cell;
}

- (UITableViewCell *)myGroupCellCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"MyGroupCell" forIndexPath:indexPath];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *carIdLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *statusLabel = (UILabel *)[cell.contentView viewWithTag:1003];
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:1004];
    UIButton *opeBtn = (UIButton *)[cell.contentView viewWithTag:1005];
    
    nameLabel.text = @"史上最强大脑团";
    carIdLabel.text = @"浙A66666";
    statusLabel.text = @"组团中，资料审核不通过，无法加入该团";
    timeLabel.text = @"有效期：\n 2016.03.10-2016.03.22";
    [[[opeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        InviteByCodeVC * vc = [UIStoryboard vcWithId:@"InviteByCodeVC" inStoryboard:@"MutualInsJoin"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    return cell;
}


@end

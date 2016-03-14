//
//  InviteByCodeVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "InviteByCodeVC.h"

@interface InviteByCodeVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation InviteByCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        self.tableView.estimatedRowHeight = 26; //估算高度
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate and datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 5;
    }
    return 4;
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
    if (indexPath.row == 0) {
        if (indexPath.section == 0) {
            return 44;
        }
        else {
            return 40;
        }
    }
    else if (indexPath.row == 3) {
        return 75;
    }
    else {
        if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
        {
            return UITableViewAutomaticDimension;
        }
        
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        [cell layoutIfNeeded];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
        return ceil(size.height+1);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        if (indexPath.section == 0) {
            cell = [self codeCellAtIndexPath:indexPath];
        }
        else {
            cell = [self headerCellAtIndexPath:indexPath];
        }
    }
    else if (indexPath.row == 3) {
        cell = [self btnCellAtIndexPath:indexPath];
    }
    else {
        cell = [self contentCellAtIndexPath:indexPath];
    }
    return cell;
}

- (UITableViewCell *)codeCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"CodeCell" forIndexPath:indexPath];
    UILabel *codeLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    UIButton *copyBtn = (UIButton *)[cell.contentView viewWithTag:1002];
    codeLabel.text = @"团队暗号：HK123456";
    
    [copyBtn setTitle:@"复制暗号" forState:UIControlStateNormal];
    [copyBtn setCornerRadius:5];
    [copyBtn setBorderColor:HEXCOLOR(@"#18d05a")];
    [copyBtn setBorderWidth:1];
    
    
    return cell;
}

- (UITableViewCell *)headerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    if (indexPath.section == 1) {
        titleLabel.text = @"已下载小马达达";
    }
    else {
        titleLabel.text = @"未下载小马达达";
    }
    return cell;
}

- (UITableViewCell *)btnCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"BtnCell" forIndexPath:indexPath];
    UIButton *btn = (UIButton *)[cell.contentView viewWithTag:1001];
    if (indexPath.section == 1) {
        [btn setTitle:@"分享入团口令" forState:UIControlStateNormal];
        [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
        }];
    }
    else {
        [btn setTitle:@"邀请好友下载小马达达" forState:UIControlStateNormal];
        [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
        }];
    }
    return cell;
}

- (UITableViewCell *)contentCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContentCell" forIndexPath:indexPath];
    UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            contentLabel.text = @"1、您需要啊煽风点火爱迪生发斯蒂芬";
        }
        else if (indexPath.row == 2) {
            contentLabel.text = @"2、您需要啊煽风点火爱迪生发斯蒂芬爱的发的苏发的苏";
        }
        else {
            contentLabel.text = @"您需要啊煽风sa点火afsd f打撒大佛啊舌尖的佛教事件发送放假就覅啥地方就暗示法阿飞的说法啊手机防盗是爱迪生发斯蒂芬 \n ";
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 1) {
            contentLabel.text = @"1、sectio2答复还是个冯绍峰的需要啊煽风点火爱迪生发斯蒂芬";
        }
        else {
            contentLabel.text = @"2、第二行大幅度发撒大佛苏";
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end

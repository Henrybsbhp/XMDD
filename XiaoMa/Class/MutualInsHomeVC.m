//
//  MutualInsHomeVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/3.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsHomeVC.h"

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
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        return 56;
    }
    else if (indexPath.row == 3) {
        return 50;
    }
    else if (indexPath.row > 3) {
        return 195;
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

- (UITableViewCell *)groupCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"GroupTypeCell" forIndexPath:indexPath];
    UIImageView *backgroundView = (UIImageView *)[cell.contentView viewWithTag:1001];
    
    return cell;
}

- (UITableViewCell *)btnCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"BtnCell" forIndexPath:indexPath];
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
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end

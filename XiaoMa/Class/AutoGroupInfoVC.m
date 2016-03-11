//
//  AutoGroupInfoVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/3.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "AutoGroupInfoVC.h"
#import "CarListVC.h"

@interface AutoGroupInfoVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AutoGroupInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 15;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 42;
    }
    else if (indexPath.row == 4) {
        return 50;
    }
    return 23;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [self headerCellAtIndexPath:indexPath];
    }
    else if (indexPath.row == 4) {
        cell = [self footerCellAtIndexPath:indexPath];
    }
    else {
        cell = [self infoCellAtIndexPath:indexPath];
    }
    return cell;
}

- (UITableViewCell *)headerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
    UIImageView *backgroundView = (UIImageView *)[cell.contentView viewWithTag:1001];
    return cell;
}

- (UITableViewCell *)infoCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
    return cell;
}

- (UITableViewCell *)footerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"FooterCell" forIndexPath:indexPath];
    UILabel *tagLabel = (UILabel *)[cell.contentView viewWithTag:101];
    [tagLabel setCornerRadius:12];
    [tagLabel setBorderColor:HEXCOLOR(@"#ff7428")];
    [tagLabel setBorderWidth:0.5];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CarListVC *vc = [UIStoryboard vcWithId:@"CarListVC" inStoryboard:@"Car"];
    vc.title = @"选择爱车";
    vc.model.allowAutoChangeSelectedCar = YES;
    vc.model.disableEditingCar = YES; //不可修改
    vc.model.originVC = self;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end

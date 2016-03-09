//
//  EditInsInfoVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "EditInsInfoVC.h"

@interface EditInsInfoVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EditInsInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate and datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 12, 0, 0)];
    headerLabel.textColor = HEXCOLOR(@"#888888");
    headerLabel.font = [UIFont systemFontOfSize:16];
    if (section == 0) {
        headerLabel.text = @"请上传车主身份证照片";
    }
    else if (section == 1) {
        headerLabel.text = @"请上传车主行驶证照片";
    }
    else {
        headerLabel.text = @"请选择保险公司";
    }
    [headerLabel sizeToFit];
    [view addSubview:headerLabel];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return 15;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
        return 166;
    }
    return 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0 || indexPath.section == 1) {
        cell = [self sImageCellAtIndexPath:indexPath];
    }
    else {
        cell = [self sOtherCellAtIndexPath:indexPath];
    }
    return cell;
}

- (UITableViewCell *)sImageCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"SelectImgCell" forIndexPath:indexPath];
    UIImageView *backgroundView = (UIImageView *)[cell.contentView viewWithTag:1001];
    return cell;
}

- (UITableViewCell *)sOtherCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"SelectOtherCell" forIndexPath:indexPath];
    UIImageView *backgroundView = (UIImageView *)[cell.contentView viewWithTag:1001];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end

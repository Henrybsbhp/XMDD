//
//  JoinResultViewController.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/25.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "JoinResultViewController.h"

@interface JoinResultViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JoinResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 50;
    }
    else if (indexPath.row == 4) {
        return 34;
    }
    else {
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"TitleCell" forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.row == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FooterCell" forIndexPath:indexPath];
        UILabel * footL = (UILabel *)[cell.contentView viewWithTag:1001];
        footL.text = self.tip;
        return cell;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ContentCell" forIndexPath:indexPath];
        UILabel * contentL = (UILabel *)[cell.contentView viewWithTag:1001];
        if (indexPath.row == 1) {
            contentL.text = [NSString stringWithFormat:@"手机：%@", self.phone];
        }
        else if (indexPath.row == 2) {
            contentL.text = [NSString stringWithFormat:@"姓名：%@", self.name];
        }
        else {
            contentL.text = [NSString stringWithFormat:@"城市：%@", self.address];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)actionBack:(id)sender
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers safetyObjectAtIndex:1] animated:YES];
}

- (void)dealloc {
    DebugLog(@"dealloc~~");
}

@end

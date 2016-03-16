//
//  ClaimAccountVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/15.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ClaimAccountVC.h"

@interface ClaimAccountVC ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIButton *addBtn;

@end

@implementation ClaimAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setupUI
{
    self.addBtn.layer.cornerRadius = 5;
    self.addBtn.layer.masksToBounds = YES;
}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0 || indexPath.section == 3)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
        UILabel *titleLb = [cell viewWithTag:100];
        titleLb.text = indexPath.section == 0 ? @"已有账户" : @"添加其他理赔账户";
    }
    else if(indexPath.section == 1 || indexPath.section == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"selectCell"];
        UIImageView *img = [cell viewWithTag:100];
        UILabel *cardNumLb = [cell viewWithTag:101];
        cardNumLb.layer.cornerRadius = 3;
        cardNumLb.layer.masksToBounds = YES;
        cardNumLb.backgroundColor = [UIColor colorWithHex:@"#f7f7f8" alpha:1];
    }
    else if (indexPath.section == 4 || indexPath.section ==5)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"inputCell"];
        UITextField *textField = [cell viewWithTag:100];
        textField.placeholder = indexPath.section == 4 ? @"请输入银行卡号":@"请再次输入银行卡号";
        textField.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
        textField.layer.borderWidth = 1;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"chooseCell"];
        UIView *backgroundView = [cell viewWithTag:100];
        backgroundView.layer.borderWidth = 1;
        backgroundView.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 44;
    }
    else if (indexPath.section == 1 || indexPath.section == 2)
    {
        return 55;
    }
    else if (indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 6)
    {
        return 60;
    }
    else
    {
        return 50;
    }
}

@end

//
//  MutualInsPayResultVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsPayResultVC.h"

@interface MutualInsPayResultVC ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MutualInsPayResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"resultCell"];
    }
    else if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell"];
        UIView *backgoundView = [cell viewWithTag:100];
        backgoundView.layer.borderWidth = 1;
        backgoundView.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
    }
    else if (indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"inputCell"];
        UILabel *title = [cell viewWithTag:100];
        UITextField *textField = [cell viewWithTag:101];
        textField.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
        textField.layer.borderWidth = 1;
        switch (indexPath.section)
        {
            case 2:
                title.text = @"联系人姓名";
                break;
            case 3:
                title.text = @"联系人手机";
                break;
            default:
                title.text = @"协议寄送地址";
                textField.hidden = YES;
                break;
        }
    }
    else if (indexPath.section == 5)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"districtCell"];
        UITextField *textField = [cell viewWithTag:101];
        textField.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
        textField.layer.borderWidth = 1;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 48;
    }
    else if (indexPath.section == 1)
    {
        return 140;
    }
    else if (indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 5)
    {
        return 53;
    }
    return 30;
}

-(void)setupUI
{
    self.tableView.tableFooterView = [UIView new];
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
}

@end

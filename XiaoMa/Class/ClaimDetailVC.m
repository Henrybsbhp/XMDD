//
//  ClaimDetailVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ClaimDetailVC.h"

@interface ClaimDetailVC ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIButton *agreeBtn;
@property (strong, nonatomic) IBOutlet UIButton *disagreeBtn;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ClaimDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return 2;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"noticeCell"];
        UILabel *label = [cell viewWithTag:100];
    }
    return cell;
}

#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 60;
    }
    return 44;
}

#pragma mark Action

- (IBAction)call:(id)sender {
    NSString * number = @"4007111111";
    [gPhoneHelper makePhone:number andInfo:@"投诉建议,商户加盟等\n请拨打客服电话: 4007-111-111"];
}



#pragma mark Init

-(void)setupUI
{
    self.agreeBtn.layer.cornerRadius = 5;
    self.agreeBtn.layer.masksToBounds = YES;
    self.disagreeBtn.layer.cornerRadius = 5;
    self.disagreeBtn.layer.masksToBounds = YES;
    self.disagreeBtn.layer.borderColor = [[UIColor colorWithHex:@"#18D06A" alpha:1]CGColor];
    self.disagreeBtn.layer.borderWidth = 1;
    
    self.tableView.tableFooterView = [UIView new];
}

@end

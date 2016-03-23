//
//  MutualInsDicountVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/18.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsActivityVC.h"

@interface MutualInsActivityVC ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MutualInsActivityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UILabel *label = [cell viewWithTag:101];
    
    NSString * str = [self.dataArr safetyObjectAtIndex:indexPath.row];
    label.text = str;
    return cell;
}


#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark Init

-(void)setupUI
{
    self.tableView.tableFooterView = [[UIView alloc]init];
}

@end

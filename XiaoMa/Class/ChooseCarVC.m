//
//  ChooseCarVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ChooseCarVC.h"
#import "ScencePageVC.h"


@interface ChooseCarVC () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSArray *dataArr;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *indexPth;
@property (nonatomic,strong) NSString *licensenumber;

@end

@implementation ChooseCarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.reports.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *report = [self.reports safetyObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UIImageView *carLogo = [cell viewWithTag:100];
    [carLogo sd_setImageWithURL:report[@"brandlogo"]];
    UILabel *carNum = [cell viewWithTag:101];
    carNum.text = report[@"licensenumber"];
    UILabel *carInfo = [cell viewWithTag:102];
    carInfo.text = report[@"brandname"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *report = [self.reports safetyObjectAtIndex:indexPath.row];
    ScencePageVC *scencePageVC = [UIStoryboard vcWithId:@"ScencePageVC" inStoryboard:@"MutualInsClaims"];
    scencePageVC.claimid = report[@"claimid"];
    [self.navigationController pushViewController:scencePageVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark LazyLoad

-(NSArray *)dataArr
{
    if (!_dataArr)
    {
        _dataArr = [[NSArray alloc]init];
    }
    return _dataArr;
}

-(NSIndexPath *)indexPth
{
    if (!_indexPth)
    {
        _indexPth = [[NSIndexPath alloc]init];
    }
    return _indexPth;
}

#pragma mark Init

-(void)setupUI
{
    self.tableView.tableFooterView = [UIView new];
}

@end

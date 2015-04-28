//
//  SimplePolicyInfoVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/27.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "SimplePolicyInfoVC.h"
#import "UIView+Layer.h"

@interface SimplePolicyInfoVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *coveragers;
@end

@implementation SimplePolicyInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadDatasource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadDatasource
{
    SubInsurance *head = [SubInsurance new];
    head.coveragerName = @"承保险种";
    head.coveragerValue = @"保险金额/责任限额（元）";
    NSMutableArray *coveragers = [NSMutableArray arrayWithObject:head];
    [coveragers safetyAddObjectsFromArray:self.policy.subInsuranceArray];
    self.coveragers = coveragers;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate and dataoource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.coveragers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GridCell" forIndexPath:indexPath];
    SubInsurance *item = [self.coveragers safetyObjectAtIndex:indexPath.row];
    UILabel *leftL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *rightL = (UILabel *)[cell.contentView viewWithTag:1002];
    leftL.text = item.coveragerName;
    rightL.text = item.coveragerValue;
    NSInteger leftLineMask, rightLineMask;
    if (indexPath.row == 0) {
        leftL.backgroundColor  = HEXCOLOR(@"#eaeaea");
        rightL.backgroundColor = HEXCOLOR(@"#eaeaea");
        leftLineMask = CKViewBorderDirectionTop | CKViewBorderDirectionLeft |
        CKViewBorderDirectionBottom | CKViewBorderDirectionRight;
        rightLineMask = CKViewBorderDirectionRight | CKViewBorderDirectionBottom | CKViewBorderDirectionTop;
    }
    else {
        leftL.backgroundColor  = HEXCOLOR(@"#f7f7f7");
        rightL.backgroundColor = HEXCOLOR(@"#f7f7f7");
        leftLineMask = CKViewBorderDirectionLeft | CKViewBorderDirectionRight | CKViewBorderDirectionBottom;
        rightLineMask = CKViewBorderDirectionRight | CKViewBorderDirectionBottom;
    }
    [leftL setBorderLineColor:kDefLineColor forDirectionMask:leftLineMask];
    [leftL showBorderLineWithDirectionMask:leftLineMask];
    [rightL setBorderLineColor:kDefLineColor forDirectionMask:rightLineMask];
    [rightL showBorderLineWithDirectionMask:rightLineMask];
    
    return cell;
}

@end

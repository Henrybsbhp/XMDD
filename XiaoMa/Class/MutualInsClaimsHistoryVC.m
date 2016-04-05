//
//  MutualInsClaimsHistoryVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/3.
//  Copyright © 2016年 huika. All rights reserved.
//
#import "HKInclinedLabel.h"
#import "MutualInsClaimsHistoryVC.h"
#import "GetCooperationClaimsListOp.h"
#import "MutualInsClaimInfo.h"
#import "MutualInsClaimDetailVC.h"
#import "NSString+Price.h"
#import "NSDate+DateForText.h"
#import "HKImageAlertVC.h"

@interface MutualInsClaimsHistoryVC ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *dataArr;
@property (strong, nonatomic) HKImageAlertVC *alert;
@end

@implementation MutualInsClaimsHistoryVC

-(void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MutualInsClaimsHistoryVC dealloc");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    @weakify(self)
    [[self.tableView.refreshView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self loadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MutualInsClaimInfo *model = [self.dataArr safetyObjectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self addCorner:cell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    HKInclinedLabel *hkLabel = [cell viewWithTag:101];
    hkLabel.text = model.statusdesc;
    NSLog(@"%lf",hkLabel.frame.size.width);
    hkLabel.backgroundColor = [UIColor clearColor];
    if (model.detailstatus < 3)
    {
        hkLabel.trapeziumColor = [UIColor colorWithHex:@"#ff7428" alpha:1];
    }
    else
    {
        hkLabel.trapeziumColor = [UIColor colorWithHex:@"#18D06A" alpha:1];
    }
    hkLabel.textColor = [UIColor whiteColor];

    UIView *backView = [cell viewWithTag:1000];
    [self addCorner:backView];
    
    UILabel *detaiLabel = [cell viewWithTag:1002];
    detaiLabel.preferredMaxLayoutWidth = cell.bounds.size.width - 35;
    detaiLabel.text = [NSString stringWithFormat:@"事故概述：%@",model.accidentdesc];
    UILabel *priceLabel = [cell viewWithTag:1003];
    priceLabel.text = [NSString formatForPriceWithFloat:model.claimfee];
    UILabel *statusLabel = [cell viewWithTag:1004];
    statusLabel.text = model.detailstatusdesc;
    
    UILabel *timeLabel = [cell viewWithTag:1005];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy.MM.dd HH:mm"];
    timeLabel.text = [format stringFromDate:[NSDate dateWithUTS:model.lstupdatetime]];
    return cell;
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MutualInsClaimInfo *model = [self.dataArr safetyObjectAtIndex:indexPath.section];
    MutualInsClaimDetailVC *detailVC = [[UIStoryboard storyboardWithName:@"MutualInsClaims" bundle:nil]instantiateViewControllerWithIdentifier:@"MutualInsClaimDetailVC"];
    detailVC.claimid = model.claimid;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 15;
    }
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

#pragma mark Utility

-(void)addCorner:(UIView *)view
{
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
}

-(void)loadData
{
    GetCooperationClaimsListOp *op = [GetCooperationClaimsListOp new];
    [[[op rac_postRequest]initially:^{
        [self.tableView.refreshView beginRefreshing];
    }]subscribeNext:^(id x) {
        self.dataArr = op.rsp_claimlist;
        [self.tableView reloadData];
        [self.tableView.refreshView endRefreshing];
        if (self.dataArr.count == 0)
        {
            self.tableView.hidden = YES;
            [self.view showDefaultEmptyViewWithText:@"暂无理赔记录"];
        }
        
    }error:^(NSError *error) {
        [self.tableView.refreshView endRefreshing];
    }];
}


#pragma mark Action

- (IBAction)callAction:(id)sender {
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#18d06a") clickBlock:^(id alertVC) {
        [alertVC dismiss];
    }];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#18d06a") clickBlock:^(id alertVC) {
        [alertVC dismiss];
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKAlertVC *alert = [self alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"如有任何疑问，可拨打客服电话：4007-111-111" ActionItems:@[cancel,confirm]];
    [alert show];
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

-(HKImageAlertVC *)alertWithTopTitle:(NSString *)topTitle ImageName:(NSString *)imageName Message:(NSString *)message ActionItems:(NSArray *)actionItems
{
    if (!_alert)
    {
        _alert = [[HKImageAlertVC alloc]init];
    }
    _alert.topTitle = topTitle;
    _alert.imageName = imageName;
    _alert.message = message;
    _alert.actionItems = actionItems;
    return _alert;
}

@end

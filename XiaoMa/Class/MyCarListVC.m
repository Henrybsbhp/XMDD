//
//  MyCarListVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/5.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyCarListVC.h"
#import "GetUserCarOp.h"
#import "EditMyCarVC.h"
#import "XiaoMa.h"

@interface MyCarListVC ()<UITableViewDataSource, UITableViewDelegate,JTTableViewDelegate>
@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (nonatomic, strong) NSArray *carList;
@end

@implementation MyCarListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView.refreshView addTarget:self action:@selector(reloadDatasource) forControlEvents:UIControlEventValueChanged];
    [self setupSignals];
    [self reloadDatasource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setupSignals
{
    [self listenNotificationByName:kNotifyRefreshMyCarList withNotifyBlock:^(NSNotification *note, id weakSelf) {
        [weakSelf reloadDatasource];
    }];
}

- (void)reloadDatasource
{
    GetUserCarOp *op = [GetUserCarOp new];
    [[[[op rac_postRequest] deliverOn:[RACScheduler mainThreadScheduler]] initially:^{
        [self.tableView.refreshView beginRefreshing];
    }] subscribeNext:^(GetUserCarOp *rspOp) {
        [self.tableView.refreshView endRefreshing];
        self.carList = rspOp.rsp_carArray;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [self.tableView.refreshView endRefreshing];
        [gToast showError:error.domain];
    }];
}

#pragma mark - Action
- (IBAction)actionAddCar:(id)sender
{
    EditMyCarVC *vc = [UIStoryboard vcWithId:@"EditMyCarVC" inStoryboard:@"Mine"];
    [self.navigationController pushViewController:vc animated:YES];
    [vc reloadWithOriginCar:nil];
}

#pragma mark - UITableViewDelegate
- (void)tableViewDidStartRefresh:(JTTableView *)tableView
{
    [self reloadDatasource];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.carList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *subTitleL = (UILabel *)[cell.contentView viewWithTag:1002];
    HKMyCar *car = [self.carList safetyObjectAtIndex:indexPath.section];
    titleL.font = [UIFont systemFontOfSize:17];
    subTitleL.textColor = [UIColor darkTextColor];
    switch (indexPath.row) {
        case 0:
            titleL.font = [UIFont boldSystemFontOfSize:19];
            titleL.text = car.licencenumber;
            subTitleL.textColor = kDefTintColor;
            subTitleL.text = car.isDefault ? @"[默认]" : nil;
            break;
        case 1:
            titleL.text = @"购车时间";
            subTitleL.text = [car.purchasedate dateFormatForYYMM];
            break;
        case 2:
            titleL.text = @"品牌车系";
            subTitleL.text = car.brand;
            break;
        case 3:
            titleL.text = @"具体车型";
            subTitleL.text = car.model;
            break;
        case 4:
            titleL.text = @"整车价格";
            subTitleL.text = [NSString stringWithFormat:@"%.2f元", car.price];
            break;
        case 5:
            titleL.text = @"当前里程";
            subTitleL.text = [NSString stringWithFormat:@"%d公里", (int)car.odo];
            break;
        case 6:
            titleL.text = @"保险到期日";
            subTitleL.text = [car.insexipiredate dateFormatForYYMM];
            break;
        case 7:
            titleL.text = @"保险公司";
            subTitleL.text = car.inscomp;
            break;
        default:
            break;
    }
    
    cell.customSeparatorInset = UIEdgeInsetsZero;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EditMyCarVC *vc = [UIStoryboard vcWithId:@"EditMyCarVC" inStoryboard:@"Mine"];
    [self.navigationController pushViewController:vc animated:YES];
    [vc reloadWithOriginCar:[self.carList safetyObjectAtIndex:indexPath.section]];
}
@end

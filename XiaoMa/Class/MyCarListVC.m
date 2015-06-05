//
//  MyCarListVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/5.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyCarListVC.h"
#import "EditMyCarVC.h"
#import "XiaoMa.h"
#import "MyCarListVModel.h"

@interface MyCarListVC ()<UITableViewDataSource, UITableViewDelegate,JTTableViewDelegate>
@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (nonatomic, strong) NSArray *carList;
@property (nonatomic, strong) MyCarListVModel *model;
@end

@implementation MyCarListVC

- (void)awakeFromNib {
    self.model = [MyCarListVModel new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self setupSignals];
    [self reloadDataIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginEvent:@"rp309"];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endEvent:@"rp309"];
}

- (void)setupSignals
{
    [RACObserve(gAppMgr, myUser) subscribeNext:^(JTUser *user) {
        [[user.carModel rac_observeDataWithDoRequest:^{
            
            [self.tableView.refreshView beginRefreshing];
        }] subscribeNext:^(JTQueue *queue) {
            
            [self.tableView.refreshView endRefreshing];
            self.carList = [queue allObjects];
            [self.tableView reloadData];
            if (self.carList.count == 0) {
                [self.tableView showDefaultEmptyViewWithText:@"暂无爱车，快去添加一辆吧"];
            }
            else {
                [self.tableView hideDefaultEmptyView];
            }
        }];
    }];
}

#pragma mark - Reload datas
- (void)reloadDataIfNeeded
{
    [self reloadDataFromSignal:[gAppMgr.myUser.carModel rac_fetchDataIfNeeded]];
}

- (void)reloadData
{
    [self reloadDataFromSignal:[gAppMgr.myUser.carModel rac_fetchData]];
}

- (void)reloadDataFromSignal:(RACSignal *)signal
{
    [[signal initially:^{
        
        [self.tableView.refreshView beginRefreshing];
    }] subscribeNext:^(JTQueue *queue) {
        
        [self.tableView.refreshView endRefreshing];
        self.carList = [queue allObjects];
        [self.tableView reloadData];
        if (self.carList.count == 0) {
            [self.tableView showDefaultEmptyViewWithText:@"暂无爱车，快去添加一辆吧"];
        }
        else {
            [self.tableView hideDefaultEmptyView];
        }
    } error:^(NSError *error) {
        
        [self.tableView.refreshView endRefreshing];
        [gToast showError:error.domain];
    }];
}

#pragma mark - Action
- (IBAction)actionAddCar:(id)sender
{
    [MobClick event:@"rp309-1"];
    EditMyCarVC *vc = [UIStoryboard vcWithId:@"EditMyCarVC" inStoryboard:@"Mine"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)uploadDrivingLicenceAtIndexPath:(NSIndexPath *)indexPath
{
    HKMyCar *car = [self.carList safetyObjectAtIndex:indexPath.section];
    
    @weakify(self);
    [[[self.model rac_uploadDrivingLicenseWithTargetVC:self initially:^{
        
        [gToast showingWithText:@"正在上传..."];
    }] flattenMap:^RACStream *(NSString *url) {

        //更新行驶证的url，如果更新失败，重置为原来的行驶证url
        NSString *oldurl = car.licenceurl;
        car.licenceurl = url;
        return [[gAppMgr.myUser.carModel rac_updateCar:car] catch:^RACSignal *(NSError *error) {
            car.licenceurl = oldurl;
            return [RACSignal error:error];
        }];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        car.status = 1;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UILabel *bottomL = (UILabel *)[cell.contentView viewWithTag:3001];
        UIButton *bottomB = (UIButton *)[cell.contentView viewWithTag:3002];
        [self.model setupUploadBtn:bottomB andDescLabel:bottomL forStatus:1];
        [gToast showSuccess:@"上传行驶证成功!"];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.carList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    HKMyCar *car = [self.carList safetyObjectAtIndex:indexPath.section];
    UIButton *licenseB = (UIButton *)[cell.contentView viewWithTag:1001];
    UIButton *isDefalutB = (UIButton *)[cell.contentView viewWithTag:4001];
    UILabel *bottomL = (UILabel *)[cell.contentView viewWithTag:3001];
    UIButton *bottomB = (UIButton *)[cell.contentView viewWithTag:3002];
    
    MyCarListVModel *model = self.model;
    [model setupUploadBtn:bottomB andDescLabel:bottomL forStatus:car.status];
    //一键上传行驶证
    @weakify(self);
    [[[bottomB rac_signalForControlEvents:UIControlEventTouchUpInside]
      takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        [MobClick event:@"rp309-3"];
        @strongify(self);
        [self uploadDrivingLicenceAtIndexPath:indexPath];
    }];
    
    [licenseB setTitle:car.licencenumber forState:UIControlStateNormal];
    isDefalutB.hidden = !car.isDefault;
    for (int i = 0; i < 7; i++) {
        int tag = 2001+2*i;
        UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:tag];
        UILabel *subTitleL = (UILabel *)[cell.contentView viewWithTag:tag+1];
        switch (i) {
            case 0:
                titleL.text = @"购车时间";
                subTitleL.text = [car.purchasedate dateFormatForYYMM];
                break;
            case 1:
                titleL.text = @"爱车品牌";
                subTitleL.text = car.brand;
                break;
            case 2:
                titleL.text = @"具体车系";
                subTitleL.text = car.model;
                break;
            case 3:
                titleL.text = @"整车价格";
                subTitleL.text = [NSString stringWithFormat:@"%.2f万元", car.price];
                break;
            case 4:
                titleL.text = @"当前里程";
                subTitleL.text = [NSString stringWithFormat:@"%d公里", (int)car.odo];
                break;
            case 5:
                titleL.text = @"保险到期日";
                subTitleL.text = [car.insexipiredate dateFormatForYYMM];
                break;
            case 6:
                titleL.text = @"保险公司";
                subTitleL.text = car.inscomp;
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"rp309-2"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EditMyCarVC *vc = [UIStoryboard vcWithId:@"EditMyCarVC" inStoryboard:@"Mine"];
    vc.originCar = [self.carList safetyObjectAtIndex:indexPath.section];
    [self.navigationController pushViewController:vc animated:YES];
}
@end

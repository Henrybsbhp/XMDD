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
#import "MyCarListVModel.h"
#import "UpdateCarOp.h"

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
}

- (void)uploadDrivingLicenceAtIndexPath:(NSIndexPath *)indexPath
{
    HKMyCar *car = [self.carList safetyObjectAtIndex:indexPath.section];
    @weakify(self);
    [[[self.model rac_uploadDrivingLicenseWithTargetVC:self initially:^{
        
        [gToast showingWithText:@"正在上传..."];
    }] flattenMap:^RACStream *(NSString *url) {
        
        NSString *oldurl = car.licenceurl;
        car.licenceurl = url;
        UpdateCarOp *op = [UpdateCarOp new];
        op.req_car = car;
        return [[op rac_postRequest] catch:^RACSignal *(NSError *error) {
            car.licenceurl = oldurl;
            return [RACSignal error:error];
        }];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EditMyCarVC *vc = [UIStoryboard vcWithId:@"EditMyCarVC" inStoryboard:@"Mine"];
    vc.originCar = [self.carList safetyObjectAtIndex:indexPath.section];
    [self.navigationController pushViewController:vc animated:YES];
}
@end

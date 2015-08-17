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
#import "HKLoadingModel.h"

@interface MyCarListVC ()<UITableViewDataSource, UITableViewDelegate,JTTableViewDelegate, HKLoadingModelDelegate>
@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (nonatomic, strong) MyCarListVModel *model;
@property (nonatomic, strong) HKLoadingModel *loadingModel;

@end

@implementation MyCarListVC

- (void)awakeFromNib {
    self.model = [MyCarListVModel new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
    [self.loadingModel loadDataForTheFirstTime];
    [self setupCarModel];
}

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    DebugLog(deallocInfo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp309"];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"rp309"];
}

- (void)setupCarModel
{
    @weakify(self);
    [RACObserve(gAppMgr, myUser) subscribeNext:^(JTUser *user) {
       
        [[user.carModel rac_observeDataWithDoRequest:nil] subscribeNext:^(JTQueue *queue) {
           
            @strongify(self);
            [self.loadingModel reloadDataWithDatasource:[queue allObjects]];
        }];
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
    HKMyCar *car = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    
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

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKDatasourceLoadingType)type
{
    return @"暂无爱车，快去添加一辆吧";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKDatasourceLoadingType)type error:(NSError *)error
{
    return @"获取爱车信息失败，点击重试";
}

- (void)loadingModel:(HKLoadingModel *)model didTappedForBlankPrompting:(NSString *)prompting type:(HKDatasourceLoadingType)type
{
    [self actionAddCar:nil];
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKDatasourceLoadingType)type
{
    RACSignal *signal;
    if (type == HKDatasourceLoadingTypeReloadData) {
        signal = [gAppMgr.myUser.carModel rac_fetchData];
    }
    else {
        signal = [gAppMgr.myUser.carModel rac_fetchData];
    }
    return [signal map:^id(JTQueue *queue) {
        return [queue allObjects];
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKDatasourceLoadingType)type
{
    [self.tableView reloadData];
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
    return self.loadingModel.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    HKMyCar *car = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
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
                titleL.text = @"年检到期日";
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
    vc.originCar = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    [self.navigationController pushViewController:vc animated:YES];
}
@end

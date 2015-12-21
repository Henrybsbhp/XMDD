//
//  PickerAutoModelVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PickerAutoSeriesVC.h"
#import "GetAutomobileSeriesV2Op.h"
#import "HKLoadingModel.h"
#import "PickerAutoModelVC.h"
#import "AutoSeriesModel.h"

@interface PickerAutoSeriesVC ()<UITableViewDelegate, UITableViewDataSource, HKLoadingModelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) HKLoadingModel *loadingModel;
@end

@implementation PickerAutoSeriesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
    [self.loadingModel loadDataForTheFirstTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    DebugLog(deallocInfo);
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKLoadingTypeMask)type
{
    return @"暂无车系信息";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @"获取车系信息失败，点击重试";
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    GetAutomobileSeriesV2Op *op = [GetAutomobileSeriesV2Op new];
    op.req_brandid = self.brand.brandid;
    return [[op rac_postRequest] map:^id(GetAutomobileSeriesV2Op *rspOp) {
        return rspOp.rsp_seriesList;
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate And Dataousrce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.loadingModel.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    AutoSeriesModel * seriesDic = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.row];
    titleL.text = seriesDic.seriesname;
    
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        [(JTTableViewCell *)cell setHiddenTopSeparatorLine:YES];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AutoSeriesModel *series = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.row];
    PickerAutoModelVC *vc = [UIStoryboard vcWithId:@"PickerAutoModelVC" inStoryboard:@"Car"];
    vc.brand = self.brand;
    vc.series = series;
    vc.completed = self.completed;
    vc.originVC = self.originVC;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
}
@end

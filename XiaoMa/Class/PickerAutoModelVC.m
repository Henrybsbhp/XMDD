//
//  PickerAutoModelVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/18.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "PickerAutoModelVC.h"
#import "GetAutomobileModelV2Op.h"
#import "HKLoadingModel.h"
#import "AutoSeriesModel.h"
#import "PickerAutoSeriesVC.h"
#import "AutoSeriesModel.h"

@interface PickerAutoModelVC ()<UITableViewDelegate, UITableViewDataSource, HKLoadingModelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) HKLoadingModel *loadingModel;

@end

@implementation PickerAutoModelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        self.tableView.estimatedRowHeight = 44; //估算高度
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
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
    return @"暂无车型信息";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @"获取车型信息失败，点击重试";
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    GetAutomobileModelV2Op *op = [GetAutomobileModelV2Op new];
    op.req_seriesid = self.series.seriesid;
    return [[op rac_postRequest] map:^id(GetAutomobileModelV2Op *rspOp) {
        if (rspOp.rsp_modelList.count == 0) {
            NSDictionary * defaultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"mid", @"全系车型", @"name", nil];
            AutoDetailModel * defaultModel = [AutoDetailModel setModelWithJSONResponse:defaultDic];
            NSArray * defaultArr = [[NSArray alloc] initWithObjects:defaultModel, nil];
            return defaultArr;
        }
        return rspOp.rsp_modelList;
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        return UITableViewAutomaticDimension;
    }
    
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell layoutIfNeeded];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    return ceil(size.height+1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.loadingModel.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    AutoDetailModel * model = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.row];
    titleL.text = model.modelname;
    if (!IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        titleL.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 24;
    }
    
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        [(JTTableViewCell *)cell setHiddenTopSeparatorLine:YES];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AutoDetailModel *model = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.row];
    if (self.originVC) {
        if (self.completed) {
            self.completed(self.brand, self.series, model);
        }
        [self.navigationController popToViewController:self.originVC animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
}

@end

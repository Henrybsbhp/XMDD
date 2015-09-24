//
//  CheckAwardViewController.m
//  XiaoMa
//
//  Created by jt on 15-7-1.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CheckAwardViewController.h"
#import "HKLoadingModel.h"
#import "CheckUserAwardOp.h"
#import "GainedViewController.h"
#import "GainAwardViewController.h"
#import "WebVC.h"

@interface CheckAwardViewController ()<HKLoadingModelDelegate>

@property (nonatomic, strong) HKLoadingModel *loadingModel;
- (IBAction)helpAction:(id)sender;

@end

@implementation CheckAwardViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.view delegate:self];
    [self.loadingModel loadDataForTheFirstTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (IBAction)helpAction:(id)sender {
    WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
    vc.title = @"每周礼券";
    vc.url = @"http://www.xiaomadada.com/apphtml/meizhouliquan.html";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKDatasourceLoadingType)type
{
    return @"获取红包信息失败";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKDatasourceLoadingType)type error:(NSError *)error
{
    return @"获取红包信息失败，点击重试";
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKDatasourceLoadingType)type
{
    CheckUserAwardOp * op = [CheckUserAwardOp operation];
    return [[op rac_postRequest] map:^id(CheckUserAwardOp *rspOp) {
        return @[rspOp];
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKDatasourceLoadingType)type
{
    CheckUserAwardOp * op = [model.datasource safetyObjectAtIndex:0];
    if (op.rsp_leftday > 0)
    {
        GainedViewController * vc = [awardStoryboard instantiateViewControllerWithIdentifier:@"GainedViewController"];
        vc.leftDay = op.rsp_leftday;
        vc.amount = op.rsp_amount;
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
        vc.view.frame = self.view.bounds;
    }
    else
    {
        GainAwardViewController * vc = [awardStoryboard instantiateViewControllerWithIdentifier:@"GainAwardViewController"];
        vc.gainedNum = op.rsp_total;
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
        vc.view.frame = self.view.bounds;
    }

}

@end

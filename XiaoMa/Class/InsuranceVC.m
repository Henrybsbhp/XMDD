//
//  InsuranceVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceVC.h"
#import "XiaoMa.h"
#import "AiCheBaoInsuranceVC.h"
#import "SYPaginator.h"
#import "HKAdvertisement.h"
#import "InsuranceEnquiryVC.h"
#import "WebVC.h"
#import "InsuranceResultVC.h"
#import "WebVC.h"
#import "ADViewController.h"
#import "InsuranceChooseViewController.h"
#import "InsuranceDirectSellingVC.h"
#import "PaymentHelper.h"

@interface InsuranceVC ()
@property (nonatomic, strong) ADViewController *advc;
@end

@implementation InsuranceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupADView];
}

- (void)dealloc
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp114"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp114"];
}

- (void)setupADView
{
    CKAsyncMainQueue(^{
        self.advc = [ADViewController vcWithADType:AdvertisementInsurance boundsWidth:self.view.frame.size.width
                                          targetVC:self mobBaseEvent:@"rp114-3"];
        [self.advc reloadDataForTableView:self.tableView];
    });
}

#pragma mark - Action
- (void)actionInsuraceEnquiry {
    [MobClick event:@"rp114-1"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        InsuranceEnquiryVC *vc = [UIStoryboard vcWithId:@"InsuranceEnquiryVC" inStoryboard:@"Insurance"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionInsuranceDirectSelling {
    [MobClick event:@"rp114-4"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        InsuranceDirectSellingVC *vc = [UIStoryboard vcWithId:@"InsuranceDirectSellingVC" inStoryboard:@"Insurance"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionAiCheBao {
    AiCheBaoInsuranceVC *vc = [UIStoryboard vcWithId:@"AiCheBaoInsuranceVC" inStoryboard:@"Insurance"];
    vc.originVC = self;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        JTTableViewCell *jtcell = (JTTableViewCell *)cell;
        jtcell.customSeparatorInset = UIEdgeInsetsMake(-1, 0, 0, 0);
        jtcell.customSeparatorColor = kDefLineColor;
        [jtcell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //保险询价
    if (indexPath.row == 0) {
         [self actionInsuraceEnquiry];
    }
    //车险直销
    else if (indexPath.row == 1) {
        [self actionInsuranceDirectSelling];
    }
    //爱车宝
    else if (indexPath.row == 2) {
        [self actionAiCheBao];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
@end

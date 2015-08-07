//
//  InsuranceVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceVC.h"
#import "XiaoMa.h"
#import "BuyInsuranceOnlineVC.h"
#import "EnquiryInsuranceVC.h"
#import "WebVC.h"
#import "ADViewController.h"

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
- (IBAction)actionBuyInsuraceOline:(id)sender {
    [MobClick event:@"rp114-2"];
    BuyInsuranceOnlineVC *vc = [UIStoryboard vcWithId:@"BuyInsuranceOnlineVC" inStoryboard:@"Insurance"];
    vc.originVC = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionEnquireInsurance:(id)sender {
    [MobClick event:@"rp114-1"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        EnquiryInsuranceVC *vc = [UIStoryboard vcWithId:@"EnquiryInsuranceVC" inStoryboard:@"Insurance"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *jtcell = (JTTableViewCell *)cell;
    jtcell.customSeparatorInset = UIEdgeInsetsMake(-1, 0, 0, 0);
    [jtcell prepareCellForTableView:tableView atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

@end

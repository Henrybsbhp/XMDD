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
#import "SYPaginator.h"

@interface InsuranceVC ()<SYPaginatorViewDataSource,SYPaginatorViewDelegate>
@property (nonatomic, strong) SYPaginatorView *adView;
@end

@implementation InsuranceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    CKAsyncMainQueue(^{
        [self setupADView];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupADView
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = width*360.0/1242.0;
    SYPaginatorView *adView = [[SYPaginatorView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    adView.delegate = self;
    adView.dataSource = self;
    adView.pageGapWidth = 0;
    self.adView = adView;
    self.adView.currentPageIndex = 0;
}


#pragma mark - Action
- (IBAction)actionBuyInsuraceOline:(id)sender {
    BuyInsuranceOnlineVC *vc = [UIStoryboard vcWithId:@"BuyInsuranceOnlineVC" inStoryboard:@"Insurance"];
    vc.originVC = self;
    [self.navigationController pushViewController:vc animated:YES];
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
